library(data.table)
library(dplyr)
library(ggplot2)

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



##
## Condition table grokking.
##
loadConditionTable <- function(conditionTableCSV,
                               wfOutRoot=dirname(conditionTableCSV))
{
    ## We load the Bauhaus2 CSV and augment it with extra columns R analysis is
    ## going to need:
    ##  - Reference      (path to reference FASTA)
    ##  - MappedSubreads (path to the mapped subreads)
    ##  - more??
    ## (These files should all found in the wfOutRoot)
    ct <- read.csv(conditionTableCSV)
    data.table(ct)
    mappedSubreads <- file.path(wfOutRoot, "conditions", ct$Condition, "mapped/mapped.alignmentset.xml")
    ct$MappedSubreads <- mappedSubreads
    referenceFasta <- file.path(wfOutRoot, "conditions", ct$Condition, "reference.fasta")
    ct$Reference <- referenceFasta
    ct
}


##
## Generating reports about plots, tables
##
bh2Reporter <- function(conditionTableCSV, outputFile, reportTitle) {

    reportOutputPath <- dirname(outputFile)
    reportOutputFile = outputFile
    version <- version
    plotsToOutput <- data.frame()
    tablesToOutput <- data.frame()
    cond_table <- loadConditionTable(conditionTableCSV)

    ## Save a ggplot in the report.
    .ggsave <- function(img_file_name, plot, id = "plot_name", title="Default Title",
                       caption="No caption specified", ...)
    {
        if (!chkPng(img_file_name)) {
            img_file_name = paste0(img_file_name, ".png")
        }
        img_path = file.path(reportOutputPath, img_file_name)
        ggplot2::ggsave(img_path, plot = plot, ...)
        logging::loginfo(paste("Wrote img to: ", img_path))
        ## FIXME.
        ##plotsToOutput <<- c(list(p), plotsToOutput)
    }

    ## Add a table to the report.
    .write.table<- function(tbl_file_name, tbl, id = "table_name", title = "Default Title")
    {
        if (!chkCsv(tbl_file_name)) {
            tbl_file_name = paste(tbl_file_name, ".csv")
        }
        tbl_path = file.path(reportOutputPath, tbl_file_name)

        write.csv(tbl, file=tbl_path)
        ## FIXME
        ##tablesToOutput <<- c(table, tablesToOutput)
    }

    ## Output the report file as json.
    .write.report <- function()
    {
        ## FIXME
        write("{}", file=file.path(reportOutputPath, "report.json"))
    }


    list(condition.table = cond_table,
         ggsave = .ggsave,
         write.table = .write.table,
         write.report = .write.report,
         outputPath = reportOutputPath)
}
