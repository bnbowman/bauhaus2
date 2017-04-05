library(ggplot2)
library(plyr)
library(stringr)
library(pbbamr)
library(gtools) # for "permutations"

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

.squishWhitespace <- function(s) {
  str_replace_all(s, "[[:space:]]+", " ")
}

## Abbrev: wf == "workflow"

## TODO: functions like these should move to pbexperiment or whatnot, or at least a
##       common.R or somesuch

getConditionTable <- function(wfOutputRoot)
{
    read.csv(file.path(wfOutputRoot, "condition-table.csv"))
}

variableNames <- function(ct)
{
    nms <- names(ct)
    matches <- str_detect(nms, "(Genome)|(p_.*)")
    nms[matches]
}

makeCoverageTitrationTable1 <- function(maskedVariantsDir)
{
    ##
    ## Get the precomputed masked files, which we expect to find as
    ##   {worfklowOutputRoot}/{condition}/variant_calling/{algo}/masked-variants-{coverage}.gff
    ##
    alnSummary <- file.path(maskedVariantsDir, "alignments-summary.gff")
    mvs <- Sys.glob(file.path(maskedVariantsDir, "masked-variants.*.gff"))

    condition <- basename(dirname(maskedVariantsDir))
    coverageFromPath   <- function(path) as.integer(str_match(path, ".*/masked-variants\\.(.*)\\.gff")[,2])

    variantsCount.fast <- function(fname) {
        CMD <- sprintf("egrep -v '^#' %s | wc -l", fname)
        result <- as.integer(.squishWhitespace(system(CMD, intern=T)))
        result
    }

    empiricalQV <- function(numErrors, genomeSize) {
        err <- (numErrors + 1)/(genomeSize + 1)
        -10*log10(err)
    }

    computeGenomeSize <- function(alignmentSummaryFile)
    {
        lines <- readLines(alignmentSummaryFile)
        sequenceRegionLines <- lines[grep("##sequence-region", lines)]
        cols <- str_split(sequenceRegionLines, " ")
        chromosomeSizes <- as.integer(lapply(cols, tail, 1))
        sum(chromosomeSizes)
    }

    computeQ01Coverage <- function(alignmentSummaryFile) {
        cov2 <- readGFF(alignmentSummaryFile)$cov2
        cov <- as.numeric(str_extract(cov2, "[^,]*"))
        as.numeric(quantile(cov, 0.01))
    }

    q01Coverage <- computeQ01Coverage(alnSummary)
    numVariants <- sapply(mvs, variantsCount.fast)
    genomeSize <- computeGenomeSize(alnSummary)
    concordanceQV <- empiricalQV(numVariants, genomeSize)

    ctt <- data.frame(
        MaskedVariantsFile  = mvs,
        Coverage            = coverageFromPath(mvs),
        AvailableCoverage   = q01Coverage,
        Condition           = condition,
        NumVariants         = sapply(mvs, variantsCount.fast),
        ConcordanceQV       = concordanceQV)

    ctt$ShouldCensor = (ctt$Coverage > ctt$AvailableCoverage)
    ctt
}

makeCoverageTitrationTable <- function(wfOutputRoot)
{
    ct <- getConditionTable(wfOutputRoot)

    ## dig around the wf output to find masked-variants files.
    mvDirs <- Sys.glob(file.path(wfOutputRoot, "conditions/*/variant_calling/"))

    rawCtt <- ldply(mvDirs,  function(d) { makeCoverageTitrationTable1(d) })

    ## Get the table of just the conditions and associated variables---no runcodes/other inputs
    ## Is this a concept that is more broadly useful?
    keepColumns = append("Condition", variableNames(ct))
    condensedCt <- unique(ct[,keepColumns])

    merge(rawCtt, condensedCt, by="Condition")
}


doTitrationPlots <- function(report, tbl)
{
    tbl <- tbl[!tbl$ShouldCensor,]

    ## Implicit variables: Genome
    ## Explicit variables: have the "p_" prefix
    variables <- names(tbl)[grep("^p_|^Genome$", names(tbl))]
    nvals <- lapply(variables, function(x) length(unique(tbl[,x])))
    variables <- variables[nvals > 1]
    stopifnot(length(variables) %in% c(0,1,2,3,4))

    q <- (ggplot(tbl, aes(x=Coverage, y=ConcordanceQV, color=Condition)) +
          geom_line() +
          scale_y_continuous("Concordance (QV)") +
          ggtitle(paste("Consensus Performance By Condition")))
    report$ggsave(
        "concordance-by-condition.png",
        q,
        id = "concordance-by-condition",
        title = "Consensus Performance By Condition",
        caption = "Consensus Performance By Condition")

    if (length(variables) >= 1)
    {
      # Facet on individual variables
      for (v in variables) {
          title <- paste("Consensus Performance By", v)
          id <- paste0("concordance-by-", v)
          q <- (ggplot(tbl, aes(x=Coverage, y=ConcordanceQV, color=Condition)) +
                geom_line() +
                facet_grid(paste(".~", v)) +
                scale_y_continuous("Concordance (QV)") +
                ggtitle(paste("Consensus Performance By", v)))
          report$ggsave(paste0(id, ".png"), q, id, title, title)
      }
    }

    if (length(variables) >= 2)
    {
      # Take pairs of variables, facet on first and color by second
      apply(permutations(n=length(variables), r=2, v=variables), 1,
            function(twoVars)
            {
              id <- str_c("concordance-by-", str_c(twoVars, collapse="-and-"))
              title <- str_c("Consensus performance by ", str_c(twoVars, collapse=" and "))
              q <- (ggplot(tbl, aes_string(x="Coverage", y="ConcordanceQV", color=twoVars[2], group="Condition")) +
                    geom_line() +
                    facet_grid(paste(".~", twoVars[1])) +
                    scale_y_continuous("Concordance (QV)") +
                    ggtitle(paste("Consensus Performance By", twoVars[1])))
              report$ggsave(paste0(id, ".png"), q, id, title, title)
            })
    }

    # Take triples of variables, facet on first two and color by third
    if (length(variables) >= 3)
    {
      # Take pairs of variables, facet on first and color by second
      apply(permutations(n=length(variables), r=3, v=variables), 1,
            function(threeVars)
            {
              id <- str_c("concordance-by-", str_c(threeVars, collapse="-and-"))
              title <- str_c("Consensus performance by ", str_c(threeVars, collapse=" and "))
              q <- (ggplot(tbl, aes_string(x="Coverage", y="ConcordanceQV", color=threeVars[3], group="Condition")) +
                    geom_line() +
                    facet_grid(paste(threeVars[1], "~", threeVars[2])) +
                    scale_y_continuous("Concordance (QV)") +
                    ggtitle(paste0("Consensus Performance By ", threeVars[1], ", ", threeVars[2])))
              report$ggsave(paste0(id, ".png"), q, id, title, title)
            })
    }
}


