require( XML )
require( pbbamr )


#=================================================================



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



getStatsCsvStandIn = function( smrtlinkID )
{
  # pad the smrtlinkID number with zeros:
  a = paste( paste( rep( "0", 6 - nchar( smrtlinkID ) ), collapse = "" ), smrtlinkID, sep = "" )

  # take the first three digits in the result:
  b = paste( strsplit( a, "" )[[1]][1:3], collapse = "" )

  d = paste( "http://web/~smrtpipe/heatmaps/", b, "/", a, "/smrtlink_", a, ".csv", sep = "" )
  read.csv( d, header = TRUE )
}


getSMRTlinkIDfromCommandLine = function()
{
  args = commandArgs( trailingOnly = FALSE )
  smrtlinkID = args[ length(args) ]
  sub( "-", "", smrtlinkID )
}



getFastaFileFromSMRTlinkDirectory = function( dir )
{
  input = file.path( strsplit( dir, "tasks/")[[1]][1], "index.html" )
  ref = file.path( rawDataAndRefFromSMRTlinkHTML( input, TRUE ), "sequence" )
  file.path( ref, list.files( ref, "*.fasta$" ) )
}


fetchSMRTlinkDirectory = function( smrtlinkID )
{
  # pad the smrtlinkID number with zeros:
  a = paste( paste( rep( "0", 6 - nchar( smrtlinkID ) ), collapse = "" ), smrtlinkID, sep = "" )

  # take the first three digits in the result:
  b = paste( strsplit( a, "" )[[1]][1:3], collapse = "" )

  # expected directory corresponding to smrtlinkID:
  paste( "/pbi/dept/secondary/siv/smrtlink/smrtlink-beta/smrtsuite_166987/userdata/jobs_root/", b, "/", a, "/tasks/", sep = "" )
}


#=================================================================




getPathToUnaligendBAMfiles = function( smrtlinkID )
{
  dir = fetchSMRTlinkDirectory( smrtlinkID )
  raw = rawDataAndRefFromSMRTlinkHTML( file.path( strsplit( dir, "tasks/")[[1]][1], "index.html" ) )
  file.path( raw, list.files( raw, "*[0-9].subreads.bam$" ) )
}


getFastaFileFromSMRTlinkDirectory = function( dir )
{
  input = file.path( strsplit( dir, "tasks/")[[1]][1], "index.html" )
  ref = file.path( rawDataAndRefFromSMRTlinkHTML( input, TRUE ), "sequence" )
  file.path( ref, list.files( ref, "*.fasta$" ) )
}


fetchSMRTlinkDirectory = function( smrtlinkID )
{
  # pad the smrtlinkID number with zeros:
  a = paste( paste( rep( "0", 6 - nchar( smrtlinkID ) ), collapse = "" ), smrtlinkID, sep = "" )

  # take the first three digits in the result:
  b = paste( strsplit( a, "" )[[1]][1:3], collapse = "" )

  # expected directory corresponding to smrtlinkID:
  paste( "/pbi/analysis/smrtlink/beta/jobs-root/", b, "/", a, "/tasks/", sep = "" )
}


getPathsToAlignedBAMfiles = function( smrtlinkID )
{
  dir = fetchSMRTlinkDirectory( smrtlinkID  )
  file.path( dir, list.files( dir, "pbalign.tasks.pbalign-[0-9]+" ) )
}


getDataFromIndex = function( smrtlinkID, FUNC )
{
  paths = getPathsToAlignedBAMfiles( smrtlinkID )
  res = lapply( paths, function( path )
  {
    bamFile = file.path( path, list.files( path, "*.bam$" ) )
    bam = loadpbi( bamFile, loadSNR = TRUE )
    cbind( getHoleNumber( bam ), FUNC( bam ) )
  } )
  do.call( rbind, res )
}

getMaxSubreadLength = function( smrtlinkID )
{
  rstart = getDataFromIndex( smrtlinkID, getRstart )
  TemplateSpan = getDataFromIndex( smrtlinkID, getTemplateSpan )
  qend = getDataFromIndex( smrtlinkID, getQueryEnd )

  s = split( 1:nrow(rstart), rstart[,1] )

  data.frame(
    rStart = vapply( s, function(x) min( rstart[x,2], na.rm = TRUE ), 0 ),
    maxInsertLen = vapply( s, function(x) max( tspan[x,2], na.rm = TRUE ), 0 ),
    hqlen = vapply( s, function(x) sum( tspan[x,2], na.rm = TRUE ), 0 ),
    firstPass = vapply( s, function(x) tspan[x[1],2], 0 ),
    qend = vapply( s, function(x) qend[x[1],2], 0 )
  )
}


