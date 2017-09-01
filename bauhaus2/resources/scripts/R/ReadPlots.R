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

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

#' Define a basic addition to all plots
plTheme <- theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
themeTilt = theme(axis.text.x = element_text(angle = 90, hjust = 1))
plotwidth = 7.2
plotheight = 4.2

# These are "global" and do change state at certain points ( <<- is called later on)
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")


makeGapSizePlots <- function(report, cd) {
  loginfo("Making Gap Size Plots")
  gaps = cd[["gapSizes"]]
  
  
  # Convert to relative frequencies
  gapf = gaps %>% group_by(Condition) %>% mutate(refFreq = refCnts / sum(refCnts),
                                                 readFreq = readCnts / sum(readCnts)) %>% ungroup()
  
  if (sum(gapf$refCnts) == 0) {
    warning("The sum of reference Counts cannot be 0!")
  } else {
    ## Plot Deletion Sizes
    loginfo("Plot Deletion Sizes")
    tp = ggplot(gapf, aes(x=gapSize, y = refFreq, group=Condition, color=Condition)) + geom_line() + geom_point() +
      clScale + plTheme + labs(x="Deletion Size", y="Relative Frequency (Sum = 1)",
                               title = "Deletion Sizes")
    report$ggsave(
      "deletion_norm.png",
      tp,
      width = plotwidth,
      height = plotheight,
      id = "deletion_norm",
      title = "Deletion Sizes",
      caption = "Deletion Sizes",
      tags = c("readplots", "deletion")
    )
    
    loginfo("Plot log Deletion Sizes")
    report$ggsave(
      "deletion_size_log.png",
      tp + scale_y_log10() + labs(y = "Log10 Relative Frequency"),
      width = plotwidth,
      height = plotheight,
      id = "deletion_size_log",
      title = "Deletion Sizes (Log)",
      caption = "Deletion Sizes (Log)",
      tags = c("readplots", "deletion", "log")
    )
  }
  
  if (sum(gapf$readCnts) == 0) {
    warning("The sum of read Counts cannot be 0!")
  } else {
    ## Now plot insertion sizes
    loginfo("Plot insertion sizes")
    tp = ggplot(gapf, aes(x=gapSize, y = readFreq, group=Condition, color=Condition)) + geom_line() + geom_point() +
      clScale + plTheme + labs(x="Insertion Size", y="Relative Frequency (Sum = 1)",
                               title = "Insertion Sizes")
    report$ggsave(
      "insert_size_norm.png",
      tp,
      width = plotwidth,
      height = plotheight,
      id = "insert_size_norm",
      title = "Insertion Sizes",
      caption = "Insertion Sizes",
      tags = c("readplots", "insertion")
    )
    
    loginfo("Plot log insertion sizes")
    report$ggsave(
      "insert_size_log.png",
      tp + scale_y_log10() + labs(y = "Log10 Relative Frequency"),
      width = plotwidth,
      height = plotheight,
      id = "insert_size_log",
      title = "Insertion Sizes (Log)",
      caption = "Insertion Sizes (Log)",
      tags = c("readplots", "insertion", "log")
    )
  }
}

