#!/usr/bin/env Rscript
# Test Simple Comparison Script
# This script takes a set of conditions and produces a png for display

library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR, quietly = TRUE)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr)
library(tidyr)
library(survival)
library(ggfortify)
library(rhdf5)
library(grid)
library(xml2)
library(h5r)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

#' Define a basic addition to all plots
plTheme <-
  theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
clScale <- NULL #scale_colour_brewer(palette = "Set1")
clFillScale <- NULL# scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))
plotwidth = 7.2
plotheight = 4.2
ASP_RATIO = 0.5
dna = c("A", "C", "G", "T")
channel = c("Green", "Red")
nonalnedZMWMetrics = c(
  "Loading",
  "NumBases",
  "NumPulses",
  "PulseRate",
  "PulseWidth",
  "ReadLength",
  "ReadType",
  "ReadScore",
  paste("HQRegionSnrMean", dna, sep = "_"),
  paste("HQPkmid", dna, sep = "_"),
  paste("BaselineLevel", channel, sep = "_"),
  paste("BaselineStd", channel, sep = "_"),
  paste("HQBaselineLevel", channel, sep = "_"),
  paste("HQBaselineStd", channel, sep = "_"),
  paste("SnrMean", dna, sep = "_"))

#create a dataframe with all column names that are NOT plotted separately for P0, P1 and P2 and the corresponding uid
plot_names = c (
  "Unrolled Alignments Length (Summation) by Read Type",
  "Accuracy (per ZMW) by Read Type",
  "readTypeAgg.1",
  "readTypeAgg.2",
  "Yield (ZMWs) Percentage by Read Type",
  "Yield (ZMWs) Percentage by Productivity",
  "Adapter Dimer Fraction by Condition",
  "Short Insert Fraction by Condition",
  "BaselineLevel Box Plot",
  "BaselineLevel Density Plot",
  "BaselineLevel CDF Plot",
  "BaselineLevel CDF Plot (Log-scale)"
)
uid_column = paste ("00", 60001:60012, sep = "")
uid_table = data.frame(plot_names, uid_column)

#create a dataframe with all columns that are plotted for separately for P0, P1 and P2 and the corresponding uid
plot_names2 = c(
  "Count",
  nonalnedZMWMetrics[1:8],
  paste("HQPkmid", dna, sep = "_"),
  nonalnedZMWMetrics[17:28],
  "BaseIpd",
  "BaseRate",
  "BaseWidth",
  "HQRegionEnd",
  "HQRegionEndTime",
  "HQRegionStart",
  "HQRegionStartTime",
  "InsertReadLength" ,
  "LocalBaseRate",
  "MedianInsertLength",
  "Pausiness",
  "Productivity",
  paste("BaseFraction", dna, sep = "_"),
  paste("HQRegionSnrMean", dna, sep = "_"),
  paste("DyeAngle", dna, sep = "_")
)
uid_P0 = paste("00", 71001:71049, sep = '')
uid_P1 = paste("00", 72001:72049, sep = '')
uid_P2 = paste("00", 73001:73049, sep = '')
pplot_uid_table = data.frame(plot_names2, uid_P0, uid_P1, uid_P2)

generateStsH5Heatmaps = function(report, file, label, N, dist = NULL)
{
  S = getStsH5Data(file, labelReadTypes = FALSE)

  # Plots for P0 reads
  dna = c("A", "C", "G", "T")
  channel = c("Green", "Red")
  nonalnedZMWMetrics = c(
    "Loading",
    "NumBases",
    "NumPulses",
    "PulseRate",
    "PulseWidth",
    "ReadLength",
    "ReadType",
    "ReadScore",
    paste("HQRegionSnrMean", dna, sep = "_"),
    paste("HQPkmid", dna, sep = "_"),
    paste("BaselineLevel", channel, sep = "_"),
    paste("BaselineStd", channel, sep = "_"),
    paste("HQBaselineLevel", channel, sep = "_"),
    paste("HQBaselineStd", channel, sep = "_"),
    paste("SnrMean", dna, sep = "_")
  )

  P0 = subset(S, Productivity == 0)
  P0 = P0[, c(nonalnedZMWMetrics, "HoleNumber", "X", "Y")]
  plotProductivityCategories(report, P0, "P0", label, N, dist)

  # Plots for P1 reads
  P1 = subset(S, Productivity == 1)
  plotProductivityCategories(report, P1, "P1", label, N, dist)

  # Plots for P2 reads
  P2 = subset(S, Productivity == 2)
  P2 = P2[, c(nonalnedZMWMetrics, "HoleNumber", "X", "Y")]
  plotProductivityCategories(report, P2, "P2", label, N, dist)
}

