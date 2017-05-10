#!/usr/bin/env Rscript

require(argparser)
require(dtplyr)
require(jsonlite)
require(logging)
require(ggplot2)
require(pbbamr)
require(pbcommandR)
require(doParallel)

source("./scripts/R/Bauhaus2.R")

#' Use the following aspect ratio, width, and height for all heatmaps

ASP_RATIO = 0.5
plotwidth = 7.2
plotheight = 4.2


#----------------------------------------------------------------
# Convenience functions for extracting specific metrics from bam file using pbbamr
#----------------------------------------------------------------


#' Return the number of frames per second from PacBio bam index
#'
#' @param bamFile input PacBio bam file.
#' @export
#' @examples
#' getFrameRate( "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/006/006712/tasks//pbalign.tasks.pbalign-1/mapped.alignmentset.bam" )

getFrameRate = function(bamFile)
  as.numeric(as.character(loadHeader(bamFile)$readgroups$framerate[1]))

#' Helper for pbbamr convenience functions
#'
#' @param tmp numeric vector with hole numbers
#' @param idx optional numeric vector containing indices of desired subset of tmp
#' @examples
#' .getBAMData( bam$hole, idx )

.getBAMData = function(tmp, idx)
{
  if (is.null(idx))
    return(tmp)
  tmp[intersect(idx, c(1:length(tmp)))]
}

#' Return numeric vector containing hole numbers from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getHoleNumber( bam )

getHoleNumber = function(bam, idx = NULL)
  .getBAMData(bam$hole, idx)

#' Return numeric vector containing hole X values from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getHoleX( bam )

getHoleX = function(bam, idx = NULL)
  (getHoleNumber(bam, idx) %/% 65536)

#' Return numeric vector containing hole Y values from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getHoleY( bam )

getHoleY = function(bam, idx = NULL)
  (getHoleNumber(bam, idx) %% 65536)



#' Return data frame with columns X and Y ( for Hole X and Hole Y ) from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getHoleXY( bam )

getHoleXY = function(bam, idx = NULL)
{
  HoleNumber = getHoleNumber(bam, idx)
  data.frame(X = HoleNumber %/% 65536, Y = HoleNumber %% 65536)
}

#' Return numeric vector containing tend - tstart from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getReadLength( bam )

getReadLength = function(bam, idx = NULL)
  .getBAMData(bam$tend - bam$tstart, idx)

#' Same as getReadLength
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getTemplateSpan( bam )

getTemplateSpan = getReadLength

#' Return numeric vector containing tend from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getTemplateEnd( bam )
getTemplateEnd = function(bam, idx = NULL)
  .getBAMData(bam$tend, idx)

#' Return numeric vector containing tstart from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getTemplateStart( bam )

getTemplateStart = function(bam, idx = NULL)
  .getBAMData(bam$tstart, idx)



#' Return a vector of factors with reference names from bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getReferenceName( bam )

getReferenceName = function(bam, idx = NULL)
  .getBAMData(bam$ref, idx)


#' Return a vector containing qend from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getQueryEnd( bam )

getQueryEnd = function(bam, idx = NULL)
  .getBAMData(bam$qend, idx)


#' Return a vector containing qstart from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getQueryStart( bam )

getQueryStart = function(bam, idx = NULL)
  .getBAMData(bam$qstart, idx)



#' Return a vector containing astart from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getReadStart( bam )

getReadStart = function(bam, idx = NULL)
  .getBAMData(bam$astart, idx)



#' Return a vector containing aend from PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getReadEnd( bam )

getReadEnd = function(bam, idx = NULL)
  .getBAMData(bam$aend, idx)


#' Return a vector containing the number of matches from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getMatches( bam )

getMatches = function(bam, idx = NULL)
  .getBAMData(bam$matches, idx)



#' Return a vector containing the number of mismatches from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getMismatches( bam )

getMismatches = function(bam, idx = NULL)
  .getBAMData(bam$mismatches, idx)



#' Return a vector containing the number of insertions from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getInsertions( bam )

getInsertions = function(bam, idx = NULL)
  .getBAMData(bam$inserts, idx)



#' Return a vector containing the number of deletions from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getDeletions( bam )

getDeletions = function(bam, idx = NULL)
  .getBAMData(bam$dels, idx)



#' Return a vector containing the SNR_A values from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName, loadSNR = TRUE )
#' getSNR_A( bam )

getSNR_A = function(bam, idx = NULL)
  .getBAMData(bam$snrA, idx)



#' Return a vector containing the SNR_C values from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName, loadSNR = TRUE )
#' getSNR_C( bam )

getSNR_C = function(bam, idx = NULL)
  .getBAMData(bam$snrC, idx)


#' Return a vector containing the SNR_G values from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName, loadSNR = TRUE )
#' getSNR_G( bam )

getSNR_G = function(bam, idx = NULL)
  .getBAMData(bam$snrG, idx)


#' Return a vector containing the SNR_T values from each row of PacBio bam index
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName, loadSNR = TRUE )
#' getSNR_T( bam )

getSNR_T = function(bam, idx = NULL)
  .getBAMData(bam$snrT, idx)



#' Return a data frame containing SNR_A, SNR_C, SNR_G, and SNR_T from PacBio bam file.
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param idx optional vector containing desired rows of bam
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName, loadSNR = TRUE )
#' getSNR( bam )

getSNR = function(bam, idx = NULL)
  data.frame(
    SNR_A = getSNR_A(bam, idx),
    SNR_C = getSNR_C(bam, idx),
    SNR_G = getSNR_G(bam, idx),
    SNR_T = getSNR_T(bam, idx)
  )



