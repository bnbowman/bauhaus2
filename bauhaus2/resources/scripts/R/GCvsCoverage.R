#!/usr/bin/env Rscript

require( Biostrings )


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

boxplotVsGC = function( report, p, name, label )
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
    uid = "008000"
  )
}


#' Generate line plot with reference position on the x-axis
#'
#' @param p = data frame output of \code{\link{getGCandCov}}
#' @param label = string title for plots
#' @param name = string name of p column: "GC_Content", "Coverage", or "Subread_Length"
#' @export

plotVrefPosition = function( report, p, label, name )
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
    tags = c( "position", "gc", "coverage", "content", name, label, tag )
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
  plotVrefPosition( report, p, label, "GC_Content" )
  plotVrefPosition( report, p, label, "Coverage" )
  plotVrefPosition( report, p, label, "Subread_Length" )
  boxplotVsGC( report, p, "Coverage", label )
  boxplotVsGC( report, p, "Subread_Length", label )
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



