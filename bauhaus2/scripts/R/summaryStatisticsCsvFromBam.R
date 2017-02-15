#!/usr/bin/env Rscript

# To submit to cluster:
# qsub -V -cwd -pe smp 12 -b y 'R CMD BATCH --no-save -3656 summaryStatisticsCsvFromBam.R'


# ppbamr installation:
#
# module load R/3.2.1
#
# from R in linux  ( say yes to all yes/no questions )
#
# library(devtools)
# httr::set_config( httr::config( ssl_verifypeer = 0L ) )
# install_github("PacificBiosciences/pbbamr")


# Usage example:


require( pbbamr )
require( ggplot2 )

source("/home/UNIXHOME/smrtpipe/public_html/heatmaps/pbbamRfunctions.R")


#----------------------------------------------------------------
# Functions for summarizing data per-molecule
#----------------------------------------------------------------

nMedian = function(x) median( x, na.rm = TRUE )

nSum = function(x) sum( x, na.rm = TRUE )

nMin = function(x) min( x, na.rm = TRUE )

nMax = function(x) max( x, na.rm = TRUE )

nMean = function(x) mean( x, na.rm = TRUE )

nFirst = function(x) x[1]


summarizeByMolecule = function( res, LAPPLYfunction )
{
  tmp = split( 1:nrow( res ), res$HoleNumber )
  N = length( tmp )
  # tmp = sapply( 1:ncol( res ),
  #              function(k) vapply( tmp, function(x) summaryFuncs[[k]]( res[x,k] ), 0 ) )

  summaryFuncs = vector( "list" )
  for ( k in 1:ncol( res ) )
  {
    summaryFuncs[[k]] = nMedian
    n = names( res )[k]
    if ( n %in% c( "HoleNumber", "X", "Y", "Reference", "FrameRate", "SMRTlinkID" ) ) { summaryFuncs[[k]] = nFirst }
    else if ( n %in% c( "Matches", "Mismatches", "Inserts", "Dels", "AlnReadLen") ) { summaryFuncs[[k]] = nSum }
    else if ( n == "rStart" ) { summaryFuncs[[k]] = nMin }
  }

  tmp = LAPPLYfunction( 1:ncol( res ),
                function(k) vapply( tmp, function(x) summaryFuncs[[k]]( as.numeric( res[x,k] ) ), 0 ) )

  tmp = do.call( cbind, tmp )

  if ( N == 1 )
  {
    tmp = t( tmp )
  }
  tmp = data.frame( tmp )
  names( tmp ) = names( res )
  tmp
}


#----------------------------------------------------------------


#----------------------------------------------------------------
# Process information from loadpbi
#----------------------------------------------------------------


getBasicInformation = function( bam )
{
  res = data.frame( 	HoleNumber = getHoleNumber( bam  ),
			X = getHoleX( bam ),
			Y = getHoleY( bam ),
			rStart = getRstart( bam ),
			Matches = getMatches( bam ),
			Mismatches = getMismatches( bam ),
			Inserts = getInsertions( bam ),
			Dels = getDeletions( bam ),
			AlnReadLen = getTemplateSpan( bam ),
			Reference = getReferenceName( bam ) )
  cbind( res, getSNR( bam ) )
}


applySummarization = function( res, LAPPLYfunction )
{
  refTable = names( table( res$Reference ) )
  res$Reference = match( res$Reference, refTable )

  res = summarizeByMolecule( res, LAPPLYfunction )
  res$Reference = refTable[ res$Reference ]

  res$MismatchRate = res$Mismatches / res$AlnReadLen
  res$InsertionRate = res$Inserts / res$AlnReadLen
  res$DeletionRate = res$Dels / res$AlnReadLen
  res$Accuracy = 1 - res$MismatchRate - res$InsertionRate - res$DeletionRate

  res
}

#----------------------------------------------------------------




#----------------------------------------------------------------
# Process information from loadDataAtOffsets
#----------------------------------------------------------------


