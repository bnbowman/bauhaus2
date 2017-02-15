#!/usr/bin/env Rscript
library(pbbamr)
library(pbcommandR)
library(ggplot2)
library(tidyr)
library(dplyr)
library(logging)
library(data.table)
library(parallel)
library(doParallel)

ASP_RATIO = 0.5
SAMPLE_DOWN = FALSE # Sample down BAMs for faster processing/debugging
N = c(10, 8) # BLock sizes

## Setup cluster
n_cores = parallel::detectCores() - 1
# Fork for speed
cl <- makeCluster(n_cores, type="FORK")
registerDoParallel(cl)


# Get the alignment statistics, combining across subreads if applicable
getSummaryTable <- function(alnxml, fastaname)
{
  logging::loginfo(paste("Getting data for:", alnxml))
  #alnxml = "/pbi/dept/secondary/siv/smrtlink/smrtlink-beta/smrtsuite_166987/userdata/jobs_root/036/036727/tasks/pbalign.tasks.consolidate_alignments-0/combined.alignmentset.xml"
  #fastaname = getReferencePath(as.character(report$condition.table$referenceset[1]))
  bam <- loadPBI2(alnxml)
  logging::loginfo("Index Loaded")
  if (SAMPLE_DOWN) { 
    logging::loginfo("Downsampling BAM index")
    bam = bam[sample(nrow(bam), 400),] 
  }
  bam$X = pbbamr::getHoleX(bam$hole)
  bam$Y = pbbamr::getHoleY(bam$hole)
  bam$AlnTempLength = bam$tend - bam$tstart
  
  # Function to load an alignment and calculate a bunch of summary statistics
  getAlnSummaryStats <- function(tbl) {
    # First let's aggregate across the subreads if applicable
    if (nrow(tbl) > 1) {
      new_tbl = tbl %>% summarise(file = first(file),
                                  hole = first(hole),
                                  matches = sum(matches),
                                  mismatches = sum(mismatches),
                                  inserts = sum(inserts),
                                  dels = sum(dels),
                                  X = first(X),
                                  Y = first(Y),
                                  AlnTempLength = sum(AlnTempLength),
                                  qstart = min(qstart),
                                  qend = max(qend),
                                  tstart = min(tstart),
                                  tend = max(tend),
                                  astart = min(astart),
                                  aend = max(aend))
      tmp <- data.table::rbindlist(loadAlnsFromIndex(tbl, fastaname))
    }
    else {
      new_tbl = tbl[,c("file", "hole", "matches", "mismatches", "inserts", "dels", "X", "Y",
                       "AlnTempLength", "qstart", "qend", "tstart", "tend", "astart", "aend")]
      tmp <- loadAlnsFromIndex(tbl, fastaname)[[1]]
    }
    # Calculate the total advance time
    totalTime = tmp %>% summarize(TotalTime = (sum(ipd, na.rm = TRUE) + sum(pw, na.rm = TRUE)))
    # Now let's get the median IPD, PW and if available pkmid per base
    medians  = tmp %>% group_by(ref) %>% 
                     summarize(IPD = median(ipd, na.rm = TRUE),
                               PW = median(pw, na.rm = TRUE),
                               Pkmid = ifelse("pkmid" %in% names(tmp), median(pkmid, na.rm = TRUE), NA)) %>% 
                     ungroup()
    # Remove the insertions
    medians = medians[medians$ref != "-",]
    # Ditch any dummy values we put in, these columns will all be NA for pkmid or sf if it wasn't available
    medians = medians[, apply(medians, 2, function(x) ifelse(all(is.na(x)), FALSE, TRUE))]
    # Now spread the data from long to wide format for each thing we measured
    goLong <- function(covar) {
      long = medians[, c("ref", covar)] %>% spread_("ref", covar, sep = paste("_", covar, "_", sep = ""))
      # Now remove the ref_ in front of all of these
      colnames(long) = sub("ref_", "", colnames(long))
      long
    }
    # And concatenate it all, adding in SNR (and start frame if available) and return
    toReturn = do.call(cbind, c(new_tbl,
                                 lapply(colnames(medians)[-1], goLong),
                                 totalTime,
                                 tmp[1, grep("snr", colnames(tmp))]))
    if("sf" %in% names(tmp)) {toReturn$sf = min(tmp$sf)}
    toReturn
  }
  # Calculate summary statistic for each alignment
  logging::loginfo("Calculating Statistics over Loaded Alignments")
  res = bam %>% group_by(file, hole) %>% do(getAlnSummaryStats(.)) %>% ungroup()
  logging::loginfo("Parsed and Loaded Alignment Values")
  
  # Now let's get the frame rate from all BAM files
  frameRates = sapply(getBAMNamesFromDatasetFile(alnxml),
                      function(bamFile) as.numeric(as.character(loadHeader(bamFile)$readgroups$framerate[1])),
                      USE.NAMES = FALSE)
  frameRate = unique(frameRates)
  if (length(frameRate) != 1) { stop("BAM files in dataset had different frame rates.")}
  res$PolRate <- res$AlnTempLength / (res$TotalTime * frameRate)
  if ("sf" %in% names(res)) { res$StartTime <- res$sf / frameRate }
  
  # Add in Error Rates
  res$MismatchRate <- res$mismatches / res$AlnTempLength
  res$InsertionRate <- res$inserts / res$AlnTempLength
  res$DeletionRate <- res$dels / res$AlnTempLength
  res$Accuracy <-
    1 - res$MismatchRate - res$InsertionRate - res$DeletionRate
  res
}
#----------------------------------------------------------------

