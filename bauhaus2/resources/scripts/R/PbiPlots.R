#!/usr/bin/env Rscript
# Test Simple Comparison Script
# This script takes a set of conditions and produces a png for display

library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(survival)
library(ggfortify)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

#' Define a basic addition to all plots
plTheme <-
  theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
clScale <- NULL #scale_colour_brewer(palette = "Set1")
clFillScale <- NULL# scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))
sampleSize = 5000
plotwidth = 7.2
plotheight = 4.2

makeReadLengthSurvivalPlots <- function(report, cd) {
  loginfo("Making Template Span Survival Plots")
  cd2 = cd %>% dplyr::group_by(hole, Condition) %>% dplyr::summarise(tlen = sum(tlen))
  cd2 <- as.data.frame(cd2)

  cd2$SurvObj <- with(cd2, Surv(tlen))
  cd2.by.con <- survfit(SurvObj ~ Condition, data = cd2)


  # When cd2.by.con is empty or only has one row, skip the following two plots
  if (nrow(cd2.by.con) > 1) {
    p1 <-
      autoplot(cd2.by.con) + labs(x = "Template Span", title = "Template Span Survival") + plTheme
    p2 <-
      autoplot(cd2.by.con) + scale_x_log10() + labs(x = "Template Span", title = "Template Span Survival (Log-scale)") + plTheme
    #  tp <- arrangeGrob(p1, p2, nrow = 2)
    report$ggsave(
      "template_span_survival.png",
      p1,
      width = plotwidth,
      height = plotheight,
      id = "template_span_survival",
      title = "Template Span Survival",
      caption = "Template Span Survival",
      tags = c("basic", "pbiplots", "survival", "template"),
      uid = "0030001"
    )
    report$ggsave(
      "template_span_survival (Log-scale).png",
      p2,
      width = plotwidth,
      height = plotheight,
      id = "template_span_survival(log)",
      title = "Template Span Survival (Log-scale)",
      caption = "Template Span Survival (Log-scale)",
      tags = c("basic", "pbiplots", "survival", "template", "log"),
      uid = "0030002"
    )
  }

  loginfo("Making Aligned Read Length Survival Plots")

  cd2 = cd %>% dplyr::group_by(hole, Condition) %>% dplyr::summarise(alen = sum(alen))
  cd2 <- as.data.frame(cd2)

  cd2$SurvObj <- with(cd2, Surv(alen))
  cd2.by.con <- survfit(SurvObj ~ Condition, data = cd2)

  #against subread length
  cd0 = as.data.frame(cd)
  cd0$SurvObj <- with(cd0, Surv(tlen))
  cd0.by.con <- survfit(SurvObj ~ Condition, data = cd0)

  if (nrow(cd2.by.con) > 1) {
    p1 <-
      autoplot(cd2.by.con) + labs(x = "Aligned Pol Read Length", title = "Aligned Pol Read Length Survival") + plTheme
    p3 <-
      autoplot(cd0.by.con) + labs(x = "Aligned Subread Read Length", title = "Aligned Subread Read Length Survival") + plTheme
    p2 <-
      autoplot(cd2.by.con) + scale_x_log10() + labs(x = "Aligned Pol Read Length", title = "Aligned Pol Read Length Survival (Log-scale)") + plTheme
    #  tp <- arrangeGrob(p1, p2, nrow = 2)


    report$ggsave(
      "aligned_pol_read_length_survival.png",
      p1,
      width = plotwidth,
      height = plotheight,
      id = "aligned_pol_read_length_survival",
      title = "Aligned Pol Read Length Survival",
      caption = "Aligned Pol Read Length Survival",
      tags = c("basic", "pbiplots", "survival", "read", "aligned"),
      uid = "0030003"
    )
    report$ggsave(
      "aligned_pol_read_length_survival (Log-scale).png",
      p2,
      width = plotwidth,
      height = plotheight,
      id = "aligned_pol_read_length_survival(log)",
      title = "Aligned Pol Read Length Survival (Log-scale)",
      caption = "Aligned Pol Read Length Survival (Log-scale)",
      tags = c("basic", "pbiplots", "survival", "read", "log", "aligned"),
      uid = "0030004"
    )
    report$ggsave(
      "aligned_subread_read_length_survival.png",
      p3,
      width = plotwidth,
      height = plotheight,
      id = "aligned_subread_read_length_survival",
      title = "Aligned Subread Read Length Survival",
      caption = "Aligned Subread Read Length Survival",
      tags = c("basic", "pbiplots", "survival", "read", "aligned"),
      uid = "0030017"
    )
  }
}

