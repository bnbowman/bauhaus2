library(ggplot2)
library(plyr)
library(stringr)
library(logging)

myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))
plotwidth = 7.2
plotheight = 4.2


makeReport <- function(report, csv_fn)
{
    # CSV file is a tab delimited file containing columnes ['name', 'path'],
    # where name is name or id of a png file and path is filepath to a png file.
    csv = read.table(csv_fn, header=TRUE)
    logging::loginfo(head(csv))
    for (i in 1:nrow(csv)) {
        name <- as.character(csv$name[i])
        path <- as.character(csv$path[i])
        logging::loginfo(paste("PNG plot filepath:", print(path), ", id:", print(name), sep=" "))
        report$register.png(path, name)
    }
    # Save the report object for later debugging
    save(report, file = file.path(report$outputDir, "report.Rd"))
}

main <- function(in_plt_csv, out_report_json)
{
    logging::loginfo(paste("Input csv containing columns ['name', 'path']: ", print(in_plt_csv), sep=''))
    logging::loginfo(paste("Output zia report json: ", print(out_report_json), sep=''))
    report <- bh2Reporter("condition-table.csv", out_report_json, "Structural Variants Validation Report")
    makeReport(report, in_plt_csv)
    # At the end of this function we need to call this last, it outputs the report
    report$write.report()
    0
}

logging::basicConfig()
## Set up options
get_opt <- function() {
    library(optparse)
    i <- make_option(c("-i", "--name_path_csv"), type="character", default='reports/plt.csv', metavar="character",
                     help="Input tab-delimited CSV containing columns ['name', 'path'], where each column contains name and path of an existing png file, default=[ %default]")
    o <- make_option(c("-o", "--zia_report_json"),  type="character", default='reports/zia.report.json',
                     help="Output zia report json, default=[ %default]", metavar="character")
    option_list = list(i, o);
    opt_parse = OptionParser(option_list=option_list);
    opt = parse_args(opt_parse);
    if (is.null(opt$name_path_csv) || is.null(opt$zia_report_json)) {
        print_help(opt_parse)
        stop("INPUT and OUTPUT file must be provided.", call.=FALSE)
    }
    opt
}
opt = get_opt()
## Leave this as the last line in the file.
main(opt$name_path_csv, opt$zia_report_json)