drawMaxSubreadPlotsFromBAM = function( smrtlinkID, plotTitle, maxRstart = 100, dir = getwd() )
{
  setwd( "/home/NANOFLUIDICS/obanerjee/src/software/R/rdtools/libraryDiagnostics/" )
  source( "libraryDiagnostics.R" )
  setwd( dir )

  settings = loadDefaultSettings()
  settings$scatterplotRegionalDensities = TRUE
  settings$includeScatterplotTable = TRUE

  res = getMaxSubreadLength( smrtlinkID )
  S = subset( res, rStart <= maxRstart )
  pdf( file.path( dir, paste( smrtlinkID, "pdf", sep = "." ) ) )
  plotMaxInsertScatter( S, settings, plotTitle, alignmentBased = TRUE )
  dev.off()
  1

}



getReferenceFromIndex = function( smrtlinkID )
{
  paths = getPathsToAlignedBAMfiles( smrtlinkID )
  res = lapply( paths, function( path )
  {
    bamFile = file.path( path, list.files( path, "*.bam$" ) )
    bam = loadpbi( bamFile )
    getReferenceName( bam )
  } )
  unlist( res )
}



getDataFromIndex2 = function( smrtlinkID, functionList )
{
  paths = getPathsToAlignedBAMfiles( smrtlinkID )
  res = lapply( paths, function( path )
  {
    bamFile = file.path( path, list.files( path, "*.bam$" ) )
    bam = loadpbi( bamFile, loadSNR = TRUE )
    do.call( cbind, lapply( functionList, function( f ) f( bam ) ) )
  } )
  res = data.frame( do.call( rbind, res ) )
  res$RefFullName = getReferenceFromIndex( smrtlinkID )
  res
}


collectLibDiagnosticsData = function( smrtlinkID )
{
  functionList = list( 	holeNumbers = getHoleNumber,
			rStart = getRstart,
			rEnd = getQueryEnd,
			tStart = getTemplateStart,
			tEnd = getTemplateEnd
		 )
  res = getDataFromIndex2( smrtlinkID, functionList )
  names( res ) = c("holeNumbers", "rStart", "rEnd", "tStart", "tEnd", "RefFullName")
  # setNames( res, colnames( res ) )
  res$TemplateSpan = res$tEnd - res$tStart + 1
  res
}




setAdapterCensoringFilter3 = function( cmpH5, R_Adapters, settings )
{
  cmpH5 = cmpH5[ order( cmpH5$holeNumber, cmpH5$rStart, decreasing = FALSE ), ]
  R_Adapters = R_Adapters[ order( R_Adapters$holeNumber, R_Adapters$start, decreasing = FALSE ), ]

  s = split( 1:nrow(cmpH5 ), cmpH5$holeNumber )
  e = split( 1:nrow( R_Adapters ), R_Adapters$holeNumber )
  k = match( as.numeric( names(s) ), as.numeric( names(e) ) )

  w = which( !is.na(k) )
  v = vapply( w, function( i )
	tail( R_Adapters$start[ e[[ k[i] ]] ], 1 ) - tail( cmpH5$rEnd[ s[[i]] ], 1 ), 0 )

  ACn = rep( 0, nrow( cmpH5 ) )
  for ( i in w )
  {
    ACn[ s[[i]] ] = v[ i ]
  }
  AC = rep( FALSE, nrow( cmpH5 ) )
  u = which( ACn > 0 )
  AC[ u ] = ACn[ u ] < settings$rEnd2AdapterMax
  AC
}