makeAccuracyDensityPlots <- function(report, cd) {
  loginfo("Making Accuracy Density Plots")
  tp = ggplot(cd, aes(x = Accuracy, colour = Condition)) + geom_density(alpha = .5) + plTheme + clScale +
    labs(x = "Accuracy (1 - Mean Errors Per Template Position)", title = "Accuracy by Condition (all ZMWs included)")
  report$ggsave(
    "acc_density.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "acc_density",
    title = "Accuracy Distribution (all ZMWs included)",
    caption = "Accuracy Distribution (all ZMWs included)",
    tags = c("basic", "pbiplots", "density", "accuracy"),
    uid = "0030005"
  )

  loginfo("Making Accuracy Box Plots")
  tp = ggplot(cd, aes(x = Condition, y = Accuracy, colour = Condition)) + geom_boxplot() + stat_summary(
    fun.y = median,
    colour = "black",
    geom = "text",
    show.legend = FALSE,
    vjust = -0.6,
    aes(label = round(..y.., digits = 4))
  ) + plTheme + clScale +
    labs(x = "Accuracy (1 - Mean Errors Per Template Position)", title = "Accuracy by Condition (all ZMWs included)")
  report$ggsave(
    "acc_boxplot.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "acc_boxplot",
    title = "Accuracy Boxplot (all ZMWs included)",
    caption = "Accuracy Boxplot (all ZMWs included)",
    tags = c("basic", "pbiplots", "boxplot", "accuracy"),
    uid = "0030019"
  )

  # loginfo("Making Accuracy Violin Plots")
  # tp = ggplot(cd, aes(x = Condition, y = Accuracy, fill = Condition)) + geom_violin() +
  #   plTheme + clFillScale + themeTilt +
  #   labs(y = "Accuracy (1 - Mean Errors Per Template Position)", title = "Accuracy by Condition", x = "Condition") +
  #   geom_boxplot(width = 0.1, fill = "white")
  # report$ggsave(
  #   "acc_violin.png",
  #   tp,
  #   width = plotwidth,
  #   height = plotheight,
  #   id = "acc_violin",
  #   title = "Accuracy Violin",
  #   caption = "Accuracy Violin"
  # )

  loginfo("Making Template Length vs. Accuracy")
  samps_per_group = sampleSize / length(levels(cd$Condition))
  sample_nigel <-
    function(tbl,
             size,
             replace = FALSE,
             weight = NULL,
             .env = parent.frame())
    {
      #assert_that(is.numeric(size), length(size) == 1, size >= 0)
      weight <- substitute(weight)
      index <- attr(tbl, "indices")
      sizes = sapply(index, function(z)
        min(length(z), size)) # here's my contribution
      sampled <-
        lapply(1:length(index), function(i)
          dplyr:::sample_group(
            index[[i]],
            frac = FALSE,
            tbl = tbl,
            size = sizes[i],
            replace = replace,
            weight = weight
          ))
      idx <- unlist(sampled) + 1
      grouped_df(tbl[idx, , drop = FALSE], vars = groups(tbl))
    }

  cd2 = cd %>% group_by(Condition) %>% sample_nigel(size = samps_per_group) %>% ungroup()
  tp = ggplot(cd2, aes(x = tlen, y = Accuracy, color = Condition)) + geom_point(alpha = .2) +
    plTheme  + geom_smooth(fill = NA) + clScale + labs(
      y = "Accuracy (1 - Mean Errors Per Template Position)",
      title = paste("Accuracy vs. Template Length\n(Sampled to <= ", sampleSize, ")"),
      x = "Template Length"
    ) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition)))
  img_height = min(49.5, 3.6 * length(levels(cd2$Condition)))
  report$ggsave(
    "acc_accvtl.png",
    tp,
    id = "acc_accvtl",
    width = plotwidth,
    height = img_height,
    title = "Template Length v. Accuracy",
    caption = "Template Length v. Accuracy",
    tags = c("basic", "pbiplots", "accuracy", "template"),
    uid = "0030006"
  )

  tp = ggplot(cd2, aes(x = alen, y = Accuracy, color = Condition)) + geom_point(alpha = .2) +
    plTheme  + geom_smooth(fill = NA) + clScale + labs(
      y = "Accuracy (1 - Mean Errors Per Template Position)",
      title = paste(
        "Accuracy vs. Aligned Read Length (aend - astart)\n(Sampled to <= ",
        sampleSize,
        ")"
      ),
      x = "Aligned Read Length"
    ) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition)))
  report$ggsave(
    "acc_accvrl.png",
    tp,
    id = "acc_accvrl",
    width = plotwidth,
    height = img_height,
    title = "Aligned Read Length v. Accuracy",
    caption = "Aligned Read Length v. Accuracy",
    tags = c("basic", "pbiplots", "accuracy", "read", "aligned"),
    uid = "0030007"
  )

  tp = ggplot(cd2, aes(x = qrlen, y = alen, color = Condition)) + geom_point(alpha = .2) +
    plTheme  + geom_abline(intercept = 0,
                           slope = 1,
                           color = "red") + clScale + labs(
                             y = "Aligned Read Length (aend - astart)",
                             title = paste(
                               "Unaligned Read Length v. Aligned Read Length\n(Sampled to <= ",
                               sampleSize,
                               ")"
                             ),
                             x = "Unaligned Read Length (qend - qstart)"
                           ) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition)))
  report$ggsave(
    "alen_v_qlen.png",
    tp,
    id = "alen_v_qlen",
    width = plotwidth,
    height = img_height,
    title = "Unaligned Read Length v. Aligned Read Length",
    caption = "Unaligned Read Length v. Aligned Read Length",
    tags = c("basic", "pbiplots", "read", "aligned", "unaligned"),
    uid = "0030008"
  )



  # loginfo("Making Template Span Violin Plot")
  # tp = ggplot(cd, aes(x = Condition, y = tlen, fill = Condition)) + geom_violin() +
  #   plTheme + clFillScale + themeTilt +
  #   labs(y = "Template Span (tend - tstart)", title = "Template Span Violin Plot", x = "Condition")
  # report$ggsave(
  #   "tlen_violin.png",
  #   tp,
  #   id = "tlen_violin",
  #   width = plotwidth,
  #   height = plotheight,
  #   title = "Template Span Violin Plot",
  #   caption = "Template Span Violin Plot"
  # )

  loginfo("Making Template Span Density Plot")
  tp = ggplot(cd, aes(x = tlen, colour = Condition)) + geom_density() +
    plTheme + clScale + themeTilt +
    labs(y = "Density", title = "Template Span Density Plot", x = "Template Span (tend - tstart)")
  report$ggsave(
    "tlen_density.png",
    tp,
    id = "tlen_density",
    width = plotwidth,
    height = plotheight,
    title = "Template Span Density Plot",
    caption = "Template Span Density Plot",
    tags = c("basic", "pbiplots", "density", "template"),
    uid = "0030009"
  )

  loginfo("Making Aligned Subread Read Length Density Plot")
  tp = ggplot(cd, aes(x = alen, colour = Condition)) + geom_density() +
    plTheme + clScale + themeTilt +
    labs(y = "Density", title = "Aligned Subread Read Length Density Plot", x = "Aligned Subread Read Length (aend - astart)")
  report$ggsave(
    "alen_subread_density.png",
    tp,
    id = "alen_subread_density",
    width = plotwidth,
    height = plotheight,
    title = "Aligned Subread Read Length Density Plot",
    caption = "Aligned Subread Read Length Density Plot",
    tags = c("basic", "pbiplots", "density", "read", "aligned"),
    uid = "0030010"
  )

  loginfo("Making Aligned Pol Read Length Density Plot")
  cd3 = cd %>% dplyr::group_by(hole, Condition) %>% dplyr::summarise(tlen = sum(tlen))
  cd3 <- as.data.frame(cd3)
  tp2 = ggplot(cd3, aes(x = tlen, colour = Condition)) + geom_density() +
    plTheme + clScale + themeTilt +
    labs(y = "Density", title = "Aligned Pol Read Length Density Plot", x = "Aligned Pol Read Length")
  report$ggsave(
    "alen_pol_density.png",
    tp2,
    id = "alen_pol_density",
    width = plotwidth,
    height = plotheight,
    title = "Aligned Pol Read Length Density Plot",
    caption = "Aligned Pol Read Length Density Plot",
    tags = c("basic", "pbiplots", "density", "read", "aligned"),
    uid = "0030018"
  )

  loginfo("Making Template Span Boxplot")
  tp = ggplot(cd, aes(x = Condition, y = tlen, fill = Condition)) + geom_boxplot() +
    plTheme + clFillScale + themeTilt + stat_summary(
      fun.y = median,
      colour = "black",
      geom = "text",
      show.legend = FALSE,
      vjust = -0.8,
      aes(label = round(..y..))
    ) +
    labs(y = "Template Span (tend - tstart)", title = "Template Span Boxplot", x = "Condition")
  report$ggsave(
    "tlen_box.png",
    tp,
    id = "tlen_box",
    width = plotwidth,
    height = plotheight,
    title = "Template Span Boxplot",
    caption = "Template Span Boxplot",
    tags = c("basic", "pbiplots", "boxplot", "template"),
    uid = "0030011"
  )
}

