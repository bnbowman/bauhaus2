#!/usr/bin/env Rscript

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=1)
  stop("Provide *.lima.report file.\n", call.=FALSE)

library(ggplot2,quietly = TRUE, warn.conflicts = FALSE)
library(dplyr,quietly = TRUE, warn.conflicts = FALSE)
library(tidyr,quietly = TRUE, warn.conflicts = FALSE)
library(viridis,quietly = TRUE, warn.conflicts = FALSE)
library(scales,quietly = TRUE, warn.conflicts = FALSE)
library(data.table,quietly = TRUE, warn.conflicts = FALSE)
library(hexbin,quietly = TRUE, warn.conflicts = FALSE)

# The core function, change the implementation in this to add new features.
makeReport <- function(reportbh) {
  s = unlist(strsplit(args[1],'/'))
  args[1] = paste(s[1:length(s)-1],collapse = "/")
  
  reportbh$write.table("guess.csv",
                       as.data.frame(fread(paste0(args[1],"/barcoded.lima.guess"))),
                       id = "guess.csv",
                       title = "Barcode Guess")
  
  reportbh$write.table("counts.csv",
                       as.data.frame(fread(paste0(args[1],"/barcoded.lima.counts"))),
                       id = "counts.csv",
                       title = "Barcode Counts")
  
  reportbh$write.table("summary.csv",
                       as.data.frame(fread(paste0(args[1],"/barcoded.lima.summary"),blank.lines.skip=TRUE,sep=":")),
                       id = "summary.csv",
                       title = "Lima Summary")
  
  reportPath = paste0(args[1],"/barcoded.lima.report")
  
  report_sum = as.data.frame(fread(reportPath,stringsAsFactors=FALSE))
  report_sum$IdxFirstNamed[report_sum$IdxFirstNamed == "-1"] = "X"
  report_sum$IdxCombinedNamed[report_sum$IdxCombinedNamed == "-1"] = "X"
  report_sum$IdxSecondCandidateNamed[report_sum$IdxSecondCandidateNamed == "-1"] = "X"
  report_sum$IdxLowestNamed[report_sum$IdxLowest == -1] = "X"
  report_sum$IdxHighestNamed[report_sum$IdxHighest == -1] = "X"
  report_sum$BarcodePair = paste(report_sum$IdxLowestNamed,report_sum$IdxHighestNamed,sep="--")
  report_sum$Barcoded = report_sum$IdxLowestNamed!="X" & report_sum$IdxHighestNamed!="X"
  report_sum = report_sum %>% arrange(BarcodePair)
  unique_bps = report_sum %>% filter(Barcoded) %>% filter(PassedFilters == 1) %>% distinct(BarcodePair)
  zmwYield = report_sum %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW) %>% count(BarcodePair)
  zmwYield = rename(zmwYield, NumZMWs = n)
  
  report_sum = report_sum %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair)
  relevant_bps = report_sum %>% filter(PassedFilters == 1) %>% group_by(BarcodePair) %>% summarize(n=n()) %>% filter(n>100)
  if (nrow(relevant_bps) > 500)
    relevant_bps = relevant_bps[1:500,]
  
  zmwYieldVsMeanScore1 = report_sum %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, ScoreCombined) %>% group_by(BarcodePair) %>% summarise(MeanScore=mean(ScoreCombined))
  zmwYieldVsMeanScore2 = report_sum %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, ScoreCombined) %>% group_by(BarcodePair) %>% count(BarcodePair)
  zmwYieldVsMeanScore = full_join(zmwYieldVsMeanScore1,zmwYieldVsMeanScore2,by="BarcodePair") %>% rename(NumZMWs=n)
  
  g = ggplot(zmwYieldVsMeanScore) +
    geom_jitter(aes(MeanScore, NumZMWs)) +
    coord_cartesian(xlim = c(0, 100), ylim = c(0, max(zmwYieldVsMeanScore$NumZMWs)*1.1)) +
    theme_minimal()+
    ylab("ZMW yield")+xlab("Mean Score")
  reportbh$ggsave(
    "summary_meanscore_vs_yield_jitter.png",
    g,width=20,height=15,units="cm",
    id = "summary_meanscore_vs_yield_jitter",
    title = "summary_meanscore_vs_yield_jitter",
    caption = "summary_meanscore_vs_yield_jitter",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  g = ggplot(zmwYieldVsMeanScore) +
    geom_jitter(aes(MeanScore, log10(NumZMWs))) +
    coord_cartesian(xlim = c(0, 100)) +
    theme_minimal()+
    ylab("ZMW yield log10")+xlab("Mean Score")
  reportbh$ggsave(
    "summary_meanscore_vs_yield_jitter_log10.png",
    g,width=20,height=15,units="cm",
    id = "summary_meanscore_vs_yield_jitter_log10",
    title = "summary_meanscore_vs_yield_jitter_log10",
    caption = "summary_meanscore_vs_yield_jitter_log10",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  g = ggplot(zmwYieldVsMeanScore) +
    geom_hex(aes(MeanScore, NumZMWs)) +
    coord_cartesian(xlim = c(0, 100), ylim = c(0, max(zmwYieldVsMeanScore$NumZMWs)*1.1)) +
    theme_minimal()+
    ylab("ZMW yield")+xlab("Mean Score")
  reportbh$ggsave(
    "summary_meanscore_vs_yield_hex.png",
    g,width=20,height=15,units="cm",
    id = "summary_meanscore_vs_yield_hex",
    title = "summary_meanscore_vs_yield_hex",
    caption = "summary_meanscore_vs_yield_hex",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  g = ggplot(zmwYieldVsMeanScore) +
    geom_hex(aes(MeanScore, log10(NumZMWs))) +
    coord_cartesian(xlim = c(0, 100)) +
    theme_minimal()+
    ylab("ZMW yield log10")+xlab("Mean Score")
  reportbh$ggsave(
    "summary_meanscore_vs_yield_hex_log10.png",
    g,width=20,height=15,units="cm",
    id = "summary_meanscore_vs_yield_hex_log10",
    title = "summary_meanscore_vs_yield_hex_log10",
    caption = "summary_meanscore_vs_yield_hex_log10",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  g = ggplot(zmwYield) +
    geom_histogram(aes(NumZMWs),fill="gray",color="black",alpha=.3)+
    scale_y_continuous(labels=comma)+
    theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + xlab("Number of ZMWs") + ylab("Number of Barcoded Samples")
  reportbh$ggsave(
    "summary_yield_zmw.png",
    g,width=20,height=15,units="cm",
    id = "summary_yield_zmw",
    title = "summary_yield_zmw",
    caption = "summary_yield_zmw",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  g = ggplot(report_sum) +
    geom_histogram(aes(ScoreCombined),fill="gray",color="black",alpha=.3,binwidth = 1)+
    scale_y_continuous(labels=comma)+ scale_x_continuous(limits = c(0, 100))+
    theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + xlab("Mean Barcode Score") + ylab("Number of Barcoded Samples")
  reportbh$ggsave(
    "summary_score_hist.png",
    g,width=20,height=15,units="cm",
    id = "summary_score_hist",
    title = "summary_score_hist",
    caption = "summary_score_hist",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  binned = report_sum %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined) %>% select(BarcodePair, ScoreCombined) %>% arrange(BarcodePair) %>% group_by(BarcodePair) %>%  count(ScoreCombined) %>% arrange(BarcodePair, ScoreCombined)
  binned = rename(binned, counts=n)
  g = ggplot(binned) +
    geom_bin2d(aes(BarcodePair,ScoreCombined,fill=counts),stat = 'identity') + scale_fill_viridis() + theme_minimal() +
    theme(axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
    scale_y_continuous(limits = c(0, 100))+
    xlab("Barcoded Samples") + ylab("Mean Barcode Score")
  reportbh$ggsave(
    "summary_score_hist_2d.png",
    width=50,height=15,units="cm",g,
    id = "summary_score_hist_2d",
    title = "summary_score_hist_2d",
    caption = "summary_score_hist_2d",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  tryCatch({report_sum$ReadLengths = sapply(report_sum$ReadLengths,function(x) list(as.numeric(unlist(strsplit(x,",")))))},error=function(e){})
  names(report_sum$ReadLengths) = c()
  readLengthsUnnested = report_sum %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined) %>% select(ReadLengths, BarcodePair) %>% unnest(ReadLengths)
  g = ggplot(readLengthsUnnested) +
    geom_bin2d(aes(x=BarcodePair,y=ReadLengths),binwidth=1000) + scale_fill_viridis() + theme_minimal() +
    theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
    xlab("Barcoded Samples") +
    ylab("Read Length")
  reportbh$ggsave(
    "summary_read_length_hist_2d.png",
    width=50,height=15,units="cm",g,
    id = "summary_read_length_hist_2d",
    title = "summary_read_length_hist_2d",
    caption = "summary_read_length_hist_2d",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  report_sum$HQLength = sapply(report_sum$ReadLengths,sum)
  g = ggplot(report_sum %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined)) +
    geom_bin2d(aes(x=BarcodePair,y=HQLength),binwidth=1000) + scale_fill_viridis() + theme_minimal() +
    theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
    xlab("Barcoded Samples") +
    ylab("HQ Length")
  reportbh$ggsave(
    "summary_hq_length_hist_2d.png",
    width=50,
    height=15,
    units="cm",g,
    id = "summary_hq_length_hist_2d",
    title = "summary_hq_length_hist_2d",
    caption = "summary_hq_length_hist_2d",
    tags = c("lima"),
    limitsize = FALSE
  )
  
  
  report = as.data.frame(fread(reportPath,stringsAsFactors=FALSE))
  report$IdxFirstNamed[report$IdxFirstNamed == "-1"] = "X"
  report$IdxCombinedNamed[report$IdxCombinedNamed == "-1"] = "X"
  report$IdxSecondCandidateNamed[report$IdxSecondCandidateNamed == "-1"] = "X"
  report$IdxLowestNamed[report$IdxLowest == -1] = "X"
  report$IdxHighestNamed[report$IdxHighest == -1] = "X"
  report$BarcodePair = paste(report$IdxLowestNamed,report$IdxHighestNamed,sep="--")
  report$Barcoded = report$IdxLowestNamed!="X" & report$IdxHighestNamed!="X"
  if (length(args) >= 3) {
    barcodeNamesOfInterest = args[3:length(args)]
    combineBC = function(x) {
      s=unlist(strsplit(x,"--"))
      c(paste0(s[1],"--",s[2]),paste0(s[2],"--",s[1]))
    }
    barcodeNamesOfInterest = unlist(sapply(barcodeNamesOfInterest,function(x) {if(grepl("--",x)) { combineBC(x) } else {x }}))
    names(barcodeNamesOfInterest) = c()
    report = report %>% filter(IdxFirstNamed %in% barcodeNamesOfInterest | IdxCombinedNamed %in% barcodeNamesOfInterest | BarcodePair %in% barcodeNamesOfInterest)
  }
  
  reportCounts = count(report,BarcodePair)
  count_labeller <- function(value){
    sapply(value,function(x) { paste(x,  " / ZMWs ", reportCounts[reportCounts$BarcodePair==x,]$n,sep="")})
  }
  
  tryCatch({report$ReadLengths = sapply(report$ReadLengths,function(x) list(as.numeric(unlist(strsplit(x,",")))))},error=function(e){})
  names(report$ReadLengths) = c()
  report$HQLength = sapply(report$ReadLengths,sum)
  
  unique_bps = report %>% filter(Barcoded) %>% filter(PassedFilters == 1) %>% distinct(BarcodePair)
  report_relevant = report %>% filter(BarcodePair %in% relevant_bps$BarcodePair)
  reportFilteredADP = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair)
  reportFilteredADP$NumAdapters = as.numeric(reportFilteredADP$NumAdapters)
  if (any(reportFilteredADP$NumAdapters >= 2)) reportFilteredADP[reportFilteredADP$NumAdapters >= 2,]$NumAdapters = 2
  reportFilteredADP = reportFilteredADP%>% mutate(Filter = PassedFilters) %>% mutate(Filter=ifelse(Filter==0,"NONE","PASS"))
  
  reportFilteredADP_pass = report_relevant %>% filter(Barcoded, PassedFilters == 1) %>% filter(BarcodePair %in% unique_bps$BarcodePair)
  reportFilteredADP_pass$NumAdapters = as.numeric(reportFilteredADP_pass$NumAdapters)
  if (any(reportFilteredADP_pass$NumAdapters >= 2)) reportFilteredADP_pass[reportFilteredADP_pass$NumAdapters >= 2,]$NumAdapters = 2
  
  reportFiltered = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% mutate(Filter = "NONE", ScoreLead = ifelse(ScoreLead==-1,NA,ScoreLead))
  reportFiltered_pass = reportFiltered %>% filter(PassedFilters == 1) %>% mutate(Filter = "PASS")
  
  reportFiltered$ScoreCombinedAll = reportFiltered$ScoreCombined
  if (any(reportFiltered$PassedFilters == 0)) reportFiltered[reportFiltered$PassedFilters == 0,]$ScoreCombined = NA
  
  numadapters = report_relevant %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, NumAdapters,Barcoded) %>% group_by(BarcodePair, NumAdapters, Barcoded)
  
  baseYield = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ReadLengths, PassedFilters) %>% unnest(ReadLengths) %>% group_by(BarcodePair,PassedFilters) %>% mutate(MegaBases = sum(ReadLengths) / 1000000) %>% select(BarcodePair, MegaBases, PassedFilters) %>% ungroup() %>% distinct(BarcodePair,MegaBases, PassedFilters) %>% mutate(Filter = PassedFilters) %>% ungroup() %>% mutate(Filter=ifelse(Filter==0,"NONE","PASS"))
  readYield = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ReadLengths, PassedFilters) %>% unnest(ReadLengths) %>% group_by(BarcodePair,PassedFilters) %>% count(BarcodePair, PassedFilters) %>% rename(NumReads = n) %>% mutate(Filter = PassedFilters) %>% mutate(Filter=ifelse(Filter==0,"NONE","PASS"))
  zmwYield = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, PassedFilters) %>% count(BarcodePair, PassedFilters) %>% rename(NumZMWs = n, Filter = PassedFilters) %>% mutate(Filter=ifelse(Filter==0,"NONE","PASS"))
  
  readLengthsUnnestedByBC = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ReadLengths, ScoreCombined) %>% unnest(ReadLengths) %>% mutate(ReadLengths = ReadLengths / 1000)
  readLengthsUnnestedByBCZmw = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, ReadLengths, ScoreCombined) %>% unnest(ReadLengths) %>% group_by(BarcodePair,ZMW) %>% mutate(KiloBases = sum(ReadLengths) / 1000) %>% select(BarcodePair, KiloBases,ScoreCombined, ZMW) %>% ungroup() %>% distinct(BarcodePair,KiloBases,ScoreCombined, ZMW)
  
  barcodeCounts = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% count(BarcodePair)
  titration = report_relevant %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ScoreCombined) %>% group_by(BarcodePair) %>% arrange(BarcodePair,desc(ScoreCombined)) %>% count(BarcodePair,ScoreCombined) %>% mutate(cs = cumsum(n))
  titration$Filter = "NONE"
  titration_pass = report_relevant %>% filter(Barcoded, PassedFilters) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ScoreCombined) %>% group_by(BarcodePair) %>% arrange(BarcodePair,desc(ScoreCombined)) %>% count(BarcodePair,ScoreCombined) %>% mutate(cs = cumsum(n))
  titration_pass$Filter = "PASS"
  
  readLengthsUnnested = report %>% select(ReadLengths, Barcoded) %>% unnest(ReadLengths)
  
  dpi = 150
  unique_bps_relevant = unique_bps %>% filter(BarcodePair %in% relevant_bps$BarcodePair)
  facetHeight = max(nrow(unique_bps_relevant)+1,4)/4*5+1
  yieldHeight = max(nrow(unique_bps_relevant)+1,4)*0.5+3
  facetWidth = 5 + min(nrow(unique_bps_relevant)+1,4)*5
  
  g = ggplot(bind_rows(titration,titration_pass)) +
    facet_wrap(~BarcodePair, scales = "free_y", ncol = 4)+
    geom_line(aes(x=ScoreCombined,y=cs,color=Filter))+
    ylab("ZMW yield")+xlab("Mean Score")+
    coord_cartesian(xlim=c(0,100))+
    theme_light()
  reportbh$ggsave("detail_score_vs_yield.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_score_vs_yield",
                  title = "detail_score_vs_yield",
                  caption = "detail_score_vs_yield",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(bind_rows(reportFiltered, reportFiltered_pass), aes(group = BarcodePair)) +
    facet_wrap(~BarcodePair, scales = "free_y", ncol = 4)+
    geom_freqpoly(binwidth=5, aes(x = ScoreLead, group=Filter, color=Filter),alpha=.5)+
    theme_light()+
    ylab("Number of ZMWs")+xlab("Score Leads")
  reportbh$ggsave("detail_score_lead.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_score_lead",
                  title = "detail_score_lead",
                  caption = "detail_score_lead",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(bind_rows(reportFiltered, reportFiltered_pass), aes(group = BarcodePair)) +
    facet_wrap(~BarcodePair, scales = "free_y", ncol = 4)+
    geom_freqpoly(binwidth=1, aes(x = SignalIncrease, group=Filter, color=Filter),alpha=.75)+
    theme_light()+
    ylab("Number of ZMWs")+xlab("Score Increase")
  reportbh$ggsave("detail_signal_increase.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_signal_increase",
                  title = "detail_signal_increase",
                  caption = "detail_signal_increase",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(readLengthsUnnestedByBCZmw)+
    facet_wrap(~BarcodePair, labeller=as_labeller(count_labeller),ncol = 4)+
    geom_hex(aes(KiloBases, ScoreCombined, color = ..count..))+
    scale_fill_viridis()+
    scale_color_viridis()+
    coord_cartesian(xlim = c(0, quantile(readLengthsUnnestedByBCZmw$KiloBases,0.999)))+
    theme_light()+xlab("HQ Length in Kilo Bases")+ylab("Mean Score")
  reportbh$ggsave("detail_hq_length_vs_score.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_hq_length_vs_score",
                  title = "detail_hq_length_vs_score",
                  caption = "detail_hq_length_vs_score",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(readLengthsUnnestedByBC)+
    facet_wrap(~BarcodePair, labeller=as_labeller(count_labeller),ncol = 4)+
    geom_hex(aes(ReadLengths, ScoreCombined, color = ..count..))+
    scale_fill_viridis()+
    scale_color_viridis()+
    coord_cartesian(xlim = c(0, quantile(readLengthsUnnestedByBC$ReadLengths,0.999)))+
    theme_light()+xlab("Read Length in Kilo Bases")+ylab("Mean Score")
  reportbh$ggsave("detail_read_length_vs_score.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_read_length_vs_score",
                  title = "detail_read_length_vs_score",
                  caption = "detail_read_length_vs_score",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(zmwYield) +
    geom_bar(aes(BarcodePair, NumZMWs, fill=Filter), stat='identity', width = .5)+
    scale_y_continuous(labels=comma)+ coord_flip()+
    theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + ylab("Number of ZMWs")+
    ggtitle(paste("CV with filter: NONE=",(zmwYield %>% group_by(BarcodePair) %>% mutate(n=sum(NumZMWs)) %>% ungroup() %>% distinct(BarcodePair,n)%>% summarize(cv=round(100*sd(n)/mean(n))))$cv," PASS=",(zmwYield %>% filter(Filter=="PASS") %>% ungroup() %>% summarize(cv=round(100*sd(NumZMWs)/mean(NumZMWs))))$cv,sep=""))+
    theme(plot.title = element_text(hjust = 0.5))
  reportbh$ggsave("detail_yield_zmw.png",
                  g,
                  width=25,
                  height=yieldHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_yield_zmw",
                  title = "detail_yield_zmw",
                  caption = "detail_yield_zmw",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(readYield) +
    geom_bar(aes(BarcodePair, NumReads, fill=Filter), stat='identity', width = .5)+
    scale_y_continuous(labels=comma)+ coord_flip()+
    theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + ylab("Number of Reads")+
    ggtitle(paste("CV with filter: NONE=",(readYield %>% group_by(BarcodePair) %>% mutate(n=sum(NumReads)) %>% ungroup() %>% distinct(BarcodePair,n) %>% summarize(cv=round(100*sd(n)/mean(n))))$cv," PASS=",(readYield %>% filter(Filter=="PASS") %>% ungroup() %>% summarize(cv=round(100*sd(NumReads)/mean(NumReads))))$cv,sep=""))+
    theme(plot.title = element_text(hjust = 0.5))
  reportbh$ggsave("detail_yield_read.png",
                  g,
                  width=25,
                  height=yieldHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_yield_read",
                  title = "detail_yield_read",
                  caption = "detail_yield_read",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(baseYield) +
    geom_bar(aes(BarcodePair, MegaBases, fill=Filter), stat='identity', width = .5)+
    scale_y_continuous(labels=comma)+
    theme_minimal() +coord_flip() + theme(axis.text.x = element_text(hjust=1)) + ylab("Yield in Mega Bases")+
    ggtitle(paste("CV with filter: NONE=",(baseYield %>% group_by(BarcodePair) %>% mutate(n=sum(MegaBases)) %>% ungroup() %>% distinct(BarcodePair,n) %>% summarize(cv=round(100*sd(n)/mean(n))))$cv," PASS=",(baseYield %>% filter(Filter=="PASS") %>% ungroup() %>% summarize(cv=round(100*sd(MegaBases)/mean(MegaBases))))$cv,sep=""))+
    theme(plot.title = element_text(hjust = 0.5))
  reportbh$ggsave("detail_yield_base.png",
                  g,
                  width=25,
                  height=yieldHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_yield_base",
                  title = "detail_yield_base",
                  caption = "detail_yield_base",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(report, aes(group = Barcoded, color = Barcoded, fill = Barcoded)) +
    geom_histogram(binwidth=2000,aes(HQLength),position = "identity", alpha=0.3)+
    coord_cartesian(xlim = c(0, quantile(report$HQLength,0.999))) +
    theme_minimal()+scale_x_continuous(labels=comma) + xlab("HQ Length") + ylab("Number of ZMWs")
  reportbh$ggsave("detail_hq_length_hist_barcoded_or_not.png",
                  g,
                  width=25,
                  height=15,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_hq_length_hist_barcoded_or_not",
                  title = "detail_hq_length_hist_barcoded_or_not",
                  caption = "detail_hq_length_hist_barcoded_or_not",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(readLengthsUnnested, aes(group = Barcoded, color = Barcoded, fill = Barcoded)) +
    geom_histogram(binwidth=1000,aes(ReadLengths),position = "identity", alpha=0.3)+
    coord_cartesian(xlim = c(0, quantile(readLengthsUnnested$ReadLengths,0.999))) +
    theme_minimal() + xlab("Read Length") + ylab("Number of ZMWs")
  reportbh$ggsave("detail_read_length_hist_barcoded_or_not.png",
                  g,
                  width=25,
                  height=15,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_read_length_hist_barcoded_or_not",
                  title = "detail_read_length_hist_barcoded_or_not",
                  caption = "detail_read_length_hist_barcoded_or_not",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(reportFilteredADP, geom='none', aes(group = BarcodePair)) +
    facet_wrap(~BarcodePair,scales = "free_y",ncol=4)+
    coord_cartesian(xlim=c(0,100))+
    geom_histogram(data=reportFilteredADP,binwidth=5,aes(ScoreCombined,group=Filter,fill=Filter),color="grey",alpha=.15)+
    geom_freqpoly(binwidth=5,aes(ScoreCombined,color=as.factor(NumAdapters),group=as.factor(NumAdapters)))+
    theme_light() +scale_color_discrete(breaks = names(table(reportFilteredADP$NumAdapters)), name="#Adapters",
                                        labels=paste(c(replicate(length(names(table(reportFilteredADP$NumAdapters)))-1, "=="),">="),
                                                     c(as.numeric(names(table(reportFilteredADP$NumAdapters))[1:length(names(table(reportFilteredADP$NumAdapters)))]))))+
    ylab("Number of ZMWs") + xlab("Mean Score")
  reportbh$ggsave("detail_scores_per_adapter.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_scores_per_adapter",
                  title = "detail_scores_per_adapter",
                  caption = "detail_scores_per_adapter",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  q = quantile(numadapters$NumAdapters,0.999)
  g = ggplot(numadapters, aes(group = BarcodePair, x = NumAdapters)) +
    facet_wrap(~BarcodePair, scales = "free_y",ncol=4)+
    coord_cartesian(xlim = c(0, q)) +
    geom_histogram(binwidth=.5, aes(group=Barcoded))+
    theme_light()+
    scale_x_continuous(breaks=seq(0,q,round(q/min(10,q))))+
    ylab("Number of ZMWs")+xlab("Number of Adapters")
  reportbh$ggsave("detail_num_adapters.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_num_adapters",
                  title = "detail_num_adapters",
                  caption = "detail_num_adapters",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  x = reportFiltered %>% group_by(BarcodePair) %>% select(ReadLengths,BarcodePair) %>% unnest(ReadLengths)
  g = ggplot(x, aes(group = BarcodePair, x = ReadLengths)) +
    facet_wrap(~BarcodePair,ncol=4)+
    coord_cartesian(xlim = c(0, quantile(x$ReadLengths,0.999))) +
    geom_histogram(binwidth = 1000, position="dodge", color="black", fill="gray")+
    theme_light()+ylab("Number of ZMWs")+xlab("Read Length")
  reportbh$ggsave("detail_read_length_hist_group_same_y.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_read_length_hist_group_same_y",
                  title = "detail_read_length_hist_group_same_y",
                  caption = "detail_read_length_hist_group_same_y",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(x, aes(group = BarcodePair, x = ReadLengths)) +
    facet_wrap(~BarcodePair, scales = "free_y",ncol=4)+
    coord_cartesian(xlim = c(0, quantile(x$ReadLengths,0.999))) +
    geom_histogram(binwidth = 1000, position="dodge", color="black", fill="gray")+
    theme_light()+ylab("Number of ZMWs")+xlab("Read Length")
  reportbh$ggsave("detail_read_length_hist_group_free_y.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_read_length_hist_group_free_y",
                  title = "detail_read_length_hist_group_free_y",
                  caption = "detail_read_length_hist_group_free_y",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(x, aes(group = BarcodePair, ReadLengths, color = BarcodePair)) +
    coord_cartesian(xlim = c(0, quantile(x$ReadLengths,0.999))) +
    geom_freqpoly(binwidth = 1000)+
    theme_minimal()+ylab("Number of ZMWs")+xlab("Read Length")
  reportbh$ggsave("detail_read_length_linehist_nogroup.png",
                  g,
                  width=25,
                  height=15,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_read_length_linehist_nogroup",
                  title = "detail_read_length_linehist_nogroup",
                  caption = "detail_read_length_linehist_nogroup",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  y = reportFiltered %>% group_by(BarcodePair) %>% select(HQLength,BarcodePair) %>% unnest(HQLength)
  g = ggplot(y, aes(group = BarcodePair, x = HQLength)) +
    facet_wrap(~BarcodePair,ncol=4)+
    coord_cartesian(xlim = c(0, quantile(y$HQLength,0.999))) +
    geom_histogram(binwidth = 2000, position="dodge", color="black", fill="gray")+
    theme_light()+ylab("Number of ZMWs")+xlab("HQ Length")
  reportbh$ggsave("detail_hq_length_hist_group_same_y.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_hq_length_hist_group_same_y",
                  title = "detail_hq_length_hist_group_same_y",
                  caption = "detail_hq_length_hist_group_same_y",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(y, aes(group = BarcodePair, x = HQLength)) +
    facet_wrap(~BarcodePair, scales = "free_y",ncol=4)+
    coord_cartesian(xlim = c(0, quantile(y$HQLength,0.999))) +
    geom_histogram(binwidth = 2000, position="dodge", color="black", fill="gray")+
    theme_light()+ylab("Number of ZMWs")+xlab("HQ Length")
  reportbh$ggsave("detail_hq_length_hist_group_free_y.png",
                  g,
                  width=facetWidth,
                  height=facetHeight,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_hq_length_hist_group_free_y",
                  title = "detail_hq_length_hist_group_free_y",
                  caption = "detail_hq_length_hist_group_free_y",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  g = ggplot(y, aes(group = BarcodePair, HQLength, color = BarcodePair)) +
    coord_cartesian(xlim = c(0, quantile(y$HQLength,0.999))) +
    geom_freqpoly(binwidth = 2000)+
    theme_minimal()+ylab("Number of ZMWs")+xlab("HQ Length")
  reportbh$ggsave("detail_hq_length_linehist_nogroup.png",
                  g,
                  width=25,
                  height=15,
                  units="cm",
                  limitsize = FALSE,
                  id = "detail_hq_length_linehist_nogroup",
                  title = "detail_hq_length_linehist_nogroup",
                  caption = "detail_hq_length_linehist_nogroup",
                  tags=c("lima"),
                  dpi=dpi
  )
  
  # Save the report object for later debugging
  save(reportbh, file = file.path(reportbh$outputDir, "report.Rd"))
  # At the end of this function we need to call this last, it outputs the report
  reportbh$write.report()
}

main <- function()
{
  reportbh <- bh2Reporter("condition-table.csv",
                          "reports/BarcodingQC/report.json",
                          "Lima BarcodingQC Plots")
  makeReport(reportbh)
  jsonFile = "reports/BarcodingQC/report.json"
  uidTagCSV = "reports/uidTag.csv"
  
  # TODO: currently we don't rewrite the json report since the uid is not added to the lima plots yet
  # rewriteJSON(jsonFile, uidTagCSV)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
