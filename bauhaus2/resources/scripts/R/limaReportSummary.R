#!/usr/bin/env Rscript

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=1)
  stop("Provide *.lima.report file.\n", call.=FALSE)

library(ggplot2,quietly = TRUE, warn.conflicts = FALSE)
library(Biostrings,quietly = TRUE, warn.conflicts = FALSE)
library(dplyr,quietly = TRUE, warn.conflicts = FALSE)
library(tidyr,quietly = TRUE, warn.conflicts = FALSE)
library(viridis,quietly = TRUE, warn.conflicts = FALSE)
library(scales,quietly = TRUE, warn.conflicts = FALSE)
library(data.table,quietly = TRUE, warn.conflicts = FALSE)
#library(cowplot,quietly = TRUE, warn.conflicts = FALSE)

# The core function, change the implementation in this to add new features.
makeReport <- function(reportbh) {
  reportPath = args[1]
  
  report = as.data.frame(fread(reportPath,stringsAsFactors=FALSE))
  report$IdxFirstNamed[report$IdxFirstNamed == "-1"] = "X"
  report$IdxCombinedNamed[report$IdxCombinedNamed == "-1"] = "X"
  report$IdxSecondCandidateNamed[report$IdxSecondCandidateNamed == "-1"] = "X"
  report$IdxLowestNamed[report$IdxLowest == -1] = "X"
  report$IdxHighestNamed[report$IdxHighest == -1] = "X"
  report$BarcodePair = paste(report$IdxLowestNamed,report$IdxHighestNamed,sep="--")
  report$Barcoded = report$IdxLowestNamed!="X" & report$IdxHighestNamed!="X"
  
  unique_bps = report %>% filter(Barcoded) %>% filter(PassedFilters == 1) %>% distinct(BarcodePair)
  zmwYield = report %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW) %>% count(BarcodePair)
  # zmwYield = rename(zmwYield, NumZMWs = n)
  
  zmwYieldVsMeanScore1 = report %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, ScoreCombined) %>% group_by(BarcodePair) %>% summarise(MeanScore=mean(ScoreCombined))
  zmwYieldVsMeanScore2 = report %>% filter(Barcoded) %>% filter(BarcodePair %in% unique_bps$BarcodePair) %>% select(BarcodePair, ZMW, ScoreCombined) %>% group_by(BarcodePair) %>% count(BarcodePair)
  zmwYieldVsMeanScore = full_join(zmwYieldVsMeanScore1,zmwYieldVsMeanScore2,by="BarcodePair") # %>% rename(NumZMWs=n)
  
  
  # g1 = ggplot(zmwYieldVsMeanScore) +
  #   geom_jitter(aes(MeanScore, NumZMWs)) +
  #   coord_cartesian(xlim = c(0, 100), ylim = c(0, max(zmwYieldVsMeanScore$NumZMWs)*1.1)) +
  #   theme_minimal()+
  #   ylab("ZMW yield")+xlab("Mean Score")
  # 
  # g2 = ggplot(zmwYieldVsMeanScore) +
  #   geom_jitter(aes(MeanScore, log10(NumZMWs))) +
  #   coord_cartesian(xlim = c(0, 100)) +
  #   theme_minimal()+
  #   ylab("ZMW yield log10")+xlab("Mean Score")
  # 
  # g3 = ggplot(zmwYieldVsMeanScore) +
  #   geom_hex(aes(MeanScore, NumZMWs)) +
  #   coord_cartesian(xlim = c(0, 100), ylim = c(0, max(zmwYieldVsMeanScore$NumZMWs)*1.1)) +
  #   theme_minimal()+
  #   ylab("ZMW yield")+xlab("Mean Score")
  # 
  # g4 = ggplot(zmwYieldVsMeanScore) +
  #   geom_hex(aes(MeanScore, log10(NumZMWs))) +
  #   coord_cartesian(xlim = c(0, 100)) +
  #   theme_minimal()+
  #   ylab("ZMW yield log10")+xlab("Mean Score")
  
  #g = plot_grid(g1,g3,g2,g4, labels = c("A", "B", "C", "D"), ncol = 2)
  #ggsave("summary_meanscore_vs_yield.png",g,width=20,height=15,dpi=150,units="cm")
  
  g = ggplot(zmwYield) +
    geom_histogram(aes(n),fill="gray",color="black",alpha=.3)+
    scale_y_continuous(labels=comma)+
    theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + xlab("Number of ZMWs") + ylab("Number of Barcoded Samples")
  # ggsave("summary_yield_zmw.png",g,width=20,height=15,dpi=150,units="cm")
  reportbh$ggsave(
    "summary_yield_zmw.png",
    g,
    width = 20,
    height = 15,
    units="cm",
    id = "summary_yield_zmw",
    title = "summary_yield_zmw",
    caption = "summary_yield_zmw",
    tags = c("lima")
  )
  
  # g = ggplot(report) +
  #   geom_histogram(aes(ScoreCombined),fill="gray",color="black",alpha=.3,binwidth = 1)+
  #   scale_y_continuous(labels=comma)+ scale_x_continuous(limits = c(0, 100))+
  #   theme_minimal() + theme(axis.text.x = element_text(hjust=1)) + xlab("Mean Barcode Score") + ylab("Number of Barcoded Samples")
  # ggsave("summary_score_hist.png",g,width=20,height=15,dpi=150,units="cm")
  # 
  # binned = report %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined) %>% select(BarcodePair, ScoreCombined) %>% arrange(BarcodePair) %>% group_by(BarcodePair) %>%  count(ScoreCombined) %>% arrange(BarcodePair, ScoreCombined)
  # binned = rename(binned, counts=n)
  # g = ggplot(binned) +
  #   geom_bin2d(aes(BarcodePair,ScoreCombined,fill=counts),stat = 'identity') + scale_fill_viridis() + theme_minimal() +
  #   theme(axis.text.x=element_blank(),
  #         axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
  #   scale_y_continuous(limits = c(0, 100))+
  #   xlab("Barcoded Samples") + ylab("Mean Barcode Score")
  # ggsave("summary_score_hist_2d.png",width=50,height=15,dpi=150,units="cm")
  # 
  # tryCatch({report$ReadLengths = sapply(report$ReadLengths,function(x) list(as.numeric(unlist(strsplit(x,",")))))},error=function(e){})
  # names(report$ReadLengths) = c()
  # readLengthsUnnested = report %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined) %>% select(ReadLengths, BarcodePair) %>% unnest(ReadLengths)
  # g = ggplot(readLengthsUnnested) +
  #   geom_bin2d(aes(x=BarcodePair,y=ReadLengths),binwidth=1000) + scale_fill_viridis() + theme_minimal() +
  #   theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
  #   xlab("Barcoded Samples") +
  #   ylab("Read Length")
  # ggsave("summary_read_length_hist_2d.png",width=50,height=15,dpi=150,units="cm")
  # 
  # report$HQLength = sapply(report$ReadLengths,sum)
  # g = ggplot(report %>% filter(Barcoded) %>% filter(IdxFirst == IdxCombined)) +
  #   geom_bin2d(aes(x=BarcodePair,y=HQLength),binwidth=1000) + scale_fill_viridis() + theme_minimal() +
  #   theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5))+
  #   xlab("Barcoded Samples") +
  #   ylab("HQ Length")
  # ggsave("summary_hq_length_hist_2d.png",width=50,height=15,dpi=150,units="cm")
  
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