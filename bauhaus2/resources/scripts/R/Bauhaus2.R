library(data.table)
library(dplyr)
library(ggplot2)
library(jsonlite)

##
## Core functions for operation in a bauhaus2/zia environment.
##

# Random utils

chkClass <- function(var, classname, msg) {
  if (!(classname %in% class(var))) {
    stop(msg)
  }
}

#' Check the file ends as a png
chkPng <- function(fname) {
  substr(fname, nchar(fname) - 3, nchar(fname)) == '.png'
}

#' Check the file ends as a csv
chkCsv <- function(fname) {
  substr(fname, nchar(fname) - 3, nchar(fname)) == '.csv'
}

#' Returns a default there for making plots.
#' @export
getPBTheme <- function() {
  return(ggplot2::theme_bw(base_size = 14))
}

defaultPalette = "Set1"
defaultLargePaletteGetter = colorRampPalette(RColorBrewer::brewer.pal(9, "Set1"))

#' Get the default color scheme, adding more colors if they are available.
#' @export
getPBColorScale <- function(numLevels = 9) {
  if (numLevels <= 9) {
    return(ggplot2::scale_colour_brewer(palette = defaultPalette))
  } else {
    return(ggplot2::scale_color_manual(values = defaultLargePaletteGetter(numLevels)))
  }
}

#' Get the default color scheme for fills, adding more colors if the current
#' palette is maxed out
#' @export
getPBFillScale <- function(numLevels = 9) {
  if (numLevels <= 9) {
    return(ggplot2::scale_fill_brewer(palette = "Set1"))
  } else {
    return(ggplot2::scale_fill_manual(values = defaultLargePaletteGetter(numLevels)))
  }
}

#' Generate a single heatmap corresponding to one column of a data frame.
#'
#' @param res output of \code{\link{convenientSummarizer}} - bam data summarized into N[1] x N[2] blocks of ZMWs
#' @param n string name of column of res to be plotted.
#' @param label string label for plot
#' @param N vector of length two giving dimensions of blocks of ZMWs
#' @param limits (optional) vector of length two describing upper and lower bounds in heatmap range - in order to compare across heatmaps
#' @seealso \code{\link{drawSummarizedHeatmaps}} which calls this function
#' @export

plotSingleSummarizedHeatmap = function(report,
                                       res,
                                       n,
                                       label,
                                       N,
                                       limits = NULL,
                                       sts = FALSE)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  title = paste(n, " (summarized into ", N[1], " x ", N[2], " blocks) : ", label, sep = "")
  
  loginfo(paste("\t Draw", n, "heatmap for condition:", label))
  
  if (is.null(limits))
  {
    tmp = removeOutliers(res, n)
    myplot = (
      qplot(
        data = tmp,
        Y,
        X,
        size = I(0.75),
        color = tmp[, n]
      ) +
        scale_colour_gradientn(colours = rainbow(10)) +
        labs(title = title) +
        scale_y_reverse() +
        scale_x_continuous(position = "top") +
        theme(aspect.ratio = ASP_RATIO)
    )
    
  }
  else
  {
    # Above range tan, below range black, na.value grey
    low = subset(res, res[, n] < limits[1])
    high = subset(res, res[, n] > limits[2])
    tmp = subset(res, res[, n] >= limits[1] & res[, n] <= limits[2])
    myplot = (
      qplot(
        data = tmp,
        Y,
        X,
        size = I(0.75),
        color = tmp[, n]
      ) +
        scale_colour_gradientn(colours = rainbow(10), limits = limits) +
        geom_point(
          data = low,
          aes(Y, X),
          size = I(0.75),
          alpha = I(0.05),
          colour = "black"
        ) +
        geom_point(
          data = high,
          aes(Y, X),
          size = I(0.75),
          alpha = I(0.05),
          colour = "tan"
        ) +
        labs(title = title) +
        scale_y_reverse() +
        scale_x_continuous(position = "top") +
        theme(aspect.ratio = ASP_RATIO)
    )
  }
  
  if (sts) {
    report$ggsave(
      paste(n, "_", label, ".png", sep = ""),
      myplot,
      width = plotwidth,
      height = plotheight,
      type = c("cairo"),
      id = paste(n, "STSheatmap", label, sep = "_"),
      title = paste(n, "STSHeatmap:", label),
      caption = paste(n, "STSheatmap", label, sep = "_"),
      tags = c("heatmap", "heatmaps", n, "sts", "h5", label)
    )
  } else {
    report$ggsave(
      paste(n, "_", label, ".png", sep = ""),
      myplot,
      width = plotwidth,
      height = plotheight,
      id = paste(n, "heatmap", label, sep = "_"),
      title = paste(n, "Heatmap:", label),
      caption = paste(n, "heatmap", label, sep = "_"),
      tags = c("heatmap", "heatmaps", n)
    )
  }
}

