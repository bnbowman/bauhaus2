#!/usr/bin/env Rscript

require(argparser)
require(dtplyr)
require(jsonlite)
require(logging)
require(ggplot2)
require(pbbamr)
require(pbcommandR)
require(Biostrings)


source("./scripts/R/Bauhaus2.R")

#' Use the following aspect ratio, width, and height for all heatmaps

ASP_RATIO = 0.5
plotwidth = 7.2
plotheight = 4.2



#---------------------------------------------------------------
# Functions for plotting coverage and subread length vs. GC content
#---------------------------------------------------------------

#' Called by \code{\link{getCovAndReadLen}}
#'
#' @param k = vector of coverage or mean read length at a subset of refererence positions
#' @param N = length of reference genome
#' @export
#' @examples

fillInMissingPositions = function( k, N )
{
  # n = complete vector of coverages:
  n = rep( NA, N )
  n[ as.numeric( names( k ) ) ] <- k
  
  # Fill in any missing reference positions with last non-missing value:
  w = !is.na( n )
  if ( sum( w ) > 0 )
  {
    w = which( w )[1]
    prev = n[w]
    if ( w > 1 ) { n[1:(w-1)] <- prev }
    bool = is.na( n )
    for ( i in (w+1):N ) 
    {  
      if ( bool[i] ) { n[i] <- prev }
      else { prev <- n[i] } 
    }
  }
  n
}



#' Return a vector the length of the reference genome with the mean unaligned subread length at each position
#'
#' @param data = output of pbbamr::loadPBI
#' @param N = length of reference genome
#' @export
#' @examples

getCovAndReadLen = function( data, N )
{ 
  data$len = data$qend - data$qstart
  data$tstart = data$tstart + 1
  data$tend = data$tend + 1 
  n = nrow( data )
  z = c( data$tstart, data$tend )
  label1 = c( data$len, -data$len )
  label0 = c( rep( 1, n ), rep( -1, n ) )
  o = order( z )
  k1 = cumsum( vapply( split( label1[o], z[o] ), sum, 0 ) )
  k0 = cumsum( vapply( split( label0[o], z[o] ), sum, 0 ) )
  coverage = fillInMissingPositions( k0, N )
  readlen  = fillInMissingPositions( k1 / k0, N )
  cbind( coverage, readlen )
}




#' Return data frame with coverage vs. gc content at each template position in reference
#'
#' @param coverage = output of getCovAndReadLen above
#' @param ref = output of Biostrings::DNAStringSet from reference fasta
#' @param winsize = window size for computing GC content
#' @export
#' @examples

getGCandCov = function( covreadlen, ref, winsize, half = floor( winsize / 2.0 ), N = length( ref ) )
{
  y = strsplit( as.character( ref ), "" )[[1]]
  d = diff( cumsum( y %in% c("G", "C") ), winsize ) / winsize
  res = data.frame( pos = (half + 1):(N - half), GC_Content = d )
  res$Coverage = covreadlen[ res$pos, 1 ]
  res$Subread_Length = covreadlen[ res$pos, 2 ]
  subset( res, !is.na( Coverage ) & !is.na( GC_Content ) )
}




#' Plot normalized coverage or normalized readlength vs. GC-content 
#'
#' @param p = data frame output of \code{\link{{getGCandCov}}
#' @param stat = string, either "Coverage", or "SubreadLength" -- columns of p
#' @param label = string title for plots
#' @export

boxplotVsGC = function( report, p, name, label, uid )
{
  r = range( p$GC_Content, na.rm = TRUE )
  p$nSites = cut( p$GC_Content, breaks = seq( r[1], r[2], 0.05 ) )
  p = subset( p, !is.na( nSites ) )
  s = split( 1:nrow( p ), p$nSites )
  n = vapply( s, length, 0 )
  p$nSites = factor( n[ match( p$nSites, names( s ) ) ], levels = n )
  
  m = median( p[,name], na.rm = TRUE )
  p[,name] = p[,name] / m
  loginfo( paste( "m = ", m ) )
  myplot = ( ggplot( p, aes( x = p[,"GC_Content"], y = p[,name], fill = p[,"nSites"] ) ) +
               geom_boxplot() +
               geom_hline( yintercept = 1.0 ) + 
               labs( x = "GC Content", y = paste( name, "/ Median" ), title = paste( label, "\n Median", name, ":", format( m, digits = 4 ) ) ) )
  
  tag = paste( name, "vs_GC_Content", sep = "_" )
  pngfile = paste( tag, "png", sep = "." )
  
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = tag,
    title = tag,
    caption = tag,
    tags = c("gc", "content", name, label ),
    uid = uid
  )
}