libraryDiagnosticsForSMRTlink = function( smrtlinkID, plotTitle = "tmp", plotFileName = "tmp", MovieLengthSeconds = NULL )
{
  cat("collect basic data from aligned bam.pbi ...\n")
  res = collectLibDiagnosticsData( smrtlinkID )

  cat("collect adapter information from associated scraps ...\n" )
  source("/home/UNIXHOME/obanerjee/pacbio_bam_examples/pbbam/auxilliary.R")
  raw = getRawDirectoryFromSMRTlinkID( smrtlinkID )
  adp = getAdapters( raw )

  cat("set adapter censoring and rStart filters ...\n" )
  source("/home/UNIXHOME/obanerjee/src/software/R/rdtools/libraryDiagnostics/libraryDiagnostics.R")
  settings = loadDefaultSettings()
  settings$includeScatterplotTable = TRUE
  settings$scatterplotRegionalDensities = TRUE
  settings$rStartMax = 100

  res$MovieLengthCensoring = FALSE
  res$fltr = res$rStart <= settings$rStartMax
  res$AC = setAdapterCensoringFilter3( res, adp, settings )

  M = split( 1:nrow( res ), res$RefFullName )
  nms = names( M )
  for ( k in 1:length(M) )
  {
     tmp = res[ M[[k]], ]
     tmp = tmp[ order( tmp$holeNumbers, tmp$rStart, decreasing = FALSE ), ]
     tmp$first = !duplicated( tmp$holeNumbers )
     tmp$rStarts = tmp$rStart
     tmp$holeNumber = tmp$holeNumbers

     s = split( 1:nrow( tmp ), tmp$holeNumbers )
     tmp$subreadNumber = unlist( lapply( s, function(x) c(1:length(x)) ) )
     tmp$nsubs = unlist( lapply( s, function(x) rep( length(x), length(x) ) ) )

     cat("summarize data for max subread scatter plot ...\n")
     smp = list( lib = summarizeAndSubsetSortedCmpH5File(  tmp, settings ), materials = NULL )

     cat("generate plots ...\n")
     result = list( res = tmp, tmp = smp )
     generateAllPlots( result, settings, alignmentBased = TRUE, paste( plotTitle, nms[k], sep = "_" ), paste( plotFileName, nms[k], sep = "_" ) )
  }
}



plotMaxSubreadScatter = function( res, smrtlinkID, maxRstart, dir = getwd(), PNG = TRUE )
{
  res = subset( res, rStart <= maxRstart )
  if (PNG )
  {
    png( file.path( dir, paste( "max_subread_scatterplot_", smrtlinkID, ".png", sep = "" ) ),
	 type = c("cairo"))
  }
  plot( res$hqlen, res$maxInsertLen, pch = 16, col = "blue",
	cex = 0.5, ylab = "Max Subread Length", xlab = "Unrolled Template Span",
	main = paste( smrtlinkID, "\nZMWs with rStart <", maxRstart ) )
  abline( a = 0, b  = 1, col = 'red' )
  abline( a = 0, b = 0.5, col = 'red' )
  legend( "bottomright", paste( nrow( res ), "ZMWs" ), fill = c( "blue" ) )
  grid()
  if ( PNG ) {   dev.off() }
  1
}


getMaxInsertScatterplotData = function( smrtlinkID, maxRstart )
{
  bamFile = getPathToUnaligendBAMfiles( smrtlinkID )
  bam = loadpbi( path )
  s = split( 1:length( bam$hole ), bam$hole )
  v = vapply( s, function( x ) max( bam$qend[x] - bam$qstart[x] + 1, na.rm = TRUE ), 0 )
  w = vapply( s, function( x ) max( bam$qend[x], na.rm = TRUE ) -
				min( bam$qstart[x], na.rm = TRUE ), 0 )

  res = data.frame( HoleNumber = names( s ), MaxInsertLength = v, HQLength = w )
  row.names( res ) = NULL
  tmp = getDataFromIndex( smrtlinkID, getRstart )
  subset( res, HoleNumber %in% subset( tmp, tmp[,2] < maxRstart )[,1] )
}


isPacbioBAMFormatInternal = function( path, dir = getwd() )
{
  filename = file.path( dir, "tmp.txt" )
  setwd( path )
  system( paste( "samtools view -H *.bam >", filename ) )
  res = length( grep( "PulseWidth", readLines( filename ) ) ) > 0
  setwd( dir )
  res
}


strsplitFunction = function( str )
{
  tmp = as.character( str )
  tmp = strsplit( tmp[ length( tmp ) ], "/" )[[1]]
  paste( tmp[-length( tmp )], collapse = "/" )
}



