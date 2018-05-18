library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(reshape2)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))
source(file.path(myDir, "mummerOneCondition.R"))

midTitle <- theme(plot.title = element_text(hjust = 0.5, size = 12))
plTheme <-
  theme_bw(base_size = 14) + theme(
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 12)
  )
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(
  angle = 45,
  hjust = 1,
  size = 12
))
plotwidth = 7.2
plotheight = 4.2


makeTwelvePlots <- function(report, data) {
  tp1 = ggplot(data, aes(x = condition, polished_assembly.polished_contigs)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Polished.Contigs", title = "Polished.Contigs. vs. Condition")
  report$ggsave(
    "polished_contigs.png",
    tp1,
    width = plotwidth,
    height = plotheight,
    id = "Polished.Contigs. vs. Condition",
    title = "Polished.Contigs. vs. Condition",
    caption = "Polished.Contigs. vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100000"
  )
  tp2 = ggplot(data,
               aes(x = condition, polished_assembly.max_contig_length)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Maximum.Contig.Length", title = "Maximum.Contig.Length vs. Condition")
  
  report$ggsave(
    "max_contig_length.png",
    tp2,
    width = plotwidth,
    height = plotheight,
    id = "Maximum.Contig.Length vs. Condition",
    title = "Maximum.Contig.Length vs. Condition",
    caption = "Maximum.Contig.Length vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100001"
  )
  tp3 = ggplot(data,
               aes(x = condition, polished_assembly.sum_contig_lengths)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Sum.of.Contig.Lengths", title = "Sum.of.Contig.Lengths vs. Condition")
  report$ggsave(
    "polished_assembly.sum_contig_lengths.png",
    tp3,
    width = plotwidth,
    height = plotheight,
    id = "Sum.of.Contig.Lengths vs. Condition",
    title = "Sum.of.Contig.Lengths vs. Condition",
    caption = "Sum.of.Contig.Lengths vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100002"
  )
  tp4 = ggplot(data, aes(x = condition, preassembly.raw_coverage)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Filtered.Subread.Coverage", title = "Filtered.Subread.Coverage vs. Condition")
  report$ggsave(
    "preassembly.raw_coverage.png",
    tp4,
    width = plotwidth,
    height = plotheight,
    id = "Filtered.Subread.Coverage vs. Condition",
    title = "Filtered.Subread.Coverage vs. Condition",
    caption = "Filtered.Subread.Coverage vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100003"
  )
  tp5 = ggplot(data, aes(x = condition, preassembly.seed_mean)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Seed.Read.Length.Mean", title = "Seed.Read.Length.Mean vs. Condition")
  report$ggsave(
    "preassembly.seed_mean.png",
    tp5,
    width = plotwidth,
    height = plotheight,
    id = "Seed.Read.Length.Mean vs. Condition",
    title = "Seed.Read.Length.Mean vs. Condition",
    caption = "Seed.Read.Length.Mean vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100004"
  )
  tp6 = ggplot(data, aes(x = condition, preassembly.seed_n50)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Seed.Read.Length..N50", title = "Seed.Read.Length..N50 vs. Condition")
  report$ggsave(
    "preassembly.seed_n50.png",
    tp6,
    width = plotwidth,
    height = plotheight,
    id = "Seed.Read.Length..N50 vs. Condition",
    title = "Seed.Read.Length..N50 vs. Condition",
    caption = "Seed.Read.Length..N50 vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100005"
  )
  tp7 = ggplot(data, aes(x = condition, preassembly.preassembled_reads)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Number.of.Pre.Assembled.Reads", title = "Number.of.Pre.Assembled.Reads vs. Condition")
  report$ggsave(
    "preassembly.preassembled_reads.png",
    tp7,
    width = plotwidth,
    height = plotheight,
    id = "Number.of.Pre.Assembled.Reads vs. Condition",
    title = "Number.of.Pre.Assembled.Reads vs. Condition",
    caption = "Number.of.Pre.Assembled.Reads vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100006"
  )
  tp8 = ggplot(data, aes(x = condition, preassembly.preassembled_yield)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Pre.Assembled.Yield..bases.seed_bases", title = "Pre.Assembled.Yield..bases.seed_bases vs. Condition")
  report$ggsave(
    "preassembly.preassembled_yield.png",
    tp8,
    width = plotwidth,
    height = plotheight,
    id = "Pre.Assembled.Yield..bases.seed_bases vs. Condition",
    title = "Pre.Assembled.Yield..bases.seed_bases vs. Condition",
    caption = "Pre.Assembled.Yield..bases.seed_bases vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100007"
  )
  tp9 = ggplot(data, aes(x = condition, preassembly.preassembled_mean)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Pre.Assembled.Read.Length.Mean", title = "Pre.Assembled.Read.Length.Mean vs. Condition")
  report$ggsave(
    "preassembly.preassembled_mean.png",
    tp9,
    width = plotwidth,
    height = plotheight,
    id = "Pre.Assembled.Read.Length.Mean vs. Condition",
    title = "Pre.Assembled.Read.Length.Mean vs. Condition",
    caption = "Pre.Assembled.Read.Length.Mean vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100008"
  )
  tp10 = ggplot(data, aes(x = condition, preassembly.preassembled_n50)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Pre.Assembled.Read.Length..N50", title = "Pre.Assembled.Read.Length..N50 vs. Condition")
  report$ggsave(
    "preassembly.preassembled_n50.png",
    tp10,
    width = plotwidth,
    height = plotheight,
    id = "Pre.Assembled.Read.Length..N50 vs. Condition",
    title = "Pre.Assembled.Read.Length..N50 vs. Condition",
    caption = "Pre.Assembled.Read.Length..N50 vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100009"
  )
  tp11 = ggplot(data,
                aes(x = condition, preassembly.preassembled_seed_fragmentation)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Avg.Num.Reads.Each.Seed.Is.Broken.Into", title = "Avg.Num.Reads.Each.Seed.Is.Broken.Into vs. Condition")
  report$ggsave(
    "preassembly.preassembled_seed_fragmentation.png",
    tp11,
    width = plotwidth,
    height = plotheight,
    id = "Avg.Num.Reads.Each.Seed.Is.Broken.Into vs. Condition",
    title = "Avg.Num.Reads.Each.Seed.Is.Broken.Into vs. Condition",
    caption = "Avg.Num.Reads.Each.Seed.Is.Broken.Into vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100010"
  )
  tp12 = ggplot(data, aes(x = condition, preassembly.preassembled_coverage)) + geom_point() + plTheme + themeTilt  + clFillScale +
    labs(x = "Condition", y = "Pre.Assembled.Coverage", title = "Pre.Assembled.Coverage vs. Condition")
  report$ggsave(
    "preassembly.preassembled_coverage.png",
    tp12,
    width = plotwidth,
    height = plotheight,
    id = "Pre.Assembled.Coverage vs. Condition",
    title = "Pre.Assembled.Coverage vs. Condition",
    caption = "Pre.Assembled.Coverage vs. Condition",
    tags = c("basic", "hgapplots", "pointplot"),
    uid = "0100011"
  )
  
  
  
}

makeResidualErrorReports <- function(report, residualErrorPlots) {
  report$ggsave(
    "combined_residual_error_1.png",
    residualErrorPlots[[1]],
    width = plotwidth,
    height = plotheight,
    id = "combined_residual_error_1",
    title = "Residual Error - 1 - all Conditions",
    caption = "Residual Error - 1 - all Conditions",
    tags = c("basic", "hgapplots", "residual", "error"),
    uid = "0100020"
  )
  
  report$ggsave(
    "combined_residual_error_2.png",
    residualErrorPlots[[2]],
    width = plotwidth,
    height = plotheight,
    id = "combined_residual_error_2",
    title = "Residual Error - 2 - all Conditions",
    caption = "Residual Error - 2 - all Conditions",
    tags = c("basic", "hgapplots", "residual", "error"),
    uid = "0100021"
  )
}

makeReport <- function(report) {
  table1 = read.csv("reports/Combined_Conditions/combinedAssembly.csv")
  #Adding the condition name
  #data$Condition = c("A","B", "C")
  data = dcast(table1, condition ~ id, value.var = 'value')
  
  # Make combined residual error plots from snps.csv
  snps = read.csv("reports/Combined_Conditions/merge_snps.csv")
  
  # Make Plots
  residualErrorPlots = makeResidualErrorPlots(snps)
  try(makeResidualErrorReports(report, residualErrorPlots), silent = TRUE)
  try(makeTwelvePlots(report, data), silent = TRUE)
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter("condition-table.csv",
                        "reports/Combined_Conditions/report.json")
  makeReport(report)
  jsonFile = "reports/Combined_Conditions/report.json"
  #uidTagCSV = "reports/uidTag.csv"
  #rewriteJSON(jsonFile, uidTagCSV)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
