#!/usr/bin/env Rscript
# Test Simple Comparison Script
# This script takes a set of conditions and produces a png for display

library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR, quietly = TRUE)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(survival)
library(ggfortify)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

#' Define a basic addition to all plots
plTheme <- theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
clScale <- NULL #scale_colour_brewer(palette = "Set1")
clFillScale <- NULL# scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))
plotwidth = 7.2
plotheight = 4.2

makeCDFofaStartPlots <- function(report, cd) {
  loginfo("Making CDF of aStart Plots")
  
  # Create and add a plot group
  tp = ggplot(cd, aes(x = astart)) + stat_ecdf(aes(colour = Condition)) + geom_vline(xintercept = 50, colour = "red") + plTheme + clScale + labs(x = "astart", y = "C.D.F", title = "CDF of aStart")
  
  report$ggsave(
    "cdf_astart.png",
    tp,
    width = 12,
    height = 6,
    id = "cdf_astart",
    title = "CDF of aStart",
    caption = "CDF of aStart"
  )
  
  tp = ggplot(cd, aes(x = astart)) + stat_ecdf(aes(colour = Condition)) + scale_x_log10() + geom_vline(xintercept = 50, colour = "red") +
    plTheme + clScale +
    labs(x = "astart (Log-scale)", y = "C.D.F", title = "CDF of aStart (Log-scale)")
  
  report$ggsave(
    "cdf_astart_log.png",
    tp,
    width = 12,
    height = 6,
    id = "cdf_astart_log",
    title = "CDF of aStart (Log-scale)",
    caption = "CDF of aStart (Log-scale)"
  )
  
  # Yield (Subreads) by Reference
  tp = ggplot(cd, aes(ref, fill = Condition)) + geom_bar(position = "dodge") + 
    plTheme + themeTilt  + clFillScale + 
    labs(x = "Reference", y = "nSubreads", title = "Yield (Subreads) by Reference")
  
  report$ggsave(
    "subreads_ref_hist.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "subreads_ref_hist",
    title = "Yield (Subreads) by Reference",
    caption = "Yield (Subreads) by Reference"
  )
  
  # Yield (Subreads) Percentage by Reference
  
  cdref = cd %>% group_by(Condition, ref) %>% summarise(n = n())
  cdref = cdref %>% group_by(Condition) %>% mutate(nper = n/sum(n)) %>% ungroup()
  tp = ggplot(cdref, aes(x = ref, y = nper, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale + 
    labs(x = "Reference", y = "(nSubreads by Reference)/nSubreads ", title = "Yield (Subreads) Percentage by Reference")
  
  report$ggsave(
    "nsubreads_ref_hist_percentage.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "nsubreads_ref_hist_percentage",
    title = "Yield (Subreads) Percentage by Reference",
    caption = "Yield (Subreads) Percentage by Reference"
  )
  
  # for unrolled data
  cdunrolled = cd %>% group_by(Condition, hole, ref) %>% summarise(unrolledT = sum(tlen))
  
  # Yield (Unrolled Alignments) by Reference
  tp = ggplot(cdunrolled, aes(ref, fill = Condition)) + geom_bar(position = "dodge") + 
    plTheme + themeTilt  + clFillScale + 
    labs(x = "Reference", y = "Unrolled Alignments", title = "Yield (Unrolled Alignments) by Reference")
  
  report$ggsave(
    "unrolled_ref_hist.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "unrolled_ref_hist",
    title = "Yield (Unrolled Alignments) by Reference",
    caption = "Yield (Unrolled Alignments) by Reference"
  )
  
  # Yield (Unrolled Alignments) Percentage by Reference
  
  cdunrolledref = cdunrolled %>% group_by(Condition, ref) %>% summarise(n = n())
  cdunrolledref = cdunrolledref %>% group_by(Condition) %>% mutate(nper = n/sum(n)) %>% ungroup()
  tp = ggplot(cdunrolledref, aes(x = ref, y = nper, fill = Condition)) + geom_bar(stat = "identity", position = "dodge") +
    plTheme + themeTilt  + clFillScale + 
    labs(x = "Reference", y = "(Unrolled Alignments by Reference)/Unrolled Alignments ", title = "Yield (Unrolled Alignments) Percentage by Reference")
  
  report$ggsave(
    "unrolled_ref_hist_percentage.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "unrolled_ref_hist_percentage",
    title = "Yield (Unrolled Alignments) Percentage by Reference",
    caption = "Yield (Unrolled Alignments) Percentage by Reference"
  )
  
  # Template Span by Reference
  tp <- ggplot(data = cd, aes(x = factor(ref), y = tlen, fill = factor(Condition))) +
    geom_boxplot(position = position_dodge(width = 0.9)) 
  a <- aggregate(tlen ~ ref + Condition , cd, function(i) round(median(i)))
  tp <- tp +  geom_text(data = a, aes(label = tlen), 
                 position = position_dodge(width = 0.9), vjust = -0.8)
  
  report$ggsave(
    "template_span_ref_box.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "template_span_ref_box",
    title = "Template Span by Reference",
    caption = "Template Span by Reference"
  )
  
}

makeMaxVsUnrolledPlots <- function(report, cd) {
  loginfo("Making Max Insert Length vs Unrolled Aligned Read Length Plots")
  
  # Here the unrolled sequence lengths are computed using High-Low method
  # They can also be computed by Summation method
  cd2_summation = cd %>% dplyr::group_by(Condition, hole) %>% dplyr::summarise(
    MaxInsert = max(alen),
    MaxInsertT = max(tlen),
    Unrolled = sum(alen),
    UnrolledT = sum(tlen),
    hqmin = min(qstart),
    hqmax = max(qend)
  ) %>% dplyr::ungroup()
  cd2_summation$hqlen = cd2_summation$hqmax - cd2_summation$hqmin
  cd2_summation$Region = NA
  cd2_summation$Region[cd2_summation$MaxInsert == cd2_summation$Unrolled] = "Region 1"
  cd2_summation$Region[cd2_summation$MaxInsert > 0.51 * cd2_summation$Unrolled &
                         cd2_summation$MaxInsert < cd2_summation$Unrolled] = "Region 2"
  cd2_summation$Region[cd2_summation$MaxInsert <= 0.51 * cd2_summation$Unrolled &
                         cd2_summation$MaxInsert >= 0.49 * cd2_summation$Unrolled] = "Region 3"
  cd2_summation$Region[cd2_summation$MaxInsert < 0.49 * cd2_summation$Unrolled] = "Region 4"
  cd2_summation$Region = as.factor(cd2_summation$Region)
  
  cd2 = cd %>% dplyr::group_by(Condition, hole) %>% dplyr::summarise(
    MaxInsert = max(alen),
    MaxInsertT = max(tlen),
    Unrolled = max(aend) - min(astart),
    UnrolledT = max(tend) - min(tstart),
    hqmin = min(qstart),
    hqmax = max(qend)
  ) %>% dplyr::ungroup()
  cd2$hqlen = cd2$hqmax - cd2$hqmin
  cd2$Region = NA
  cd2$Region[cd2$MaxInsert == cd2$Unrolled] = "Region 1"
  cd2$Region[cd2$MaxInsert > 0.51 * cd2$Unrolled &
               cd2$MaxInsert < cd2$Unrolled] = "Region 2"
  cd2$Region[cd2$MaxInsert <= 0.51 * cd2$Unrolled &
               cd2$MaxInsert >= 0.49 * cd2$Unrolled] = "Region 3"
  cd2$Region[cd2$MaxInsert < 0.49 * cd2$Unrolled] = "Region 4"
  cd2$Region = as.factor(cd2$Region)
  
  summaries = table(cd2$Region, by = cd2$Condition)
  report$write.table("sumtable.csv",
                     summaries,
                     id = "nReads",
                     title = "nReads in Regions I-IV")
  
  # To avoid this warning: Error: Dimensions exceed 50 inches (height and width are specified in 'in' not pixels). If you're sure you a plot that big, use `limitsize = FALSE`.
  img_height = min(49.5, 3.6 * length(levels(cd2$Condition)))
  lim = max(cd2$Unrolled)
  limhq = max(cd2$hqlen)
  
  cd2$SurvObj <- with(cd2, Surv(UnrolledT))
  cd2.by.con <- survfit(SurvObj ~ Condition, data = cd2)
  p1 <-
    autoplot(cd2.by.con) + labs(x = "Unrolled template Span", title = "Unrolled template Span Survival")
  p2 <-
    autoplot(cd2.by.con) + scale_x_log10() + labs(x = "Unrolled template Span", title = "Unrolled template Span Survival (Log-scale)")
  #tp <- arrangeGrob(p1, p2, nrow = 2)
  
  report$ggsave(
    "unrolled_template.png",
    p1,
    id = "unrolled_template",
    width = plotwidth,
    height = plotheight,
    title = "Unrolled template Span Survival",
    caption = "Unrolled template Span Survival"
  )
  report$ggsave(
    "unrolled_template_log.png",
    p2,
    id = "unrolled_template_log",
    width = plotwidth,
    height = plotheight,
    title = "Unrolled template Span Survival (Log-scale)",
    caption = "Unrolled template Span Survival (Log-scale)"
  )
  
  tp = ggplot(cd2, aes(x = Condition, y = UnrolledT, fill = Condition)) + geom_boxplot() + stat_summary(
    fun.y = median,
    colour = "black",
    geom = "text",
    show.legend = FALSE,
    vjust = -0.8,
    aes(label = round(..y.., digits = 4))
  ) +
    labs(y = "Unrolled template Span", title = "Unrolled template Span") + plTheme + themeTilt + clFillScale
  
  report$ggsave(
    "unrolled_template_boxplot.png",
    tp,
    id = "unrolled_template_boxplot",
    width = plotwidth,
    height = plotheight,
    title = "Unrolled template Span (Boxplot)",
    caption = "Unrolled template Span (Boxplot)"
  )
  
  tp = ggplot(cd2, aes(x = UnrolledT, colour = Condition)) + geom_density(alpha = .5) + 
    plTheme + themeTilt  + clScale + 
    labs(x = "Unrolled template Span - HighLow", title = "Unrolled template Span - HighLow (Density Plot)") + scale_x_log10()
  
  report$ggsave(
    "unrolled_template_densityplot.png",
    tp,
    id = "unrolled_template_densityplot",
    width = plotwidth,
    height = plotheight,
    title = "Unrolled template Span - HighLow (Density Plot)",
    caption = "Unrolled template Span - HighLow (Density Plot)"
  )
  
  # Summation
  tp = ggplot(cd2_summation, aes(x = UnrolledT, colour = Condition)) + geom_density(alpha = .5) + 
    plTheme + themeTilt  + clScale + 
    labs(x = "Unrolled template Span - Summation", title = "Unrolled template Span - Summation (Density Plot)") + scale_x_log10()
  
  report$ggsave(
    "unrolled_template_densityplot_summation.png",
    tp,
    id = "unrolled_template_densityplot_summation",
    width = plotwidth,
    height = plotheight,
    title = "Unrolled template Span - Summation (Density Plot)",
    caption = "Unrolled template Span - Summation (Density Plot)"
  )
  
  # max insert length vs hqlen
  tp = ggplot(cd2, aes(x = hqlen, y = MaxInsert)) + geom_point(aes(colour = Condition), size = 0.2) + 
    xlim(0, limhq) + ylim(0, limhq) + facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt + labs(y = "Max Insert Length)", title = "Max Insert Length vs hqlen", x = "hqlen")
  
  report$ggsave(
    "max_hqlen.png",
    tp,
    id = "max_hqlen",
    width = 6,
    height = img_height,
    title = "Max Insert Length vs hqlen",
    caption = "Max Insert Length vs hqlen"
  )
  
  # CDF of (hqlen - MaxInsert)/hqlen
  tp = ggplot(cd2, aes(x = (hqlen - MaxInsert) / hqlen)) + stat_ecdf(aes(colour = Condition)) + scale_x_log10() + 
    plTheme + clScale + 
    labs(x = "(hqlen - MaxInsert)/hqlen", y = "C.D.F", title = "CDF of (hqlen - MaxInsert)/hqlen")
  report$ggsave(
    "cdf_hqlenmax.png",
    tp,
    id = "cdf_hqlenmax",
    width = 12,
    height = 6,
    title = "CDF of (hqlen - MaxInsert)/hqlen",
    caption = "CDF of (hqlen - MaxInsert)/hqlen"
  )
  
  # max insert length vs unrolled aligned read length
  tp = ggplot(cd2, aes(x = Unrolled, y = MaxInsert)) + geom_point(aes(colour = Region), size = 0.2) + 
    xlim(0, lim) + ylim(0, lim) + facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt + 
    labs(y = "Max Insert Length)", title = "Max Insert Length vs Unrolled Aligned Read Length", x = "Unrolled Aligned Read Length")
  
  report$ggsave(
    "max_unrolled.png",
    tp,
    id = "max_unrolled",
    width = 6,
    height = img_height,
    title = "Max Insert Length vs Unrolled Aligned Read Length",
    caption = "Max Insert Length vs Unrolled Aligned Read Length"
  )
  
  tp = ggplot(cd2, aes(x = UnrolledT, y = MaxInsertT)) + geom_point(aes(colour = Condition), size = 0.2) + 
    xlim(0, lim) + ylim(0, lim) + facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt + 
    labs(y = "Max Subread Template Span)", title = "Max Subread Template Span vs Unrolled Template Span", x = "Unrolled Template Span")
  
  report$ggsave(
    "maxt_unrolledt.png",
    tp,
    id = "maxt_unrolledt",
    width = 6,
    height = img_height,
    title = "Max Subread Template Span vs Unrolled Template Span",
    caption = "Max Subread Template Span vs Unrolled Template Span"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, fill = Region)) + geom_histogram(binwidth = 100) + 
    facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + 
    labs(y = "Frequency", title = "Histogram of Max Insert Length", x = "Max Insert Length")
  
  report$ggsave(
    "hist_max.png",
    tp,
    id = "hist_max",
    width = 6,
    height = img_height,
    title = "Histogram of Max Insert Length",
    caption = "Histogram of Max Insert Length"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, colour = Region)) + geom_density(alpha = .5) + 
    facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt  + clScale + 
    labs(y = "Density", title = "Denstiy Plot of Max Insert Length (by Region)", x = "Max Insert Length") 
  
  report$ggsave(
    "density_max_region.png",
    tp,
    id = "density_max_region",
    width = 6,
    height = img_height,
    title = "Density Plot of Max Insert Length (by Region)",
    caption = "Density Plot of Max Insert Length (by Region)"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, colour = Condition)) + geom_density(alpha = .5) + 
    plTheme + themeTilt  + clScale + 
    labs(y = "Density", title = "Denstiy Plot of Max Insert Length", x = "Max Insert Length") 
  
  report$ggsave(
    "density_max.png",
    tp,
    id = "density_max",
    title = "Density Plot of Max Insert Length",
    caption = "Density Plot of Max Insert Length"
  )
  
  tp = ggplot(cd2, aes(x = Unrolled, fill = Region)) + geom_histogram(binwidth = 500) + 
    facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + 
    labs(y = "Frequency", title = "Histogram of Unrolled Aligned Read Length", x = "Unrolled Aligned Read Length") 
  
  report$ggsave(
    "hist_unroll.png",
    tp,
    id = "hist_unroll",
    width = 6,
    height = img_height,
    title = "Histogram of Unrolled Aligned Read Length",
    caption = "Histogram of Unrolled Aligned Read Length"
  )
  
  tp = ggplot(cd2, aes(x = Unrolled, colour = Region)) + geom_density(alpha = .5) + 
    facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt  + clScale + 
    labs(y = "Density", title = "Denstiy Plot of Unrolled Aligned Read Length - HighLow", x = "Unrolled Aligned Read Length - HighLow")
  
  report$ggsave(
    "density_unroll.png",
    tp,
    id = "density_unroll",
    width = 6,
    height = img_height,
    title = "Density Plot of Unrolled Aligned Read Length - HighLow",
    caption = "Density Plot of Unrolled Aligned Read Length - HighLow"
  )
  # Summation
  tp = ggplot(cd2_summation, aes(x = Unrolled, colour = Region)) + geom_density(alpha = .5) + 
    facet_wrap(~Condition, nrow = length(levels(cd2$Condition))) + 
    plTheme + themeTilt  + clScale + 
    labs(y = "Density", title = "Denstiy Plot of Unrolled Aligned Read Length - Summation", x = "Unrolled Aligned Read Length - Summation")
  report$ggsave(
    "density_unroll_summation.png",
    tp,
    id = "density_unroll_summation",
    width = 6,
    height = img_height,
    title = "Density Plot of Unrolled Aligned Read Length - Summation",
    caption = "Density Plot of Unrolled Aligned Read Length - Summation"
  )
  
  cd2$Ratio  = (cd2$Unrolled - cd2$MaxInsert) / cd2$Unrolled
  tp = ggplot(cd2, aes(x = Ratio)) + stat_ecdf(aes(colour = Condition)) + 
    plTheme + 
    labs(y = "C.D.F", title = "CDF plot of (Unrolled - Max)/Unrolled", x = "(Unrolled Aligned Read Length − Max Insert Length) / Unrolled Aligned Read Length")
  
  report$ggsave(
    "cdf_ratio.png",
    tp,
    id = "cdf_ratio",
    width = 12,
    height = 6,
    title = "CDF plot of (Unrolled - Max)/Unrolled",
    caption = "CDF plot of (Unrolled - Max)/Unrolled"
  )
}