summarizeStats <- function(df) {
  # For some variables we want the median, others the max
  df2 = bind_cols(
    summarize_at(df, c("snrA", "snrC", "snrG", "snrT", "Accuracy", "MismatchRate"), median, na.rm = TRUE),
    summarize_at(df, c("AlnTempLength"), max, na.rm = TRUE),
    summarize(df, Count = n())
  )
  if ("Pkmid_C" %in% names(df)) df2$PkmidC = median(df$PkmidC, na.rm = TRUE)
  df2
}

summarizeBlocks_N_by_N <- function(res, N)
{
  if (length(N) == 1) { N <- c(N, N) }
  # Define blocks they belong to
  res$xblock = (res$X + .5 * N[1]) %/% N[1]
  res$yblock = (res$Y + .5 * N[2]) %/% N[2]
  
  # Now calculate various statistics for each block
  df = res %>% group_by(xblock, yblock) %>% do(summarizeStats(.))  %>% ungroup()
  df$X = df$xblock * N[1]
  df$Y = df$yblock * N[2]
  df
}

#----------------------------------------------------------------


#----------------------------------------------------------------
# Loading uniformity histogram and metrics
#----------------------------------------------------------------

drawHistogramForUniformity <- function(report, df) {
    title <- "Loading Uniformity"
    id = "loading_uniformity_hist_smrtlink"
    xlabel <- paste("# of Alignments per", N[1], "x", N[2], "block of ZMWs")
    ylabel <- paste("# of",  N[1], "x", N[2], "blocks")
    myplot <- ggplot(df, aes(x = df$Count)) + geom_histogram() + 
              labs(title = title, x = xlabel, y = ylabel) + facet_wrap( ~ Condition)
    pngfile <- paste(id, "png", sep = ".")
    report$ggsave(pngfile, myplot, id = id, title = title, caption = title)
}

getLoadingEfficiency <- function(z)
{
  pol_pM <- z / (N[1] * N[2])
  maxConc <- floor(3 / min(pol_pM[pol_pM > 0]))
  conc <- seq(1, maxConc, 1)
  lambda <- pol_pM %o% conc
  single <- lambda * exp(-lambda)
  total <- colMeans(single)  # assume uniform
  100 * max(total, na.rm = TRUE) * exp(1)
}

writeUniformityMetricsTable <- function(report, df) {
    newtbl = df %>% group_by(Condition) %>%
              summarize(Cutoff = round(max(1, boxplot(Count, plot = FALSE)$stat[1])),
                        LowLoadFrac = sum(Count < Cutoff) / length(Count),
                        Mean = mean(Count[Count >= Cutoff]),
                        Var = var(Count[Count >= Cutoff]),
                        PoissonDisp = Var / Mean - 1,
                        nRead = sum(Count),
                        NumBlks = length(Count),
                        NumBlksAboveCutoff = sum(Count >= Cutoff),
                        T1_WangEtAll = PoissonDisp * sqrt(2 / NumBlksAboveCutoff),
                        NonUniformityPenalty = getLoadingEfficiency(Count),
                        COM.x = mean(X) - 595,
                        COM.y = mean(Y) - 544,
                        SNR_A = mean(snrA, na.rm = TRUE),
                        SNR_C = mean(snrC, na.rm = TRUE),
                        SNR_G = mean(snrG, na.rm = TRUE),
                        SNR_T = mean(snrT, na.rm = TRUE)) %>% ungroup()
    report$write.table(newtbl, id = "uniform_metrics", title = "Uniformity Metrics")
}

#----------------------------------------------------------------

#----------------------------------------------------------------
# Plotting heatmaps
#----------------------------------------------------------------

removeOutliers <- function(m, name)
{
  m <- subset(m,!is.na(m[, name]))
  values <- m[, name]
  m[, name] <-
    ifelse(values <= boxplot(m[, name], plot = FALSE)$stat[5], values, NA)
  m
}