#' Return a list containing vectors of IPDs, measured in frames, corresponding to rows of PacBio bam file
#'
#' @param tmp output of pbbamr::loadAlnsFromIndex - list as long as the number of specified rows.
#' @param idx optional vector containing indices for subsetting tmp list.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' getIPD( tmp )

getIPD = function(tmp, idx = NULL)
  lapply(tmp, function(x)
    x$ipd)



#' Return a list of vectors of factors containing read bases from PacBio bam file.
#'
#' @param tmp output of pbbamr::loadAlnsFromIndex - list as long as the number of specified rows.
#' @param idx optional vector containing indices for subsetting tmp list.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' getBasecalls( tmp )

getBasecalls = function(tmp)
  lapply(tmp, function(x)
    x$read)



#' Return a list containing vectors of pulse widths, measured in frames, corresponding to rows of PacBio bam file
#' Returns vectors of 0s if pulse widths are not available.
#'
#' @param tmp output of pbbamr::loadAlnsFromIndex - list as long as the number of specified rows.
#' @param idx optional vector containing indices for subsetting tmp list.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' getPulseWidth( tmp )

getPulseWidth = function(tmp)
{
  if ("pw" %in% names(tmp[[1]]))
  {
    return(lapply(tmp, function(x)
      x$pw))
  }
  lapply(getIPD(tmp), function(x)
    rep(0, length(x)))
}



#' Return a list containing vectors of pkmid values corresponding to rows of PacBio bam file
#' Returns vectors of 0s if pulse widths are not available.
#'
#' @param tmp output of pbbamr::loadAlnsFromIndex - list as long as the number of specified rows.
#' @param idx optional vector containing indices for subsetting tmp list.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' getPkmid( tmp )

getPkmid = function(tmp)
{
  if ("pkmid" %in% names(tmp[[1]]))
  {
    return(lapply(tmp, function(x)
      x$pkmid))
  }
  lapply(getIPD(tmp), function(x)
    rep(0, length(x)))
}


#' Return a list containing vectors of start frames corresponding to rows of PacBio bam file
#' Returns vectors of 0s if start frames are not available.
#'
#' @param tmp output of pbbamr::loadAlnsFromIndex - list as long as the number of specified rows.
#' @param idx optional vector containing indices for subsetting tmp list.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' getStartFrames( tmp )

getStartFrames = function(tmp)
{
  if ("sf" %in% names(tmp[[1]]))
  {
    return(lapply(tmp, function(x)
      x$sf))
  }
  lapply(getIPD(tmp), function(x)
    rep(0, length(x)))
}



#' Return a list containing vectors of cumulative advance times corresponding to rows of PacBio bam file.
#'
#' @param ipds list output of getIPD above
#' @param pws list output of getPulseWidth above
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' ipds = getIPD( tmp )
#' pws = getPulseWidth( tmp )
#' getCumulativeAdvanceTime( ipds, pws )

getCumulativeAdvanceTime = function(ipds, pws)
{
  mapply(
    ipds,
    pws,
    FUN = function(ipd, pw) {
      v = ipd + pw
      v = cumsum(ifelse(is.na(v), 0, v))
      v[is.na(pw)] = NA
      v
    },
    SIMPLIFY = FALSE
  )
}


#' Return a list containing total length in frames of corresponding rows in PacBio bam file.
#'
#' @param ipds list output of getIPD above
#' @param pws list output of getPulseWidth above
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = pbbamr::loadAlnsFromIndex( bam, fastaname, rows )
#' ipds = getIPD( tmp )
#' pws = getPulseWidth( tmp )
#' getCumulativeAdvanceTime( ipds, pws )

getTotalTime = function(ipds, pws)
{
  sapply(getCumulativeAdvanceTime(ipds, pws), function(a)
    a[length(a)] - a[1])
}


#----------------------------------------------------------------




#----------------------------------------------------------------
# Call pbbamr::loadPBI and pbbamr::loadAlnsFromIndex to generate a single data frame with summary statistics
#----------------------------------------------------------------

#' Return data frame containing hole number, rStart, rEnd, and other basic statistics
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @seealso \code{\link{writeSummaryTable}} which calls this function.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getBasicInformation( bam )

getBasicInformation = function(bam)
{
  res = data.frame(
    HoleNumber = getHoleNumber(bam),
    X = getHoleX(bam),
    Y = getHoleY(bam),
    rStart = getReadStart(bam),
    rEnd = getReadEnd(bam),
    tStart = getTemplateStart(bam),
    tEnd = getTemplateEnd(bam),
    Matches = getMatches(bam),
    Mismatches = getMismatches(bam),
    Inserts = getInsertions(bam),
    Dels = getDeletions(bam),
    AlnReadLen = getTemplateSpan(bam),
    Reference = getReferenceName(bam)
  )
  cbind(res, getSNR(bam))
}

#' Return data frame containing total Pkmid ( or IPD, Pulse Width ) by base for each subread
#'
#' @param data a list of vectors containing either IPDs, pulse widths, or pkmid values
#' @param name a string describing the data contained in the list data (for example, "IPD")
#' @param mA a list of vectors containing indices for corresponding elements of data; locations of A bases
#' @param mC a list of vectors containing indices for corresponding elements of data; locations of C bases
#' @param mG a list of vectors containing indices for corresponding elements of data; locations of G bases
#' @param mT a list of vectors containing indices for corresponding elements of data; locations of T bases
#' @seealso \code{\link{getDetailedInformation}} which calls this function.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' tmp = loadAlnsFromIndex( bam, fastaname, rows )
#' ipd = getIPD( tmp )
#' getSumByBase( ipd, "IPD", mA, mC, mG, mT )

