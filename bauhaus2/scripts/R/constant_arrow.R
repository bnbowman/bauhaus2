#!/usr/bin/env Rscript
# Fit a constant rate arrow model to an alignment/reference and output the
# parameters as a CSV

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
library(unitem)
library(nnet)

## PARAMETERS THAT SHOULD BECOME TASK OPTIONS
# Used to filter out alignments that don't have enough data for fitting
MIN_ALN_LENGTH = 900 # Should be larger, but test data was ~930 bp in size and wanted to keep that working.
# Set up sample size of the sampled ZMW for each condition:
SAMPLING_SIZE = 500

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
  "Iterations"
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
           outputcsv) {
    loginfo("Running Arrow Training.")
    loginfo(paste("Input Aln:", input_aln))
    loginfo(paste("Input Ref:", input_ref))
    loginfo(paste("Requested Sampling Size:", SAMPLING_SIZE))
    loginfo(paste("Output CSV:", outputcsv))
    loginfo(paste(
      "R_LIBS is: ",
      .libPaths(),
      sep = "",
      collapse = "\n"
    ))

    # Commented out test data
    #input_aln = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/005/005573/tasks/pbalign.tasks.consolidate_alignments-0/combined.alignmentset.xml"
    #input_ref = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/005/005572/pacbio-reference/All4mers_circular_215x_l150070/referenceset.xml"
    input_ref = pbbamr::getReferencePath(as.character(input_ref))
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
      write.csv(errormode, outputcsv, row.names = F)
      logging::loginfo(paste("Wrote CSV to ", outputcsv))
      return(0)
    }
    # Decide the sampling size
    ZMWS_TO_SAMPLE = min(nrow(indFilter), SAMPLING_SIZE)
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
        predictions$CTX = fit$sPmf$CTX
        predictions = predictions[,c(1:4)]

        # Dark rate
        darkCols <- which(csv_names == "A.Dark.A"):which(csv_names == "T.Dark.T")
        errormode[i, darkCols] = predictions[c(5:8), 4]

        # Merge rate
        mergeCols <- which(csv_names == "A.Merge.A"):which(csv_names == "T.Merge.T")
        errormode[i, mergeCols] = predictions[c(1:4), 4] - predictions[c(5:8), 4]

        # Match rate
        matchCols <- which(csv_names == "A.Match.A"):which(csv_names == "T.Match.T")
        errormode[i, matchCols] = predictions[, 1] * as.vector(as.matrix(baseAgg(fit$mPmf)[, c(2:5)]))

        # When insert a same base, use branch
        branchCols <- which(csv_names %in% paste(bases, ".Insert.", bases, sep = ""))
        errormode[i, branchCols] = (predictions[1, 2] * as.vector(as.matrix(baseAgg(fit$bPmf)[, c(2:5)])))[c(1, 6, 11, 16)]

        # When insert a different base, use stick
        stickCols <- setdiff(which(csv_names == "A.Insert.A"):which(csv_names == "T.Insert.T"), branchCols)
        errormode[i, stickCols] = (predictions[, 3] * as.vector(as.matrix(baseAgg(fit$sPmf)[, c(2:5)])))[c(2:5, 7:10, 12:15)]


        # Get the alignment length, accounting for any filtered bases
        errormode[i, "AlnTLength"] = sum(sapply(singleZMW, function(x) sum(x$ref != "-")))
        errormode[i, "Time"] = fit$time_s
        errormode[i, "Iterations"] = length(fit$likelihoodHistory)
      }
    }

    write.csv(errormode, outputcsv, row.names = F)
    logging::loginfo(paste("Wrote CSV to ", outputcsv))
    return(0)
  }

constantArrowRtc <- function(rtc) {
  return(
    constantArrow(
      rtc@task@inputFiles[1],
      rtc@task@inputFiles[2],
      rtc@task@outputFiles[1]
    )
  )
}


# Example populated Registry for testing
#' @export
PBIReseqconditionRegistryBuilder <- function() {
  r <- registryBuilder(PB_TOOL_NAMESPACE, "constant_arrow.R run-rtc ")

  registerTool(
    r,
    "constant_arrow",
    "0.0.1",
    c(FileTypes$DS_ALIGN, FileTypes$DS_REF),
    c(FileTypes$CSV),
    16,
    TRUE,
    constantArrowRtc
  )
  return(r)
}

## Add this line to enable logging
basicConfig()
q(status = mainRegisteryMainArgs(PBIReseqconditionRegistryBuilder()))