#' Replace boxplot outliers in a column of a data frame with NA values
#'
#' @param m data frame
#' @param name string name of one of the columns in m
#' @seealso \code{\link{plotSingleSummarizedHeatmap}} which calls this function
#' @export
#' @examples
#' removeOutliers( res, "AlnReadLen" )

removeOutliers = function(m, name)
{
  m = subset(m,!is.na(m[, name]))
  values = m[, name]
  m[, name] = ifelse(values <= boxplot(m[, name], plot = FALSE)$stat[5], values, NA)
  m
}

#' Set diagonal elements of weight matrix to 0 and normalize by row sums
#'
#' @param weight = square weighting matrix defined in \code{\link{getDistMat}}
#'
#' @seealso \code{\link{ape.moransI}} which uses this function
#' @export

normalizeWeightMatrix = function(weight)
{
  diag(weight) <- 0
  
  #' Normalize weight matrix by row sums:
  r = rowSums(weight)
  r[r == 0] <- 1
  weight / r
}

#' Define a basic distance matrix to be used in Moran's I calculation
#'
#' @param N = data is summarized into N[1] x N[2] blocks of zmws
#' @param key = used to create a key to uniquely identify each block
#'
#' @return list:
#'      ID = vector of unique keys,
#'      MatList = list of weight matrices,
#'      S1.S2 = needed for std. dev calculation
#'
#' @seealso \code{\link{ape.moranI}} which uses the output
#' @export

getDistMat = function(N, key)
{
  # 64 to 1143; 64 to 1023
  m = 1080 %/% N[1]
  n = 960 %/% N[2]
  D = expand.grid(1:m, 1:n)
  names(D) = c("x", "y")
  N = as.matrix(dist(D))
  diag(N) <- 1
  
  M = normalizeWeightMatrix(1 / N)
  N[N < 1.5] <- 1
  N[N >= 1.5] <- 0
  N = normalizeWeightMatrix(N)
  
  MatList = list(Inv = M, N = N)
  list(
    MatList = MatList,
    S1.S2 = lapply(MatList, getS1andS2forMoransI),
    ID = key * D$x + D$y,
    nMatrices = length(MatList)
  )
}

#' Needed to calculate standard deviation and p-value for Moran's I statistic:
#'
#' @param weight = square weighting matrix defined in \code{\link{getDistMat}}
#'
#' @seealso \code{\link{ape.moransI}} which uses this function
#' @export

getS1andS2forMoransI = function(weight)
{
  tmp = weight + t(weight)
  S1 = sum(tmp * tmp) / 2
  tmp = 1 + colSums(weight)
  S2 = sum(tmp * tmp)
  c(S1, S2)
}

##
## Condition table grokking.
##
loadConditionTable <- function(conditionTableCSV,
                               wfOutRoot = dirname(conditionTableCSV))
{
  ## We load the Bauhaus2 CSV and augment it with extra columns R analysis is
  ## going to need:
  ##  - Reference      (path to reference FASTA)
  ##  - MappedSubreads (path to the mapped subreads)
  ##  - sts.h5
  ##  - sts.xml
  ## (These files should all found in the wfOutRoot)
  ct <- read.csv(conditionTableCSV)
  data.table(ct)
  mappedSubreads <-
    file.path(wfOutRoot,
              "conditions",
              ct$Condition,
              "mapped/mapped.alignmentset.xml")
  ct$MappedSubreads <- mappedSubreads
  referenceFasta <-
    file.path(wfOutRoot, "conditions", ct$Condition, "reference.fasta")
  ct$Reference <- referenceFasta
  ct$sts_h5 <-
    file.path(wfOutRoot, "conditions", ct$Condition, "sts.h5")
  ct$sts_xml <-
    file.path(wfOutRoot, "conditions", ct$Condition, "sts.xml")
  ct
}