getSumByBase = function(data, name, mA, mC, mG, mT)
{
  mmed = function(x)
    sum(x, na.rm = TRUE)
  
  res = data.frame(cbind(
    vapply(mapply(`[`, data, mA, SIMPLIFY = FALSE), mmed, 0),
    vapply(mapply(`[`, data, mC, SIMPLIFY = FALSE), mmed, 0),
    vapply(mapply(`[`, data, mG, SIMPLIFY = FALSE), mmed, 0),
    vapply(mapply(`[`, data, mT, SIMPLIFY = FALSE), mmed, 0)
  ))
  
  dna = c("A", "C", "G", "T")
  names(res) = paste(name, dna, sep = "_")
  res
}

#' Return data frame containing median pulse widths by base, median pkmids by base and other data from PacBio bam file
#'
#' @param bam data frame returned by pbbamr::loadPBI
#' @param fastaname fasta file path
#' @param rows vector containing desired set of rows of bam
#' @seealso \code{\link{writeSummaryTable}} which calls this function.
#' @export
#' @examples
#' bam = pbbamr::loadPBI( bamFileName )
#' getDetailedInformation( bam, fastaname, rows )

getDetailedInformation = function(bam, fastaname, rows)
{
  tmp = loadAlnsFromIndex(bam, fastaname, rows)
  holenumber = bam$hole[rows]
  
  # Get indices of A, C, G, and T for each row in rows:
  
  bcs = getBasecalls(tmp)
  p = lapply(bcs, function(x)
    split(1:length(x), x))
  mA = lapply(p, function(x)
    x[["A"]])
  mC = lapply(p, function(x)
    x[["C"]])
  mG = lapply(p, function(x)
    x[["G"]])
  mT = lapply(p, function(x)
    x[["T"]])
  
  ipds = getIPD(tmp)
  pws = getPulseWidth(tmp)
  
  # Include total pulse width by base -- will compute average later.
  
  m = getSumByBase(pws, "PW", mA, mC, mG, mT)
  m$TotalTime = getTotalTime(ipds, pws)
  
  # Include total pkmid by base -- will compute average later.
  
  if ("pkmid" %in% names(tmp[[1]]))
  {
    pkm = getPkmid(tmp)
    m = cbind(m, getSumByBase(pkm, "Pkmid", mA, mC, mG, mT))
  }
  
  if ("sf" %in% names(tmp[[1]]))
  {
    m$StartFrames = vapply(getStartFrames(tmp), function(x)
      x[1], 0)
  }
  
  # Get number of A's, C's, G's, and T's:
  
  m$NumBases_A = vapply(mA, length, 0)
  m$NumBases_C = vapply(mC, length, 0)
  m$NumBases_G = vapply(mG, length, 0)
  m$NumBases_T = vapply(mT, length, 0)
  m$HoleNumber = holenumber
  m
}



#' Return data frame containing hole number, accuracy, pulse widths by base, and all other statistics from PacBio bam file
#'
#' @param bamFile PacBio bam file path
#' @param fastaname fasta file path
#' @param blockSize (optional); number or rows of bam file to read in at a time
#' @seealso \code{\link{simpleErrorHandling}} which wraps this function.
#' @export
#' @examples
#' writeSummaryTable( bamFile, fastaname )

writeSummaryTable = function(bamFile, fastaname, blockSize = 5e3)
{
  loginfo("Get basic statistics, such as read length, insertions, and deletions:")
  bam = loadPBI(bamFile, loadSNR = TRUE)
  
  if (nrow(bam) == 0)
  {
    loginfo("[WARNING] - # rows in bam file == 0")
    return(NULL)
  }
  
  res = getBasicInformation(bam)
  loginfo("Get kinetic and pkmid information, blockSize rows at a time:")
  blockSize = min(blockSize, nrow(bam) - 1)
  s = seq(1, nrow(bam), blockSize)
  s[length(s)] = s[length(s)] + 1
  s = lapply(1:(length(s) - 1), function(i)
    c(s[i]:(s[i + 1] - 1)))
  
  loginfo("Prepare to parallelize:")
  noCores = detectCores() - 1
  registerDoParallel(cores = noCores)
  cl = makeCluster(noCores, type = "FORK")
  L = parLapply(cl, s, function(rows)
    getDetailedInformation(bam, fastaname, rows))
  stopCluster(cl)
  
  loginfo("Combine basic and kinetic/pkmid information:")
  tmp = bind_rows(L)
  tmp = tmp[, -which(colnames(tmp) == "HoleNumber")]
  res = bind_rows(lapply(s, function(rows)
    res[rows,]))
  res = cbind(res, tmp)
  
  res$FrameRate = getFrameRate(getBAMNamesFromDatasetFile(bamFile)[1])
  res$TotalTime = res$TotalTime / res$FrameRate
  if ("StartFrames" %in% names(res))
  {
    res$StartTime = res$StartFrames / res$FrameRate
  }
  res
}


#' Simple error handling for \code{\link{writeSummaryTable}}
#'
#' @param bamFile PacBio bam file path
#' @param fastaname fasta file path
#' @param blockSize (optional); number or rows of bam file to read in at a time
#' @export
#' @examples
#' simpleErrorHandling( bamFile, fastname )

simpleErrorHandling = function(bamFile, fastaname, blockSize = 5e3)
{
  res = try(writeSummaryTable(bamFile, fastaname, blockSize), silent = FALSE)
  if (class(res) == "try-error")
  {
    cat("[WARNING]: Unable to open or process file: ",
        as.character(bamFile),
        "\n")
    return(NULL)
  }
  loginfo(paste("Loaded alignments for:", bamFile))
  res
}

#----------------------------------------------------------------



#------------------------------------------------------------
# Summarize by ZMW
#------------------------------------------------------------


