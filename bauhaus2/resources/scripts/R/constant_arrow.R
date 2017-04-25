#!/usr/bin/env Rscript
# Fit a constant rate arrow model to an alignment/reference and output the
# parameters as a CSV

library(argparse)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(unitem)
library(nnet)
library(reshape2)
library(lazyeval)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

# load sample size for argument, default sample size = 1000
parser <- ArgumentParser()
<<<<<<< HEAD
parser$add_argument("--sampleByRef", nargs = 1, default = FALSE, help = "subsample ZMWs for different references or not")
parser$add_argument("--sampleSize", nargs = 1, default = 1000, help = "number of samples (ZMWs) for each condition")
try(args <- parser$parse_args())
set.seed(args$seed)

## PARAMETERS THAT SHOULD BECOME TASK OPTIONS
# Used to filter out alignments that don't have enough data for fitting
MIN_ALN_LENGTH = 1000 # Should be larger, but test data was ~930 bp in size and wanted to keep that working.
# Set up sample size of the sampled ZMW for each condition:
SAMPLING_SIZE = args$sampleSize
# Check whether the arrow model samples from each condition or from each condition and reference
# the enzymology group may rewrite the condition table, which chunks the data set by reference.
# To enable running constant arrow model for each reference, loading this option from CLI is allowed.
SAMPLE_BY_REF = args$sampleByRef

# Define a basic addition to all plots
plTheme <- theme_bw(base_size = 18)
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(size = 11, angle = 45, hjust = 1))
pd <- position_dodge(0.2)
dpi <- 72

# Output column names
# In below column names, ‘X.Insert.Y’ indicates the Y-insertion (read base) rate for a XX or NX context (template)
# Similar for match/mismatch events
csv_names = c(
  "ZMW",
  "SNR.A",
  "SNR.C",
  "SNR.G",
  "SNR.T",
  "A.Insert.A",
  "C.Insert.A",
  "G.Insert.A",
  "T.Insert.A",
  "A.Insert.C",
  "C.Insert.C",
  "G.Insert.C",
  "T.Insert.C",
  "A.Insert.G",
  "C.Insert.G",
  "G.Insert.G",
  "T.Insert.G",
  "A.Insert.T",
  "C.Insert.T",
  "G.Insert.T",
  "T.Insert.T",
  "A.Match.A",
  "C.Match.A",
  "G.Match.A",
  "T.Match.A",
  "A.Match.C",
  "C.Match.C",
  "G.Match.C",
  "T.Match.C",
  "A.Match.G",
  "C.Match.G",
  "G.Match.G",
  "T.Match.G",
  "A.Match.T",
  "C.Match.T",
  "G.Match.T",
  "T.Match.T",
  "A.Dark.A",
  "C.Dark.C",
  "G.Dark.G",
  "T.Dark.T",
  "A.Merge.A",
  "C.Merge.C",
  "G.Merge.G",
  "T.Merge.T",
  "AlnTLength",
  "Time",
  "Iterations",
  "Condition",
  "Reference"
)

##' Filters out data with large length discrepencies
##' param data Data to be filtered
# Filter out large descrepancies
# The idea is that if a read/template pair differ by more than 20% in length, they are not
# suitable for fitting.
filterData <- function(data) {
  noGood <- function(x) {
    nm = sum(x$read != "-")
    no = sum(x$ref != "-")
    dif = abs(1 - nm / no)
    dif < .3
  }
  Filter(noGood, data)
}