getDetailedInformation = function( offsets, bamFile, fastaname, holenumber )
{
  tmp = loadDataAtOffsets( offsets, bamFile, fastaname )
  bcs = getBasecalls( tmp  )

  m = getMedianByBaseIdentity( getIPD( tmp ), bcs, "IPD" )
  m$TotalTime = getTotalTime( tmp )

  if ( "pkmid" %in% names( tmp[[1]] ) )
  {
    m = cbind( m, getMedianByBaseIdentity( getPkmid( tmp ), bcs, "Pkmid" ) )
  }

  if ( "pw" %in% names( tmp[[1]] ) )
  {
    m = cbind( m, getMedianByBaseIdentity( getPulseWidth( tmp ), bcs, "PW" ) )
  }

  m$HoleNumber = holenumber
  m
}


getMedianByBaseIdentity = function( pkmid, bcs, name )
{
  dna = c("A", "C", "G", "T")

  m = data.frame( t( mapply(
	FUN = function( p, b ) vapply( 	split( p[ b %in% dna ], factor( b[ b %in% dna ], levels = dna ) ),
					function(x) median( x, na.rm = TRUE ), 0 ),
 	pkmid, bcs ) ) )

  names( m ) = paste( name, names( m ), sep = "_" )
  m
}

#----------------------------------------------------------------




#----------------------------------------------------------------
# Write results to csv file
#----------------------------------------------------------------


writeSummaryTable = function( bamFile, fastaname )
{
  bam = loadpbi( bamFile, loadSNR = TRUE, loadNumPasses = TRUE, loadRQ = TRUE)
  res = getBasicInformation( bam )

  hns = bam$hole
  s = split( 1:length( bam$hole ), bam$hole )
  L =  lapply( s, function(x) getDetailedInformation( bam$offset[x], bamFile, fastaname, hns[x] ) )
  tmp = do.call( rbind, L )

  tmp = tmp[,-which(colnames(tmp) == "HoleNumber")]
  res = do.call( rbind, lapply( s, function(x) res[x,] ) )
  res = cbind( res, tmp )

  # res = merge( res, tmp, by = "HoleNumber", all = TRUE )

  if ( "Pkmid_A" %in% names( res ) )
  {
    res$BaselineSigma_A = res$Pkmid_A / res$SNR_A
    res$BaselineSigma_C = res$Pkmid_C / res$SNR_C
    res$BaselineSigma_G = res$Pkmid_G / res$SNR_G
    res$BaselineSigma_T = res$Pkmid_T / res$SNR_T
  }

  res$FrameRate = getFrameRate( bamFile )
  res$PolRate = res$AlnReadLen / res$TotalTime * res$FrameRate
  res
}


# If unable to process one BAM file, keep going:

simpleErrorHandling = function( bamFile, fastaname )
{
  res = try( writeSummaryTable( bamFile, fastaname ), silent = FALSE )
  if (class(res) == "try-error")
  {
    cat( "[WARNING]: Unable to open or process file under subdirectory : ", x, "\n" )
    return( NULL )
  }
  res
}

#----------------------------------------------------------------


#----------------------------------------------------------------
# For loading uniformity plots
#----------------------------------------------------------------


getLoadingEfficiency = function( z, N )
{
  pol_pM = z / (N^2)
  maxConc = floor( 3 / min( pol_pM[ pol_pM > 0 ] ) )
  conc = seq( 1, maxConc, 1 )
  lambda = pol_pM %o% conc
  single = lambda * exp( -lambda )
  total = colMeans( single )  # assume uniform
  100 * max( total, na.rm = TRUE ) * exp(1)
}


drawHeatmapForUniformity = function( ID, f, writedir = getwd() )
{
  title = paste( "Loading_uniformity_heatmap_smrtlink", ID, sep = "_" )

  df = data.frame( Count = as.numeric( c( f ) ) )
  df$Y = as.numeric( rep( colnames( f ), each  = nrow( f ) ) )
  df$X = as.numeric( rep( row.names( f ), ncol( f ) ) )

  png( file.path( writedir, paste( title, "png", sep="." ) ), type = c("cairo"))

  print( qplot( data = df, Y, X, size = I(1), color = Count ) +
        scale_colour_gradientn( colours = rainbow(7) ) + labs( title = title ) )

  dev.off()
  1
}