makeCDFofTemplatePlots <- function(report, cd) {
  loginfo("Making CDF of Template Span Plots")
  
  # Create and add a plot group
  tp = ggplot(cd, aes(x = tlen)) + stat_ecdf(aes(colour = Condition)) + scale_y_log10() + 
    plTheme + clScale + labs(x = "Template Span", y = "C.D.F", title = "CDF of Template Span")
  
  report$ggsave(
    "cdf_tlen.png",
    tp,
    id = "cdf_tlen",
    width = 12,
    height = 6,
    title = "CDF of Template Span",
    caption = "CDF of Template Span"
  )
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  # Make fake data - for debugging
  #condFile = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/005/005578/tasks/pbcommandR.tasks.pbiplot_reseq_condition-0/resolved-tool-contract.json"
  #condjson = jsonlite::fromJSON(condFile)
  #input = condjson$resolved_tool_contract$input_files
  #decoded <- loadReseqConditionsFromPath(input)
  #conds = decoded@conditions
  #tmp = lapply(conds, function(z) data.frame(condition = z@condId,subreadset = z@subreadset, alignmentset = z@alignmentset, referenceset = z@referenceset))
  #conditions = do.call(rbind, tmp)
  
  conditions = report$condition.table
  # Load the pbi index for each data frame
  dfs = lapply(as.character(unique(conditions$MappedSubreads)), function(s) {
    loginfo(paste("Loading alignment set:", s))
    loadPBI2(s)
  })

  ## Let's set the graphic defaults
  n = length(levels(conditions$Condition))
  clFillScale <<- getPBFillScale(n)
  clScale <<- getPBColorScale(n)
  
  # Now combine into one large data frame
  cd = combineConditions(dfs, as.character(conditions$Condition))
  cd$tlen = as.numeric(cd$tend - cd$tstart)
  cd$alen = as.numeric(cd$aend - cd$astart)

  # Make Plots
  makeCDFofaStartPlots(report, cd)
  makeMaxVsUnrolledPlots(report, cd)
  makeCDFofTemplatePlots(report, cd)
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
  report <- bh2Reporter(
    "condition-table.csv",
    "reports/LibDiagnosticPlots/report.json",
    "Library Diagnostic Plots")
  makeReport(report)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()