#' Summarize the data frame contained in x by HoleNumber
#'
#' @param x data frame, output of \code{\link{writeSummaryTable}}
#' @param colList list with elements: nSum, nFirst, nMin, and nMax.  Each contains a list of names of columns of x.
#' @export
#' @examples
#' sumUpByMolecule( res, list( nSum = c("AlnReadLen", "TotalTime"), nFirst = c("HoleNumber", "X", "Y") ) )
#' sumUpByMolecule( res, list( nSum = c("AlnReadLen", "TotalTime"), nFirst = c("HoleNumber", "X", "Y"), nMin= c("rStart"), nMax=c("rEnd") ) )
#' colList = getColumnsForSummarization( names( res ), dna = c("A", "C", "G", "T") )
#' sumUpByMolecule( res, colList )

sumUpByMolecule = function(x, colList)
{
  # Make sure only columns actually contained in data frame x are listed in nSum and so on.
  
  colList$nSum = intersect(colList$nSum, names(x))
  colList$nFirst = intersect(colList$nFirst, names(x))
  colList$nMin = intersect(colList$nMin, names(x))
  colList$nMax = intersect(colList$nMax, names(x))
  
  # Sum elements by hole number for columns listed in nSum:
  m = as.matrix(x[, colList$nSum])
  res = data.frame(rowsum(m, x$HoleNumber))
  res$HoleNumber = as.numeric(row.names(res))
  
  # Take first elements by hole number for columns listed in nFirst:
  
  m = match(res$HoleNumber, x$HoleNumber)
  for (nms in colList$nFirst)
  {
    res[, nms] = x[m, nms]
  }
  
  # Take minimum per hole number for columns listed in nMin ( if any ):
  
  if (length(colList$nMin) > 0)
  {
    for (n in colList$nMin)
    {
      tmp = x[, c("HoleNumber", n)]
      tmp = tmp[order(tmp[, 1], tmp[, 2], decreasing = FALSE),]
      d = which(!duplicated(tmp$HoleNumber))
      res = merge(res, tmp[d, ], by = "HoleNumber")
    }
  }
  
  # Take maximum per hole number for columns listed in nMax ( if any ):
  
  if (length(colList$nMax) > 0)
  {
    for (n in colList$nMax)
    {
      tmp = x[, c("HoleNumber", n)]
      tmp = tmp[order(tmp[, 1], tmp[, 2], decreasing = TRUE),]
      d = which(!duplicated(tmp$HoleNumber))
      res = merge(res, tmp[d, ], by = "HoleNumber")
    }
  }
  res
}

#' Return average IPD, Pulse Width, Pkmid by base, starting from total values.
#'
#' @param res, output of \code{\link{sumUpByMolecule}}
#' @param name, string containing column name (minus the specified base)
#' @param dna = c("A", "C", "G", "T")
#' @seealso \code{\link{postSummation}} which calls this function
#' @export
#' @examples
#' res = writeSummaryTable( bamFile, fastaname )
#' colList = getColumnsForSummarization( names( res ), "A", "C", "G", "T") )
#' res = sumUpByMolecule( res, colList )
#' res = averagePerBase( res, "IPD", c("A", "C", "G", "T") )

averagePerBase = function(res, name, dna)
{
  num = vapply(dna, function(x)
    paste(name, x, sep = "_"), "")
  den = vapply(dna, function(x)
    paste("NumBases", x, sep = "_"), "")
  
  for (i in 1:length(dna))
  {
    res[, num[i]] = res[, num[i]] / res[, den[i]]
  }
  res
}

#' To obtain lists of columns for summarization for \code{\link{sumUpByBase}}
#'
#' @param names.res string containing names of res, input to \code{\link{sumUpByBase}}
#' @dna = c( "A", "C", "G", "T" )
#' @seealso \code{\link{applySummarization}} which calls this function
#' @export
#' @examples
#' res = writeSummaryTable( bamFile, fastaname )
#' colList = getColumnsForSummarization( names( res ), c("A", "C", "G", "T") )

getColumnsForSummarization = function(names.res, dna)
{
  list(
    nFirst = c(
      "HoleNumber",
      "X",
      "Y",
      "Reference",
      "FrameRate",
      "SMRTlinkID",
      paste("SNR", dna, sep = "_")
    ),
    
    nMax = c("MaxSubreadLen", "rEnd", "tEnd"),
    nMin = c("rStart", "tStart", "StartTime"),
    
    nSum = c(
      "Matches",
      "Mismatches",
      "Inserts",
      "Dels",
      "AlnReadLen",
      "TotalTime",
      paste("NumBases", dna, sep = "_"),
      paste("IPD", dna, sep = "_"),
      paste("PW", dna, sep = "_"),
      paste("Pkmid", dna, sep = "_")
    )
  )
}


#' Takes output of \code{\link{sumUpByMolecule}} and appends some extra columns, such as Accuracy
#'
#' @param res data frame, output of \code{\link{SumUpByMolecule}}
#' @param refTable string, unique reference names found in data used to compile res
#' @param dna = c("A", "C", "G", "T")
#' @seealso \code{\link{applySummarization}} which calls this function
#' @export
#' @examples
#' postSummation( res, refTable, c("A", "C", "G", "T")

postSummation = function(res, refTable, dna)
{
  for (name in c("IPD", "PW", "Pkmid"))
  {
    if (paste(name, "A", sep = "_") %in% names(res))
    {
      res = averagePerBase(res, name, dna)
    }
  }
  
  res$PolRate = res$AlnReadLen / res$TotalTime
  res$Reference = refTable[res$Reference]
  res$MismatchRate = res$Mismatches / res$AlnReadLen
  res$InsertionRate = res$Inserts / res$AlnReadLen
  res$DeletionRate = res$Dels / res$AlnReadLen
  res$Accuracy = 1 - res$MismatchRate - res$InsertionRate - res$DeletionRate
  
  tmp = try(res$MaxSubreadLen / res$AlnReadLen , silent = FALSE)
  if (class(tmp) != "try-error") {
    res$MaxSubreadLenToAlnReadLenRatio = tmp
  }
  res
}