#' Generate line plot with reference position on the x-axis
#'
#' @param p = data frame output of \code{\link{getGCandCov}}
#' @param label = string title for plots
#' @param name = string name of p column: "GC_Content", "Coverage", or "Subread_Length"
#' @export

plotVrefPosition = function( report, p, label, name, uid )
{
  myplot = ( ggplot( data = p, aes( x = pos, y = p[,name] ) ) +
               geom_line( ) +
               labs( x = "Ref. Position", y = name, title = label ) )
  tag = paste( name, "vs_tpl_position", sep = "_" )
  pngfile = paste( tag, "png", sep = "." )
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = tag,
    title = tag,
    caption = tag,
    tags = c( "position", "gc", "coverage", "content", name, label, tag ),
    uid = uid
  )
}



#' Plot coverage vs. gc content for a single reference
#'
#' @param data = pbbamr::loadPBI output
#' @param ref = Biostrings::readDNAStringSet output using fasta file as input
#' @param label = string title for plots
#' @param winsize = window size for computing GC content

singleRef = function( report, data, ref, label, winsize )
{
  coverage = getCovAndReadLen( data, length( ref ) )
  p = getGCandCov( coverage, ref, winsize )
  plotVrefPosition( report, p, label, "GC_Content", uid = "0075000" )
  plotVrefPosition( report, p, label, "Coverage", uid = "0075001" )
  plotVrefPosition( report, p, label, "Subread_Length", uid = "0075002" )
  boxplotVsGC( report, p, "Coverage", label, uid = "0075003" )
  boxplotVsGC( report, p, "Subread_Length", label, uid = "0075004" )
}





#' Main function called by makeReport
#' Load aligned bam pbi files.
#' Use Biostrings to open reference fasta.
#' For each reference in fasta, call \link{singleRef} above
#'
#' @param alndir = smrtlink alignment directory
#' @param reffasta = path to reference fasta file 
#' @param label = string title for plots
#' @param winsize = window size for computing GC content
#' @export

gcVcoverage = function( report, alnxml, reference, label, winsize = 100 )
{
  fastaname = getReferencePath( reference )
  refs = readDNAStringSet( fastaname )
  data = loadPBI( alnxml )
  s = split( 1:nrow( data ), as.character( data$ref ) )
  
  for ( refName in names( s ) )
  {
    loginfo( paste( "Draw plots for reference:", refName ) )
    tmp = subset( data, ref == refName )
    if ( nrow( tmp ) < 100 ) { return( 0 ) }
    ref = refs[[ which( grepl( pattern = refName, x = names( refs ) ) ) ]]
    singleRef( report, tmp, ref, paste( label, refName ), winsize ) 
  }
  1
}


#---------------------------------------------------------------
# End of functions for GC content plots
#---------------------------------------------------------------




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
  
  getBasicInformation(bam)
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

#------------------------------------------------------------
# Summarize by ZMW
#------------------------------------------------------------

#' Summarize the data frame contained in x by HoleNumber
#'
#' @param res data frame, output of \code{\link{writeSummaryTable}}
#' @param colList list with elements: nSum, nFirst, nMin, and nMax.  Each contains a list of names of columns of x.
#' @export
#' @examples
#' sumUpByMolecule( res, list( nSum = c("AlnReadLen", "TotalTime"), nFirst = c("HoleNumber", "X", "Y") ) )
#' sumUpByMolecule( res, list( nSum = c("AlnReadLen", "TotalTime"), nFirst = c("HoleNumber", "X", "Y"), nMin= c("rStart"), nMax=c("rEnd") ) )
#' colList = getColumnsForSummarization( names( res ), dna = c("A", "C", "G", "T") )
#' sumUpByMolecule( res, colList )