# makeErateViolinPlots <- function(report, cd) {
#   loginfo("Making Error Rate Violin Plots")
#   vnames = c("mmrate", "irate", "drate")
#   labels = c("Mismatch", "Insertion", "Deletion")
#   mkErate <- function(i) {
#     vname = vnames[i]
#     label = labels[i]
#     tp = ggplot(cd, aes_string(x = "Condition", y = vname, fill = "Condition")) + geom_violin() +
#       plTheme + clFillScale + geom_boxplot(width = 0.1, fill = "white") + themeTilt +
#       labs(
#         y = label,
#         title = paste(label, " Rate by Condition - Violin Plot"),
#         x = "Condition"
#       )
#     report$ggsave(
#       paste("etype_", "_", vname, "_violin.png", sep = ""),
#       tp,
#       width = plotwidth,
#       height = plotheight,
#       id = paste("etype_", "_", vname, "_violin", sep = ""),
#       title = paste(label, "Rate - Violin Plot"),
#       caption = paste(label, "Rate - Violin Plot")
#     )
#   }
#   pv = lapply(1:3, mkErate)
#   return(pv)
# }

makeErateBoxPlots <- function(report, cd) {
  loginfo("Making Error Rate Boxplots")
  vnames = c("mmrate", "irate", "drate")
  labels = c("Mismatch", "Insertion", "Deletion")
  uniqueids = c("0030012", "0030013", "0030014")
  mkErateBox <- function(i) {
    vname = vnames[i]
    label = labels[i]
    uniqueid = uniqueids[i]
    tp = ggplot(cd, aes_string(x = "Condition", y = vname, fill = "Condition")) + geom_boxplot() +
      plTheme + clFillScale + themeTilt + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) +
      labs(
        y = label,
        title = paste(label, " Rate by Condition - Boxplot"),
        x = "Condition"
      )
    report$ggsave(
      paste("etype_", "_", vname, "_boxplot.png", sep = ""),
      tp,
      width = plotwidth,
      height = plotheight,
      id = paste("etype_", "_", vname, "_boxplot", sep = ""),
      title = paste(label, "Rate - Boxplot"),
      caption = paste(label, "Rate - Boxplot"),
      tags = c("basic", "pbiplots", "boxplot", label),
      uid = uniqueid
    )
  }
  pv = lapply(1:3, mkErateBox)
  return(pv)
}