#' Summarize output of \code{\link{writeSummaryTable}} by hole number
#'
#' @param res data frame, output of \code{\link{writeSummaryTable}}
#' @export
#' @examples
#' res = writeSummaryTable( bamFile, fastaname )
#' applySummarization( res )

applySummarization = function(res)
{
  # check to make sure there are enough rows in the input data frame:
  if (nrow(res) < 5) {
    return(NULL)
  }
  dna = c("A", "C", "G", "T")
  refTable = names(table(res$Reference))
  res$Reference = match(res$Reference, refTable)
  res$MaxSubreadLen = res$AlnReadLen
  colList = getColumnsForSummarization(names(res), dna)
  res = sumUpByMolecule(res, colList)
  postSummation(res, refTable, dna)
}

#----------------------------------------------------------------


#------------------------------------------------------------
# Summarize chips into N[1] x N[2] blocks of ZMWs
#------------------------------------------------------------


#' Called by \code{\link{convenientSummarizer}} if data.table library is installed
#'
#' @param z data frame, output of \code{\link{applySummarization}} with an ID column appended, to identify the block to which a ZMW belongs.
#' @seealso \code{\link{convenientSummarizer}} which calls this function
#' @export

forConvenientSummarizer.datatable = function(z)
{
  cols = which(names(z) != "ID")
  FUN = function(x, na.rm = TRUE)
    as.double(median(x, na.rm))
  z = data.table(z)
  setkey(z, ID)
  u = data.frame(z[, .N, by = ID])
  names(u)[which(names(u) != "ID")] = "Count"
  z = data.frame(z[, lapply(.SD, FUN), by = ID, .SDcols = cols])
  merge(u, z, by = "ID")
}


#' Called by \code{\link{convenientSummarizer}} if data.table library is not installed -- slightly slower
#'
#' @param z data frame, output of \code{\link{applySummarization}} with an ID column appended, to identify the block to which a ZMW belongs.
#' @seealso \code{\link{convenientSummarizer}} which calls this function
#' @export

forConvenientSummarizer = function(z)
{
  cols = which(names(z) != "ID")
  FUN = function(x, na.rm = TRUE)
    median(x, na.rm)
  y = z[, cols]
  s = split(1:nrow(y), z$ID)
  a = lapply(s, function(k)
    apply(y[k, ], 2, FUN))
  a = data.frame(do.call(rbind, a))
  a$Count = vapply(s, length, 0)
  a$ID = as.numeric(row.names(a))
  a
}


#' Take output of \code{\link{applySummarization}} and summarize data into N[1] x N[2] blocks of ZMWs
#'
#' @param res data frame output of \code{\link{applySummarization}}
#' @param N vector of length two, containing dimensions of ZMW blocks for summarization
#' @param key (optional) - use to create a unique ID number for each block of ZMWs.
#' @export
#' @examples
#' res = writeSummaryTable( bamFile, fastaname )
#' res = applySummarization( res )
#' convenientSummarizer( res, N = c( 10, 8 ) )

convenientSummarizer = function(res, N, key = 1e3)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  FUNC = forConvenientSummarizer
  r = try(require(data.table), silent = FALSE)
  r = ifelse(class(r) != "try-error", r, FALSE)
  if (r) {
    FUNC = forConvenientSummarizer.datatable
  }
  
  exclude = c(
    "HoleNumber",
    "X",
    "Y",
    "Reference",
    "FrameRate",
    "SMRTlinkID",
    "Matches",
    "Mismatches",
    "Inserts",
    "Dels",
    "Scraps"
  )
  
  x = as.numeric(res$X)
  y = as.numeric(res$Y)
  a = floor(seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), N[1]))
  b = floor(seq(min(y, na.rm = TRUE), max(y, na.rm = TRUE), N[2]))
  kx = findInterval(x, a)
  ky = findInterval(y, b)
  
  res$ID = ky + kx * key
  nms = setdiff(names(res), exclude)
  z = FUNC(res[, nms])
  z$HoleNumber = res$X[match(z$ID, res$ID)]
  z$X = z$ID %/% key
  z$Y = z$ID %% key
  z[, which(names(z) != "ID")]
}

#----------------------------------------------------------------





#----------------------------------------------------------------
# Plotting heatmaps
#----------------------------------------------------------------


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


#' Generate a single heatmap corresponding to one column of a data frame.
#'
#' @param res output of \code{\link{convenientSummarizer}} - bam data summarized into N[1] x N[2] blocks of ZMWs
#' @param n string name of column of res to be plotted.
#' @param label string label for plot
#' @param N vector of length two giving dimensions of blocks of ZMWs
#' @param limits (optional) vector of length two describing upper and lower bounds in heatmap range - in order to compare across heatmaps
#' @seealso \code{\link{drawSummarizedHeatmaps}} which calls this function
#' @export

plotSingleSummarizedHeatmap = function(report, res, n, label, N, limits = NULL)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  
  plotID =  paste(n, "_Heatmap_", label, sep = "")
  pngfile = paste(plotID, "png", sep = ".")
  title = paste(n, " (median per ", N[1], " x ", N[2], " block) : ", label, sep = "")
  
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
        theme(aspect.ratio = ASP_RATIO)
    )
    
  }
  else
  {
    # Above range gray ( na.value ), below range black
    low = subset(res, res[, n] < limits[1])
    tmp = subset(res, res[, n] >= limits[1])
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
        labs(title = title) +
        theme(aspect.ratio = ASP_RATIO)
    )
  }
  
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = paste(n, "heatmap", label, sep = "_"),
    title = paste(n, "Heatmap:", label),
    caption = paste(n, "heatmap", label, sep = "_"),
    tags = c("heatmap", "heatmaps", n)
  )
}


