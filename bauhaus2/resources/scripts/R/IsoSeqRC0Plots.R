library(ggplot2)
library(plyr)
library(stringr)
library(logging)

myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))
plotwidth = 7.2
plotheight = 4.2

readlength_txt <- 'prefix\tdesc
ccs\tCCS
flnc\tFull Length Non-Chimeric
nfl\tNon-Full-Length
consensus_isoforms\tUnpolished Consensus Isoforms
hq\tHigh Quality Consensus Isoforms
lq\tLow Quality Consensus Isoforms
collapsed_to_sirv_rep\tCollapsed SIRV Isoforms'

val_report_txt <- 'key\tprefix\tdesc
collapse_to_sirv.num_TruePositive\tcollapse_to_sirv_n_true_positive\tSIRV True Positive max=68
collapse_to_sirv.num_FalseNegative\tcollapse_to_sirv_n_false_negative\tSIRV False Negative max=68
collapse_to_sirv.num_FalsePositive\tcollapse_to_sirv_n_false_positive\tSIRV False Positive
reseq_to_sirv.hq_isoforms_n_mapped_reads\treseq_to_sirv_hq_n_mapped_reads\tHQ Isoforms Mappable to SIRV
reseq_to_sirv.hq_isoforms_n_mapped_refs\treseq_to_sirv_hq_n_mapped_refs\tSIRV Mapped by HQ Isoforms max=68
reseq_to_sirv.isoseq_flnc_n_mapped_reads\treseq_to_sirv_flnc_n_mapped_reads\tFull Length Non-Chimeric Reads Mappable to SIRV
reseq_to_sirv.isoseq_flnc_n_mapped_refs\treseq_to_sirv_flnc_n_mapped_refs\tSIRV Mapped by Full Length Non-Chimeric Reads max=68
reseq_to_sirv.lq_isoforms_n_mapped_reads\treseq_to_sirv_lq_n_mapped_reads\tLQ Isoforms Mappable to SIRV
reseq_to_sirv.lq_isoforms_n_mapped_refs\treseq_to_sirv_lq_n_mapped_refs\tSIRV Mapped by LQ Isoforms max=68'

file_exists <- function(fn) {(file.info(fn)$size > 0) %in% TRUE} # TRUE if fn exists and has content
files_exist <- function(fns) {all(file.info(fns)$size > 0) %in% TRUE} # TRUE if all files in fns exist and have content

makeReadLengthPlots <- function(report, conditions) {
    makeReadLengthPlot <- function(report, conditions, csv_prefix, csv_desc)
    {
        # For example, conditions = data.frame(Condition<-c('MovieA', 'MovieB'),...), csv_prefix='ccs', csv_desc='CCS'
        # Fetch readlength datapoints from CSV file: './conditions/MovieA/eval/csv/ccs_readlength.csv', and
        # './conditions/MovieA/eval/csv/ccs_readlength.csv', which must contain ("name", "readlength") fields.
        # Make read length histogram in '.reports/ReadLengthPlots/isoseq_rc0_ccs_readlength_hist.png'.
        conditions$CSV <- file.path("./conditions", conditions$Condition, "eval", "csv", paste(csv_prefix, "_readlength.csv", sep=""))
        if (files_exist(conditions$CSV) != TRUE) {
            logging::loginfo(paste('Could not find all files in ', print(conditions$CSV), sep=''))
            return (NA)
        } # stop processing if some files missing
        make_dat_from_csv <- function(csv_fn, cd) {
            # input csv file must contain fields, ('name', 'readlength') where 'name' repsent read name
            # return data frame ('readlength', 'condition')
            data.frame(readlength<-read.table(csv_fn, header=TRUE, colClasses=c("NULL", "integer")),
                       condition<-factor(rep(cd, nrow(readlength))))
        }
        make_dat_from_csvs <- function(csv_fns, conditions) { # return rbind data frame ('readlength', 'condition')
            stopifnot(length(csv_fns) == length(conditions))
            dat <- data.frame(readlength=integer(), condition=factor())
            for (i in 1:length(csv_fns)) {
                dat <- rbind(dat, make_dat_from_csv(csv_fns[i], conditions[i]))
            }
            names(dat) = c('readlength', 'condition')
            dat
        }
        # Make vars to display in plot
        id <- paste("isoseq_rc0_", csv_prefix, "_readlength_hist", sep="")
        png_fn <- paste(id, ".png", sep="")
        title <- paste("IsoSeq RC0", csv_desc, "Read Length Histogram", sep=" ")
        caption <- title
        tags <- c("isoseq", "rc0", csv_prefix, "histogram")

        # dat<-data.frame(condition=factor(rep(c("A", "B"), each=200)), readlength=c(sample(1:2000, 200), sample(500:2200, 200))) # test data
        dat <- make_dat_from_csvs(conditions$CSV, conditions$Condition)
        # Make plot
        bd <- min(300, floor(max(dat$readlength) / 20 /100.0) * 100) # compute binwidth
        tp <- ggplot(dat, aes(x=readlength, fill=condition)) + geom_histogram(binwidth=bd, position='dodge') + ggtitle(title)

        # Save plot to report
        report$ggsave(png_fn, tp, width = plotwidth, height = plotheight, id = id, title = title, caption = caption, tags = tags)
    }

    prefix_descs <- read.table(header=TRUE, text=readlength_txt, sep='\t')
    # Make read length plots for CCS, FLNC, NFL, HQ, LQ, and etc.
    for (i in 1:length(prefix_descs$prefix)) {
        logging::loginfo(paste('Making Read Length Plot for ', prefix_descs$prefix, sep=''))
        makeReadLengthPlot(report, conditions, prefix_descs$prefix[i], prefix_descs$desc[i])
    }
}