sumUpByMolecule = function(res, colList)
{
  # Make sure only columns actually contained in data frame x are listed in nSum and so on.
  
  nms = names(res)
  colList = lapply(colList, function(x)
    intersect(x, nms))
  
  res = data.table(res)
  x = res[, lapply(.SD, function(x)
    sum(x, na.rm = TRUE)), by = .(HoleNumber), .SDcols = colList$nSum]
  y = res[, lapply(.SD, function(x)
    x[1]), by = .(HoleNumber), .SDcols = colList$nFirst]
  z = res[, lapply(.SD, function(x)
    min(x, na.rm = TRUE)), by = .(HoleNumber), .SDcols = colList$nMin]
  w = res[, lapply(.SD, function(x)
    max(x, na.rm = TRUE)), by = .(HoleNumber), .SDcols = colList$nMax]
  
  #' Merge together and return:
  m = merge(x, y, by = "HoleNumber")
  m = merge(m, z, by = "HoleNumber")
  data.frame(merge(m, w, by = "HoleNumber"))
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
      "X",
      "Y",
      "Reference",
      "SMRTlinkID",
      paste("SNR", dna, sep = "_")
    ),
    nMax = c("MaxSubreadLen", "rEnd", "tEnd"),
    nMin = c("rStart", "tStart"),
    nSum = c("Matches", "Mismatches", "Inserts", "Dels", "AlnReadLen", "centerP1", "edgeP1")
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

postSummation = function(res, refTable)
{
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
  # Chip hole: x: (64,1143) y: (64,1023)
  # Center load: x: (222,985) y: (205,882). center percent: 49.96%
  res$center = ifelse(res$X > 221 & res$X < 986 & res$Y > 206 & res$X < 883,1,0)
  res$edge = ifelse(res$center == 0,1,0)
  res$centerP1 = ifelse(duplicated(res[,c("X","Y")]),0,res$center)
  res$edgeP1 = ifelse(duplicated(res[,c("X","Y")]),0,res$edge)
  colList = getColumnsForSummarization(names(res), dna)
  res = sumUpByMolecule(res, colList)
  postSummation(res, refTable)
}

#' Take output of \code{\link{applySummarization}} and summarize data into N[1] x N[2] blocks of ZMWs
#'
#' @param res data frame output of \code{\link{applySummarization}}
#' @param N vector of length two, containing dimensions of ZMW blocks for summarization
#' @param key (optional) - use to create a unique ID number for each block of ZMWs.
#'
#' @examples
#' res = writeSummaryTable( bamFile, fastaname )
#' res = applySummarization( res )
#' convenientSummarizer( res, N = c( 10, 8 ) )
#'
#' @export

convenientSummarizerbam = function(res,
                                   N,
                                   key = 1e3,
                                   x.min = 64,
                                   y.min = 64)
{
  if (length(N) == 1) {
    N = c(N, N)
  }
  x = as.numeric(res$X) - x.min + 1
  y = as.numeric(res$Y) - y.min + 1
  X = (x %/% N[1]) + (x %% N[1] > 0)
  Y = (y %/% N[2]) + (y %% N[2] > 0)
  
  if ("SNR_A" %in% names(res))
  {
    res$SNR_A[res$SNR_A == -1] <- NA
    res$SNR_C[res$SNR_C == -1] <- NA
    res$SNR_G[res$SNR_G == -1] <- NA
    res$SNR_T[res$SNR_T == -1] <- NA
    excl = c(
      "Matches",
      "Mismatches",
      "Inserts",
      "Dels",
      "HoleNumber",
      "Reference",
      "SMRTlinkID"
    )
    u = data.table(res[, -which(names(res) %in% excl)])
    u$X = X
    u$Y = Y
    v = u[, c("X", "Y", "centerP1", "edgeP1")] %>% group_by(X, Y) %>% summarise(sumcenterP1 = sum(centerP1), sumedgeP1 = sum(edgeP1), N = n())
    # v$N contains the number of alignments per N[1] x N[2] block
    FUN = function(x, na.rm = TRUE)
      as.double(median(x, na.rm))
    cols = setdiff(names(u), c("X", "Y"))
    tmp = data.frame(u[, lapply(.SD, FUN), by = .(X, Y), .SDcols = cols])
    m = match(key * tmp$X + tmp$Y, key * v$X + v$Y)
    tmp$Count = v$N[m]
    tmp$centerP1 = v$sumcenterP1[m]
    tmp$edgeP1 = v$sumedgeP1[m]
  }
  
  #' Estimate average number of pols per ZMW in each block of ZMWs:
  nZMWsPerBlk = N[1] * N[2]
  counts = as.numeric(tmp$Count)
  counts[counts == nZMWsPerBlk] = nZMWsPerBlk - 1
  tmp$AvgPolsPerZMW = -log(1 - (counts / nZMWsPerBlk))
  tmp
}