plotProductivityCategories = function(report, res, x, label, N, dist = NULL)
{
  try(plotAllFields(report,
                    res,
                    pvalue = x,
                    N,
                    paste(label, x, sep = "_"),
                    FALSE,
                    dist),
      silent = FALSE)
  1
}

plotAllFields = function(report,
                         res,
                         N,
                         pvalue,
                         label,
                         addUnif,
                         dist = NULL,
                         pois.frac = NA)
{
  if (is.null(res)) {
    return(0)
  }
  if (nrow(res) < 5)
  {
    cat("[WARNING]: Too few elements.\n")
    return(0)
  }

  exclude = identifyEmptyOrSingleValuedColumns(res, c("HoleNumber", "X", "Y"))
  colNames = setdiff(names(res), exclude)
  loadingUnif = NULL
  res = convenientSummarizersts(res, N = N)
  pvaluefind = 0
  if (pvalue == 'P0') {
    pvaluefind = 2
  }
  if (pvalue == "P1") {
    pvaluefind = 3
  }
  if (pvalue == "P2") {
    pvaluefind = 4
  }

  lapply(c("Count", colNames), function(n) {
    if (is.null(pplot_uid_table[, pvaluefind][plot_names2 == n]))
    {
      warning("Columns non-excluded different from set list")
    }
    else {
      try(plotSingleSummarizedHeatmap(
        report,
        res,
        n,
        label = label,
        N = N,
        sts = TRUE,
        uid = as.vector(pplot_uid_table[, pvaluefind][plot_names2 == n])
      ),
      silent = FALSE)
    }
  })

  countUniqueZMWs(res)
}

convenientSummarizersts = function(res,
                                   N,
                                   key = 1e3,
                                   x.min = 64,
                                   y.min = 64)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  x = as.numeric(res$X) - x.min + 1
  y = as.numeric(res$Y) - y.min + 1
  X = (x %/% N[1]) + (x %% N[1] > 0)
  Y = (y %/% N[2]) + (y %% N[2] > 0)
  z = data.frame(data.table(X, Y)[, .N, by = .(X, Y)])
  # z$N contains the number of alignments per N[1] x N[2] block

  if ("SNR_A" %in% names(res))
  {
    res$SNR_A[res$SNR_A == -1] <- NA
    res$SNR_C[res$SNR_C == -1] <- NA
    res$SNR_G[res$SNR_G == -1] <- NA
    res$SNR_T[res$SNR_T == -1] <- NA
  }

  excl = c(
    "Matches",
    "Mismatches",
    "Inserts",
    "Dels",
    "HoleNumber",
    "Reference",
    "SMRTlinkID"
  )
  u = data.table(res[, -which(names(res) %in% excl)])
  u$X = X
  u$Y = Y
  FUN = function(x, na.rm = TRUE)
    as.double(median(x, na.rm))
  cols = setdiff(names(u), c("X", "Y"))
  tmp = data.frame(u[, lapply(.SD, FUN), by = .(X, Y), .SDcols = cols])
  m = match(key * tmp$X + tmp$Y, key * z$X + z$Y)
  tmp$Count = z$N[m]
  tmp
}

countUniqueZMWs = function(res)
  length(unique(res$HoleNumber))

identifyEmptyOrSingleValuedColumns = function(res, exclude)
{
  nms = setdiff(names(res), exclude)
  v = vapply(nms, function(n)
    length(unique(res[, n])), 0)
  c(exclude, nms[which(v < 1)])
}