makeSIRVPlots <- function(report, conditions)
{
    # e.g., conditions=c('MovieA','MovieB'), read from './conditions/MovieA/eval/isoseq_rc0_validation_report.csv'
    # and './conditions/MovieB/eval/isoseq_rc0_validation_report.csv', make data.frame('name', 'value', 'condition'),
    # ('collapse_to_sirv.num_TruePositive', 58, 'MovieA')
    make_dat_from_val_report <- function(val_report_fn, cd) {
        # val_report_fn format: 'name   value', e.g.,'collapse_to_sirv.num_isoforms   55'
        d <- read.table(val_report_fn, sep='\t', header=TRUE)
        data.frame(name=as.character(d$name), value=d$value, condition=factor(rep(cd, length(d$name))))
    }
    make_dat_from_val_reports <- function(val_reports_fns, cds) {
        stopifnot(length(val_reports_fns) == length(cds))
        dat <- data.frame(name=character(), value=as.numeric(), condition=factor())
        for (i in 1:length(val_reports_fns)) {
            dat <- rbind(dat, make_dat_from_val_report(val_reports_fns[i], cds[i]))
        }
        dat
    }
    makeBarPlot <- function(report, dat, key, prefix, desc)
    {
        # dat = data.frame(name=character(), value=as.integer(), condition=factor())
        # key = 'collapse_to_sirv.num_TruePositive', prefix = 'sirv_n_true_positive', desc = 'SIRV True Positive'
        # Get SIRV True Positive from dat[dat$name=='collapse_to_sirv.num_TruePositive',]$value
        # make barplot: reports/IsoSeqRC0Plots/isoseq_rc0_sirv_n_true_positive.png
        # make vars to display in plot
        id <- paste("isoseq_rc0_", prefix, sep="")
        png_fn <- paste(id, ".png", sep="")
        title <- paste("IsoSeq RC0", desc, sep=" ")
        caption <- title
        tags <- c("isoseq", "rc0", 'sirv', "histogram")
        # Make data frame
        #dat <- data.frame(name=c('collapse_to_sirv.num_TruePositive'), value=c(56), condition=c('moviea')), test data
        dat <- dat[as.character(dat$name)==key,] # ('name', 'value', 'condition'), e.g., ('collapse_to_sirv.num_TruePositive', 57, 'MovieA')
        # Make plot
        tp <- ggplot(dat, aes(condition)) + geom_bar(aes(weight=value, fill=condition)) + ggtitle(title)
        report$ggsave(png_fn, tp, width=plotwidth, height=plotheight, id=id, title=title, caption=caption, tags=tags)
    }

    conditions = data.frame(Condition <- report$condition.table[, c("Condition")])
    val_report_fns <- file.path('./conditions', conditions$Condition, 'eval', 'isoseq_rc0_validation_report.csv')
    stopifnot(files_exist(val_report_fns)) # raise an error if not all files exist
    dat <- make_dat_from_val_reports(val_report_fns, conditions$Condition)
    key_prefix_descs <- read.table(header=TRUE, text=val_report_txt, sep='\t')

    for (i in 1:length(key_prefix_descs$key)) {
        makeBarPlot(report, dat, key_prefix_descs$key[i], key_prefix_descs$prefix[i], key_prefix_descs$desc[i])
    }
}

