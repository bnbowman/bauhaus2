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
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(survival)
library(ggfortify)
library(rhdf5)

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

loadstsH5 <- function(stsH5file) {
  stsH5 = data.frame(
    hole = h5read(stsH5file, "/ZMW/HoleNumber"),
    readType = h5read(stsH5file, "/ZMWMetrics/ReadType"),
    productivity = h5read(stsH5file, "/ZMWMetrics/Productivity")
  )
  stsH5
}

makeReadTypePlots <- function(report, cd2) {
  loginfo("Making Read Type Plots")
  
  cdunrolled = cd2 %>% group_by(Condition, hole, readType, productivity) %>% summarise(unrolledT = sum(tlen), accuracy = 1 - (sum(mismatches) + sum(dels) + sum(inserts)) / sum(tlen))
  
  tp <-
    ggplot(data = cdunrolled, aes(
      x = readType,
      y = unrolledT,
      fill = Condition
    )) +
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
    tags = c(
      "sts",
      "h5",
      "boxplot",
      "unrolled",
      "template",
      "readtype"
    )
  )
  
  tp <-
    ggplot(data = cdunrolled, aes(
      x = readType,
      y = accuracy,
      fill = Condition
    )) +
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
    tags = c(
      "sts",
      "h5",
      "boxplot",
      "accuracy",
      "readtype"
    )
  )
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
    tags = c(
      "sts",
      "h5",
      "histogram",
      "readtype",
      "zmws",
      "percentage"
    )
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
    )
  )
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  conditions = report$condition.table
  
  # Check if sts.h5 file exist
  conditions$STS = paste("./conditions/", conditions$Condition, "/sts.h5", sep = "")
  stsExist = TRUE
  for (i in 1:length(conditions$STS)) {
    if (file.info(conditions$STS[i])$size == 0) {
      stsExist = FALSE
    }
  }
  
  if (stsExist) {
    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)
    
    # Load the sts.h5 file for each data frame
    dfsH5 = lapply(as.character(unique(conditions$STS)), function(s) {
      loginfo(paste("Loading sts.h5 file:", s))
      loadstsH5(s)
    })
    cdH5 = combineConditions(dfsH5, as.character(conditions$Condition))
    
    # Make Read Type and Productivity as factor
    cdH5$readType = as.factor(cdH5$readType)
    levels(cdH5$readType) <- list("Empty" = "0", "FullHqRead0" = "1", "FullHqRead1" = "2", "PartialHqRead0" = "3", "PartialHqRead1" = "4", "PartialHqRead2" = "5", "Multiload" = "6", "Indeterminate" = "7")
    cdH5$productivity = as.factor(cdH5$productivity)
    levels(cdH5$productivity) <- list("Empty" = "0", "Productive_HQ_Region" = "1", "Other" = "2")
    
    # Load the pbi index for each data frame
    dfs = lapply(as.character(unique(conditions$MappedSubreads)), function(s) {
      loginfo(paste("Loading alignment set:", s))
      loadPBI2(s)
    })
    cd = combineConditions(dfs, as.character(conditions$Condition))
    
    length(unique(cdH5$hole))
    length(unique(cd$hole))
    length(intersect(unique(cdH5$hole), unique(cd$hole)))
    
    # Now combine into one large data frame
    cd2 = left_join(cd, cdH5, by = c("hole", "Condition"))
    cd2$tlen = cd2$tend - cd2$tstart
    
    # Make Plots
    makeReadTypePlots(report, cd2)
    makeYieldPlots(report, cdH5)
    
  } else {
    warning("sts.h5 file does not exsit for at least one condition!")
  }
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter(
    "condition-table.csv",
    "reports/ZMWstsPlots/report.json",
    "ZMW STS Plots"
  )
  makeReport(report)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()