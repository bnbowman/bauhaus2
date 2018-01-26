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

# Define a basic addition to all plots
midTitle <- theme(plot.title = element_text(hjust = 0.5))
plTheme <-
  theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))
plotwidth = 7.2
plotheight = 4.2

makeBurstLengthPlots <- function(report, cd) {
  loginfo("Log of Burst Length Histogram Plots")
  tp = ggplot(cd, aes(x = burstLength, colour = Condition)) + geom_freqpoly(data=subset(cd,Condition=='5k_tetraloop'),aes(y=..count../sum(..count..)), binwidth=0.14, fill = 'white')  +
    geom_freqpoly(data=subset(cd,Condition=='6k_tetraloop'),aes(y=..count../sum(..count..)),binwidth=0.14, fill = 'white') +
    plTheme + clScale + themeTilt +
    labs(y = "Burst Length Histogram", title = "Burst Length Histogram", x = "Burst Length") + scale_x_log10(breaks = 10 ^
                                                                                                               (0:5))
  report$ggsave(
    "logburstlength.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_length",
    title = "Burst Length",
    caption = "Burst Length",
    tags = c("basic", "burst", "length"),
    uid = "6000000"
  )
  cd_H = cd %>% filter(seqType == 'H')
  tp = ggplot(cd_H, aes(x = burstLength, colour = Condition)) + geom_freqpoly(data=subset(cd_H,Condition=='5k_tetraloop'),aes(y=..count../sum(..count..)), binwidth=0.14, fill = 'white')  +
    geom_freqpoly(data=subset(cd_H,Condition=='6k_tetraloop'),aes(y=..count../sum(..count..)),binwidth=0.14, fill = 'white') +
    plTheme + clScale + themeTilt +
    labs(y = "Burst Length Histogram with H", title = "Burst Length Histogram with H", x = "Burst Length with H") + scale_x_log10(breaks = 10^(0:5))
  report$ggsave(
    "logburstlength_H.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_length_H",
    title = "Burst Length H",
    caption = "Burst Length H",
    tags = c("basic", "burst", "length_h"),
    uid = "6000001"
  )
  
  cd_noH = cd %>% filter(seqType != 'H')
  tp = ggplot(cd_noH, aes(x = burstLength, colour = Condition)) + geom_freqpoly(data=subset(cd_H,Condition=='5k_tetraloop'),aes(y=..count../sum(..count..)), binwidth=0.14, fill = 'white')  +
    geom_freqpoly(data=subset(cd_H,Condition=='6k_tetraloop'),aes(y=..count../sum(..count..)),binwidth=0.14, fill = 'white') +
    plTheme + clScale + themeTilt +
    labs(y = "Burst Length Histogram with no H", title = "Burst Length Histogram with no H", x = "Burst Length with no H") + scale_x_log10(breaks = 10^(0:5))
  report$ggsave(
    "logburstlength_noH.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_length_noH",
    title = "Burst Length No H",
    caption = "Burst Length No H",
    tags = c("basic", "burst", "length_noh"),
    uid = "6000002"
  )
}

makeBurstDurationPlots <- function(report, cd) {
  loginfo("Log of Burst Duration Histogram Plots")
  cd$burstDuration = cd$burstEndTime - cd$burstStartTime
 # tp = ggplot(cd, aes(x = burstDuration, colour = Condition)) + geom_freqpoly(data=subset(cd,Condition=='5k_tetraloop'),aes(y=..count../sum(..count..)), binwidth=0.14, fill = 'white')  +
  #  geom_freqpoly(data=subset(cd,Condition=='6k_tetraloop'),aes(y=..count../sum(..count..)),binwidth=0.14, fill = 'white') +
   # plTheme + clScale + themeTilt +
    #labs(y = "Burst Duration CDF", title = "Burst Duration CDF", x = "Burst Duration") + scale_x_log10(breaks = 10 ^
  tp = ggplot(cd, aes(x = burstDuration, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ labs(y = "Burst Duration CDF", title = "Burst Duration CDF", x = "Burst Duration")
  report$ggsave(
    "logburstduration.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_duration",
    title = "Burst Duration",
    caption = "Burst Duration",
    tags = c("basic", "burst", "duration"),
    uid = "6000003"
  )
  cd_H = cd %>% filter(seqType == 'H')
  tp = ggplot(cd_H, aes(x = burstDuration, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ labs(y = "Burst Duration with H CDF", title = "Burst Duration with H CDF", x = "Burst Duration")
  report$ggsave(
    "logburstduration_H.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_duration_H",
    title = "Burst Duration H",
    caption = "Burst Duration H",
    tags = c("basic", "burst", "length_h"),
    uid = "6000004"
  )
  
  cd_noH = cd %>% filter(seqType != 'H')
  tp = ggplot(cd_noH, aes(x = burstDuration, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ labs(y = "Burst Duration with no H CDF", title = "Burst Duration with no H CDF", x = "Burst Duration")
  report$ggsave(
    "logburstduration_noH.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "burst_duration_noH",
    title = "Burst Duration No H",
    caption = "Burst Duration No H",
    tags = c("basic", "burst", "length_noh"),
    uid = "6000005"
  )
}

makeCumSumBurstLength <- function(report, cd) {
  loginfo("Making Bases Data Distribution")
  cd_H = cd %>% filter(seqType == 'H')
  res = cd_H %>% group_by(Condition, zmw, qStart) %>% summarise(cumlen = sum(burstLength))
  tp = ggplot(cd,
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
  conditions = report$condition.table
  # Load the pbi index for each data frame
  #cd = read.csv("conditions/5k_tetraloop/subreads/ppa_burst_metrics.csv")

  dfs = lapply(as.character(conditions$Condition), function(s) {
    string0 = paste("conditions/",s,"/subreads/ppa_burst_metrics.csv", sep ="")
    read.csv(string0)
  })
    
    # Now combine into one large data frame
    cd = combineConditions(dfs, as.character(conditions$Condition))
    #for testing purposes
    cd2 = cd[1:1000,]
    cd3 = cd[1001:1600,]
    cd3$Condition = NULL
    cd3$Condition = "6k_tetraloop"
    cd = rbind(cd2, cd3)
    cd$Condition = as.factor(cd$Condition)
    
    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)
    
    cd$logburstlength = log(cd$burstLength)
    
   
    # Make Plots
    try(makeReadLengthSurvivalPlots(report, cd), silent = TRUE)
    
  }
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()


main <- function()
{
  report <- bh2Reporter("condition-table.csv",
                        "reports/BurstPlots/report.json",
                        "Burst Plots")
  makeReport(report)
  jsonFile = "reports/BurstPlots/report.json"
  uidTagCSV = "reports/uidTag.csv"
  rewriteJSON(jsonFile, uidTagCSV)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()