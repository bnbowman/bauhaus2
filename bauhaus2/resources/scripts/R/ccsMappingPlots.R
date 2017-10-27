library(pbbamr)
library(dplyr)
library(ggplot2)
library(xml2)
library(stringr)
# library(feather)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

toPhred <- function(acc, maximum = 60) {
  err = pmax(1 - acc, 10 ^ (-maximum / 10))
  - 10 * log10(err)
}


makeCCSDataFrame1 <-
  function(datasetXmlFile,
           conditionName,
           sampleFraction = 1.0)
  {
    print(datasetXmlFile)
    pbi <-
      pbbamr::loadPBI(
        datasetXmlFile,
        loadSNR = TRUE,
        loadNumPasses = TRUE,
        loadRQ = TRUE
      )
    ## TODO: readlength not yet available, unfortunately, due to the
    ## qstart/qend convention for CCS reads.
    if (nrow(pbi) == 0) {
      warning("No data in the Xml file!")
      0
    } else {
      with(pbi,
           tbl_df(
             data.frame(
               Condition = conditionName,
               Reference = ref,
               NumPasses = np,
               HoleNumber = hole,
               ReadQuality = qual,
               ReadQualityPhred = toPhred(qual),
               Identity = 1. - (mismatches + inserts + dels) / (tend - tstart),
               IdentityPhred = toPhred(1. - (mismatches + inserts + dels) /
                                         (tend - tstart)),
               NumErrors = (mismatches + inserts + dels),
               TemplateSpan = (tend - tstart),
               ReadLength = (aend - astart),
               ## <-- this is a lie, see above!
               SnrA = snrA,
               SnrC = snrC,
               SnrG = snrG,
               SnrT = snrT
             )
           ))
    }
  }

makeCCSDataFrame <-
  function(report, wfOutputRoot, sampleFraction = 1.0)
  {
    ct <- report$condition.table
    conditions <- unique(ct$Condition)
    dsetXmls <- sapply(conditions, function(condition) {
      file.path("conditions",
                condition,
                "mapped_ccs/mapped-ccs.alignmentset.xml")
    })
    dfs <-
      mapply(
        makeCCSDataFrame1,
        dsetXmls,
        conditions,
        sampleFraction = sampleFraction,
        SIMPLIFY = F
      )
    tbl_df(do.call(rbind, dfs))
  }


doCCSCumulativeYieldPlots <- function(report, ccsDf)
{
  cumByCut <- function(x) {
    qvOrder <- order(x$IdentityPhred, decreasing = TRUE)
    xo <- x[qvOrder, ]
    xo$NumReads <- seq(1, nrow(xo))
    xo$YieldFraction <- cumsum(xo$ReadLength) / sum(xo$ReadLength)
    xo[seq(1, nrow(xo), by = 10), ]
  }
  
  ## yield <- ddply(ccsDf, "Condition", cumByCut)
  yield <- ccsDf %>% group_by(Condition) %>% do(cumByCut(.))
  
  ## NumReads on y-axis
  p <-
    qplot(
      IdentityPhred,
      NumReads,
      colour = Condition,
      data = yield,
      main = "Yield of reads by CCS accuracy"
    )
  report$ggsave(
    "yield_reads_ccs_accuracy.png",
    p,
    id = "yield_reads_ccs_accuracy",
    title = "Yield of reads by CCS accuracy",
    caption = "Yield of reads by CCS accuracy"
  )
  
  ## Fraction of reads on y-axis
  p <-
    qplot(
      IdentityPhred,
      YieldFraction,
      colour = Condition,
      data = yield,
      main = "Fractional yield by CCS accuracy"
    )
  report$ggsave(
    "fractional_yield_ccs_accuracy.png",
    p,
    id = "fractional_yield_ccs_accuracy",
    title = "Fractional yield by CCS accuracy",
    caption = "Fractional yield by CCS accuracy"
  )
}

doCCSNumPassesHistogram <- function(report, ccsDf)
{
  p <- qplot(
    NumPasses,
    data = ccsDf,
    geom = "density",
    color = Condition,
    main = "NumPasses distribution (density)"
  )
  report$ggsave(
    "numpasses_dist_density.png",
    p,
    id = "numpasses_dist_density",
    title = "NumPasses distribution (density)",
    caption = "NumPasses distribution (density)"
  )
}

doCCSNumPassesCDF <- function(report, ccsDf)
{
  p <- (
    ggplot(aes(x = NumPasses, color = Condition), data = ccsDf) +
      stat_ecdf(geom = "step") +
      ggtitle("NumPasses distribution (ECDF)")
  )
  report$ggsave(
    "numpasses_dist_ecdf.png",
    p,
    id = "numpasses_dist_ecdf",
    title = "NumPasses distribution (ECDF)",
    caption = "NumPasses distribution (ECDF)"
  )
}


## calibration plot...