#----------------------------------------------------------------
# Plotting heatmaps
#----------------------------------------------------------------

savePlots = function(plot, file)
{
  file = file.path("./reports/AlignmentBasedHeatmaps/", file)
  png(file, type = c("cairo"))
  print(plot)
  dev.off()
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
      scale_y_reverse() + 
      scale_x_continuous(position = "top") +
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
    tags = c("heatmap", "heatmaps", "reference", "ref"),
    uid = "0070001"
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

drawSummarizedHeatmaps = function(report, res, label, dist, N, key)
{
  loginfo(paste("First, summarize condition", label, "by ZMW:"))
  res = applySummarization(res)
  if (is.null(res))
  {
    loginfo(paste("[ERROR] -- Too few rows for condition:", label))
    return(NULL)
  }
  
  loginfo(paste("Summarize into", N[1], "x", N[2], "blocks for condition:", label))
  
  df = convenientSummarizerbam(res, N, key)
  
  # Re-order the rows so that they match the distance matrix
  tmp = data.frame(X = dist$ID %/% key, Y = dist$ID %% key)
  df = merge(tmp, df, by = c("X", "Y"), all.x = TRUE)
  df$Count[is.na(df$Count)] <- 0
  
  df$AlnReadLenExtRange = df$AlnReadLen
  df$rStartExtRange = df$rStart
  df$MaxSubreadLenExtRange = df$MaxSubreadLen
  df$AccuracyExtRange = df$Accuracy
  addLoadingUniformityPlots(report, df, N, label, dist)
  
  loginfo(paste("Plot individual heatmaps for condition:", label))
  plotReferenceHeatmap(report, res, label)
  try(plotSingleSummarizedHeatmap(report, df, "Count", label, N, limits = c(0, 60), uid = "0070002"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "Accuracy", label, N, limits = c(0.70, 0.85), uid = "0070003"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "AccuracyExtRange", label, N, limits = c(0.70, 0.91), uid = "0070022"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "AlnReadLen", label, N, limits = c(500, 9000), uid = "0070004"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report,
                                  df,
                                  "AlnReadLenExtRange",
                                  label,
                                  N,
                                  limits = c(500, 30000), uid = "0070005"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "rStart", label, N, limits = c(0, 9000), uid = "0070009"),
      silent = FALSE)
  try(plotSingleSummarizedHeatmap(report, df, "rStartExtRange", label, N, limits = c(0, 25000), uid = "0070011"),
      silent = FALSE)
  
  # Target SNR: SNR_A="5.438" SNR_C="10.406" SNR_G="4.875" SNR_T="7.969"
  targetSNR = data.frame(base = c("A", "G", "C", "T"), targetSNRvalue = c(5.438, 4.875, 10.406, 7.969))
  targetSNR$range = 0.5
  targetSNR$LowerLimit = targetSNR$targetSNRvalue * (1 - targetSNR$range)
  targetSNR$UpperLimit = targetSNR$targetSNRvalue * (1 + targetSNR$range)
  #define a column of uids
  targetSNR$uidcol = c("0070014", "0070015", "0070016", "0070017")
  
  for (k in targetSNR$base) {
    try(plotSingleSummarizedHeatmap(report, df, paste("SNR_", k, sep = ""), label, N, limits = c(targetSNR$LowerLimit[targetSNR$base == k], targetSNR$UpperLimit[targetSNR$base == k]), uid = as.vector(targetSNR$uidcol[targetSNR$base==k])), silent = FALSE)
  }
  
  try(plotSingleSummarizedHeatmap(report,
                                  df,
                                  "MaxSubreadLenExtRange",
                                  label,
                                  N,
                                  limits = c(0, 15000), uid = "0070007"),
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
    "SNR_A",
    "SNR_G",
    "SNR_T",
    "Reference",
    "Matches",
    "Mismatches",
    "Inserts",
    "Dels",
    "AlnReadLenExtRange",
    "MaxSubreadLenExtRange",
    "rStartExtRange",
    "AccuracyExtRange",
    "centerP1",
    "edgeP1"
  )
  
  #create a dataframe 'Non_excl_uid' that has column names of the non-excluded columns and corresponding uid's
  Non_excl_columns = c ("MaxSubreadLen", "MaxSubreadLenToAlnReadLenRatio", "rEnd", "tStart", "tEnd", "MismatchRate", 
                        "InsertionRate", "DeletionRate", "AvgPolsPerZMW")
  uidcolumn = c ("0070006", "0070008", "0070010", "0070012", "0070013", "0070018","0070019","0070020", "0070021")
  Non_excl_uid = data.frame(Non_excl_columns, uidcolumn)
  lapply(setdiff(names(df), excludeColumns), function(n)
  { if (is.null(Non_excl_uid$uidcolumn[Non_excl_uid$Non_excl_columns==n]))
  {warning("Columns non-excluded different from set list")}
    else {
      try(plotSingleSummarizedHeatmap(report, df, n, label, N, uid = as.vector(Non_excl_uid$uidcolumn[Non_excl_uid$Non_excl_columns==n])),
          silent = FALSE)}
  })
}

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

drawHistogramForUniformity = function(report, label, counts, N, tbl)
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
  # savePlots( myplot, pngfile )
  # if ( 0 ) {
  report$ggsave(
    pngfile,
    myplot,
    width = plotwidth,
    height = plotheight,
    id = paste("uniformity_histogram", label, sep = "_"),
    title = title,
    caption = paste("Loading Uniformity Histogram:", label),
    tags = c("heatmap", "heatmaps", "uniformity", "loading", label),
    uid = "0071000"
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
  maxConc = floor(3 / min(pol_pM[pol_pM > 0], na.rm = TRUE))
  conc = seq(1, maxConc, 1)
  lambda = pol_pM %o% conc
  single = lambda * exp(-lambda)
  total = colMeans(single, na.rm = TRUE)  # assume uniform
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
                      S1.S2,
                      scaled = FALSE,
                      n = length(x))
{
  #' ASSUMPTIONS: No NA values in x -- any NAs should be 0 and n == nrow( weight )
  if (nrow(weight) != n)
    stop("Number of counts should match size of weight matrix")
  x[is.na(x)] <- 0
  
  #' Observed value of statistic, obs:
  y = x - sum(x, na.rm = TRUE) / n
  y2 = y * y
  var = sum(y2, na.rm = TRUE)
  
  #' The next non-commented line is faster than, but equivalent to,
  #' obs = sum( weight * y %o% y, na.rm = TRUE ) / var
  obs = sum(y * (weight %*% y), na.rm = TRUE) / var
  
  if (scaled)
  {
    i.max = sd(y) / sqrt(var / (n - 1))
    obs = obs / i.max
  }
  
  #' Expected value of statistic if there is no spatial autocorrelation:
  expected = -1 / (n - 1)
  
  #' Standard deviation of Moran's I statistic -- needed for p-value
  S1 = S1.S2[1]
  S2 = S1.S2[2]
  S0.2 = n * n
  k = (sum(y2 * y2) / n) / (var * var / S0.2)
  num.1 = n * ((n ^ 2 - 3 * n + 3) * S1 - n * S2 + 3 * S0.2)
  num.2 = k * (n * (n - 1) * S1 - 2 * n * S2 + 6 * S0.2)
  den = ((n - 1) * (n - 2) * (n - 3) * S0.2)
  sd = sqrt((num.1 - num.2) / den - expected ^ 2)
  
  #' obs ~ N( expected, sd ):
  c(obs, sd, pnorm(
    obs,
    mean = expected,
    sd = sd,
    lower.tail = (obs <= expected)
  ))
}

#' (K. Voss) If the entire chip loaded as well as one of the best regions, what would the loading be?
#'
#' @param res = data frame, summarized into blocks of ZMWs
#' @param qnt = quantile to use
#' @param nZMWs = number of ZMWs per chip
#'
#' @return two metrics: 95th percentile loading and observed loading percentile
#' @export

getKVossMetric = function(res, qnt = 0.95, nZMWs = 1032000)
{
  v = as.numeric(res$AvgPolsPerZMW)
  n = round(nZMWs * v * exp(-v))
  r = sum(as.numeric(res$Count), na.rm = TRUE)
  c(quantile(n, qnt, na.rm = TRUE), round(100 * sum(r >= n, na.rm = TRUE) / nrow(res)))
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

getUniformityMetricsTable = function(res, label, N, com, SNR, dist, cutoff = 2)
{
  loginfo(paste("\t Write uniformity metrics table for condition:", label))
  counts = as.numeric(res$Count)
  
  # cutoff = round( max( 1, boxplot( counts, plot = FALSE )$stat[1] ) )
  y = counts[counts >= cutoff]
  
  n.counts = length(counts)
  n.y = length(y)
  lowLoad = 1 - (n.y / n.counts)
  
  mu = mean(y, na.rm = TRUE)
  vr = var(y, na.rm = TRUE)
  dispersion = vr / mu - 1
  t1 = dispersion * sqrt(2 / n.y)
  le = getLoadingEfficiency(counts, N)
  kv = getKVossMetric(res)
  
  # Compute "center to edge" metric
  # "center to edge" metric is a ratio of the loading (P1) of 
  # the 50% of the inside zmws divided by the loading of the 50% outside zmws
  centerLoad = sum(res$centerP1, na.rm = T)
  edgeLoad = sum(res$edgeP1, na.rm = T)
  centertoedge = centerLoad/edgeLoad
  
  # Compute Moran's I statistics and corresponding p-values
  mi = unlist(lapply(1:dist$nMatrices,
                     function(i)
                       ape.moranI(counts, dist$MatList[[i]], dist$S1.S2[[i]])))
  
  data.frame(
    ID =  label,
    Cutoff = cutoff,
    NumBlks = n.counts,
    nReads = sum(counts, na.rm = TRUE),
    LowLoadFrac = lowLoad,
    Mean = mu,
    Var = vr,
    PoissonDispersion = dispersion,
    T1_WangEtAll = t1,
    LambdaUniformity = le,
    CenterOfMass.X = com[1],
    CenterOfMass.Y = com[2],
    CenterToEdge = centertoedge,
    MoransI.Inv = mi[1],
    MoransI.Inv.sd = mi[2],
    MoransI.Inv.p = mi[3],
    MoransI.N = mi[4],
    MoransI.N.sd = mi[5],
    MoransI.N.p = mi[6],
    ProjectedMaxLoading = kv[1],
    ObservedLoadingPercentile = kv[2],
    SNR_A = SNR[1],
    SNR_C = SNR[2],
    SNR_G = SNR[3],
    SNR_T = SNR[4]
  )
}

#' The length of a string (in characters).
#'
#' @param res data frame output of \code{\link{convenientSummarizer}}, summarized into blocks
#' @param N vector of length two describing dimensions of blocks of ZMWs
#' @param label string containing label for histogram and metrics table.
#'
#' @seealso \code{\link{drawSummarizedHeatmaps}} which calls this function.
#'
#' @export
#' @examples
#' N = c( 10, 8 )
#' res = convenientSummarizer( res, N )
#' addLoadingUniformityPlots( report, res, c(10, 8), "Condition_A" )

addLoadingUniformityPlots = function(report, tmp, N, label, dist)
{
  if (is.null(N))
    return(0)
  if (length(N) == 1) {
    N = c(N, N)
  }
  
  SNR_A = mean(tmp$SNR_A, na.rm = TRUE)
  SNR_C = mean(tmp$SNR_C, na.rm = TRUE)
  SNR_G = mean(tmp$SNR_G, na.rm = TRUE)
  SNR_T = mean(tmp$SNR_T, na.rm = TRUE)
  SNR = c(SNR_A, SNR_C, SNR_G, SNR_T)
  
  #' Compute center of mass
  x = as.numeric(tmp$X)
  y = as.numeric(tmp$Y)
  com = c(mean(x, na.rm = TRUE), mean(y, na.rm = TRUE)) - c(595 %/% N[1], 544 %/% N[2])
  
  tbl = getUniformityMetricsTable(tmp, label, N, com, SNR, dist)
  drawHistogramForUniformity(report, label, as.numeric(tmp$Count), N, tbl)
  csvfile = paste("Uniformity_metrics_", label, ".csv", sep = "")
  report$write.table(
    csvfile,
    tbl,
    id = "loading_metrics_table",
    title = paste(label, "Loading_uniformity_metrics", sep = "_"),
    tags = c("table", "uniformity", "loading", "metrics"),
    uid = "0073000"
  )
}



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

generateHeatmapsPerCondition = function(report,
                                        alnxml,
                                        reference,
                                        label,
                                        dist,
                                        N,
                                        key)
{
  loginfo(paste("Render coverage vs. GC content plots for condition:", label))
  gcVcoverage( report, alnxml, reference, label )
  
  loginfo(paste("Get data for condition:", label))
  fastaname = getReferencePath(reference)
  res = simpleErrorHandling(alnxml, fastaname)
  if (is.null(res)) {
    loginfo("[WARNING] - Empty BAM file.")
    return(0)
  } else {
    if (nrow(res) < 5)
    {
      loginfo("[WARNING] - Too few rows in BAM file.")
      return(0)
    }
    
    loginfo(paste("Summarize data for condition:", label))
    res$SMRTlinkID = label
    
    loginfo(paste("Draw regular heatmaps for condition:", label))
    res = subset(res, SNR_A != -1 &
                   SNR_C != -1 & SNR_G != -1 & SNR_T != -1)
    drawSummarizedHeatmaps(report, res, label, dist, N, key)
    1
  }
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
  
  N = c(8, 8)
  key = 1e3
  dist = getDistMat(N, key)
  res = lapply(1:length(alnxmls), function(k)
    generateHeatmapsPerCondition(report, alnxmls[k], refs[k], labels[k], dist, N, key))
  # Make barplot for Uniformity metrics
  csvfile = paste(report$outputDir,
                  "/Uniformity_metrics_",
                  labels,
                  ".csv",
                  sep = "")[unlist(lapply(res, function(i) {
                    !i == 0
                  }))]
  if (length(csvfile) == 0) {
    loginfo("[WARNING] - All conditions are empty!")
    0
  } else {
    Uniformity = rbindlist(lapply(csvfile, function(i) {
      read.csv(i)
    }))[, c("ID", "LambdaUniformity", "MoransI.Inv", "MoransI.N", "CenterToEdge")]
    Uniformity$MoransI.Inv_percentage = 100 * Uniformity$MoransI.Inv
    Uniformity$MoransI.N_percentage = 100 * Uniformity$MoransI.N
    UniformityMerge = Uniformity[, c("ID",
                                     "LambdaUniformity",
                                     "MoransI.Inv_percentage",
                                     "MoransI.N_percentage")]
    UniformityLong = melt(UniformityMerge, id.vars = "ID")
    tp = ggplot(UniformityLong, aes(factor(variable), value, fill = ID)) +
      geom_bar(stat = "identity", position = "dodge") +
      scale_fill_brewer(palette = "Set1") +
      labs(x = "Variables", y = "Score", title = "Barchart of Uniformity")
    report$ggsave(
      "barchart_of_uniformity.png",
      tp,
      width = plotwidth,
      height = plotheight,
      id = "barchart_of_uniformity",
      title = "Barchart of Uniformity",
      caption = "barchart_of_uniformity",
      tags = c(
        "bar",
        "barchart",
        "uniformity",
        "Lambda",
        "MoransI",
        "Morans"
      ),
      uid="0072000"
    )
    
    # Center to edge histogram
    UniformityCTE = Uniformity[, c("ID",
                                   "CenterToEdge")]
    UniformityLong2 = melt(UniformityCTE, id.vars = "ID")
    tp = ggplot(UniformityLong2, aes(factor(variable), value, fill = ID)) +
      geom_bar(stat = "identity", position = "dodge") +
      scale_fill_brewer(palette = "Set1") +
      labs(x = "Variables", y = "Score", title = "Center to Edge P1 Ratio")
    report$ggsave(
      "barchart_of_center_to_edge_p1.png",
      tp,
      width = plotwidth,
      height = plotheight,
      id = "barchart_of_center_to_edge_p1",
      title = "Center to Edge P1 Ratio",
      caption = "barchart_of_center_to_edge_p1",
      tags = c(
        "bar",
        "barchart",
        "uniformity",
        "center",
        "edge",
        "P1"
      ),
      uid="0074000"
    )
  }
  # Uniformity = rbindlist(lapply(csvfile, function(i){read.csv(i)}))[,c("ID", "LambdaUniformity", "MoransI.Inv", "MoransI.Inv.sd", "MoransI.N", "MoransI.N.sd")]
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.RData"))
  report$write.report()
  1
}

main = function()
{
  report = bh2Reporter(
    "condition-table.csv",
    "reports/AlignmentBasedHeatmaps/report.json",
    "Alignment Based Heatmaps"
  )
  makeReport(report)
  jsonFile = "reports/AlignmentBasedHeatmaps/report.json"
  uidTagCSV = "reports/uidTag.csv"
  
  # TODO: currently we don't rewrite the json report since the uid is not added to the heatmaps yet
  
  # rewriteJSON(jsonFile, uidTagCSV)
  0
}

logging::basicConfig()
main()
