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
midTitle <- theme(plot.title = element_text(hjust = 0.5, size = 8))
plTheme <-
  theme_bw(base_size = 14) + theme(legend.text = element_text(size=8), legend.title = element_text(size=8), plot.title = element_text(hjust = 0.5, size = 8), 
                                   axis.title=element_text(size=8), axis.text=element_text(size=8))
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 8))
plotwidth = 4.2
plotheight = 7.2

labels <- function (cd){
  labels=""
  if (comment(cd)=="cd") {return (labels="all bursts")}
  if (comment(cd) == "cd_H") {return (labels = "HQ")}
  if (comment(cd) == "cd_noH") {return (labels = "LQ")}
}

#working 
makeBurstLengthPlots <- function(report,cd,cd_H, cd_noH) {
  loginfo("Log of Burst Length Plots")
  label = labels(cd)
  label = paste("Burst_Length_CDF", label, sep = "_")
  tp2 = ggplot(cd, aes(x = burstLength, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ 
    labs(y = "Burst Length CDF", title = label, x = "Burst Length (pulses)")
  label2 = labels(cd_H)
  label2 = paste("Burst_Length_CDF", label2, sep = "_")
  tp3 = ggplot(cd_H, aes(x = burstLength, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ 
    labs(y = "Burst Length CDF", title = label2, x = "Burst Length (pulses)")
  label3 = labels(cd_noH)
  label3 = paste("Burst_Length_CDF", label3, sep = "_")
  tp4 = ggplot(cd_noH, aes(x = burstLength, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ 
    labs(y = "Burst Length CDF", title = label3, x = "Burst Length (pulses)")
  tp5 = grid.arrange(tp2, tp3, tp4, ncol=1)
  report$ggsave(
    "BurstLength_CDF",
    tp5,
    width = plotwidth,
    height = plotheight,
    id = "BurstLength_CDF",
    title = "BurstLength_CDF",
    caption = "BurstLength_CDF",
    tags = c("basic", "burst", "length"),
    uid = "0080000"
  )
}
makeBurstDurationPlots <- function(report,cd,cd_H, cd_noH) {
  loginfo("Log of Burst Duration Plots")
  label = labels(cd)
  label = paste("Burst_Duration_CDF", label, sep = "_")
  cd$burstDuration = cd$burstEndTime - cd$burstStartTime
  tp1 = ggplot(cd, aes(x = burstDuration, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ labs(y = "Burst Duration CDF", title = label, x = "Burst Duration (minutes)")
  label2 = labels(cd_H)
  label2 = paste("Burst_Duration_CDF", label2, sep = "_")
  cd_H$burstDuration = cd_H$burstEndTime - cd_H$burstStartTime
  tp2 = ggplot(cd_H, aes(x = burstDuration, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ 
    labs(y = "Burst Duration CDF", title = label2, x = "Burst Duration (minutes)")
  label3 = labels(cd_noH)
  label3 = paste("Burst_Duration_CDF", label3, sep = "_")
  cd_noH$burstDuration = cd_noH$burstEndTime - cd_noH$burstStartTime
  tp3 = ggplot(cd_noH, aes(x = burstLength, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ scale_x_log10(breaks = 10^(0:8))+ 
    labs(y = "Burst Duration CDF", title = label3, x = "Burst Duration (minutes)")
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  report$ggsave(
    "Burst_Duration_CDF.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "Burst_Duration_CDF",
    title = "Burst_Duration_CDF",
    caption = "Burst_Duration_CDF",
    tags = c("basic", "burst", "duration"),
    uid = "0080001"
  )
}
makeCumSumBurstLength <- function(report,cd_H) {
  loginfo("Making Bases Data Distribution")
  #cd_H = cd %>% filter(seqType == 'H')
  res = cd_H %>% group_by(Condition, zmw, qStart) %>% summarise(cumlen = sum(burstLength))
  tp = ggplot(res, aes(x = cumlen, colour = Condition)) + stat_ecdf() +
    plTheme + clScale + themeTilt + scale_x_log10(breaks = 10 ^ (0:8)) + labs(y = "CDF", title = "Cumulative burst length per subread CDF (pulses)", x = "Cumulative burst length per subread")
  report$ggsave(
    "cumsum_burst_length.png",
    tp,
    width = plotheight,
    height = plotwidth,
    id = "cumsum_burst_length",
    title = "Cumulative burst length per subread CDF",
    caption = "Cumulative burst length per subread CDF",
    tags = c("basic", "burstplots", "cdf", "cumsum"),
    uid = "0080002"
  )
}
makeCumSumBurstDuration <- function(report,cd_H) {
  loginfo("Making Burst Duration Sum Plots")
  #cd_H = cd %>% filter(seqType == 'H')
  cd_H$burstDuration = cd_H$burstEndTime - cd_H$burstStartTime
  res = cd_H %>% group_by(Condition, zmw, qStart) %>% summarise(cumlen = sum(burstDuration))
  tp = ggplot(res, aes(x = cumlen, colour = Condition)) + stat_ecdf() +
    plTheme + clScale + themeTilt + scale_x_log10(breaks = 10 ^ (0:8)) + labs(y = "CDF", title = "Cumulative Burst Duration Per Subread CDF (pulses)", x = "Cumulative burst duration per subread")
  report$ggsave(
    "cumsum_burst_duration.png",
    tp,
    width = plotheight,
    height = plotwidth,
    id = "cumsum_burst_duration",
    title = "Cumulative burst duration per subread CDF",
    caption = "Cumulative burst duration per subread CDF",
    tags = c("basic", "burstplots", "cdf", "cumsum"),
    uid = "0080003"
  )
}

makeBurstStartPlots <- function(report,cd,cd_H, cd_noH) {
  loginfo("Log of Burst Starttime CDF Plots")  
  label = labels(cd)
  label = paste("Burst_Starttime_CDF", label, sep = "_")
  tp1 = ggplot(cd, aes(x = burstStartTime, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ labs(y = "Burst Start Time CDF", title = label, x = "Burst Start Time (minutes)")
  label2 = labels(cd_H)
  label2 = paste("Burst_Starttime_CDF", label2, sep = "_")
  tp2 = ggplot(cd_H, aes(x = burstStartTime, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ 
    labs(y = "Burst Start Time CDF", title = label2, x = "Burst Start Time (minutes)")
  label3 = labels(cd_noH)
  label3 = paste("Burst_Duration_CDF", label3, sep = "_")
  tp3 = ggplot(cd_noH, aes(x = burstStartTime, colour = Condition)) + stat_ecdf()+plTheme + clScale + themeTilt+ 
    labs(y = "Burst Start Time CDF", title = label3, x = "Burst Start Time (minutes)")
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  report$ggsave(
    "log_burst_starttime.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "burst_start_time",
    title = "Burst Start Time CDF",
    caption = "Burst Start Time",
    tags = c("basic", "burst", "starttime"),
    uid = "0080004"
  )
}

makePreviousBaseCount <- function(cd){
  loginfo("Making Preivous Base Bar Charts")
  levels(cd$previousBasecall) = c("A", "G", "C", "T", "Z", "None")
  cd$previousBasecall[cd$previousBasecall == 'Z'] = 'None'
  label = labels(cd)
  label = paste("Previous_Base_Count", label, sep = "_")
  tp = ggplot(cd, aes(previousBasecall, fill = Condition)) + geom_bar(position = "dodge") + plTheme + themeTilt  + clFillScale +
    labs(x = "Bases", y = "Count", title = label)
  return(tp)
}
makePreviousBaseCountAll <- function(report,cd,cd_H, cd_noH){
  tp1 = makePreviousBaseCount(cd)
  tp2 = makePreviousBaseCount(cd_H)
  tp3 = makePreviousBaseCount(cd_noH)
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  report$ggsave(
    "previous_basecall_count.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "PreviousBaseCall_by_Condition",
    title = "PreviousBaseCall by Condition",
    caption = "PreviousBaseCall by Condition",
    tags = c("basic", "burstplots", "barplot", "previousbase"),
    uid = "0080005"
  )
}

makePreviousBaseFreq <- function(cd){
  loginfo("Making Preivous Base Bar Charts")
  levels(cd$previousBasecall) = c("A", "G", "C", "T", "Z", "None")
  cd$previousBasecall[cd$previousBasecall == 'Z'] = 'None'
  label = labels(cd)
  label = paste("Previous_Base_Count", label, sep = "_")
  transcd2 = cd %>% group_by(Condition, previousBasecall)%>%summarise (n = n()) %>% mutate(freq = n / sum(n))
  tp2 = ggplot(transcd2, aes(x = previousBasecall, y = freq, fill = Condition)) + geom_bar(stat =
                                                                                             "identity", position = "dodge") +
    clFillScale + plTheme + labs(x = "Previous Basecall", y = "Relative Frequency (Sum = 1)",
                                 title = label)
  return(tp2)
}
makePreviousBaseFreqAll <- function(report,cd,cd_H, cd_noH){
  tp1 = makePreviousBaseFreq(cd)
  tp2 = makePreviousBaseFreq(cd_H)
  tp3 = makePreviousBaseFreq(cd_noH)
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  report$ggsave(
    "previousbasecallfreq.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "PreviousBaseCall_freq_by_Condition",
    title = "Previous Basecall Frequencies",
    caption = "Previous Basecall Frequencies",
    tags = c("basic", "burstplots", "barplot", "freq"),
    uid = "00800011"
  )
}
makefractionBaseType <- function(cd, freq) {
  loginfo("Making Fraction Base Bar Charts")
  label = labels(cd)
  label1 = paste("Burst Types", label, sep = "_")
  cd$typeBurst = 'Other'
  cd$typeBurst[cd$fractionC > .5] = 'C'
  cd$typeBurst[cd$fractionA > .5] = 'A'
  cd$typeBurst[cd$fractionG > .5] = 'G'
  cd$typeBurst[cd$fractionT > .5] = 'T'
  levels(cd$typeBurst) = c("A", "G", "C", "T", "Other")
  transcd = cd %>% group_by(Condition, typeBurst)%>%summarise (n = n()) %>% mutate(freq = n / sum(n))
  transcd = subset(transcd, typeBurst != 'Other')
  tp1 = ggplot(transcd, aes(x = typeBurst, y = freq, fill = Condition)) + geom_bar(stat =
                                                                                     "identity", position = "dodge") +
    clFillScale + plTheme + labs(x = "Type Burst", y = "Frequency",
                                 title = label1)
  tp2 = ggplot(transcd, aes(x = typeBurst, y = n, fill = Condition)) + geom_bar(stat =
                                                                                     "identity", position = "dodge") +
    clFillScale + plTheme + labs(x = "Type Burst", y = "Count",
                                 title = label1)
  if (freq == "freq"){
     return(tp1)
  } else{
    return(tp1)}
}
makefractionBaseforAll <- function(report,cd,cd_H, cd_noH){
 if( nrow(cd) == 0 ){ 
   tp4 = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Base Fraction Frequencies")
   tp4c = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Base Fraction Frequencies")
 } else{ 

 tp1 = makefractionBaseType(cd, 'freq')
 tp2 =  makefractionBaseType(cd_H, 'freq')
 tp3 =  makefractionBaseType(cd_noH, 'freq')
 tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
 tp1c = makefractionBaseType(cd, 'c')
 tp2c =  makefractionBaseType(cd_H, 'c')
 tp3c =  makefractionBaseType(cd_noH, 'c')
 tp4c = grid.arrange(tp1c, tp2c, tp3c, ncol=1)}
 report$ggsave(
   "typeofburst.png",
   tp4,
   width = plotwidth,
   height = plotheight,
   id = "Base Fraction Frequencies",
   title = "Base Fraction Frequencies",
   caption = "Base Fraction Frequencies",
   tags = c("basic", "burstplots", "barplot", "typeofburst"),
   uid = "0080006"
 )
 report$ggsave(
   "typeofburstcount.png",
   tp4c,
   width = plotwidth,
   height = plotheight,
   id = "Base Fraction Count",
   title = "Base Fraction Count",
   caption = "Base Fraction Count",
   tags = c("basic", "burstplots", "barplot", "typeofburst"),
   uid = "0080012"
 )
}

makefractionBaseRorG <- function(cd, freq) {
  loginfo("Making Fraction Base Bar Charts")
  label = labels(cd)
  label2 = paste("Type of Burst (R or G)", label, sep = "_")
  cd$RorG = 'Other'
  cd$RorG[cd$fractionC + cd$fractionA > .8] = 'Red'
  cd$RorG[cd$fractionG + cd$fractionT > .8] = 'Green'
  cd$RorG = as.factor(cd$RorG)
  rorgcd = cd %>% group_by(Condition, RorG)%>%summarise (n = n()) %>% mutate(freq = n / sum(n))
  rorgcd = subset(rorgcd, RorG != 'Other')
  tp2 = ggplot(rorgcd, aes(x = RorG, y = freq, fill = Condition)) + geom_bar(stat =
                                                                               "identity", position = "dodge") +
    clFillScale + plTheme + labs(x = "Type of Burst (R or G)", y = "Relative Frequency (Sum = 1)",
                                 title = label2)
  
  tp3 = ggplot(rorgcd, aes(x = RorG, y = n, fill = Condition)) + geom_bar(stat =
                                                                                  "identity", position = "dodge") +
    clFillScale + plTheme + labs(x = "Type of Burst (R or G)", y = "Count", title = label2)
  if (freq == "freq"){
    return(tp2)
  }else {
    return (tp3)}
}
makefractionBaseRorGforAll <- function(report,cd,cd_H, cd_noH){
 if( nrow(cd) == 0 ){
   tp4 = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Base Fraction Frequencies")
   tp4c = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Base Fraction Frequencies")
 } else{
  tp1 = makefractionBaseRorG(cd, 'freq')
  tp2 =  makefractionBaseRorG(cd_H, 'freq')
  tp3 =  makefractionBaseRorG(cd_noH, 'freq')
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  tp1c = makefractionBaseRorG(cd, 'c')
  tp2c =  makefractionBaseRorG(cd_H, 'c')
  tp3c =  makefractionBaseRorG(cd_noH, 'c')
  tp4c = grid.arrange(tp1c, tp2c, tp3c, ncol=1)}
  report$ggsave(
    "typeofburstRorG.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "Burst Type Frequencies (R or G)",
    title = "Burst Type Frequencies (Red or Green)",
    caption = "Burst Type Frequencies (R or G)",
    tags = c("basic", "burstplots", "barplot", "rogburst"),
    uid = "0080007"
  )
  report$ggsave(
    "typeofburstRorGcount.png",
    tp4c,
    width = plotwidth,
    height = plotheight,
    id = "Burst Type Count (R or G)",
    title = "Burst Type Count (Red or Green)",
    caption = "Burst Type Count (R or G)",
    tags = c("basic", "burstplots", "barplot", "rogburst", "count"),
    uid = "0080013"
  )
}

DensityforEachCondition<- function(cd, cd10,condition) {
    cd10$readlength = cd10$qEnd - cd10$qStart
    cd11 = cd10 %>% group_by (Condition) %>% summarise(yield = as.numeric((sum(as.numeric(readlength)))))
    densities = rep(0,20)
    yield = cd11[cd11$Condition == condition,]$yield
    cdsubset = subset(cd, Condition == condition)
    for (i in 1:20) {
      densities[i] = nrow(subset(cdsubset, burstLength > (i*50)))/yield
    }
    condition_vector = rep(condition, 20)
    minburstlength = seq(50,1000,50)
    def_den = data.frame(condition_vector,densities,minburstlength)
    return (def_den)
}
makeburstDensityvsRL_Iv <- function(cd, cd10) {
  loginfo("Making inverse burst density vs RL plots")
  cd10$qEnd = as.numeric(cd10$qEnd)
  cd10$qStart = as.numeric(cd10$qStart)
  cd10$readlength = as.numeric(cd10$qEnd - cd10$qStart)
  label = labels(cd)
  label2 = paste("Inverse_Burst_Density_vs_Min_Burst_Length", label, sep = "_")
  if( nrow(cd) == 0 || nrow(cd10) == 0){ 
    tp2 = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "1/Burst Density", title = label2, x = "Minimum Burst Length (pulses)")
  }else{
  cd11 = cd10 %>% group_by (Condition) %>% summarise(yield = as.numeric((sum(as.numeric(readlength)))))
  df = list()
  for (i in 1:nrow(cd11)){
    df[[i]]= DensityforEachCondition(cd, cd10,cd11[i,]$Condition)
  }
  #changing another way 
  #for (i in 1:(nrow(cd11)-1)){
    #df[[i+1]] = rbind(df[[i]], df[[i+1]])
  #}
  if (nrow(cd11) ==1){
    df[[1]] = df[[1]]
  } else{
  for (i in 2:(nrow(cd11))){
    df[[1]]=rbind(df[[1]], df[[i]])}
  }
  
  #tp = ggplot(df[[nrow(cd11)]], aes(x = minburstlength, y = densities, colour = condition_vector)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Burst Density", title = "Burst Density vs Burst Length", x = "Minimum Burst Length")
  tp2 = ggplot(df[[1]], aes(x = minburstlength, y = 1/densities, colour = condition_vector)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "1/Burst Density", title = label2, x = "Minimum Burst Length (pulses)")
  }
  return(tp2)
}
makeburstDensityvsRL <- function(cd, cd10) {
  loginfo("Making burst density plots")
  cd10$qEnd = as.numeric(cd10$qEnd)
  cd10$qStart = as.numeric(cd10$qStart)
  cd10$readlength = as.numeric(cd10$qEnd - cd10$qStart)
  label = labels(cd)
  label2 = paste("Burst_Density_vs_Min_Burst_Length", label, sep = "_")
  if( nrow(cd) == 0 || nrow(cd10) == 0){ 
    tp = ggplot(cd, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Burst Density", title = label2, x = "Minimum Burst Length (pulses)")
  }else{
    cd11 = cd10 %>% group_by (Condition) %>% summarise(yield = as.numeric((sum(as.numeric(readlength)))))
    df = list()
    for (i in 1:nrow(cd11)){
      df[[i]]= DensityforEachCondition(cd, cd10, as.character(cd11[i,]$Condition))
    }
    #for (i in 1:(nrow(cd11)-1)){
      #df[[i+1]] = rbind(df[[i]], df[[i+1]])
    #}
    if (nrow(cd11) ==1){
      df[[1]] = df[[1]]
    }else{
      for (i in 2:(nrow(cd11))){
        df[[1]]=rbind(df[[1]], df[[i]])}
    }
    tp = ggplot(df[[1]], aes(x = minburstlength, y = densities, colour = condition_vector)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "Burst Density", title = label2, x = "Minimum Burst Length")
    #tp2 = ggplot(df[[nrow(cd11)]], aes(x = minburstlength, y = 1/densities, colour = condition_vector)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "1/Burst Density", title = label2, x = "Minimum Burst Length")
  }
  return(tp)
}
makeburstDensityvsRLAll <- function(report,cd,cd_H, cd_noH,cd10,cd10_H,cd10_noH){
  tp1 = makeburstDensityvsRL(cd, cd10)
  tp2 = makeburstDensityvsRL(cd_H, cd10_H)
  tp3 = makeburstDensityvsRL(cd_noH, cd10_noH)
  tp4 = grid.arrange(tp1, tp2, tp3, ncol=1)
  
  tp1v = makeburstDensityvsRL_Iv(cd, cd10)
  tp2v = makeburstDensityvsRL_Iv(cd_H, cd10_H)
  tp3v = makeburstDensityvsRL_Iv(cd_noH, cd10_noH)
  tp4v = grid.arrange(tp1v, tp2v, tp3v, ncol=1)
  report$ggsave(
    "burstdenvsRL.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "Burst_Density_vs_Min_Burst_Length",
    title = "Burst_Density_vs_Min_Burst_Length",
    caption = "Burst_Density_vs_Min_Burst_Length",
    tags = c("basic", "burstplots", "barplot", "burstlength"),
    uid = "0080008"
  )
  report$ggsave(
    "inverse_burstdenvsRL.png",
    tp4v,
    width = plotwidth,
    height = plotheight,
    id = "Inverse_Burst_Density_vs_Min_Burst_Length",
    title = "Inverse_Burst_Density_vs_Min_Burst_Length",
    caption = "Inverse_Burst_Density_vs_Min_Burst_Length",
    tags = c("basic", "burstplots", "barplot", "inverseburstlength"),
    uid = "0080009"
  )
}

makePairWisedOneCon <- function(cd_H,condition){
  cdsubset = subset(cd_H, Condition == condition)
  cdsubset$zmw = as.character(cdsubset$zmw)
  subsetsummary = cdsubset%>% group_by(zmw) %>% summarise(count = n())
  vNew=list()
  for (i in 1:nrow(subsetsummary)){
    perzmw = subset(cdsubset, zmw == subsetsummary[i,]$zmw)
    if (nrow(perzmw)>1){
    vNew[[i]] <- as.matrix(as.vector(dist(perzmw[, "previousBaseIndex"] + perzmw[, "qStart"])), ncol=1)}
    else
    {vNew[[i]]= as.matrix(0, ncol=1)}
  }
  vNew_combo = as.vector(unlist(vNew))
  vNew_combo = vNew_combo[vNew_combo!=0]
  condition_vector = rep(condition, length(vNew_combo))
  def_den = data.frame(condition_vector,vNew_combo)
  return (def_den)
}

getFFTFreqs <- function(Nyq.Freq, data)
{
  if ((length(data) %% 2) == 1) # Odd number of samples
  {
    FFTFreqs <- c(seq(0, Nyq.Freq, length.out=(length(data)+1)/2), 
                  seq(-Nyq.Freq, 0, length.out=(length(data)-1)/2))
  }
  else # Even number
  {
    FFTFreqs <- c(seq(0, Nyq.Freq, length.out=length(data)/2), 
                  seq(-Nyq.Freq, 0, length.out=length(data)/2))
  }
  
  return (FFTFreqs)
}

makePairWised <- function(report,cd_H){
  summary_t = cd_H %>% group_by(Condition) %>% summarise(count = n())
  if(nrow(cd_H) == 0){
    tp1 = ggplot(cd_H, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "No data")
    tp2 = ggplot(cd_H, aes(x = 0, y = 0)) + geom_line()+plTheme + clScale + themeTilt+ labs(y = "No data")
  } else{
  df = list()
  for (i in 1:nrow(summary_t)){
    df[[i]] = makePairWisedOneCon(cd_H,as.character(summary_t[i,]$Condition))
  }
  #for (i in 1:(nrow(summary_t)-1)){
    #df[[i+1]] = rbind(df[[i]], df[[i+1]])
  #}
  if (nrow(summary_t) ==1){
    df[[1]] = df[[1]]
  } else{
    for (i in 2:(nrow(summary_t))){
      df[[1]]=rbind(df[[1]], df[[i]])}
  }
  dflist = list()
  fourier = list()
  tp = list()
  cl = colors()
  for (i in 1:nrow(summary_t)){
  subsetdf = subset(df[[1]], condition_vector == as.character(summary_t[i,]$Condition)) 
  df1 <-  transform(subsetdf, group=cut(vNew_combo, 
                                  breaks=c(seq(min(subsetdf$vNew_combo)-1, max(subsetdf$vNew_combo)+1,50))))
  res <- do.call(data.frame,aggregate(vNew_combo~group, df1, 
                                      FUN=function(x) c(Count=length(x))))
  dNew <- data.frame(group=levels(df1$group))
  dflist[[i]] = merge(res, dNew, all=TRUE)
  dflist[[i]]$vNew_combo[is.na(dflist[[i]]$vNew_combo)]=0
  dflist[[i]]$density = dflist[[i]]$vNew_combo/(sum(dflist[[i]]$vNew_combo))
  dflist[[i]]$density_final = dflist[[i]]$density/50
  fft = fft(dflist[[i]]$density_final)
  fourier[[i]] = (abs(fft))^2
  fourier[[i]]=data.frame(fourier[[i]])
  fourier[[i]]$condition = as.character(summary_t[i,]$Condition)
  fourier[[i]]$x = getFFTFreqs(1/50,dflist[[i]]$density_final)
  fourier[[i]]$y = fourier[[i]]$fourier..i..
 # tp[[i]] = ggplot(fourier[[i]], aes(x= x, y = y)) + geom_line(colour = cl[20+i])+plTheme + clScale + themeTilt + labs(x = "Component (inverse bases)", y = "Density", title = "Density over Component (inverse bases)") + coord_cartesian(xlim = c(0, 0.005)) 
  }
  if (nrow(summary_t) ==1){
    fourier[[1]] = fourier[[1]]
  } else{
    for (i in 2:nrow(summary_t)){
      fourier[[1]]=rbind(fourier[[1]], fourier[[i]])}
  }
  
  
  tp1 = ggplot(fourier[[1]], aes(x= x, y = fourier..i.., colour = condition)) + geom_line()+plTheme + clScale + themeTilt + labs(x = "Component (inverse bases)", y = "Density", title = "Density over Component (inverse bases)") + coord_cartesian(xlim = c(0, 0.005)) 
  tp2 = ggplot(df[[1]], aes(x = vNew_combo, colour = condition_vector)) + geom_density()+plTheme + clScale + themeTilt+ labs(y = "Density", title = "Pairwise Distance Density", x = "Pairwise Distance (bases)")}
  
  report$ggsave(
    "Density_over_component.png",
    tp1,
    width = plotheight,
    height = plotwidth,
    id = "Density over Component (inverse bases)",
    title = "Density over Component (inverse bases)",
    caption = "Density over Component (inverse bases)",
    tags = c("basic", "burstplots", "barplot", "density"),
    uid = "0080010"
  )
  report$ggsave(
    "Density_over_component.png",
    tp1,
    width = plotheight,
    height = plotwidth,
    id = "Density over Component (inverse bases)",
    title = "Density over Component (inverse bases)",
    caption = "Density over Component (inverse bases)",
    tags = c("basic", "burstplots", "barplot", "density"),
    uid = "0080010"
  )
  report$ggsave(
    "PairwiseDDensity.png",
    tp2,
    width = plotheight,
    height = plotwidth,
    id = "Pairwise_Distance_Density",
    title = "Pairwise_Distance_Density",
    caption = "Pairwise_Distance_Density",
    tags = c("basic", "burstplots", "barplot", "pairwise"),
    uid = "0080015"
  )
}


# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  conditions = report$condition.table
  #cd = read.csv("conditions/5k_tetraloop/subreads/ppa_burst_metrics.csv")
  dfs = lapply(as.character(conditions$Condition), function(s) {
    string0 = paste("conditions/",s,"/subreads/ppa_burst_metrics.csv", sep ="")
    table = read.csv(string0)
    if (!is.numeric(table[1,1])){
      warning(paste("Warning: No bursts data available for",s, sep=" "))
      table = table[-1,]
    }
    return(table)
  })
  
    # Now combine into one large data frame
    cd = combineConditions(dfs, as.character(conditions$Condition))
    #for testing purposes
    #cd2 = cd[1:1000,]
    #cd3 = cd[1001:1600,]
    #cd3$Condition = NULL
    #cd3$Condition = "6k_tetraloop"
    #cd = rbind(cd2, cd3)
    #real
    cd$Condition = as.factor(cd$Condition)
    cd$burstDuration = cd$burstEndTime - cd$burstStartTime
    cd_H = cd %>% filter(seqType == 'H')
    cd_noH = cd %>% filter(seqType != 'H')
    comment(cd) <- "cd"
    comment(cd_H) <- "cd_H"
    comment(cd_noH)<- "cd_noH"
    
    dfs2 = lapply(as.character(conditions$Condition), function(s) {
      string0 = paste("conditions/",s,"/subreads/read_metrics.csv", sep ="")
      table = read.csv(string0)
      if (!is.numeric(table[1,1])){
        warning(paste("Warning: No bursts data available for",s, sep=" "))
        table = table[-1,]
      }
      return(table)
    })

    
    # Now combine into one large data frame
    cd10 = combineConditions(dfs2, as.character(conditions$Condition))
    #for testing purposes
    #cd12 = cd10[1:1000,]
    #cd13 = cd10[1001:1600,]
    #cd13$Condition = NULL
    #cd13$Condition = "6k_tetraloop"
    #cd10 = rbind(cd12, cd13)
    #real transform
    cd10$Condition = as.factor(cd10$Condition)
    cd10$readlength = cd10$qEnd - cd10$qStart
    cd10_H = cd10 %>% filter(seqType == 'H')
    cd10_noH = cd %>% filter(seqType != 'H')
    
  
    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)
   
    # Make Plots
    makeBurstLengthPlots(report,cd,cd_H, cd_noH)
    makeBurstDurationPlots(report,cd,cd_H, cd_noH)
    makeCumSumBurstLength(report,cd_H)
    makeCumSumBurstDuration(report,cd_H)
    makeBurstStartPlots(report,cd,cd_H, cd_noH)
    makePreviousBaseCountAll(report,cd,cd_H, cd_noH)
    makePreviousBaseFreqAll(report,cd,cd_H, cd_noH)
    makefractionBaseforAll(report,cd,cd_H, cd_noH)
    makefractionBaseRorGforAll(report,cd,cd_H, cd_noH)
    makeburstDensityvsRLAll(report,cd,cd_H, cd_noH,cd10,cd10_H,cd10_noH)
    makePairWised(report,cd_H)
    # Save the report object for later debugging
    save(report, file = file.path(report$outputDir, "report.Rd"))
    
    # At the end of this function we need to call this last, it outputs the report
    report$write.report()
  }


main <- function()
{
  report <- bh2Reporter("condition-table.csv",
                        "reports/BurstPlots/report.json",
                        "Burst Plots")
  makeReport(report)
  jsonFile = "reports/BurstPlots/report.json"
  #uidTagCSV = "reports/uidTag.csv"
  #rewriteJSON(jsonFile, uidTagCSV)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