doCCSReadQualityCalibrationPlots <- function(report, ccsDf)
{
  ccsDf <- sample_n(ccsDf, min(5000, nrow(ccsDf)))
  
  p <-
    qplot(ReadQuality,
          Identity,
          alpha = I(0.1),
          data = ccsDf) + facet_grid(. ~ Condition) +
    geom_abline(slope = 1, color = "red") +
    ggtitle("Read quality versus empirical accuracy")
  report$ggsave(
    "read_quality_vs_empirical_accuracy.png",
    p,
    id = "read_quality_vs_empirical_accuracy",
    title = "Read quality versus empirical accuracy",
    caption = "Read quality versus empirical accuracy"
  )

  p <-
    qplot(ReadQualityPhred,
          IdentityPhred,
          alpha = I(0.1),
          data = ccsDf) + facet_grid(. ~ Condition) +
    geom_abline(slope = 1, color = "red") +
    ggtitle("Read quality versus empirical accuracy (Phred scale)")
  report$ggsave(
    "read_quality_vs_empirical_accuracy_phred.png",
    p,
    id = "read_quality_vs_empirical_accuracy_phred",
    title = "Read quality versus empirical accuracy (Phred scale)",
    caption = "Read quality versus empirical accuracy (Phred scale)"
  )
}


doCCSTitrationPlots <- function(report, ccsDf)
{
  accVsNp <- ccsDf %>%
      group_by(Condition) %>% filter(NumPasses <= quantile(NumPasses, probs = 0.98)) %>% ungroup() %>%
      group_by(Condition, NumPasses) %>%
      summarize(
                MeanIdentity = 1 - (max(1, sum(NumErrors)) / sum(TemplateSpan)),
                TotalBases = sum(TemplateSpan)) %>%
      mutate(MeanIdentityPhred = toPhred(MeanIdentity))

  p <-
    qplot(
      NumPasses,
      MeanIdentityPhred,
      size = TotalBases,
      weight = TotalBases,
      data = accVsNp
    ) +
    facet_grid(. ~ Condition) + geom_smooth() +
    geom_hline(yintercept = 30, alpha = 0.5) + geom_vline(xintercept = 15, alpha = 0.5)
  report$ggsave(
    "ccs_titration.png",
    p,
    id = "ccs_titration",
    title = "CCS Titration Plots",
    caption = "CCS Titration Plots"
  )
}

doCCSTitrationBoxPlots <- function(report, ccsDf)
{
  toPhred2 <- function(nErr, tSpan) {
    return(-10 * log10((nErr + 1)/(tSpan + 1)));
  }

  refData <- ccsDf %>%
    group_by(Condition, Reference) %>%
    summarize(TemplateSpan = mean(TemplateSpan)) %>%
    mutate(MaxQV = toPhred2(0, TemplateSpan))

  i <- 1
  for (ref in levels(ccsDf$Reference)) {
    refDf <- ccsDf %>%
      filter(Reference == ref) %>%
      group_by(Condition) %>% filter(NumPasses <= min(quantile(NumPasses, 0.98), 30)) %>% ungroup() %>%
      mutate(QV = toPhred2(NumErrors, TemplateSpan))

    refDf$NumPasses <- as.factor(refDf$NumPasses)
    p <- ggplot(refDf, aes(NumPasses, QV, fill = Condition)) +
      geom_boxplot() +
      geom_hline(aes(yintercept = MaxQV, color = Condition), filter(refData, Reference == ref)) +
      ggtitle(ref)

    report$ggsave(
      paste0("ccs_boxplot_ref", i, ".png"),
      p,
      id = paste0("ccs_boxplot_ref", i),
      title = paste0("CCS Box Plot ", i, " - ", ref),
      caption = paste0("CCS Box Plot ", i, " - ", ref)
    )
    i <- i + 1
  }
}


doAllCCSPlots <- function(report, ccsDf)
{
  doCCSTitrationPlots(report, ccsDf)
  doCCSNumPassesHistogram(report, ccsDf)
  doCCSNumPassesCDF(report, ccsDf)
  doCCSReadQualityCalibrationPlots(report, ccsDf)
  doCCSCumulativeYieldPlots(report, ccsDf)
  doCCSTitrationBoxPlots(report, ccsDf)
}

makeReport <- function(report) {
  if (!interactive()) {
    args <- commandArgs(TRUE)
    wfRootDir <- args[1]
    ccsDf <- makeCCSDataFrame(report, wfRootDir)
    # When no data is loaded from the xml files
    if (ncol(ccsDf) == 1) {
      warning("Empty alignments!")
      0
    } else {
      report$write.table("ccs-mapping.csv",
                         ccsDf,
                         id = "ccs",
                         title = "CCS Mapping CSV")
      doAllCCSPlots(report, ccsDf)
    }
    
    # Save the report object for later debugging
    save(report, file = file.path(report$outputDir, "report.Rd"))
    
    # At the end of this function we need to call this last, it outputs the report
    report$write.report()
  }
  if (0) {
    ##wfRoot = "/home/UNIXHOME/dalexander/Projects/Analysis/EchidnaConsensus/2kLambda_4hr_postTrain_CCS/"
    wfRoot <-
      "/home/UNIXHOME/ayang/projects/bauhaus/Echidna_PerfVer/EchidnaVer_CCS_postTrain"
    df <- makeCCSDataFrame(report, wfRoot, 1.0)
  }
}

main <- function()
{
  report <- bh2Reporter(
    "condition-table.csv",
    "reports/CCSMappingReports/report.json",
    "CCS Mapping Reports"
  )
  makeReport(report)
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