#' Main function to produce CSV given a json file and output path
constantArrow <-
  function(input_aln,
           input_ref,
           Condition,
           report) {
    loginfo("Running Arrow Training.")
    loginfo(paste("Input Aln:", input_aln))
    loginfo(paste("Input Ref:", input_ref))
    loginfo(paste("Requested Sampling Size:", SAMPLING_SIZE))
    loginfo(paste(
      "R_LIBS is: ",
      .libPaths(),
      sep = "",
      collapse = "\n"
    ))
    
    loginfo(paste("Fasta file:", input_ref))
    
    # Filter the data set
    ind = loadPBI(input_aln)
    org_size = nrow(ind)
    indFilter = ind[ind$tend - ind$tstart > MIN_ALN_LENGTH,]
    loginfo(paste("Filtered out", org_size - nrow(indFilter), "alignments for being too small for fitting"))
    
    # Handle case with no valid alignments, write empty CSV
    if (nrow(indFilter) == 0) {
      errormode <- data.frame(matrix(NA, nrow = 0, ncol = length(csv_names)))
      colnames(errormode) <- csv_names
      report$write.table(paste("errormode_", Condition, ".csv", sep = ''),
                         errormode,
                         id = "errormode",
                         title = "Constant Arrow Errormode")
      logging::loginfo(paste("Wrote empty CSV for ", Condition))
      return(errormode)
    }
    # Decide the sampling size
    ZMWS_TO_SAMPLE = min(nrow(indFilter), as.numeric(SAMPLING_SIZE))
    if (ZMWS_TO_SAMPLE != nrow(indFilter)) {
      sampled_rows = sample(nrow(indFilter), ZMWS_TO_SAMPLE)
    } else {
      sampled_rows = 1:nrow(indFilter)
    }
    loginfo(paste("Rows of Data Used:", length(sampled_rows)))
    sampled_ZMW <- indFilter$hole[sampled_rows]
    indFilter = indFilter[sampled_rows,]
    errormode <-
      data.frame(matrix(NA, nrow = length(sampled_rows), ncol = length(csv_names)))
    colnames(errormode) <- csv_names
    errormode$ZMW = sampled_ZMW
    errormode$Condition = Condition
    errormode$Reference = indFilter$ref
    errormode$AlnTLength = indFilter$tend - indFilter$tstart
    
    # Aggregate the pmf matrix
    baseAgg <- function(pmf) {
      pmf = aggregate(pmf[,c(1:4)], list(substr(pmf[, "CTX"], 2, 2)), function(x)
        (0.25 * x[1] + 0.75 * x[2]))
      pmf
    }
    
    bases <- c("A", "C", "G", "T")
    for (i in 1:nrow(errormode)) {
      if ((i %% 100) == 0) {
        loginfo(paste("Processing Number ", i))
      }
      singleZMW = loadSingleZmwHMMfromBAM(indFilter$offset[i], as.character(indFilter$file[i]), input_ref)
      errormode[i, paste("SNR.", bases, sep = "")] = as.numeric(attributes(singleZMW)[[1]])
      
      ## Filter out really discordant alignments, they create numeric issues
      singleZMW <- filterData(singleZMW)
      # Handle case where all data is filtered
      if (length(singleZMW) == 0) {
        loginfo("Warning!!! Alignment had all data removed by the length mismatch filter for this run.")
        errormode[i, 1:ncol(errormode)] = NA
      } else {
        # Fit hmm
        fit = hmm(read ~ 1,
                  singleZMW,
                  verbose = FALSE,
                  filter = FALSE,
                  use8Contexts = TRUE,
                  end_dif = 0.005)
        # Summerize model parameters
        predictions <- list()
        for (j in 1:8) {
          predictions[[j]] = predict(fit$models[[j]]$cfit, type = "probs")[1,]
        }
        predictions <- as.data.frame(matrix(unlist(predictions), ncol = 4, byrow = T))
        colnames(predictions) = colnames(fit$pseudoCounts) # copy the outcome names over
        CTX <- fit$sPmf$CTX
        
        # Dark rate
        darkCols <- which(csv_names == "A.Dark.A"):which(csv_names == "T.Dark.T")
        darkRows <- which(CTX == "NA"):which(CTX == "NT")
        errormode[i, darkCols] = predictions[darkRows, "Delete"]
        
        # Merge rate
        mergeCols <- which(csv_names == "A.Merge.A"):which(csv_names == "T.Merge.T")
        mergeRows <- which(CTX == "AA"):which(CTX == "TT")
        errormode[i, mergeCols] = predictions[mergeRows, "Delete"] - predictions[darkRows, "Delete"]
        
        # Match rate
        matchCols <- which(csv_names == "A.Match.A"):which(csv_names == "T.Match.T")
        matchVals <- predictions[, "Match"] * fit$mPmf[, bases]
        matchVals$CTX <- fit$mPmf$CTX
        errormode[i, matchCols] = as.vector(as.matrix(baseAgg(matchVals)[, bases]))
        
        # When insert a different base, use stick
        stickCols <- which(csv_names == "A.Insert.A"):which(csv_names == "T.Insert.T")  # also includes branch, will replace below
        stickVals <- predictions[, "Stick"] * fit$sPmf[, bases]
        stickVals$CTX <- fit$sPmf$CTX
        errormode[i, stickCols] = as.vector(as.matrix(baseAgg(stickVals)[, bases]))
        
        # When insert a same base, use branch
        branchCols <- which(csv_names %in% paste(bases, ".Insert.", bases, sep=""))
        branchVals <- predictions[, "Branch"] * fit$bPmf[, bases]
        branchVals$CTX <- fit$bPmf$CTX
        errormode[i, branchCols] = diag(as.matrix(baseAgg(branchVals)[, bases]))
        
        errormode[i, "Time"] = fit$time_s
        errormode[i, "Iterations"] = length(fit$likelihoodHistory)
      }
    }
    return(errormode)
  }

makeReport <- function(report) {
  # Load the revised condition table if the sample needs to be subsampled by references
  if (SAMPLE_BY_REF) {
    conditions = read.csv("contig-chunked-condition-table.csv")
  } else {
    conditions = report$condition.table
  }
  n = length(levels(conditions$Condition))
  clFillScale <<- getPBFillScale(n)
  clScale <<- getPBColorScale(n)
  
  # Generate constant Arrow CSV file
  errormodeList = lapply(1:n, function(i) {
    constantArrow(as.character(conditions$MappedSubreads[i]), as.character(conditions$Reference[i]), as.character(conditions$Condition[i]), report)
  })
  
  errormodeCombine = rbindlist(errormodeList)
  loginfo("Making constant Arrow CSV file")
  report$write.table("errormode.csv",
                     errormodeCombine,
                     id = "errormode",
                     title = "Constant Arrow Errormode")
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter(
    CONDITION_TABLE,
    "reports/ConstantArrowFishbonePlots/modelReport.json",
    "Constant Arrow csv file")
  makeReport(report)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