getStsH5Data = function(file, labelReadTypes = TRUE)
{
  #' Open h5 file:
  h5 = new("H5File", fileName = file, mode = "r")
  ZMWMetrics = getH5Group(h5, "ZMWMetrics")
  ZMW = getH5Group(h5, "ZMW")

  S = lapply(datasetsZMWMetrics(), function(name)
    opDS(ZMWMetrics, name))
  S = do.call(cbind, S)

  K = lapply(c("HoleNumber", "UnitFeature"), function(name)
    opDS(ZMW, name))
  K = as.matrix(do.call(cbind, K))

  S$HoleNumber = K[, 1]
  S$X = S$HoleNumber %/% MAXINT
  S$Y = S$HoleNumber %% MAXINT

  if (labelReadTypes)
  {
    S$ReadType =
      c(
        "Empty",
        "FullHq0",
        "FullHq1",
        "PartialHq0",
        "PartialHq1",
        "PartialHq2",
        "Indeterminate"
      )[S$ReadType + 1]
  }

  #' Return non-fiducial ZMWs only:
  S[K[, 2] == 0, ]
}

opDS = function(group, name, na.value = 2147483647)
{
  if (!h5DatasetExists(group, name))
  {
    return(NULL)
  }
  dset = getH5Dataset(group, name)[]
  dset[dset == na.value] <- NA
  dset = data.frame(dset)
  rm(group)
  gc()
  n = ncol(dset)
  if (n == 2) {
    name = paste(name, c("Green", "Red"), sep = "_")
  }
  if (n == 4) {
    name = paste(name, c("A", "C", "G", "T"), sep = "_")
  }
  names(dset) = name
  dset
}

datasetsZMWMetrics = function()
{
  c(
    "BaseIpd",
    "BaseRate",
    "BaseWidth",
    "HQRegionEnd",
    "HQRegionEndTime",
    "HQRegionStart",
    "HQRegionStartTime",
    "InsertReadLength",
    "Loading",
    "LocalBaseRate",
    "MedianInsertLength",
    "NumBases",
    "NumPulses",
    "Pausiness",
    "Productivity",
    "PulseRate",
    "PulseWidth",
    "ReadLength",
    "ReadScore",
    "ReadType",
    "BaseFraction",
    "HQRegionSnrMean",
    "SnrMean",
    "DyeAngle",
    "HQPkmid",
    "BaselineLevel",
    "BaselineStd",
    "HQBaselineLevel",
    "HQBaselineStd"
  )
}

loadstsH5 <- function(stsH5file) {
  stsH5 = data.frame(
    hole = h5read(stsH5file, "/ZMW/HoleNumber"),
    readType = h5read(stsH5file, "/ZMWMetrics/ReadType"),
    productivity = h5read(stsH5file, "/ZMWMetrics/Productivity"),
    BaselineLevel_Green = h5read(stsH5file, "/ZMWMetrics/BaselineLevel")[1,],
    BaselineLevel_Red = h5read(stsH5file, "/ZMWMetrics/BaselineLevel")[2,]
  )
  stsH5
}

loadstsXML <- function(stsXMLfile) {
  x = read_xml(stsXMLfile)
  ADF = NA
  SIF = NA
  for (i in 1:length(xml_children(x))) {
    if (xml_name(xml_children(x)[i]) == "AdapterDimerFraction") {
      ADF = xml_double(xml_children(x)[i])
    }
    if (xml_name(xml_children(x)[i]) == "ShortInsertFraction") {
      SIF = xml_double(xml_children(x)[i])
    }
  }
  stsXML = data.frame(AdapterDimerFraction = ADF,
                      ShortInsertFraction = SIF)
  stsXML
}

poissonPlot <- function(d, title) {
  lambdas <- seq(0, 4, length = 100)
  poissonCurve <-
    data.frame(x = 1 - dpois(0, lambdas), y = dpois(1, lambdas))
  p <-
    ggplot(poissonCurve, aes(x = x, y = y)) + geom_line() + ggtitle(title) +
    scale_x_continuous('Not Empty') + scale_y_continuous('Single Loads', limits = c(0, .80)) +
    geom_vline(xintercept = 1 - dpois(0, 1)) + geom_hline(yintercept = dpois(1, 1)) +
    geom_point(
      data = data.frame(
        empty = 1 - d[, 'empty'],
        single = d[, 'single'],
        Condition = d$Condition
      ),
      aes(empty, single, col = Condition),
      size = 8
    ) +
    plTheme + themeTilt  + clFillScale
  return(p)
}