#' Plot heatmap corresponding to the reference names.
#'
#' @param res output of \code{\link{convenientSummarizer}} - bam data summarized into N[1] x N[2] blocks of ZMWs
#' @param label string label for plot
#' @seealso \code{\link{drawSummarizedHeatmaps}} which calls this function
#' @export

plotReferenceHeatmap = function(report, res, label)
{
  loginfo(paste("Plot reference heatmap for condition:", label))
  plotID =  paste("Reference_Heatmap_", label, sep = "")
  pngfile = paste(plotID, "png", sep = ".")
  title = paste("Reference : ", label, sep = "")
  
  myplot = (
    qplot(
      data = res,
      Y,
      X,
      size = I(0.75),
      alpha = I(0.2),
      color = Reference
    ) +
      labs(title = title) +
      theme(aspect.ratio = ASP_RATIO)
  )
  
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = "Reference_heatmap",
    title = paste("Reference Heatmap:", label),
    caption = paste("Reference_heatmap", label, sep = "_"),
    tags = c("heatmap", "heatmaps", "reference", "ref")
  )
}


#' Generate all standard heatmaps and uniformity metrics for aligned PacBio bam data
#'
#' @param res data frame, output of \code{\link{applySummarization}}
#' @param label string label for all plots
#' @param N vector of length two describing dimensions of ZMW blocks - the median for each block will be plotted.
#' @seealso \code{\link{makeReport}} the core function which calls this one.
#' @export
#' @examples
#' drawSummarizedHeatmaps( report, res, "Condition_A", c( 10, 8 ) )

drawSummarizedHeatmaps = function(report, res, label, N)
{
  loginfo(paste("First, summarize condition", label, "by ZMW:"))
  res = applySummarization(res)
  if (is.null(res))
  {
    loginfo(paste("[ERROR] -- Too few rows for condition:", label))
    return(NULL)
  }
  plotReferenceHeatmap(report, res, label)
  
  loginfo(paste("Summarize into", N[1], "x", N[2], "blocks for condition:", label))
  df = convenientSummarizer(res, N)
  df$AlnReadLenExtRange = df$AlnReadLen
  df$rStartExtRange = df$rStart
  df$MaxSubreadLenExtRange = df$MaxSubreadLen
  
  loginfo(paste("Plot individual heatmaps for condition:", label))
  try(plotSingleSummarizedHeatmap(report, df, "Count", label, N, limits = c(0, 60)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "Accuracy", label, N, limits = c(0.70, 0.85)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "AlnReadLen", label, N, limits = c(500, 9000)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report,
                                  df,
                                  "AlnReadLenExtRange",
                                  label,
                                  N,
                                  limits = c(500, 30000)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "rStart", label, N, limits = c(0, 9000)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "rStartExtRange", label, N, limits = c(0, 25000)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "SNR_C", label, N, limits = c(5, 13)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "Pkmid_C", label, N, limits = c(100, 500)),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report,
                                  df,
                                  "MaxSubreadLenExtRange",
                                  label,
                                  N,
                                  limits = c(0, 15000)),
      silent = FALSE)
  
  excludeColumns = c(
    "X",
    "Y",
    "HoleNumber",
    "Count",
    "Accuracy",
    "AlnReadLen",
    "rStart",
    "SNR_C",
    "Pkmid_C",
    "Reference",
    "AlnReadLenExtRange",
    "MaxSubreadLenExtRange",
    "rStartExtRange"
  )
  lapply(setdiff(names(df), excludeColumns), function(n)
  {
    try(plotSingleSummarizedHeatmap(report, df, n, label, N),
        silent = FALSE)
    1
  })
  
  addLoadingUniformityPlots(report, res, N, label)
}

#----------------------------------------------------------------





#----------------------------------------------------------------
# Loading uniformity histogram and metrics
#----------------------------------------------------------------


#' Plot histogram showing number of ZMWs that produced an alignment in each block of N[1] x N[2].
#'
#' @param label string label for plot
#' @param counts numeric vector containing data for generating histogram.
#' @param N vector of length two describing dimenions of blocks of ZMWs.
#' @seealso \code{\link{addLoadingUniformityPlots}} which calls this function.
#' @export
#' @examples
#' drawHistogramForUniformity( report, "Condition_A", counts, c( 10, 8 ) )

drawHistogramForUniformity = function(report, label, counts, N)
{
  title = paste("Uniformity_histogram", label, sep = "_")
  pngfile = paste(title, "png", sep = ".")
  
  xlabel = paste("# of Alignments per", N[1], "x", N[2], "block of ZMWs")
  ylabel = paste("# of",  N[1], "x", N[2], "blocks")
  myplot = (qplot(
    counts,
    geom = "histogram",
    binwidth = 1,
    fill = I("blue"),
    col = I("red")
  ) +
    labs(list(
      title = title, x = xlabel, y = ylabel
    )))
  
  loginfo(paste("\t Draw loading uniformity histogram for condition:", label))
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = paste("uniformity_histogram", label, sep = "_"),
    title = title,
    caption = paste("Loading Uniformity Histogram:", label),
    tags = c("heatmap", "heatmaps", "uniformity", "loading", label)
  )
}


#' Calculate R. Grothe's loading efficiency metric for a given set of counts of # of alignments per block of ZMWs.
#'
#' @param counts numeric vector containing data for generating histogram.
#' @param N vector of length two describing dimenions of blocks of ZMWs.
#' @seealso \code{\link{addLoadingUniformityPlots}} which calls this function.
#' @export
#' @examples
#' drawHistogramForUniformity( report, "Condition_A", counts, c( 10, 8 ) )