doCoverageDiagnosticsPlot <- function(report, tbl)
{
  ## Diagnostic plot of coverage
  title <- "1-percentile coverage level by Condition"
  q <- (qplot(Condition, AvailableCoverage, data=tbl, color=Condition) +
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        geom_hline(yintercept=80, col="red") +
        ggtitle("1-percentile coverage level by Condition"))
  report$ggsave("coverage-diagnostic-plot.png", q,
                id="coverage-diagnostic-plot", title, title)
}



makeResidualsTable <- function(ccsDf, variables)
{
    ## Plots of residual error modes
    tbl <- tbl[!tbl$ShouldCensor,]

    summarizedResidualErrors <- function(variantsGffFile) {
        print(variantsGffFile)
        gff <- readGFF(variantsGffFile)
        if (nrow(gff) > 0) {
            base <- ifelse(gff$reference == ".", gff$variantSeq, gff$reference)
            base <- str_sub(base, 1, 1)
            ##count(interaction(gff$type, base))
            df <- as.data.frame(table(interaction(base, gff$type)))
            df$Base      <- str_sub(df$Var1, 1, 1)
            df$ErrorMode <- str_sub(df$Var1, 3)
            df
        }
    }

    #MIN.COVERAGE <- 40
    ROUND.COVERAGE <- c(40, 60, 100)
    varTypeCounts <- ddply(
        subset(tbl, Coverage %in% ROUND.COVERAGE),
        append(c("Condition", "Coverage", "MaskedVariantsFile", "Genome"), variables),
        function(df) {
            res <- summarizedResidualErrors(as.character(df$MaskedVariantsFile))
          })
    varTypeCounts
}

doResidualErrorsPlot <- function(report, varTypeCounts, variables)
{
    for (coverage in unique(varTypeCounts$Coverage)) {
        plt <- (ggplot(data=varTypeCounts[varTypeCounts$Coverage==coverage,],
                      mapping=aes(x=ErrorMode, y=Freq, fill=Base)) + geom_bar(stat="identity") +
                theme(axis.text.x = element_text(angle = 75, hjust = 1)))

        facet.formula <- as.formula(".~Condition")

        id.fix <- sprintf("residual-errors-fixed-y-coverage-%dx", coverage)
        title.fix <- sprintf("Residual errors in %dx consensus sequence (fixed y-axis)", coverage)
        plt.fix_y  <- (plt + facet_grid(facet.formula)
                       +  ggtitle(title.fix))
        report$ggsave(id.fix, plt.fix_y, id.fix, title.fix, title.fix)

        id.free <- sprintf("residual-errors-free-y-coverage-%dx", coverage)
        title.free <- sprintf("Residual errors in %dx consensus sequence (free y-axis)", coverage)
        plt.free_y <- (plt + facet_grid(facet.formula, scale="free_y")
                       + ggtitle(title.free))
        report$ggsave(id.free, plt.free_y, id.free, title.free, title.free)
    }
}


if (!interactive())
{
    args <- commandArgs(TRUE)
    wfRootDir <- args[1]
    tbl <- makeCoverageTitrationTable(wfRootDir)
    variables <- names(tbl)[grep("^p_", names(tbl))]
    residualsTable <- makeResidualsTable(tbl, variables)

    report <- bh2Reporter(
        "condition-table.csv",
        "reports/CoverageTitration/report.json",
        "Consensus accuracy coverage titration")

    ## Dump the ctt table
    report$write.table("coverage-titration.csv", tbl,
                       id="coverage-titration",
                       title="Coverage titration summary table")


    ## Generate plots
    doTitrationPlots(report, tbl)
    doCoverageDiagnosticsPlot(report, tbl)
    doResidualErrorsPlot(report, residualsTable, variables)
    report$write.report()
}




if(0) {

    wfRootDir <- "/home/UNIXHOME/ayang/projects/bauhaus/Echidna_PerfVer/6kecoli_2hrImmob_postTrain_CoverageTitration"
    tbl <- makeCoverageTitrationTable(wfRootDir)

    pdf("/tmp/coverage-titration.pdf", 11, 8.5)
    variables <- names(tbl)[grep("^p_", names(tbl))]
    residualsTable <- makeResidualsTable(tbl)
    doResidualErrorsPlot(residualsTable, variables)
    dev.off()


}