rawDataAndRefFromSMRTlinkHTML = function( input, refDirectory = FALSE )
{
  txt = htmlTreeParse( input )$children$html
  kpp = txt[[2]][[1]][[10]]

  choices = c( strsplitFunction( kpp[[1]][[2]][[3]][[1]] ),
                strsplitFunction( kpp[[1]][[3]][[3]][[1]] ) )

  ind = grep( "reference", choices, ignore.case = TRUE )
  if ( refDirectory ) return( choices[ ind ] )
  choices[ setdiff( 1:2, ind ) ]
}




getFrameRate = function( bamFile ) as.numeric( as.character(  loadheader( bamFile )$readgroups$framerate[1] ) )

.getBAMData = function( tmp, idx )
{
  if ( is.null( idx ) ) return( tmp )
  tmp[ intersect( idx, c(1:length(tmp)) ) ]
}

getHoleNumber = function( bam, idx = NULL ) .getBAMData( bam$hole, idx )

getHoleX = function( bam, idx = NULL ) ( getHoleNumber( bam, idx ) %/% 65536 )

getHoleY = function( bam, idx = NULL ) ( getHoleNumber( bam, idx ) %% 65536 )

getHoleXY = function( bam, idx = NULL )
{
  HoleNumber = getHoleNumber( bam, idx )
  data.frame( X = HoleNumber %/% 65536, Y = HoleNumber %% 65536 )
}

getReadLength = function( bam, idx = NULL ) .getBAMData( bam$tend - bam$tstart + 1, idx )

getTemplateSpan = getReadLength

getTemplateEnd = function( bam, idx = NULL ) .getBAMData( bam$tend, idx )

getReferenceName = function( bam, idx = NULL ) .getBAMData( bam$ref, idx )

getQueryEnd = function( bam, idx = NULL ) .getBAMData( bam$qend, idx )

getQueryStart = function( bam, idx = NULL ) .getBAMData( bam$qstart, idx )

getTemplateStart = function( bam, idx = NULL ) .getBAMData( bam$tstart, idx )

getRstart = function( bam, idx = NULL ) .getBAMData( bam$astart, idx )

getMatches = function( bam, idx = NULL ) .getBAMData( bam$matches, idx )

getMismatches = function( bam, idx = NULL ) .getBAMData( bam$mismatches, idx )

getInsertions = function( bam, idx = NULL ) .getBAMData( bam$inserts, idx )

getDeletions = function( bam, idx = NULL ) .getBAMData( bam$dels, idx )

getSNR_A = function( bam, idx = NULL ) .getBAMData( bam$snrA, idx )

getSNR_C = function( bam, idx = NULL ) .getBAMData( bam$snrC, idx )

getSNR_G = function( bam, idx = NULL ) .getBAMData( bam$snrG, idx )

getSNR_T = function( bam, idx = NULL ) .getBAMData( bam$snrT, idx )

getSNR  = function( bam, idx = NULL ) data.frame( SNR_A = getSNR_A( bam, idx ),
						  SNR_C = getSNR_C( bam, idx ),
						  SNR_G = getSNR_G( bam, idx ),
						  SNR_T = getSNR_T( bam, idx )  )




getIPD = function( tmp, idx = NULL ) lapply( tmp, function(x) x$ipd )

getBasecalls = function( tmp )  lapply( tmp, function(x) x$read )

getPulseWidth = function( tmp )
{
  if ( "pw" %in% names( tmp[[1]] ) )
  {
    return( lapply( tmp, function(x) x$pw ) )
  }
  lapply( getIPD( tmp ), function(x) rep(0,length(x)) )
}

getPkmid = function( tmp )
{
  if ( "pkmid" %in% names( tmp[[1]] ) )
  {
    return( lapply( tmp, function(x) x$pkmid ) )
  }
  lapply( getIPD( tmp ), function(x) rep(0,length(x)) )
}

getCumulativeAdvanceTime = function( tmp )
{
  mapply( getIPD( tmp ), getPulseWidth( tmp ), FUN = function( ipd, pw ) {
        v <- ipd + pw
        v <- cumsum(ifelse(is.na(v), 0, v))
        v[is.na(pw)] <- NA
        v
  }, SIMPLIFY = FALSE)
}


getTotalTime = function( tmp )
{
  sapply( getCumulativeAdvanceTime( tmp ), function(a) a[length(a)] - a[1] )
}