getLoadingEfficiency = function(counts, N)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  pol_pM = counts / (N[1] * N[2])
  maxConc = floor(3 / min(pol_pM[pol_pM > 0]))
  conc = seq(1, maxConc, 1)
  lambda = pol_pM %o% conc
  single = lambda * exp(-lambda)
  total = colMeans(single)  # assume uniform
  100 * max(total, na.rm = TRUE) * exp(1)
}



#' Return 100 * p-value for Moran's I statistic
#'
#' Copied from ape::moran.I to avoid installing package:
#' \link{https://cran.r-project.org/web/packages/ape}
#' \link{https://en.wikipedia.org/wiki/Moran%27s_I}
#'
#' @param x = vector of observations
#' @param weights = square matrix same dimension as x
#' @param scaled = if TRUE, then statistic is scaled by sample standard dev.
#' @param na.rm = if TRUE, remove NA values from x
#' @param n = length( x )
#'
#' @return scalar: 100 * p-value
#'	score ranges from 0 to 100
#'	score of 100 means no spatial autocorrelation
#'
#' @seealso \link{http://www.lpc.uottawa.ca/publications/moransi/moran.htm} for formulas
#' @export

ape.moranI = function(x,
                      weight,
                      scaled = FALSE,
                      na.rm = FALSE,
                      n = length(x))
{
  #' Error handling steps:
  d = dim(weight)
  if (d[1] != d[2])
    stop("weight matrix must be square")
  if (n != d[1])
    stop("nrow( weight ) must equal length( x ).")
  
  if (na.rm)
  {
    nas = is.na(x)
    x = x[!nas]
    n = length(x)
    weight = weight[!nas,!nas]
  }
  
  #' Normalize weight matrix by row sums:
  r = rowSums(weight)
  r[r == 0] <- 1
  weight = weight / r
  
  #' Observed value of statistic, obs:
  y = x - sum(x) / n
  y2 = y * y
  var = sum(y2)
  obs = sum(weight * y %o% y) / var
  
  if (scaled)
  {
    i.max = sd(y) / sqrt(var / (n - 1))
    obs = obs / i.max
  }
  
  #' Expected value of statistic if there is no spatial autocorrelation:
  expected = -1 / (n - 1)
  
  #' Calculate standard deviation of Moran's I statistic:
  tmp = weight + t(weight)
  S1 = sum(tmp * tmp) / 2
  tmp = 1 + colSums(weight)
  S2 = sum(tmp * tmp)
  S0.2 = n * n
  k = (sum(y2 * y2) / n) / (var * var / S0.2)
  num.1 = n * ((n ^ 2 - 3 * n + 3) * S1 - n * S2 + 3 * S0.2)
  num.2 = k * (n * (n - 1) * S1 - 2 * n * S2 + 6 * S0.2)
  den = ((n - 1) * (n - 2) * (n - 3) * S0.2)
  sd = sqrt((num.1 - num.2) / den - expected ^ 2)
  
  #' obs ~ N( expected, sd ):
  c(obs, pnorm(
    obs,
    mean = expected,
    sd = sd,
    lower.tail = (obs <= expected)
  ))
}


#' Calculate Moran's I statistic ( R. Beckman )
#'
#' @param tab = table of values -- X vs. Y
#'
#' @return vector with two values: moran's I score
#'	using inverse weights and using step function
#'
#' @seealso \code{\link{ape.moranI}} where moran's I score is computed
#' @seealso \code{\link{getUniformityMetricsTable}} which calls this function
#' @export

getRBeckmanUniformity = function(tab)
{
  statistic = as.numeric(tab)
  X = 1:nrow(tab)
  Y = 1:ncol(tab)
  D = cbind(rep(X, length(Y)), rep(Y, each = length(X)))
  m = as.matrix(dist(D))
  n = m
  diag(n) <- 1
  n = 1 / n
  diag(n) <- 0
  
  #' Calculate score using inverse distance weight matrix:
  s1 = ape.moranI(statistic, n)
  
  #' Calculate score using step function weight matrix:
  m[m < 1.5] <- 1
  m[m >= 1.5] <- 0
  diag(m) <- 0
  s2 = ape.moranI(statistic, m)
  
  c(s1, s2)
}


#' Return a data frame containing uniformity metrics for tracking uniformity across chips, including overdispersion.
#'
#' @param label string label for identification
#' @param counts numeric vector containing data for generating histogram.
#' @param N vector of length two describing dimenions of blocks of ZMWs.
#' @param nAlns number of alignments
#' @param nSubreads number of subreads -- note this is not correct here.
#' @param com vector of length two containing center of mass estimate for alignments.
#' @param SNR vector of length four containing mean SNR for A, C, G, and T.
#'
#' @seealso \code{\link{addLoadingUniformityPlots}} which calls this function.
#' @examples
#' getUniformityMetricsTable( "Condition_A", counts, c( 10, 8 ), nrow( res ), nrow( res ), com, SNR )
#'
#' @export

