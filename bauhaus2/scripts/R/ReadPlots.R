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

#library(devtools)
#install_github("PacificBiosciences/pbbamr")

#' Define a basic addition to all plots
plTheme <- theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
themeTilt = theme(axis.text.x = element_text(angle = 90, hjust = 1))

# These are "global" and do change state at certain points ( <<- is called later on)
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")


makeGapSizePlots <- function(data, img_base, reportDir) {
  loginfo("Making Gap Size Plots")
  gaps = data[["gapSizes"]]


  # Convert to relative frequencies
  gapf = gaps %>% group_by(Condition) %>% mutate(refFreq = refCnts / sum(refCnts),
                                                 readFreq = readCnts / sum(readCnts)) %>% ungroup()

  ## Plot Deletion Sizes
  img_name = paste(img_base, "deletion_norm.png", sep="")
  img_path = file.path(reportDir, img_name)
  tp = ggplot(gapf, aes(x=gapSize, y = refFreq, group=Condition, color=Condition)) + geom_line() + geom_point() +
    clScale + plTheme + labs(x="Deletion Size", y="Relative Frequency (Sum = 1)",
                                 title = "Deletion Sizes")
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pd <- methods::new("ReportPlot",
                     id = "deletion_size_norm",
                     image = img_name,
                     title = "Deletion Sizes",
                     caption = "Deletion Sizes")

  img_name = paste(img_base, "deletion_log.png", sep="")
  img_path = file.path(reportDir, img_name)
  png(img_path)
  print(tp + scale_y_log10() + labs(y = "Log10 Relative Frequency"))
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pdl <- methods::new("ReportPlot",
                      id = "deletion_size_log",
                      image = img_name,
                      title = "Deletion Sizes (Log)",
                      caption = "Deletion Sizes (Log)")


  ## Now plot insertion sizes
  img_name = paste(img_base, "insertion_norm.png", sep="")
  img_path = file.path(reportDir, img_name)
  tp = ggplot(gapf, aes(x=gapSize, y = readFreq, group=Condition, color=Condition)) + geom_line() + geom_point() +
    clScale + plTheme + labs(x="Insertion Size", y="Relative Frequency (Sum = 1)",
                                 title = "Insertion Sizes")
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pi <- methods::new("ReportPlot",
                     id = "insert_size_norm",
                     image = img_name,
                     title = "Insertion Sizes",
                     caption = "Insertion Sizes")

  img_name =  paste(img_base, "insertion_log.png", sep="")
  img_path = file.path(reportDir,img_name)
  png(img_path)
  print(tp + scale_y_log10() + labs(y = "Log10 Relative Frequency"))
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pil <- methods::new("ReportPlot",
                      id = "insertion_size_log",
                      image = img_name,
                      title = "Insertion Sizes (Log)",
                      caption = "Insertion Sizes (Log)")
  return(list(pd, pdl, pi, pil))
}