makeReSeqToHumanPlots <- function(report, conditions)
{
    make_dat_from_coverage <- function(coverage_fn, cd) {
        # input coverage file must contain fields, ('transcript', 'coverage')
        # return data frame ('transcript', 'coverage', 'condition')
        dat <- read.table(coverage_fn, header=TRUE)
        dat$condition <- factor(rep(cd, length(dat$coverage)))
        dat
    }
    make_dat_from_coverage_fns <- function(coverage_fns, conditions) {
        # return rbind data frame ('transcript', 'coverage', 'condition')
        stopifnot(length(coverage_fns) == length(conditions))
        dat <- data.frame(name=character(), coverage=integer(), condition=factor())
        for (i in 1:length(coverage_fns)) {
            dat <- rbind(dat, make_dat_from_coverage(coverage_fns[i], conditions[i]))
        }
        names(dat) = c('transcript', 'coverage', 'condition')
        dat
    }
    makePlot<-function(report, dat, prefix, desc)
    {
        id <- paste("isoseq_rc0_", prefix, sep="")
        png_fn <- paste(id, ".png", sep="")
        title <- paste("IsoSeq RC0 Depth of Selected Human Transcripts in ", desc, sep="")
        caption <- title
        tags <- c("isoseq", "rc0", 'hg', "histogram")
        tp <- ggplot(dat, aes(x=transcript, y=coverage, fill=condition)) + geom_bar(stat='identity', position=position_dodge()) + theme(axis.text.x=element_text(angle=90)) + ggtitle(title)
        report$ggsave(png_fn, tp, width=plotwidth, height=plotheight, id=id, title=title, caption=caption, tags=tags)
    }

    makeCoveragePlot <- function(report, conditions, coverage_fn, prefix, desc)
    {
        # e.x., conditions=c("A", "B"), coverage_fn='flnc_reseq_to_hg_selected.csv', desc="FLNC", prefix='flnc'
        coverage_fns =  file.path('./conditions', conditions$Condition, 'eval', 'reseq_to_hg', coverage_fn)
        stopifnot(files_exist(coverage_fns)) # raise an error if not all files exist
        dat <- make_dat_from_coverage_fns(coverage_fns, conditions$Condition)
        makePlot(report, dat, prefix, desc)
    }

    conditions = data.frame(Condition <- report$condition.table[, c("Condition")])
    # Plot coverage of selected human transcript by flnc reads and HQ isoforms
    makeCoveragePlot(report=report, conditions=conditions, coverage_fn='hq_reseq_to_hg_selected_transcripts.csv', prefix="hq_reseq_to_hg_selected", desc="HQ isoforms")
    makeCoveragePlot(report=report, conditions=conditions, coverage_fn='flnc_reseq_to_hg_selected_transcripts.csv', prefix="flnc_reseq_to_hg_selected", desc="Full Length Non-Chimeric Read")
}

makeReport <- function(report)
{
    conditions = data.frame(Condition <- report$condition.table[, c("Condition")])
    # Make Read Length Plots
    makeReadLengthPlots(report, conditions)

    # Make SIRV Plots
    makeSIRVPlots(report, conditions)

    # Make Reseq to Human Plots
    makeReSeqToHumanPlots(report, conditions)

    # Save the report object for later debugging
    save(report, file = file.path(report$outputDir, "report.Rd"))
    # At the end of this function we need to call this last, it outputs the report
    report$write.report()
}

main <- function()
{
    report <- bh2Reporter("condition-table.csv",
                          "reports/IsoSeqRC0Plots/report.json",
                          "Read Length reports")
    makeReport(report)
    0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