plotSingleSummarizedHeatmap <-
  function(report, res, outcome, limits = NULL, title = outcome)
  {
    # Make it numeric if it isn't 
    
    logging::loginfo(paste("Making heatmap for: ", outcome))
    plotID <- paste(pbcommandR:::convertIDs(title), "_summarized_heatmap", sep = "")
    pngfile <- file.path(paste(plotID, "png", sep = "."))
    title <- paste(title, " (median per ", N[1], " x ", N[2], " block)", sep = "")
    ci = match(outcome, names(res))
    # Convert integer to numeric to enable continuous scale
    res[[outcome]] =  as.numeric(res[, get(outcome)])
    if (is.null(limits))
    {
      tmp <- removeOutliers(res, outcome)
      myplot = ggplot(tmp, aes_string(y = "X", x = "Y", fill = outcome)) + 
               geom_tile() + 
               scale_colour_gradientn(colours = rainbow(10))
    }
    else
    {
      myplot <- ggplot(res, aes_string(y = "X", x = "Y", fill = outcome)) + 
                geom_tile() + 
                scale_fill_gradientn(colours = rainbow(10), limits = limits)
    }
    myplot = myplot + 
             labs(title = title) +
             theme(aspect.ratio = ASP_RATIO) + facet_wrap(~ Condition)
    report$ggsave(pngfile, myplot, id = plotID, title = title, caption = title)
}

makeSummarizedPlotsAndTables <- function(report, df)
{
  ## MAKE A COLLECTION OF HEATMAP PLOTS
  plotsToMake = list(
    list(outcome ="Count", limits = c(0, 60), title = "Count"),
    list(outcome = "Accuracy", limits = c(0.7, 0.85), title = "Accuracy"),
    list(outcome = "AlnTempLength", limits = c(500, 9000), title = "Aligned Template Length"),
    list(outcome = "AlnTempLength", limits = c(500, 30000), title = "Aligned Template Ext. Range"),
    list(outcome = "rStartExtRange", limits = c(0, 25000), title = "rStart Ext. Range"),
    list(outcome = "snrC", limits = c(5, 13), title = "SNR C"),
    list(outcome = "snrA", limits = c(5, 13), title = "SNR A"),
    list(outcome = "snrG", limits = c(5, 13), title = "SNR G"),
    list(outcome = "snrT", limits = c(5, 13), title = "SNR T"),
    list(outcome = "Pkmid_C", limits = c(100, 500), title = "Pkmid C")
  )
  lapply(plotsToMake, function(ol) {
    if (ol$outcome %in% names(df)) {
      plotSingleSummarizedHeatmap(report, df, ol$outcome, ol$limits, ol$title)
    } else {
      logging::loginfo(paste("Skipping plot", ol$outcome, "variable not available"))
    }
    })
  
  # NOW HISTOGRAMS FOR UNIFORMITY
  drawHistogramForUniformity(report, df)
  
  # AND FINALLY SOME A METRICS TABLE
  writeUniformityMetricsTable(report, df)
}

makeReport <- function(report)
{
    ct = report$condition.table
    # Function to load all the data, then combine statistics in N[1] x N[2] blocks
    getData <- function(i) {
      condition = as.character(ct$condition[i])
      referenceset = as.character(ct$referenceset[i])
      alignmentset = as.character(ct$alignmentset[i])
      fastaname = getReferencePath(referenceset)
      res = getSummaryTable(alignmentset, fastaname)
      res$X <- 1164 - res$X
      df <- summarizeBlocks_N_by_N(res, N)
      df
    }
    logging::loginfo("Starting parallel data collection.")
    ## TODO: I was running into problems late at night with certain functions not being 
    ## exported, and dumped in this ls(.GlobalEnv) based on some stack overflow notes. 
    ## it appears to work just fine, but this could probably use another look to better understand
    ## how the env capture works for this function.
    all_data = foreach(i = 1:nrow(ct), .export = ls(.GlobalEnv), .packages = c("pbbamr")) %dopar% getData(i)
    logging::loginfo("Finished parallel data collection.")
    print(str(all_data))
    data = pbbamr::combineConditions(all_data, as.character(ct$condition))
    save(data, file="heatmapData.Rd")
    #load("conditions.Rd")
    logging::loginfo("Making Plots and Tables")
    makeSummarizedPlotsAndTables(report, data)
    report$write.report()
    0
}

#----------------------------------------------------------------

logging::basicConfig()

# Now we need to wrap this tool using these two lines. Simply change the
# arguments here to match your desired filename, tool name and report id.
rpt = pbReseqJob("heatmaps.R", "heatmap_maker",
                 makeReport,
                 reportid = "heatmaps",
                 reportTitle = "Heat Maps",
                 nproc = 4,
                 distributed = TRUE)

# Leave this as the last line in the file.
logging::basicConfig()
q(status = rpt())

stopCluster(cl)
# Testing code below
#load("/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/005/005301/tasks/pbcommandR.tasks.pbi_sampled_plotter-0/report.Rd")
#makeReport(report)