makeReadTypePlots <- function(report, cd2) {
  loginfo("Making Read Type Plots")

  cdunrolled = cd2 %>% group_by(Condition, hole, readType, productivity) %>% summarise(unrolledT = sum(tlen),
                                                                                       accuracy = 1 - (sum(mismatches) + sum(dels) + sum(inserts)) / sum(tlen))

  tp <-
    ggplot(data = cdunrolled, aes(x = readType,
                                  y = unrolledT,
                                  fill = Condition)) +
    geom_boxplot(position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Read Type", y = "Unrolled Alignments Length (Summation)", title = "Unrolled Alignments Length (Summation) by Read Type")
  a <-
    aggregate(unrolledT ~ readType + Condition , cdunrolled, function(i)
      round(median(i)))
  tp <- tp +  geom_text(
    data = a,
    aes(label = unrolledT),
    position = position_dodge(width = 0.9),
    vjust = -0.8
  )

  report$ggsave(
    "unrolled_template_length_by_readtype_boxplot.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "unrolled_template_length_by_readtype_boxplot",
    title = "Unrolled Alignments Length (Summation) by Read Type",
    caption = "Unrolled Alignments Length (Summation) by Read Type",
    tags = c("sts",
             "h5",
             "boxplot",
             "unrolled",
             "template",
             "readtype"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Unrolled Alignments Length (Summation) by Read Type"])
  )

  tp <-
    ggplot(data = cdunrolled, aes(x = readType,
                                  y = accuracy,
                                  fill = Condition)) +
    geom_boxplot(position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Read Type", y = "Accuracy (per ZMW)", title = "Accuracy (per ZMW) by Read Type")

  report$ggsave(
    "accuracy_by_readtype_boxplot.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "accuracy_by_readtype_boxplot",
    title = "Accuracy (per ZMW) by Read Type",
    caption = "Accuracy (per ZMW) by Read Type",
    tags = c("sts",
             "h5",
             "boxplot",
             "accuracy",
             "readtype"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Accuracy (per ZMW) by Read Type"])
  )

  # Primary readType metric and agg plots
  if (any(!is.na(cd2$readType))) {
    cd2$readTypeAgg.1 <-
      ifelse(
        cd2$readType %in% c("Empty", "Indeterminate"),
        "Empty",
        ifelse(
          cd2$readType %in% c(
            'FullHqRead0',
            'FullHqRead1',
            'PartialHqRead1',
            'PartialHqRead2'
          ),
          "Single",
          "Other"
        )
      )

    cd2$readTypeAgg.2 <-
      ifelse(
        cd2$readType %in% c("Empty"),
        "Empty",
        ifelse(
          cd2$readType %in% c(
            'FullHqRead0',
            'FullHqRead1',
            'PartialHqRead1',
            'PartialHqRead2'
          ),
          "Single",
          "Other"
        )
      )

    emptyVals = "Empty"
    singleVals = "Single"
    d1 = cd2 %>% group_by(Condition) %>% summarise(
      empty  = mean(readTypeAgg.1 %in% emptyVals),
      single = mean(readTypeAgg.1 %in% singleVals)
    )
    d2 = cd2 %>% group_by(Condition) %>% summarise(
      empty  = mean(readTypeAgg.2 %in% emptyVals),
      single = mean(readTypeAgg.2 %in% singleVals)
    )

    tp1 <- poissonPlot(d1, "readTypeAgg.1")
    report$ggsave(
      "readTypeAgg.1.png",
      tp1,
      width = plotwidth,
      height = plotheight,
      id = "readTypeAgg.1",
      title = "readTypeAgg.1",
      caption = "readTypeAgg.1",
      tags = c("sts",
               "h5",
               "agg",
               "readTypeAgg.1",
               "readtype"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "readTypeAgg.1"])
    )

    tp2 <- poissonPlot(d2, "readTypeAgg.2")
    report$ggsave(
      "readTypeAgg.2.png",
      tp2,
      width = plotwidth,
      height = plotheight,
      id = "readTypeAgg.2",
      title = "readTypeAgg.2",
      caption = "readTypeAgg.2",
      tags = c("sts",
               "h5",
               "agg",
               "readTypeAgg.2",
               "readtype"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "readTypeAgg.2"])
    )
  }
}

makeYieldPlots <- function(report, cdH5) {
  loginfo("Making yield (ZMWs) Plots")

  # Yield (ZMWs) Percentage by Read type

  cdreadtype = cdH5 %>% group_by(Condition, readType) %>% summarise(n = n())
  cdreadtype = cdreadtype %>% group_by(Condition) %>% mutate(nper = n / sum(n)) %>% ungroup()
  tp = ggplot(cdreadtype, aes(x = readType, y = nper, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Read Type", y = "(nZMWs by Read Type)/nZMWs", title = "Yield (ZMWs) Percentage by Read Type")

  report$ggsave(
    "nzmws_readtype_hist_percentage.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "nzmws_readtype_hist_percentage",
    title = "Yield (ZMWs) Percentage by Read Type",
    caption = "Yield (ZMWs) Percentage by Read Type",
    tags = c("sts",
             "h5",
             "histogram",
             "readtype",
             "zmws",
             "percentage"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Yield (ZMWs) Percentage by Read Type"])
  )

  # Yield (ZMWs) Percentage by Productivity

  cdproductivity = cdH5 %>% group_by(Condition, productivity) %>% summarise(n = n())
  cdproductivity = cdproductivity %>% group_by(Condition) %>% mutate(nper = n / sum(n)) %>% ungroup()
  tp = ggplot(cdproductivity, aes(x = productivity, y = nper, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Productivity", y = "(nZMWs by Productivity)/nZMWs", title = "Yield (ZMWs) Percentage by Productivity")

  report$ggsave(
    "nzmws_productivity_hist_percentage.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "nzmws_productivity_hist_percentage",
    title = "Yield (ZMWs) Percentage by Productivity",
    caption = "Yield (ZMWs) Percentage by Productivity",
    tags = c(
      "sts",
      "h5",
      "histogram",
      "productivity",
      "zmws",
      "percentage"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Yield (ZMWs) Percentage by Productivity"])
  )
}

makestsXMLPlots <- function(report, cdXML) {
  loginfo("Making sts.xml Plots")

  # Adapter Dimer Fraction by Condition

  tp = ggplot(cdXML,
              aes(x = Condition, y = AdapterDimerFraction, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Adapter Dimer Fraction", title = "Adapter Dimer Fraction by Condition")

  report$ggsave(
    "adapter_dimer_fraction.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "adapter_dimer_fraction",
    title = "Adapter Dimer Fraction by Condition",
    caption = "Adapter Dimer Fraction by Condition",
    tags = c("sts",
             "xml",
             "histogram",
             "adapter",
             "zmws",
             "fraction"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Adapter Dimer Fraction by Condition"])
  )

  # Short Insert Fraction by Condition

  tp = ggplot(cdXML,
              aes(x = Condition, y = ShortInsertFraction, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Short Insert Fraction", title = "Short Insert Fraction by Condition")

  report$ggsave(
    "short_insert_fraction.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "short_insert_fraction",
    title = "Short Insert Fraction by Condition",
    caption = "Short Insert Fraction by Condition",
    tags = c("sts",
             "xml",
             "histogram",
             "shortinsert",
             "zmws",
             "fraction"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Short Insert Fraction by Condition"])
  )
}

makeEmptyPlots <- function(report) {
  df <- data.frame()
  tp = ggplot(df) + geom_point() + xlim(0, 10) + ylim(0, 10) + plTheme +
    annotate(
      geom = "text",
      x = 5,
      y = 5,
      label = 'Missing sts.h5',
      color = 'red',
      angle = 45,
      fontface = 'bold',
      size = 14,
      alpha = 0.5,
      family = 'Arial'
    )

  report$ggsave(
    "unrolled_template_length_by_readtype_boxplot.png",
    tp + labs(title = "Unrolled Alignments Length (Summation) by Read Type"),
    width = plotwidth,
    height = plotheight,
    id = "unrolled_template_length_by_readtype_boxplot",
    title = "Unrolled Alignments Length (Summation) by Read Type",
    caption = "Unrolled Alignments Length (Summation) by Read Type",
    tags = c(
      "sts",
      "h5",
      "boxplot",
      "unrolled",
      "template",
      "readtype",
      "missing"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Unrolled Alignments Length (Summation) by Read Type"])
  )

  report$ggsave(
    "accuracy_by_readtype_boxplot.png",
    tp + labs(title = "Accuracy (per ZMW) by Read Type"),
    width = plotwidth,
    height = plotheight,
    id = "accuracy_by_readtype_boxplot",
    title = "Accuracy (per ZMW) by Read Type",
    caption = "Accuracy (per ZMW) by Read Type",
    tags = c("sts",
             "h5",
             "boxplot",
             "accuracy",
             "readtype",
             "missing"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Accuracy (per ZMW) by Read Type"])
  )

  report$ggsave(
    "nzmws_readtype_hist_percentage.png",
    tp + labs(title = "Yield (ZMWs) Percentage by Read Type"),
    width = plotwidth,
    height = plotheight,
    id = "nzmws_readtype_hist_percentage",
    title = "Yield (ZMWs) Percentage by Read Type",
    caption = "Yield (ZMWs) Percentage by Read Type",
    tags = c(
      "sts",
      "h5",
      "histogram",
      "readtype",
      "zmws",
      "percentage",
      "missing"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Yield (ZMWs) Percentage by Read Type"])
  )

  report$ggsave(
    "nzmws_productivity_hist_percentage.png",
    tp + labs(title = "Yield (ZMWs) Percentage by Productivity"),
    width = plotwidth,
    height = plotheight,
    id = "nzmws_productivity_hist_percentage",
    title = "Yield (ZMWs) Percentage by Productivity",
    caption = "Yield (ZMWs) Percentage by Productivity",
    tags = c(
      "sts",
      "h5",
      "histogram",
      "productivity",
      "zmws",
      "percentage",
      "missing"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Yield (ZMWs) Percentage by Productivity"])
  )

  report$ggsave(
    "readTypeAgg.1.png",
    tp + labs(title = "readTypeAgg.1"),
    width = plotwidth,
    height = plotheight,
    id = "readTypeAgg.1",
    title = "readTypeAgg.1",
    caption = "readTypeAgg.1",
    tags = c("sts",
             "h5",
             "agg",
             "readTypeAgg.1",
             "readtype",
             "missing"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "readTypeAgg.1"])
  )

  report$ggsave(
    "readTypeAgg.2.png",
    tp + labs(title = "readTypeAgg.2"),
    width = plotwidth,
    height = plotheight,
    id = "readTypeAgg.2",
    title = "readTypeAgg.2",
    caption = "readTypeAgg.2",
    tags = c("sts",
             "h5",
             "agg",
             "readTypeAgg.2",
             "readtype",
             "missing"),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "readTypeAgg.2"])
  )
}

makeEmptyXMLPlots <- function(report) {
  df <- data.frame()
  tp = ggplot(df) + geom_point() + xlim(0, 10) + ylim(0, 10) + plTheme +
    annotate(
      geom = "text",
      x = 5,
      y = 5,
      label = 'Missing sts.xml',
      color = 'red',
      angle = 45,
      fontface = 'bold',
      size = 14,
      alpha = 0.5,
      family = 'Arial'
    )

  report$ggsave(
    "adapter_dimer_fraction.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "adapter_dimer_fraction",
    title = "Adapter Dimer Fraction by Condition",
    caption = "Adapter Dimer Fraction by Condition",
    tags = c(
      "sts",
      "xml",
      "histogram",
      "adapter",
      "zmws",
      "fraction",
      "missing"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Adapter Dimer Fraction by Condition"])
  )

  report$ggsave(
    "short_insert_fraction.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "short_insert_fraction",
    title = "Short Insert Fraction by Condition",
    caption = "Short Insert Fraction by Condition",
    tags = c(
      "sts",
      "xml",
      "histogram",
      "shortinsert",
      "zmws",
      "fraction",
      "missing"
    ),
    uid = as.vector(uid_table$uid_column[uid_table$plot_names == "Short Insert Fraction by Condition"])
  )
}

makeSTSH5Heatmaps <- function(report, conditions) {
  MAXINT <<- 2 ^ 16
  N = c(8, 8)
  dist = getDistMat(N, key = 1e3)

  try(lapply(1:nrow(conditions), function(k)
    generateStsH5Heatmaps(report, conditions$sts_h5[k], conditions$Condition[k], N, dist)), silent = FALSE)
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  conditions = report$condition.table
  ## Let's set the graphic defaults
  n = length(levels(conditions$Condition))
  clFillScale <<- getPBFillScale(n)
  clScale <<- getPBColorScale(n)

  # Check if sts.h5 file exist
  conditions$STS = paste("./conditions/", conditions$Condition, "/sts.h5", sep = "")
  stsExist = TRUE
  for (i in 1:length(conditions$STS)) {
    if (file.info(conditions$STS[i])$size == 0) {
      stsExist = FALSE
    }
  }

  # Check if sts.xml file exist
  conditions$STSXML = paste("./conditions/", conditions$Condition, "/sts.xml", sep = "")
  stsXMLExist = TRUE
  for (i in 1:length(conditions$STSXML)) {
    if (file.info(conditions$STSXML[i])$size == 0) {
      stsXMLExist = FALSE
    }
  }

  if (stsExist) {
    # Load the sts.h5 file for each data frame
    dfsH5 = lapply(as.character(unique(conditions$STS)), function(s) {
      loginfo(paste("Loading sts.h5 file:", s))
      loadstsH5(s)
    })
    cdH5 = combineConditions(dfsH5, as.character(conditions$Condition))

    # Make BaselineLevel plots
    BaselineLevel = cdH5[, .(Condition, hole, BaselineLevel_Green, BaselineLevel_Red)]
    colnames(BaselineLevel) = sub("BaselineLevel_", "", colnames(BaselineLevel))
    BaselineLevel = BaselineLevel %>% gather(channel, BaselineLevel, Green, Red)

    tp = ggplot(BaselineLevel, aes(x = Condition, y = BaselineLevel, fill = Condition)) +
      ylim(quantile(BaselineLevel$BaselineLevel, 0.05, na.rm = T), quantile(BaselineLevel$BaselineLevel, 0.95, na.rm = T)) +
      geom_boxplot() + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) + plTheme + themeTilt  + clFillScale +
      facet_wrap( ~ channel, nrow = length(levels(as.factor(BaselineLevel$channel))))
    report$ggsave(
      "BaselineLevelBoxNoViolin.png",
      tp,
      width = plotwidth,
      height = plotheight * 2,
      id = "baselinelevel_boxplot",
      title = "BaselineLevel Box Plot",
      caption = "Distribution of BaselineLevel(Boxplot)",
      tags = c("sampled", "baselinelevel", "boxplot"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "BaselineLevel Box Plot"])
    )

    tp = ggplot(BaselineLevel, aes(x = BaselineLevel, colour = Condition)) + geom_density(alpha = .5) +
      xlim(quantile(BaselineLevel$BaselineLevel, 0.05, na.rm = T), quantile(BaselineLevel$BaselineLevel, 0.95, na.rm = T)) +
      plTheme + themeTilt  + clScale + facet_wrap(~ channel, nrow = length(levels(as.factor(BaselineLevel$channel)))) +
      labs(x = "BaselineLevel", title = "Distribution of BaselineLevel (Density plot)")
    report$ggsave(
      "BaselineLevelDensity.png",
      tp,
      width = plotwidth,
      height = plotheight * 2,
      id = "baselinelevel_density",
      title = "BaselineLevel Density Plot",
      caption = "Distribution of BaselineLevel (Density plot)",
      tags = c("sampled", "baselinelevel", "density"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "BaselineLevel Density Plot"])
    )

    tp = ggplot(BaselineLevel, aes(x = BaselineLevel, colour = Condition)) + stat_ecdf() +
      xlim(quantile(BaselineLevel$BaselineLevel, 0.05, na.rm = T), quantile(BaselineLevel$BaselineLevel, 0.95, na.rm = T)) +
      plTheme + themeTilt  + clScale + facet_wrap(~ channel, nrow = length(levels(as.factor(BaselineLevel$channel)))) +
      labs(x = "BaselineLevel", title = "Distribution of BaselineLevel (CDF)")
    report$ggsave(
      "BaselineLevelCDF.png",
      tp,
      width = plotwidth,
      height = plotheight * 2,
      id = "baselinelevel_CDF",
      title = "BaselineLevel CDF Plot",
      caption = "Distribution of BaselineLevel (CDF)",
      tags = c("sampled", "baselinelevel", "cdf"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "BaselineLevel CDF Plot"])
    )

    tp = ggplot(BaselineLevel, aes(x = BaselineLevel, colour = Condition)) + stat_ecdf(aes(colour = Condition)) +
      scale_x_log10(limits = c(quantile(BaselineLevel$BaselineLevel, 0.05, na.rm = T), quantile(BaselineLevel$BaselineLevel, 0.95, na.rm = T))) +
      plTheme + themeTilt  + clScale + facet_wrap(~ channel, nrow = length(levels(as.factor(BaselineLevel$channel)))) +
      labs(x = "BaselineLevel", title = "Distribution of BaselineLevel (Log-scale CDF)")
    report$ggsave(
      "BaselineLevelCDFlog.png",
      tp,
      width = plotwidth,
      height = plotheight * 2,
      id = "baselinelevel_CDFlog",
      title = "BaselineLevel CDF Plot (Log-scale)",
      caption = "Distribution of BaselineLevel (Log-scale CDF)",
      tags = c("sampled", "baselinelevel", "cdf", "log"),
      uid = as.vector(uid_table$uid_column[uid_table$plot_names == "BaselineLevel CDF Plot (Log-scale)"])
    )

    # Make Read Type and Productivity as factor
    cdH5$readType = as.factor(cdH5$readType)
    levels(cdH5$readType) <-
      list(
        "Empty" = "0",
        "FullHqRead0" = "1",
        "FullHqRead1" = "2",
        "PartialHqRead0" = "3",
        "PartialHqRead1" = "4",
        "PartialHqRead2" = "5",
        "Multiload" = "6",
        "Indeterminate" = "7"
      )
    cdH5$productivity = as.factor(cdH5$productivity)
    levels(cdH5$productivity) <-
      list(
        "Empty" = "0",
        "Productive_HQ_Region" = "1",
        "Other" = "2"
      )

    # Load the pbi index for each data frame
    dfs = lapply(as.character(unique(conditions$MappedSubreads)), function(s) {
      loginfo(paste("Loading alignment set:", s))
      loadPBI2(s)
    })
    # Filter out empty data sets, throw a warning if any empty ones exist
    filteredData = filterEmptyDataset(dfs, conditions)
    if (length(filteredData) == 0) {
      warning("All conditions are empty!")
    } else {
      dfs  = filteredData[[1]]
      conditions = filteredData[[2]]

      cd = combineConditions(dfs, as.character(conditions$Condition))

      # Now combine into one large data frame
      cd2 = left_join(cd, cdH5, by = c("hole", "Condition"))
      cd2$tlen = cd2$tend - cd2$tstart

      # Make Plots
      try(makeReadTypePlots(report, cd2), silent = TRUE)
      try(makeYieldPlots(report, cdH5), silent = TRUE)

      # Make sts.h5 heatmaps
      try(makeSTSH5Heatmaps(report, conditions), silent = TRUE)
    }
  } else {
    warning("sts.h5 file does not exsit for at least one condition!")
    try(makeEmptyPlots(report), silent = TRUE)
  }

  if (stsXMLExist) {
    # Load the sts.xml file for each data frame
    dfsXML = lapply(as.character(conditions$STSXML), function(s) {
      loginfo(paste("Loading sts.h5 file:", s))
      loadstsXML(s)
    })
    cdXML = combineConditions(dfsXML, as.character(conditions$Condition))
    try(makestsXMLPlots(report, cdXML), silent = TRUE)
  } else {
    warning("sts.xml file does not exsit for at least one condition!")
    makeEmptyXMLPlots(report)
  }
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter("condition-table.csv",
                        "reports/ZMWstsPlots/report.json",
                        "ZMW STS Plots")
  makeReport(report)
  jsonFile = "reports/ZMWstsPlots/report.json"
  uidTagCSV = "reports/uidTag.csv"

  # Assert all plots are indexed in the confluence plot index
  # When run loca test, we suggest to delete "try" to get the error warnings
  try(PlotIDinIndex(jsonFile, uidTagCSV))
  
  # TODO: currently we don't rewrite the json report since the uid is not added to the heatmaps yet
  # try(rewriteJSON(jsonFile, uidTagCSV), silent = TRUE)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