drawHistogramForUniformity = function( ID, f, nAlns, nSubreads, N, writedir = getwd(), com = c( 0, 0 ) )
{
  z = c( f )
  cutoff = round( max( 1, boxplot( z, plot = FALSE )$stat[1] ) )
  y = z[ z >= cutoff ]

  n.z = length( z )
  n.y = length( y )

  lowLoad = 1 - ( n.y / n.z )

  mu = mean( y )
  vr = var( y )
  dispersion = vr / mu - 1
  t1 = dispersion * sqrt( 2 / n.y )

  title = paste( "Loading_uniformity_hist_smrtlink", ID, sep = "_" )
  png( file.path( writedir, paste( title, "png", sep="." ) ), type = c("cairo"))

  h = hist( z, 100,
        col = "turquoise",
        main = paste( "% low-loaded blocks = %", format( lowLoad * 100, digits = 3 ),
                ";\t cutoff =", cutoff,
                "\n var / mean - 1 =", format( dispersion, digits = 3 ),
                "\n mean =", format( mu, digits = 3 ),
                ";\t # alns =", nAlns ),
        xlab = paste( "Number of alignments per", N, "x", N, "block" ),
        ylab = paste( "Number of", N, "x", N, "blocks" ) )
  abline( v = mu, col = 'red' )
  abline( v = cutoff, col = 'red' )
  grid()

  dev.off()

  le = getLoadingEfficiency( z, N )

  write.csv(
    data.frame( 	
	ID = ID, LowLoadFrac = lowLoad, Cutoff = cutoff, Mean = mu, Var = vr,
	PoissonDisp = dispersion, nRead = nAlns, nSubreads = nSubreads,
	NumBlks	= n.z, NumBlksAboveCutoff = n.y,
	T1_WangEtAll = t1,
	NonUniformityPenalty = le,
	COM.x = com[1], COM.y = com[2] ),
    file = file.path( writedir, paste( ID, "_Loading_uniformity_metrics", ".csv", sep = "" ) ),
    row.names = FALSE )

  1
}


#----------------------------------------------------------------



#----------------------------------------------------------------
# Draw heatmaps
#----------------------------------------------------------------


summarizeColumns_N_by_N = function( res, N )
{
  # blocks must first be summarized by hole number --

  x = as.numeric( res$X )
  y = as.numeric( res$Y )

  a = floor( seq( min( x, na.rm = TRUE ), max( x, na.rm = TRUE ), N ) )
  b = floor( seq( min( y, na.rm = TRUE ), max( y, na.rm = TRUE ), N ) )

  kx = findInterval( x, a )
  ky = findInterval( y, b )

  excludeColumns = c( "HoleNumber", "X", "Y", "Reference", "FrameRate", "SMRTlinkID", "Matches", "Mismatches", "Inserts", "Dels"  )
  nms = setdiff( names( res ), excludeColumns )

  df = rep( 0, length( nms ) + 2 )
  for ( ix in unique( kx ) )
  {
    for ( iy in unique( ky ) )
    {
      df = rbind( df, c( ix, iy, apply( res[ which( kx == ix & ky == iy ), nms ], 2, function(x) median( x, na.rm=TRUE ) ) ) )
    }
  }
  df = df[-1,]
  df = data.frame( df )
  names( df )[c(1,2)] = c("X", "Y")
  df
}


drawSummarizedHeatmaps = function( res, smrtlinkID, dir, LAPPLYfunction, N )
{
  df = summarizeColumns_N_by_N( res, N )
  excludeColumns = c("X", "Y", "HoleNumber" )
  LAPPLYfunction( setdiff( names( df ), excludeColumns ), function( n )
  {
    pngfile = file.path( dir, paste( n, "_summarized_heatmap_smrtlink_", smrtlinkID, ".png", sep = "" ) )
    png( pngfile, type = c( "cairo" ) )

    title = paste( n, " (median per ", N, " x ", N, " block) : ", smrtlinkID, sep = "" )
    tmp = removeOutliers( df, n )
    print( qplot( data = tmp, Y, X, size = I(1), color = tmp[,n] ) +
	scale_colour_gradientn( colours = rainbow(7) ) + labs( title = title ) )

    dev.off()
    1
  } )
}



depr.removeOutliers = function( m, name )
{
  subset( m, m[,name] <= boxplot(  m[,name], plot = FALSE )$stat[5] )
}


removeOutliers = function( m, name )
{
  m = subset( m, !is.na( m[,name] ) )
  values = m[,name]
  m[,name] = ifelse( values <= boxplot(  m[,name], plot = FALSE )$stat[5], values, NA )
  m
}