##
## Filter out empty data sets, throw a warning if any empty ones exist
##
filterEmptyDataset <- function(dfs, conditions) {
  filteredData = list()
  if (any(lapply(dfs, nrow) == 0)) {
    emptyCond = paste(conditions[lapply(dfs, nrow) == 0, ]$Condition, collapse = ', ')
    warning(paste("Empty data set loaded for condition: ", emptyCond, sep = ""))
  }
  conditions = conditions[lapply(dfs, nrow) > 0, ]
  dfs = dfs[lapply(dfs, nrow) > 0]
  if (length(dfs) == 0) {
    warning("All conditions are empty!")
    filteredData
  } else {
    filteredData[[1]] = dfs
    filteredData[[2]] = conditions
    filteredData
  }
}

##
## Generating reports about plots, tables
##
bh2Reporter <-
  function(conditionTableCSV,
           outputFile,
           reportTitle) {
    reportOutputDir <- dirname(outputFile)
    reportOutputFile = outputFile
    version <- version
    plotsToOutput <- NULL
    tablesToOutput <- NULL
    cond_table <- loadConditionTable(conditionTableCSV)
    
    ## Save a ggplot in the report.
    .ggsave <-
      function(img_file_name,
               plot,
               id = "Default ID",
               title = "Default Title",
               caption = "No caption specified",
               tags = c(),
               uid = "Unique ID",
               ...)
      {
        if (!chkPng(img_file_name)) {
          img_file_name = paste0(img_file_name, ".png")
        }
        img_path = file.path(reportOutputDir, img_file_name)
        ggplot2::ggsave(img_path, plot = plot, ...)
        logging::loginfo(paste("Wrote img to: ", img_path))
        
        thisPlot <- list(
          id = unbox(id),
          image = unbox(img_file_name),
          title = unbox(title),
          caption = unbox(caption),
          tags = as.vector(tags, mode = "character")
        )
        plotsToOutput <<- rbind(plotsToOutput, thisPlot)
      }
    
    ## Add a table to the report.
    .write.table <-
      function(tbl_file_name,
               tbl,
               id,
               title = "Default Title",
               tags = c())
      {
        if (!chkCsv(tbl_file_name)) {
          tbl_file_name = paste(tbl_file_name, ".csv")
        }
        tbl_path = file.path(reportOutputDir, tbl_file_name)
        write.csv(tbl, file = tbl_path)
        logging::loginfo(paste("Wrote table to: ", tbl_path))
        
        thisTbl <- list(
          id = unbox(id),
          csv = unbox(tbl_file_name),
          title = unbox(title),
          tags = as.vector(tags, mode = "character")
        )
        
        tablesToOutput <<- rbind(tablesToOutput, thisTbl)
      }
    
    ## Output the report file as json.
    .write.report <- function()
    {
      pp <- as.data.frame(plotsToOutput)
      row.names(pp) <- NULL
      tt <- as.data.frame(tablesToOutput)
      row.names(tt) <- NULL
      write_json(list(plots = pp, tables = tt), reportOutputFile, pretty =
                   T)
      logging::loginfo(paste("Wrote report to: ", reportOutputFile))
    }
    
    
    list(
      condition.table = cond_table,
      ggsave = .ggsave,
      write.table = .write.table,
      write.report = .write.report,
      outputDir = reportOutputDir,
      outputJSON = reportOutputFile
    )
  }


if (0) {
  r <-
    bh2Reporter(
      "~dalexander/Projects/rsync/bauhaus/test/data/two-tiny-movies.csv",
      "/tmp/report.json"
    )
  
  p <- qplot()
  r$ggsave("1.png", p, "Id1", "Title1", "Caption1", tags = c())
  r$ggsave("2.png", p, "Id2", "Title2", "Caption2", tags = c("A"))
  
  t <- data.frame(a = 1:3, b = 4:6)
  r$write.table("foo.csv", t, "T1", "TTitle1", tags = c("A"))
  r$write.table("foo2.csv", t, "T2", "TTitle2", tags = c())
  
  r$write.report()
}