makeMismatchPlots <- function(report, cd) {
  loginfo("Making Mismatch Plots")
  mm = cd[["mismatches"]]
  
  # Remove uninteresting rows
  mm = mm[mm$ref != mm$read &
            mm$ref != "N" & mm$ref != "-" &
            mm$read!= "N" & mm$read != "-",]
  
  # Convert to relative frequencies
  mmf = mm %>% group_by(Condition) %>% mutate(freq = cnts / sum(cnts)) %>% ungroup()
  mmf$Error = mmf$ref:mmf$read
  
  tp = ggplot(mmf, aes(x=Error, y=freq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
    clFillScale + plTheme + labs(x="Ref:Read", y="Relative Frequency (Sum = 1)",
                                 title = "Mismatch Frequencies")
  report$ggsave(
    "mismatch_rate.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "mismatch_rate",
    title = "Mismatch Rates",
    caption = "Mismatch Rates",
    tags = c("readplots", "mismatch")
  )
}

makeIndelPlots <- function(report, cd) {
  loginfo("Making Indel Plots")
  ind = cd[["indelCnts"]]
  
  # Remove uninteresting rows
  ind = ind[ind$bp != "-" & ind$bp != "N",]
  # Convert to relative frequencies
  indf = ind %>% group_by(Condition) %>% mutate(delFreq = delFromRefCnt / sum(delFromRefCnt),
                                                insFreq = insertIntoReadCnt / sum(insertIntoReadCnt)) %>% ungroup()
  
  tp = ggplot(indf, aes(x=bp, y = delFreq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
    clFillScale + plTheme + labs(x="Deleted Base", y="Relative Frequency (Sum = 1)",
                                 title = "Deletion Frequencies")
  report$ggsave(
    "deletion_rate.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "deletion_rate",
    title = "Deletion Rates",
    caption = "Deletion Rates",
    tags = c("readplots", "deletion")
  )
  
  loginfo("Make Insertion Rates Plot")
  tp = ggplot(indf, aes(x=bp, y = insFreq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
    clFillScale + plTheme + labs(x="Inserted Base", y="Relative Frequency (Sum = 1)",
                                 title = "Insertion Frequencies")
  report$ggsave(
    "insertion_rate.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "insertion_rate",
    title = "Insertion Rates",
    caption = "Insertion Rates",
    tags = c("readplots", "insertion")
  )
}

makeClippingPlot <- function(report, cd) {
  loginfo("Making Clipping Plots")
  clips = cd[["clipping"]]
  
  # Convert to relative frequencies
  clipsf = clips %>% group_by(Condition) %>% mutate(freq = cnts / sum(cnts)) %>% ungroup()
  
  if (sum(clipsf$cnts) == 0) {
    warning("The sum of Counts for cliping cannot be 0!")
  } else {
    tp = ggplot(clipsf[clipsf$state=="Clipped", ], aes(x=Condition, y=freq, fill=Condition)) + geom_bar(stat="identity") +
      clFillScale + plTheme + labs(x="Condition", y="Soft Clipping Frequency", title = "Percentage of Bases Soft Clipped in Alignments") +
      themeTilt
    report$ggsave(
      "clip_rate.png",
      tp,
      width = plotwidth,
      height = plotheight,
      id = "clip_rate",
      title = "Clipping Rates",
      caption = "Clipping Rates",
      tags = c("readplots", "clipping")
    )
  }
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  
  conditions = report$condition.table
  
  ## Let's set the graphic defaults
  n = length(levels(conditions$Condition))
  clFillScale <<- getPBFillScale(n)
  clScale <<- getPBColorScale(n)
  
  # Load the read error rates for each dataset
  dfs = lapply(1:nrow(conditions), function(i) {
    alnFile = as.character(conditions$MappedSubreads[i])
    fasta = as.character(conditions$Reference[i])
    loginfo(paste("Loading alignment set:", alnFile))
    pbbamr::getReadReport(datasetname = alnFile, indexedFastaName = fasta )
  })
  
  loginfo("Finished loading aligned read data.")
  # Now combine into one large data frame
  # TODO: I hate using indexing here, perhaps another solution?
  cd = lapply(1:length(dfs[[1]]), function(i) {
    mats = lapply(dfs, function(d) d[[i]])
    combineConditions(mats, as.character(conditions$Condition))
  })
  names(cd) <- names(dfs[[1]])
  
  # Convert the integers in cd to numeric values to get rid of "integer overflow" caused by the integer maximum limit in R
  cd$mismatches$cnts = as.numeric(cd$mismatches$cnts)
  cd$gapSizes$refCnts = as.numeric(cd$gapSizes$refCnts)
  cd$gapSizes$readCnts = as.numeric(cd$gapSizes$readCnts)
  cd$indelCnts$delFromRefCnt = as.numeric(cd$indelCnts$delFromRefCnt)
  cd$indelCnts$insertIntoReadCnt = as.numeric(cd$indelCnts$insertIntoReadCnt)
  cd$clipping$cnts = as.numeric(cd$clipping$cnts)
  
  # Make Plots
  makeMismatchPlots(report, cd)
  makeGapSizePlots(report, cd)
  makeIndelPlots(report, cd)
  makeClippingPlot(report, cd)
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}


main <- function()
{
  report <- bh2Reporter(
    "condition-table.csv",
    "reports/ReadPlots/report.json",
    "All ZMW Cauculated Matrices")
  makeReport(report)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