makeBasesDistribution <- function(report, cd) {
  loginfo("Making Bases Data Distribution")
  res = cd %>% group_by(Condition) %>% summarise(Template = sum(tlen), Read = sum(alen)) %>% gather(BaseType, Bases, Template:Read)
  tp = ggplot(res,
              aes(
                x = BaseType,
                y = Bases,
                fill = Condition,
                group = Condition
              )) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + clFillScale +
    labs(y = "Total Bases\nsum(end - start)", title = "Total Bases by Condition", x = "Base Type")
  report$ggsave(
    "base_count_bar.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "base_count_bar",
    title = "Total Bases",
    caption = "Total Bases",
    tags = c("basic", "pbiplots", "bar", "base"),
    uid = "0030015"
  )
}

makeYieldHistogram <- function(report, cd) {
  loginfo("Making Yield Histogram")
  tp = ggplot(cd, aes(Condition, fill = Condition)) + geom_bar() +
    geom_text(stat = 'count', aes(label = ..count..), vjust = -0.5) +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "nReads", title = "nReads by Condition")
  report$ggsave(
    "nreads_hist.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "nreads_histogram",
    title = "nReads Histogram",
    caption = "nReads Histogram",
    tags = c("basic", "pbiplots", "histogram", "nreads"),
    uid = "0030016"
  )
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  # Make fake data - for debugging
  #condFile = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/005/005578/tasks/pbcommandR.tasks.pbiplot_reseq_condition-0/resolved-tool-contract.json"
  #condjson = jsonlite::fromJSON(condFile)
  #input = condjson$resolved_tool_contract$input_files
  #decoded <- loadReseqConditionsFromPath(input)
  #conds = decoded@conditions
  #tmp = lapply(conds, function(z) data.frame(condition = z@condId,subreadset = z@subreadset, alignmentset = z@alignmentset, referenceset = z@referenceset))
  #conditions = do.call(rbind, tmp)

  conditions = report$condition.table
  # Load the pbi index for each data frame
  dfs = lapply(as.character(conditions$MappedSubreads), function(s) {
    loginfo(paste("Loading alignment set:", s))
    loadPBI2(s)
  })
  # Filter out empty data sets, throw a warning if any empty ones exist
  filteredData = filterEmptyDataset(dfs, conditions)
  if (length(filteredData) == 0) {
    warning("No ZMW has been loaded from the alignment set!")
  } else {
    dfs  = filteredData[[1]]
    conditions = filteredData[[2]]

    # Now combine into one large data frame
    cd = combineConditions(dfs, as.character(conditions$Condition))

    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)

    cd$tlen = as.numeric(cd$tend - cd$tstart)
    cd$alen = as.numeric(cd$aend - cd$astart)
    cd$errors = as.numeric(cd$mismatches + cd$inserts + cd$dels)
    cd$Accuracy = 1 - cd$errors / cd$tlen
    cd$mmrate = cd$mismatches / cd$tlen
    cd$irate  = cd$inserts / cd$tlen
    cd$drate  = cd$dels / cd$tlen
    cd$qrlen = as.numeric(cd$qend - cd$qstart)

    summaries = cd[, .(
      AccuracyRate.Median = median(Accuracy),
      AlnLength = median(tlen),
      ReadLength = median(alen),
      QReadLength = median(qrlen),
      InsertRate = median(irate),
      DeletionRate = median(drate),
      MismatchRate = median(mmrate),
      NumberZMWs = nrow(distinct(cd, hole)),
      NumberAlns = length(hole),
      TotalAlignedBases = sum(tlen),
      TotalReadBases = sum(alen),
      BAMFiles = length(unique(file))
    ),
    by = Condition]
    colnames(summaries) <-
      c(
        "Condition",
        "Accuracy",
        "Aln Length",
        "Aln Read Length (a)",
        "Aln Read Length (q)",
        "Insert Rate",
        "Deletion Rate",
        "Mismatch Rate",
        "# ZMWs",
        "# Alignments",
        "Total Template Bases",
        "Total Read Bases",
        "Total BAM Files"
      )
    report$write.table("sumtable.csv",
                       summaries,
                       id = "sumtable",
                       title = "Summary Statistics (Median Values)")

    # Make Plots
    try(makeReadLengthSurvivalPlots(report, cd), silent = TRUE)
    try(makeAccuracyDensityPlots(report, cd), silent = TRUE)
    # makeErateViolinPlots(report, cd)
    try(makeErateBoxPlots(report, cd), silent = TRUE)
    try(makeBasesDistribution(report, cd), silent = TRUE)
    try(makeYieldHistogram(report, cd), silent = TRUE)
  }

  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))

  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter("condition-table.csv",
                        "reports/PbiPlots/report.json",
                        "Sampled ZMW metrics")
  makeReport(report)
  jsonFile = "reports/PbiPlots/report.json"
  uidTagCSV = "reports/uidTag.csv"
  try(rewriteJSON(jsonFile, uidTagCSV), silent = TRUE)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()