getUniformityMetricsTable = function(label,
                                     counts,
                                     N,
                                     nAlns,
                                     nSubreads,
                                     com,
                                     SNR,
                                     cutoff = 2)
{
  loginfo(paste("\t Write uniformity metrics table for condition:", label))
  # cutoff = round( max( 1, boxplot( counts, plot = FALSE )$stat[1] ) )
  y = counts[counts >= cutoff]
  
  n.counts = length(counts)
  n.y = length(y)
  lowLoad = 1 - (n.y / n.counts)
  
  mu = mean(y)
  vr = var(y)
  dispersion = vr / mu - 1
  t1 = dispersion * sqrt(2 / n.y)
  le = getLoadingEfficiency(counts, N)
  mi = getRBeckmanUniformity(counts)
  
  data.frame(
    ID = label,
    LowLoadFrac = lowLoad,
    Cutoff = cutoff,
    Mean = mu,
    Var = vr,
    PoissonDisp = dispersion,
    nRead = nAlns,
    nSubreads = nSubreads,
    NumBlks = n.counts,
    NumBlksAboveCutoff = n.y,
    T1_WangEtAll = t1,
    NonUniformityPenalty = le,
    COM.x = com[1],
    COM.y = com[2],
    SNR_A = SNR[1],
    SNR_C = SNR[2],
    SNR_G = SNR[3],
    SNR_T = SNR[4],
    MoransI.Inv = mi[1],
    MoransI.Inv.p = mi[2],
    MoransI.N = mi[3],
    MoransI.N.p = mi[4]
  )
}



#' The length of a string (in characters).
#'
#' @param res data frame output of \code{\link{convenientSummarizer}}
#' @param N vector of length two describing dimensions of blocks of ZMWs
#' @param lable string containing label for histogram and metrics table.
#' @seealso \code{\link{drawSummarizedHeatmaps}} which calls this function.
#' @export
#' @examples
#' N = c( 10, 8 )
#' res = convenientSummarizer( res, N )
#' addLoadingUniformityPlots( report, res, c(10, 8), "Condition_A" )

addLoadingUniformityPlots = function(report, res, N, label)
{
  if (is.null(N))
    return(0)
  if (length(N) == 1) {
    N = c(N, N)
  }
  
  tmp = res
  SNR_A = mean(tmp$SNR_A, na.rm = TRUE)
  SNR_C = mean(tmp$SNR_C, na.rm = TRUE)
  SNR_G = mean(tmp$SNR_G, na.rm = TRUE)
  SNR_T = mean(tmp$SNR_T, na.rm = TRUE)
  SNR = c(SNR_A, SNR_C, SNR_G, SNR_T)
  
  tmp = tmp[!duplicated(tmp$HoleNumber),]
  x = as.numeric(tmp$X)
  y = as.numeric(tmp$Y)
  
  #' Compute center of mass
  com = c(mean(x, na.rm = TRUE), mean(y, na.rm = TRUE)) - c(595, 544)
  
  a = floor(seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), N[1]))
  b = floor(seq(min(y, na.rm = TRUE), max(y, na.rm = TRUE), N[2]))
  tab = table(findInterval(x, a), findInterval(y, b))
  drawHistogramForUniformity(report, label, as.numeric(tab), N)
  
  tbl = getUniformityMetricsTable(label, tab, N, nrow(tmp), nrow(res), com, SNR)
  
  csvfile = paste("Uniformity_metrics_", label, ".csv", sep = "")
  
  report$write.table(
    csvfile,
    tbl,
    id = "loading_metrics_table",
    title = paste(label, "Loading_uniformity_metrics", sep = "_"),
    tags = c("table", "uniformity", "loading", "metrics")
  )
}

#----------------------------------------------------------------



#' Main function called by makeReport
#'
#' 1. Load data from aligned BAM files
#'	-- see convenience functions and functions that call loadPBI and loadAlnsFromIndex above
#'
#' 2. Summarize data by ZMW
#'	-- see functions for summarizing data by ZMW above
#'
#' 3. Summarize by blocks of ZMWs
#'	-- see functions for summarizing data into N[1] x N[2] blocks of ZMWs above
#'
#' 4. Generate heatmaps
#'	-- see functions for plotting summarized heatmaps above
#'
#' 5. Generate uniformity metrics and histogram
#'	-- uniformity metrics and plotting functions above

generateHeatmapsPerCondition = function(report, alnxml, reference, label)
{
  loginfo(paste("Get data for condition:", label))
  fastaname = getReferencePath(reference)
  res = simpleErrorHandling(alnxml, fastaname)
  
  if (nrow(res) < 5)
  {
    loginfo("[WARNING] - Too few rows in BAM file.")
    return(0)
  }
  
  loginfo(paste("Summarize data for condition:", label))
  res$SMRTlinkID = label
  res$X = 1164 - res$X
  
  loginfo(paste("Draw regular heatmaps for condition:", label))
  res = subset(res, SNR_A != -1 &
                 SNR_C != -1 & SNR_G != -1 & SNR_T != -1)
  drawSummarizedHeatmaps(report, res, label, N = c(10, 8))
  
  loginfo(paste(
    "Draw heatmaps corresponding to DME failures for condition:",
    label
  ))
  dme = subset(res, SNR_A == -1 &
                 SNR_C == -1 & SNR_G == -1 & SNR_T == -1)
  drawSummarizedHeatmaps(report, dme, paste(label, "DME_Failure", sep = "_"), N = c(10, 8))
  1
}


#' Core function required to add workflow to Zia:

makeReport = function(report)
{
  conditions = report$condition.table
  
  alnxmls = as.character(conditions$MappedSubreads)
  w = which(!duplicated(alnxmls))
  alnxmls = alnxmls[w]
  refs = as.character(conditions$Reference)[w]
  labels = as.character(conditions$Condition)[w]
  
  res = lapply(1:length(alnxmls), function(k)
    generateHeatmapsPerCondition(report, alnxmls[k], refs[k], labels[k]))
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.RData"))
  report$write.report()
  1
}

#----------------------------------------------------------------



main = function()
{
  report = bh2Reporter(
    "condition-table.csv",
    "reports/AlignmentBasedHeatmaps/report.json",
    "Alignment Based Heatmaps"
  )
  makeReport(report)
  0
}

logging::basicConfig()
main()