makeMismatchPlots <- function(data, img_name, reportDir) {
  loginfo("Making Mismatch Plots")
  mm = data[["mismatches"]]

  # Remove uninteresting rows
  mm = mm[mm$ref != mm$read &
          mm$ref != "N" & mm$ref != "-" &
          mm$read!= "N" & mm$read != "-",]

  # Convert to relative frequencies
  mmf = mm %>% group_by(Condition) %>% mutate(freq = cnts / sum(cnts)) %>% ungroup()
  mmf$Error = mmf$ref:mmf$read

  img_path = file.path(reportDir, img_name)
  tp = ggplot(mmf, aes(x=Error, y=freq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
              clFillScale + plTheme + labs(x="Ref:Read", y="Relative Frequency (Sum = 1)",
                                           title = "Mismatch Frequencies")
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pv <- methods::new("ReportPlot",
                     id = "mismatch_rate",
                     image = img_name,
                     title = "Mismatch Rates",
                     caption = "Mismatch Rates")
  return(list(pv))
}

makeIndelPlots <- function(data, img_base, reportDir) {
  loginfo("Making Indel Plots")
  ind = data[["indelCnts"]]

  # Remove uninteresting rows
  ind = ind[ind$bp != "-" & ind$bp != "N",]
  # Convert to relative frequencies
  indf = ind %>% group_by(Condition) %>% mutate(delFreq = delFromRefCnt / sum(delFromRefCnt),
                                              insFreq = insertIntoReadCnt / sum(insertIntoReadCnt)) %>% ungroup()

  img_name = paste(img_base, "deletion.png", sep="")
  img_path = file.path(reportDir, img_name)
  tp = ggplot(indf, aes(x=bp, y = delFreq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
       clFillScale + plTheme + labs(x="Deleted Base", y="Relative Frequency (Sum = 1)",
                                    title = "Deletion Frequencies")
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pd <- methods::new("ReportPlot",
                     id = "deletion_rate",
                     image = img_name,
                     title = "Deletion Rates",
                     caption = "Deletion Rates")

  img_name = paste(img_base, "insertion.png", sep="")
  img_path = file.path(reportDir, img_name)
  tp = ggplot(indf, aes(x=bp, y = insFreq, fill=Condition)) + geom_bar(stat="identity", position = "dodge") +
              clFillScale + plTheme + labs(x="Inserted Base", y="Relative Frequency (Sum = 1)",
                                           title = "Insertion Frequencies")
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pi <- methods::new("ReportPlot",
                     id = "insertion_rate",
                     image = img_name,
                     title = "Insertion Rates",
                     caption = "Insertion Rates")

  return(list(pd, pi))
}

makeClippingPlot <- function(data, img_name, reportDir) {
  loginfo("Making Clipping Plots")
  clips = data[["clipping"]]

  # Convert to relative frequencies
  clipsf = clips %>% group_by(Condition) %>% mutate(freq = cnts / sum(cnts)) %>% ungroup()

  img_path = file.path(reportDir, img_name)
  tp = ggplot(clipsf[clipsf$state=="Clipped", ], aes(x=Condition, y=freq, fill=Condition)) + geom_bar(stat="identity") +
    clFillScale + plTheme + labs(x="Condition", y="Soft Clipping Frequency", title = "Percentage of Bases Soft Clipped in Alignments") +
    themeTilt
  png(img_path)
  print(tp)
  dev.off()
  loginfo(paste("Wrote image to ", img_path, sep = ""))
  pv <- methods::new("ReportPlot",
                     id = "clip_rate",
                     image = img_name,
                     title = "Clipping Rates",
                     caption = "Clipping Rates")
  return(list(pv))
}

makePlots <- function(data, reportOutputPath) {
  reportDir <- dirname(reportOutputPath)
  loginfo(paste("Report directory:", reportDir))
  plotGroupId <- "plotgroup_a"
  # see the above comment regarding ids. The Plots must always be provided
  # as relative path to the output dir
  mm = makeMismatchPlots(data, "mismatch.png", reportDir)
  pid = makeIndelPlots(data, "rate_", reportDir)
  pta = makeGapSizePlots(data, "indel_", reportDir)
  pc = makeClippingPlot(data, "clipping.png", reportDir)
  pg <- methods::new("ReportPlotGroup",
                     id = plotGroupId,
                     plots = c(mm, pid, pta, pc))
  list(pg)
}

# Get the full path if it is listed as relative
# TODO: Move this to pbbamr
getReferencePath <- function(p) {
  dp = pbbamr::getFastaFileNameFromDatasetFile(p)
  file.path(dirname(p), basename(p))
  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
  ap = rev(split_path(dp))
  if (ap[1] == ".") {
    return(do.call(file.path, as.list(c(dirname(p), ap[2:length(ap)]))))
  } else{
    return (dp)
  }
}

#' Main function to produce plots given a json file and output path
readPlotReseqConditionMain <- function(reseqConditions, reportOutputPath) {
  loginfo("Running Read Plot with conditions ", reseqConditions)
  loginfo(paste("Output path is:", reportOutputPath))
  loginfo(paste("R_LIBS is: ", .libPaths(), sep = "",collapse = "\n"))

  # Convert json into a data frame
  #reseqConditions = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/services_ui/smrtlink_services_ui-internal-0.7.2-183537/reseq-conditions-31b6bc58-e583-4a22-bd9c-9805c5474bbf.json"
  #reportOutputPath = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/000/000061/tasks/pbcommandR.tasks.accplot_reseq_condition-0/file.json"

  decoded <- loadReseqConditionsFromPath(reseqConditions)
  conds = decoded@conditions
  tmp = lapply(conds, function(z) data.frame(condition = z@condId,
                                             subreadset = z@subreadset,
                                             alignmentset = z@alignmentset,
                                             referenceset = z@referenceset))
  cond_table = do.call(rbind, tmp)

  ## Let's set the graphic defaults
  n = length(levels(cond_table$condition))
  clFillScale <<- getPBFillScale(n)
  clScale <<- getPBColorScale(n)


  # Load the read error rates for each dataset
  dfs = lapply(1:nrow(cond_table), function(i) {
    alnFile = as.character(cond_table$alignmentset[i])
    refFile = as.character(cond_table$referenceset[i])
    fasta = getReferencePath(refFile)
    loginfo(paste("Loading alignment set:", alnFile))
    pbbamr::getReadReport(datasetname = alnFile, indexedFastaName = fasta )
  })
  loginfo("Finished loading aligned read data.")
  # Now combine into one large data frame
  # TODO: I hate using indexing here, perhaps another solution?
  data = lapply(1:length(dfs[[1]]), function(i) {
    mats = lapply(dfs, function(d) d[[i]])
    combineConditions(mats, as.character(cond_table$condition))
    })
  names(data) <- names(dfs[[1]])
  loginfo("Plotting read level metrics")


  plotGroups <- makePlots(data, reportOutputPath)

  reportUUID <- UUIDgenerate()
  reportId <- "read_based_metrics"
  version <- "1.0.0"
  attributes <- list()

  report <- methods::new("Report",
                         uuid = reportUUID,
                         version = version,
                         id = reportId,
                         title = "All ZMW Calculated Metrics",
                         plotGroups = plotGroups,
                         attributes = attributes,
                         tables = list())

  writeReport(report, reportOutputPath)
  logging::loginfo(paste("Wrote report to ", reportOutputPath))
  return(0)
}

readPlotReseqCondtionRtc <- function(rtc) {
  return(readPlotReseqConditionMain(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Example populated Registry for testing
#' @export
ReadReseqconditionRegistryBuilder <- function() {

  r <- registryBuilder(PB_TOOL_NAMESPACE, "ReadPlots.R run-rtc ")

  registerTool(r,
               "readplot_reseq_condition",
               "0.1.0",
               c(FileTypes$RESEQ_COND), c(FileTypes$REPORT), 1, TRUE, readPlotReseqCondtionRtc)
  return(r)
}

## Add this line to enable logging
basicConfig()
q(status = mainRegisteryMainArgs(ReadReseqconditionRegistryBuilder()))