drawHeatmaps = function( res, smrtlinkID, dir, LAPPLYfunction, N = NULL )
{
  if ( !is.null( N ) )
  {
    drawSummarizedHeatmaps( res, smrtlinkID, dir, LAPPLYfunction, N )
  }

  excludeColumns = c("X", "Y", "HoleNumber", "FrameRate", "TotalTime", "Matches", "Mismatches", "Inserts", "Dels" )
  LAPPLYfunction( setdiff( names( res ), excludeColumns ), function( n )
  {
    pngfile = file.path( dir, paste( n, "_heatmap_smrtlink_", smrtlinkID, ".png", sep = "" ) )
    png( pngfile, type = c( "cairo" ) )

    if ( n != "Reference" )
    {
      tmp = removeOutliers( res, n )
      print( qplot( data = tmp, Y, X, size = I(1), color = tmp[,n] ) +
		scale_colour_gradientn( colours = rainbow( 7 ) ) +
		labs( title = paste( n, ":", smrtlinkID ) ) +
		theme( aspect.ratio = 0.5) )
    }
    else
    {
      tmp = res
      print( qplot( data = tmp, Y, X, size = I(1), color = tmp[,n] ) +
		labs( title = paste( n, ":", smrtlinkID ) ) )

    }
    dev.off()
    1
  } )

  pngfile = file.path( dir, paste( "heatmap_smrtlink_", smrtlinkID, ".png", sep = "" ) )
  png( pngfile, type = c( "cairo" ), height=600, width=600 )
  print( qplot( data = res, Y, X, size = I(0.75), alpha = I(0.2) ) +
		labs( title = paste( "Alignments :", smrtlinkID ) ) +
		theme( aspect.ratio = 0.5) )
  dev.off()



  # Add in loading uniformity plots if a block size, N, is provided:

  if ( !is.null( N ) )
  {
    tmp = res
    tmp = tmp[ !duplicated( tmp$HoleNumber ), ]
    x = as.numeric( tmp$X )
    y = as.numeric( tmp$Y )

    # 5/9/2016 addition
    com = c( mean( x, na.rm = TRUE ), mean( y, na.rm = TRUE ) ) - c( 595, 544 )

    a = floor( seq( min( x, na.rm = TRUE ), max( x, na.rm = TRUE ), N ) )
    b = floor( seq( min( y, na.rm = TRUE ), max( y, na.rm = TRUE ), N ) )

    tab = table( findInterval( x, a ), findInterval( y, b ) )
    drawHeatmapForUniformity( smrtlinkID, tab, dir )
    drawHistogramForUniformity( smrtlinkID, tab, nrow( res ), nrow( res ), N, dir, com )
  }
  1
}


#----------------------------------------------------------------





summaryStatisticsCsvFromBam = function( smrtlinkID, parallel = TRUE, writedir = getwd(), writecsv = TRUE, N = NULL )
{
  LAPPLYfunction = lapply

  if ( parallel )
  {
    require( BiocParallel )
    BiocParallel::register( MulticoreParam( workers = 12 ) )
    LAPPLYfunction = bplapply
  }

  dir = fetchSMRTlinkDirectory( smrtlinkID )
  fastaname = getFastaFileFromSMRTlinkDirectory( dir )

  res = LAPPLYfunction( file.path( dir, list.files( dir, "*pbalign-[0-9]+$" ) ),
	  # function( path ) simpleErrorHandling( file.path( path, list.files( path, "aligned.subreads.alignmentset.bam$" )[1] ),
	  function( path ) simpleErrorHandling( file.path( path, list.files( path, "mapped.alignmentset.bam$" )[1] ),
						fastaname ) )

  res = do.call( rbind, res )
  res$SMRTlinkID = smrtlinkID

  if ( writecsv )
  {
    filename = file.path( writedir, paste( "smrtlink_", smrtlinkID, ".csv", sep = "" ) )
    write.csv( res, file = filename, row.names = FALSE )
  }

  # res = read.csv( "smrtlink_5284.csv", header = TRUE )

  # now summarize by hole number and draw heatmaps:

  res = applySummarization( res, LAPPLYfunction )
  drawHeatmaps( res, smrtlinkID, writedir, LAPPLYfunction, N )

  1
}

#----------------------------------------------------------------


if ( 1 )
{
  summaryStatisticsCsvFromBam( smrtlinkID = getSMRTlinkIDfromCommandLine(), N = 10 )
}

