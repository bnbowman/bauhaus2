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
plTheme <-
  theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
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
    width = plotwidth,
    height = plotheight,
    id = "cdf_astart",
    title = "CDF of aStart",
    caption = "CDF of aStart",
    tags = c("libdiagnostic", "library", "diagnostic", "cdf", "astart"),
    uid = "0020001"
  )
  
  tp = ggplot(cd, aes(x = astart)) + stat_ecdf(aes(colour = Condition)) + scale_x_log10() + geom_vline(xintercept = 50, colour = "red") +
    plTheme + clScale +
    labs(x = "astart (Log-scale)", y = "C.D.F", title = "CDF of aStart (Log-scale)")
  
  report$ggsave(
    "cdf_astart_log.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "cdf_astart_log",
    title = "CDF of aStart (Log-scale)",
    caption = "CDF of aStart (Log-scale)",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "cdf",
      "astart",
      "log"
    ),
    uid = "0020002"
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
    caption = "Yield (Subreads) by Reference",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "histogram",
      "yield",
      "reference",
      "subreads"
    ),
    uid = "0020003"
  )
  
  # Yield (Subreads) Percentage by Reference
  
  cdref = cd %>% group_by(Condition, ref) %>% summarise(n = n())
  cdref = cdref %>% group_by(Condition) %>% mutate(nper = n / sum(n)) %>% ungroup()
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
    caption = "Yield (Subreads) Percentage by Reference",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "yield",
      "reference",
      "histogram",
      "subreads",
      "percentage"
    ),
    uid = "0020004"
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
    caption = "Yield (Unrolled Alignments) by Reference",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "reference",
      "alignments",
      "unrolled",
      "yield",
      "histogram"
    ),
    uid = "0020005"
  )
  
  # Yield (Unrolled Alignments) Percentage by Reference
  
  cdunrolledref = cdunrolled %>% group_by(Condition, ref) %>% summarise(n = n())
  cdunrolledref = cdunrolledref %>% group_by(Condition) %>% mutate(nper = n /
                                                                     sum(n)) %>% ungroup()
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
    caption = "Yield (Unrolled Alignments) Percentage by Reference",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "reference",
      "alignments",
      "unrolled",
      "yield",
      "percentage",
      "histogram"
    ),
    uid = "0020006"
  )
  
  # Template Span by Reference
  tp <-
    ggplot(data = cd, aes(
      x = factor(ref),
      y = tlen,
      fill = factor(Condition)
    )) +
    geom_boxplot(position = position_dodge(width = 0.9))
  a <-
    aggregate(tlen ~ ref + Condition , cd, function(i)
      round(median(i)))
  tp <- tp +  geom_text(
    data = a,
    aes(label = tlen),
    position = position_dodge(width = 0.9),
    vjust = -0.8
  )
  
  report$ggsave(
    "template_span_ref_box.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "template_span_ref_box",
    title = "Template Span by Reference",
    caption = "Template Span by Reference",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "reference",
      "template",
      "boxplot"
    ),
    uid = "0020007"
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
  
  # When cd2.by.con is empty or only has one row, skip the following two plots
  if (nrow(cd2.by.con) > 1) {
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
      caption = "Unrolled template Span Survival",
      tags = c(
        "libdiagnostic",
        "library",
        "diagnostic",
        "template",
        "survival",
        "unrolled"
      ),
      uid = "0020008"
    )
    report$ggsave(
      "unrolled_template_log.png",
      p2,
      id = "unrolled_template_log",
      width = plotwidth,
      height = plotheight,
      title = "Unrolled template Span Survival (Log-scale)",
      caption = "Unrolled template Span Survival (Log-scale)",
      tags = c(
        "libdiagnostic",
        "library",
        "diagnostic",
        "template",
        "survival",
        "unrolled",
        "log"
      ),
      uid = "0020009"
    )
  }
  
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
    caption = "Unrolled template Span (Boxplot)",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "template",
      "boxplot",
      "unrolled"
    ),
    uid = "0020010"
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
    caption = "Unrolled template Span - HighLow (Density Plot)",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "template",
      "density",
      "unrolled",
      "hignlow"
    ),
    uid = "0020011"
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
    caption = "Unrolled template Span - Summation (Density Plot)",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "template",
      "density",
      "unrolled",
      "summation"
    ),
    uid = "0020012"
  )
  
  # max insert length vs hqlen
  tp = ggplot(cd2, aes(x = hqlen, y = MaxInsert)) + geom_point(aes(colour = Condition), size = 0.2) +
    xlim(0, limhq) + ylim(0, limhq) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt + labs(y = "Max Insert Length)", title = "Max Insert Length vs hqlen", x = "hqlen")
  
  report$ggsave(
    "max_hqlen.png",
    tp,
    id = "max_hqlen",
    width = plotwidth,
    height = img_height,
    title = "Max Insert Length vs hqlen",
    caption = "Max Insert Length vs hqlen",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "hqlen",
      "maxinsert"
    ),
    uid = "0020013"
  )
  
  # CDF of (hqlen - MaxInsert)/hqlen
  tp = ggplot(cd2, aes(x = (hqlen - MaxInsert) / hqlen)) + stat_ecdf(aes(colour = Condition)) + scale_x_log10() +
    plTheme + clScale +
    labs(x = "(hqlen - MaxInsert)/hqlen", y = "C.D.F", title = "CDF of (hqlen - MaxInsert)/hqlen")
  report$ggsave(
    "cdf_hqlenmax.png",
    tp,
    id = "cdf_hqlenmax",
    width = plotwidth,
    height = plotheight,
    title = "CDF of (hqlen - MaxInsert)/hqlen",
    caption = "CDF of (hqlen - MaxInsert)/hqlen",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "hqlen",
      "maxinsert",
      "cdf"
    ),
    uid = "0020014"
  )
  
  # max insert length vs unrolled aligned read length
  tp = ggplot(cd2, aes(x = Unrolled, y = MaxInsert)) + geom_point(aes(colour = Region), size = 0.2) +
    xlim(0, lim) + ylim(0, lim) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt +
    labs(y = "Max Insert Length)", title = "Max Insert Length vs Unrolled Aligned Read Length", x = "Unrolled Aligned Read Length")
  
  report$ggsave(
    "max_unrolled.png",
    tp,
    id = "max_unrolled",
    width = plotwidth,
    height = img_height,
    title = "Max Insert Length vs Unrolled Aligned Read Length",
    caption = "Max Insert Length vs Unrolled Aligned Read Length",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "maxinsert",
      "read",
      "unrolled"
    ),
    uid = "0020015"
  )
  
  tp = ggplot(cd2, aes(x = UnrolledT, y = MaxInsertT)) + geom_point(aes(colour = Condition), size = 0.2) +
    xlim(0, lim) + ylim(0, lim) + facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt +
    labs(y = "Max Subread Template Span)", title = "Max Subread Template Span vs Unrolled Template Span", x = "Unrolled Template Span")
  
  report$ggsave(
    "maxt_unrolledt.png",
    tp,
    id = "maxt_unrolledt",
    width = plotwidth,
    height = img_height,
    title = "Max Subread Template Span vs Unrolled Template Span",
    caption = "Max Subread Template Span vs Unrolled Template Span",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "template",
      "subread",
      "unrolled"
    ),
    uid = "0020016"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, fill = Region)) + geom_histogram(binwidth = 100) +
    facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme +
    labs(y = "Frequency", title = "Histogram of Max Insert Length", x = "Max Insert Length")
  
  report$ggsave(
    "hist_max.png",
    tp,
    id = "hist_max",
    width = plotwidth,
    height = img_height,
    title = "Histogram of Max Insert Length",
    caption = "Histogram of Max Insert Length",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "maxinsert",
      "histogram"
    ),
    uid = "0020017"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, colour = Region)) + geom_density(alpha = .5) +
    facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt  + clScale +
    labs(y = "Density", title = "Denstiy Plot of Max Insert Length (by Region)", x = "Max Insert Length")
  
  report$ggsave(
    "density_max_region.png",
    tp,
    id = "density_max_region",
    width = plotwidth,
    height = img_height,
    title = "Density Plot of Max Insert Length (by Region)",
    caption = "Density Plot of Max Insert Length (by Region)",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "maxinsert",
      "density",
      "region"
    ),
    uid = "0020018"
  )
  
  tp = ggplot(cd2, aes(x = MaxInsert, colour = Condition)) + geom_density(alpha = .5) +
    plTheme + themeTilt  + clScale +
    labs(y = "Density", title = "Denstiy Plot of Max Insert Length", x = "Max Insert Length")
  
  report$ggsave(
    "density_max.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "density_max",
    title = "Density Plot of Max Insert Length",
    caption = "Density Plot of Max Insert Length",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "density",
      "maxinsert"
    ),
    uid = "0020019"
  )
  
  tp = ggplot(cd2, aes(x = Unrolled, fill = Region)) + geom_histogram(binwidth = 500) +
    facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme +
    labs(y = "Frequency", title = "Histogram of Unrolled Aligned Read Length", x = "Unrolled Aligned Read Length")
  
  report$ggsave(
    "hist_unroll.png",
    tp,
    id = "hist_unroll",
    width = plotwidth,
    height = img_height,
    title = "Histogram of Unrolled Aligned Read Length",
    caption = "Histogram of Unrolled Aligned Read Length",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "read",
      "histogram",
      "unrolled"
    ),
    uid = "0020020"
  )
  
  tp = ggplot(cd2, aes(x = Unrolled, colour = Region)) + geom_density(alpha = .5) +
    facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt  + clScale +
    labs(y = "Density", title = "Denstiy Plot of Unrolled Aligned Read Length - HighLow", x = "Unrolled Aligned Read Length - HighLow")
  
  report$ggsave(
    "density_unroll.png",
    tp,
    id = "density_unroll",
    width = plotwidth,
    height = img_height,
    title = "Density Plot of Unrolled Aligned Read Length - HighLow",
    caption = "Density Plot of Unrolled Aligned Read Length - HighLow",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "read",
      "density",
      "unrolled",
      "highlow"
    ),
    uid = "0020021"
  )
  # Summation
  tp = ggplot(cd2_summation, aes(x = Unrolled, colour = Region)) + geom_density(alpha = .5) +
    facet_wrap( ~ Condition, nrow = length(levels(cd2$Condition))) +
    plTheme + themeTilt  + clScale +
    labs(y = "Density", title = "Denstiy Plot of Unrolled Aligned Read Length - Summation", x = "Unrolled Aligned Read Length - Summation")
  report$ggsave(
    "density_unroll_summation.png",
    tp,
    id = "density_unroll_summation",
    width = plotwidth,
    height = img_height,
    title = "Density Plot of Unrolled Aligned Read Length - Summation",
    caption = "Density Plot of Unrolled Aligned Read Length - Summation",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "read",
      "density",
      "summation"
    ),
    uid = "0020022"
  )
  
  cd2$Ratio  = (cd2$Unrolled - cd2$MaxInsert) / cd2$Unrolled
  tp = ggplot(cd2, aes(x = Ratio)) + stat_ecdf(aes(colour = Condition)) +
    plTheme +
    labs(y = "C.D.F", title = "CDF plot of (Unrolled - Max)/Unrolled", x = "(Unrolled Aligned Read Length − Max Insert Length) / Unrolled Aligned Read Length")
  
  report$ggsave(
    "cdf_ratio.png",
    tp,
    id = "cdf_ratio",
    width = plotwidth,
    height = plotheight,
    title = "CDF plot of (Unrolled - Max)/Unrolled",
    caption = "CDF plot of (Unrolled - Max)/Unrolled",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "maxinsert",
      "cdf",
      "unrolled"
    ),
    uid = "0020023"
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
    width = plotwidth,
    height = plotheight,
    title = "CDF of Template Span",
    caption = "CDF of Template Span",
    tags = c("libdiagnostic", "library", "diagnostic", "template", "cdf"),
    uid = "0020024"
  )
}

#'--------------------------------------------------------------
#' Functions for segmented linear regression upon input vector x and corresponding vector y
#'--------------------------------------------------------------
#' Fit a single line of regression for a given input vector
#
#' @param x vector of data
#' @param y vector of responses - same length as x
#' @param a scalar integer - starting index for fitting line
#' @param b scalar integer - stopping index for fitting line
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return vector of length four: intercept, slope, residual, average residual
#
#' @references \url{http://en.wikipedia.org/wiki/Simple_linear_regression}
#' @export

fit_A_to_B = function(x, y, a, b, min_sep)
{
  b = round(b)
  a = round(a)
  N = b - a + 1
  if (N < min_sep)
    return(c(0, 0, 99e99, 99e99, NA, NA))
  start = x[a]
  stop = x[b]
  
  x = x[a:b]
  y = y[a:b]
  mX = sum(x) / N
  mY = sum(y) / N
  
  #' Get slope of segment:
  x = x - mX
  y = y - mY
  beta = sum(x * y) / sum(x * x)
  
  #' Get intercept:
  alpha = mY - beta * mX
  
  #' Compute and return total and average residual
  #' Not subtracting alpha from y since x and y have been centered
  tmp = y - beta * x
  res = sum(tmp * tmp)
  c(alpha, beta, res, res / N, start, stop)
}

#' Slightly faster version of \code{\link{fit_A_to_B}} for the case where y is 1:N
#
#' @param x vector of data
#' @param y indices of data
#' @param a scalar integer - starting index for fitting line
#' @param b scalar integer - stopping index for fitting line
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return vector of length four: intercept, slope, residual, average residual
#
#' @references \url{http://en.wikipedia.org/wiki/Simple_linear_regression}
#' @export

fit_A_to_B_fast = function(x, y, a, b, min_sep)
{
  b = round(b)
  a = round(a)
  N = b - a + 1
  if (N < min_sep)
    return(c(0, 0, 99e99, 99e99))
  x = x[a:b]
  
  #' The sole difference from fit_A_to_B:
  y = a:b
  mX = sum(x) / N
  mY = sum(y) / N
  
  #' Get slope of segment:
  x = x - mX
  y = y - mY
  beta = sum(x * y) / sum(x * x)
  
  #' Get intercept:
  alpha = mY - beta * mX
  
  #' Compute and return total and average residual
  #' Not subtracting alpha from y since x and y have been centered
  tmp = y - beta * x
  res = sum(tmp * tmp)
  c(alpha, beta, res, res / N)
}

#' Get residuals corresponding to a particular breakpoint, b
#'
#' @param simple_lin_reg function, either \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#' @param b scalar double - breakpoint, must be between 1 and length of input vector
#' @param x vector of input data
#' @param y vector of response data, must be same length as x
#' @param N scalar integer length of x and of y
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return sum of residuals from fitting two lines, with a breakpoint at b
#' @seealso \code{\link{find_2_seg_breakpoint}} which minimizes the value returned by this function
#' @export

res_2_seg_breakpoint = function(b, x, y, N, simple_lin_reg, min_sep)
{
  simple_lin_reg(x, y, 1, b, min_sep)[4] +
    simple_lin_reg(x, y, b + 1, N, min_sep)[4]
}

#' Find breakpoint that minimizes the total residuals from fitting two linear segments
#'
#' @param simple_lin_reg function, either \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#' @param x vector of input data
#' @param y vector of response data, must be same length as x
#' @param N scalar integer length of x and of y
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return list with elements min (minimizing breakpont) and obj (minimum total residual)
#' @export

find_2_seg_breakpoint = function(x, y, N, simple_lin_reg, min_sep)
{
  res = try(optimize(
    f = res_2_seg_breakpoint,
    interval = c(1, N),
    x = x,
    y = y,
    N = N,
    simple_lin_reg = simple_lin_reg,
    min_sep = min_sep,
    maximum = FALSE
  ),
  silent = FALSE)
  if (class(res) == "try-error")
  {
    b = floor(N / 2)
    return(min = b, obj = res_2_seg_breakpoint(b, x, y, N, simple_lin_reg))
  }
  res
}

#' Get residuals corresponding to a particular breakpoint, b
#'
#' @param simple_lin_reg function, either \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#' @param b vector of length two - specifying two breakpoints in data
#' @param x vector of input data
#' @param y vector of response data, must be same length as x
#' @param N scalar integer length of x and of y
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return sum of residuals from fitting three lines, with breakpoints at b[1] and b[2]
#' @seealso \code{\link{find_3_seg_breakpoint}} which optimizes this function
#'
#' @export

res_3_seg_breakpoint = function(b, x, y, N, simple_lin_reg, min_sep)
{
  simple_lin_reg(x, y, 1, b[1], min_sep)[4] +
    simple_lin_reg(x, y, b[1] + 1, b[2], min_sep)[4] +
    simple_lin_reg(x, y, b[2] + 1, N, min_sep)[4]
}

#' Select three initial points for two-dimensional optimization
#'
#' A simple variation of multistart will help overcome local minima
#'
#' @param opt = optimal breakpoint if we were only looking for a single breakpoint
#' @param N = length of input data vectors
#' @param min_sep = minimum required separation between two breakpoints
#'
#' @return list of three vectors of length two
#' @seealso \code{\link{find_2_seg_breakpoint}} which is used to compute input opt
#' @export

get_initial_points = function(opt, N, min_sep)
{
  #' Make sure initial points meet minimum separation criteria:
  opt = max(opt, 2 * min_sep + 1)
  opt = min(opt, N - 2 * min_sep)
  
  #' Evenly spaced around guess opt:
  vec = c(1, opt, N)
  pt1 = (vec[-1] - vec[-3]) / 2 + vec[-3]
  
  #' The guess opt, and a point to the right:
  pt2 = c(opt, pt1[2])
  
  #' The guess opt, and a point ot the left:
  pt3 = c(pt1[1], opt)
  lapply(list(pt1, pt2, pt3), round)
}

#' Find breakpoint that minimizes the total residuals from fitting three linear segments
#'
#' @param simple_lin_reg function, either \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#' @param x vector of input data
#' @param y vector of response data, must be same length as x
#' @param N scalar integer length of x and of y
#'
#' @return list with tau, yBreakPoints, residuals, breakPoints
#' @return yBreakPoints vector of length two with optimal breakpoints
#' @return breakPoints vector of length two -- corresponding points in x
#' @return tau matrix consisting of output of \code{\link{fit_A_to_B}} for the three segments
#' @return residuals vector with total residuals from fitting one, two, and three segments
#'
#' @export

fit_3_segments = function(simple_lin_reg, x, y, N, min_sep = 10)
{
  loginfo("Negative x?")
  loginfo(range(x))
  
  #' Make sure minimum separation between two breakpoints is not too large relative to size of data:
  min_sep = min(min_sep, floor((N - 3) / 4))
  
  #' Calculate average residual for a single fitted segment:
  res = simple_lin_reg(x, y, 1, N, min_sep)[4]
  
  #' Solve problem for two segments:
  tmp = find_2_seg_breakpoint(x, y, N, simple_lin_reg, min_sep)
  res = c(res, tmp$obj)
  
  #' Linear constraints on optimization:
  #' Breakpoint in vector b must be: b[1] < b[2] - min_sep + 1; 1 < b[1]; and b[2] < N
  
  ui = as.matrix(rbind(c(-1, 1), c(1, 0), c(0, -1)))
  ci = matrix(c(min_sep - 1, 1, -N) , ncol = 1)
  
  #' Get three initial points
  init = get_initial_points(tmp$min, N, min_sep)
  
  #' Solve problem corresponding to three initial points
  L = lapply(init, function(p)
  {
    res = try(constrOptim(
      p,
      f = res_3_seg_breakpoint,
      grad = NULL,
      ui = ui,
      ci = ci,
      x = x,
      y = y,
      N = N,
      simple_lin_reg = simple_lin_reg,
      min_sep = min_sep
    ),
    silent = TRUE)
    
    if (class(res) == "try-error")
    {
      return(list(value = 99e99, opt = init[[2]]))
    }
    res
  })
  
  #' Identify the best of three solutions:
  opt = L[[which.min(vapply(L, function(x)
    x$value, 0))]]
  
  if (!is.null(opt$par)) {
    bpt = round(opt$par)
  } else {
    bpt = c(0, 0)
  }
  
  res = c(res, opt$value)
  
  tau = rbind(
    simple_lin_reg(x, y, 1, bpt[1], min_sep),
    simple_lin_reg(x, y, bpt[1] + 1, bpt[2], min_sep),
    simple_lin_reg(x, y, bpt[2] + 1, N, min_sep)
  )
  
  list(
    tau = tau,
    yBreakPoints = bpt,
    residuals = res,
    breakPoints = x[bpt]
  )
}

#' Find breakpoint that minimizes the total residuals from fitting two linear segments
#'
#' @param simple_lin_reg function, either \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#' @param x vector of input data
#' @param y vector of response data, must be same length as x
#' @param N scalar integer length of x and of y
#'
#' @return list with tau, yBreakPoints, residuals, breakPoints
#' @return yBreakPoints scalar double optimal breakpoint
#' @return breakPoints scalar double -- corresponding point in x
#' @return tau matrix consisting of output of \code{\link{fit_A_to_B}} for the two segments
#' @return residuals vector with total residuals from fitting one, two segments
#'
#' @export

fit_2_segments = function(simple_lin_reg, x, y, N, min_sep = 10)
{
  #' Calculate average residual for a single fitted segment:
  res = simple_lin_reg(x, y, 1, N, min_sep)[4]
  
  tmp = find_2_seg_breakpoint(x, y, N, simple_lin_reg, min_sep)
  opt = round(tmp$min)
  tau = rbind(simple_lin_reg(x, y, 1, opt, min_sep),
              simple_lin_reg(x, y, opt + 1, N, min_sep))
  
  list(
    tau = tau,
    residuals = c(res, tmp$obj),
    yBreakPoints = opt,
    breakPoints = x[opt]
  )
}

#'---------------------------------------------------------------
#' Censoring
#'---------------------------------------------------------------

#' General function to compute CDF with optional censoring.
#'
#' @param r vector of input values
#' @param ce boolean vector the length of r -- those entries that are TRUE are censored
#' @param what either "F" (to return CDF) or "1-F" (to return CDF complement)
#' @param eps = 1 -- at what intervals should we compute CDF values?
#'
#' @return List with x and y values for CDF function.
#'
#' @examples
#' censoredCDF( , what = "1-F", matchOriginalPoints = TRUE )
#'
#' @export

censoredCDF = function(r,
                       ce = rep(FALSE, length(r)),
                       what = "F",
                       eps = 1,
                       matchOriginalPoints = TRUE)
{
  #' Compute hazard function, h :
  
  x = seq(min(r, na.rm = TRUE), max(r, na.rm = TRUE) + eps, eps)
  censoredCounts = hist(r[!ce],
                        breaks = x,
                        right = FALSE,
                        plot = FALSE)$counts
  uncensoredCounts = hist(r,
                          breaks = x,
                          right = FALSE,
                          plot = FALSE)$counts
  h = censoredCounts / rev(cumsum(rev(uncensoredCounts)))
  
  #' Prepare x and y values for plotting
  
  x = x[-length(x)]
  if (what == "F") {
    y = 1 - cumprod(1 - h)
  } else {
    y = cumprod(1 - h)
  }
  
  
  #' Select out points in the original vector  of inputs, r:
  
  if (matchOriginalPoints)
  {
    m = match(sort(unique(r), decreasing = FALSE), x)
    m = m[!is.na(m)]
    x = x[m]
    y = y[m]
  }
  
  list(x = c(min(x, na.rm = TRUE), x), y = c(ifelse(what == 'F', 0, 1), y))
}

#'---------------------------------------------------------------
#' Fit one, two, three segments to CDF
#'---------------------------------------------------------------

#' Fit tau values to censored CDF
#'
#' Returns matrix with 1, 2, or 3 rows corresponding to the number of segments desired.
#'
#' @param nTaus integer 1, 2, or 3 specifying number of segments to fit
#' @param templateSpanLims either NULL or a vector of length two specifying a region of the x-axis
#' @param list with elements x and y, for example output of \code{link{censoredCDF}}
#' @param simple_lin_reg function, \code{\link{fit_A_to_B}} or \code{\link{fit_A_to_B_fast}}
#'
#' @return matrix with four columns: intercept, slope, total residual, average residual
#' @seealso \code{\link{fit_A_to_B}}, \code{\link{fit_2_segments}}, and \code{\link{fit_3_segments}}
#' @export

fitTausToRegions = function(nTaus,
                            p,
                            templateSpanLims = NULL,
                            simple_lin_reg = fit_A_to_B)
{
  x = p$x
  y = log(ifelse(p$y == 0, min(p$y[p$y > 0], na.rm = TRUE), p$y))
  
  if (!is.null(templateSpanLims))
  {
    w = which(x <= templateSpanLims[2] & x >= templateSpanLims[1])
    x = x[w]
    y = y[w]
  }
  N = length(x)
  
  if (nTaus == 1)
  {
    tau = simple_lin_reg(x, y, 1, N)
  }
  else if (nTaus == 2)
  {
    tau = fit_2_segments(simple_lin_reg, x, y, N)$tau
  }
  else
  {
    tau = fit_3_segments(simple_lin_reg, x, y, N)$tau
  }
  tau
}

#' Estimate a specified number of tau values, with confidence intervals for each estimate.
#'
#' @param a = vector of values for which we'll calculate the censored CDF
#' @param ce.a = boolean vector -- censor corresponding element of a?
#' @param nRegions = 1, 2, or 3 regions to fit?
#' @param nBoot = number of bootstraps for obtaining confidence interval
#'
#' @return confidence interval for tau for each of the three regions.
#' @seealso \code{\link{viewTau}} which calls this function
#' @export

getTauConfidenceInterval = function(a,
                                    ce.a = rep(FALSE, length(a)),
                                    matchOriginalPoints = FALSE,
                                    nRegions = 2,
                                    nBoot = 100)
{
  n = length(a)
  L = sapply(1:nBoot, function(i)
  {
    tmp = sample.int(n, replace = TRUE)
    
    p = censoredCDF(a[tmp],
                    ce.a[tmp],
                    what = "1-F",
                    matchOriginalPoints = matchOriginalPoints)
    tmp = try(fitTausToRegions(nRegions, p, NULL), silent = FALSE)
    if (class(tmp) == "try-error") {
      return(rep(NA, 3))
    }
    - 1 / tmp[, 2]
  })
  apply(L, 1, function(x)
    quantile(na.omit(x), c(0.025, 0.5, 0.975)))
}

#'---------------------------------------------------------------
#' Miscellaneous convenience functions
#'---------------------------------------------------------------

#' Convenience function to create a file if none exists
#'
#' @param dir directory path
#' @param subdir subdirectory name
#'
#' @return file.path( dir, subdir )
#' @export

createFile = function(dir, subdir)
{
  tmp = file.path(dir, subdir)
  if (!file.exists(tmp))
  {
    dir.create(tmp, showWarnings = TRUE)
  }
  tmp
}

#'--------------------------------------------------------------
#' Add from here: plot first pass survival and write tau estimates with confidence intervals to csv
#'--------------------------------------------------------------

#' Write table for template span values for each conditions with one column for
#'	each region: tau, 2.5th %ile, and 95.5th %ile.
#'
#' @param report = use report$write.table to save table for Zia
#' @param values = Template Span values
#' @param censored = boolean vector same length as values - if TRUE then censor that value
#' @param condition = string identifier for condition
#' @param nRegions = 1, 2, or 3 taus to fit?
#'
#' @return - write table to report object and return table as a data frame
#' @export

writeTauEstimatesToCsv = function(report,
                                  values,
                                  censored,
                                  condition,
                                  nRegions)
{
  p = censoredCDF(values,
                  censored,
                  what = "1-F",
                  matchOriginalPoints = TRUE)
  tau = fitTausToRegions(nRegions, p, NULL)
  loginfo("Investiage tau:")
  loginfo(dim(tau))
  loginfo(format(tau[, 5], digits = 4))
  loginfo(format(tau[, 6], digits = 4))
  tmp = getTauConfidenceInterval(values,
                                 censored,
                                 matchOriginalPoints = TRUE,
                                 nRegions = nRegions)
  taus = data.frame(rbind(
    tau = -1 / tau[, 2],
    tmp[-2,],
    start = tau[, 5],
    stop = tau[, 6]
  ))
  names(taus) = paste("Region", c(1:nRegions), sep = "_")
  
  title = paste(condition, "Tau_Estimates", sep = "_")
  csvfile = paste(title, "csv", sep = ".")
  
  report$write.table(
    csvfile,
    taus,
    id = "tau_estimate_table",
    title = title,
    tags = c("tau", "first", "pass", "first_pass", "survival", "table")
  )
  taus
}

#' Try to censor values in a pileup at the end, since movie length information is not
#'	easily available now -- replace with movie length censoring later.
#'
#' @param values = Template Span values
#'
#' @return boolean vector same length as values - if TRUE then censor that value
#' @export

adHocCensoring = function(values)
{
  censored = rep(FALSE, length(values))
  b = boxplot(values, plot = FALSE)$stat
  if ((b[5] - b[4]) / b[4] < 0.01)
  {
    censored = values >= b[4]
  }
  else
  {
    censored = values >= b[5]
  }
  censored
}

#' Return data frame with 1 - CDF values: x, y, and Condition
#'
#' @param report = use report$write.table to save table with tau estimates
#' @param cd = data frame containing Template Span values for all conditions
#' @param nRegions = 1, 2, or 3 taus to fit?
#'
#' @seealso \code{\link{makeReport}} in LibDiagnosticsPlots.R where cd is defined.
#' @export

getCensoredCDFDataFrame = function(report, cd, nRegions)
{
  condition = cd$Condition[1]
  values = cd$tend - cd$tstart
  censored = adHocCensoring(values)
  tau = writeTauEstimatesToCsv(report, values, censored, condition, nRegions)
  r = censoredCDF(values,
                  censored,
                  what = "1-F",
                  matchOriginalPoints = TRUE)
  data.frame(x = r$x,
             y = r$y,
             Condition = condition)
}

#' Put fitted taus into a data frame that can be plotted over the 1 - CDF plot for illustration.
#'
#' @param p = output of \code{\link{censoredCDF}} list with elements x and y of equal length.
#' @param nRegions = 1, 2, or 3 taus to fit?
#'
#' @return data frame with columns x, y, Region (corresponding to tau fitting region), and Condition
#' @export

getTauFittingLinesForGGplot = function(p, nRegions)
{
  condition = p$Condition[1]
  tau = fitTausToRegions(nRegions, p, NULL)
  bind_rows(lapply(1:nRegions, function(i)
  {
    d = data.frame(
      x = p$x,
      y = exp(tau[i, 1] + tau[i, 2] * p$x),
      Region = paste(condition, i, sep = "_"),
      Condition = condition
    )
    subset(d, 0 <= y & y <= 1)
  }))
}

#' Get just the first pass of each read
#'
#' @param x = output of pbbamr::loadPBI, with columns hole and astart
#'
#' @return only those rows of x corrsponding to the first subread for each ZMW
#' @export

getFirstPassSubreads = function(x)
{
  x = x[order(x$hole, x$astart, decreasing = FALSE), ]
  x[!duplicated(x$hole), ]
}

#' Estimate tau values for three regions of the first pass, along with confidence intervals for each tau.
#'
#' @param report = use report$write.table to save tau estimates and report$ggsave to save an illustrative plot
#' @param cd = data frame containing Template Span values for all conditions
#' @param nRegions = 1, 2, or 3 taus to fit?
#'
#' @return one plot showing tau fittings, and through \code{\link{writeTauEstimatesToCsv}}, one table per condition.
#'
#' @seealso \code{\link{makeReport}} in LibDiagnosticsPlots.R where cd is defined.
#' @export

plotFirstPassTau = function(report, cd, nRegions = 3)
{
  loginfo("Draw first pass survival and estimate tau values.\n")
  s = split(1:nrow(cd), cd$Condition)
  tm = lapply(s, function(r)
    getFirstPassSubreads(cd[r, ]))
  
  loginfo("Use simple bootstrapping to get confidence intervals for tau estimates.\n")
  l0 = lapply(tm, function(x)
    getCensoredCDFDataFrame(report, x, nRegions))
  n0 = bind_rows(lapply(l0, function(p)
    getTauFittingLinesForGGplot(p, nRegions)))
  l0 = bind_rows(l0)
  
  loginfo("Plot survival curves with dotted lines showing tau fittings.\n")
  tb = ggplot(l0, aes(x = x, y = y, colour = Condition)) +
    scale_y_log10(limits = c(1e-8, 1)) +
    geom_line() +
    plTheme +
    clScale +
    labs(x = "Template Span", y = "1 - CDF (with ad-hoc censoring)", title = "First Pass Template Span") +
    geom_line(
      data = n0,
      aes(
        x = x,
        y = y,
        group = Region,
        colour = Condition
      ),
      linetype = "dotted",
      show.legend = FALSE
    )
  
  report$ggsave(
    "first_pass_tau.png",
    tb,
    id = "first_pass_taus",
    width = plotwidth,
    height = plotheight,
    title = "1 - CDF of 1st Pass",
    caption = "1 - CDF of 1st Pass",
    tags = c(
      "libdiagnostic",
      "library",
      "diagnostic",
      "template",
      "cdf",
      "tau",
      "survival",
      "first",
      "pass"
    ),
    uid = "0020025"
  )
}

#'--------------------------------------------------------------
#' Long library metrics
#'--------------------------------------------------------------

#' Generate density plot of max subread length for all conditions
#'
#' @param report = use method ggsave to save plot of density
#' @param maxSubreadLens = list - one data frame per condition - with columns MaxSubreadLen and Condition
#' @param deNovo = if TRUE then plots will be labeled as de novo.
#' @param searchTags = vector of short strings that would allow this plot to appear in a search
#'
#' @seealso \code{\link{collectTemplateSpan}} where maxSubreadLens is defined
#' @return vector of mean max subread lengths, one mean per condition
#' @export

plotDensityOfMaxSubreadLength = function(report,
                                         maxSubreadLens,
                                         deNovo,
                                         searchTags)
{
  label = ifelse(deNovo,
                 "de_novo_max_subread_len_density",
                 "max_subread_len_density")
  title = ifelse(deNovo,
                 "de Novo Max Subread Length Density",
                 "Max Subread Length Density")
  
  loginfo("Generate density plot of max subread length for all conditions:")
  tb = ggplot(bind_rows(maxSubreadLens),
              aes(x = MaxSubreadLen, colour = Condition)) +
    geom_line(lwd = 0.5, stat = "density") +
    scale_x_log10() +
    plTheme +
    clScale +
    labs(x = "Max Subread Length", y = "Density", title = title)
  
  report$ggsave(
    paste(label, "png", sep = "."),
    tb,
    id = label,
    width = plotwidth,
    height = plotheight,
    title = title,
    caption = title,
    tags = c("density", searchTags),
    uid = "0020026"
  )
  vapply(maxSubreadLens, function(x)
    mean(x$MaxSubreadLen, na.rm = TRUE), 0)
}

#' Compute N(k) using only the longest subread for each ZMW.
#' N(k) := length N such that k percent of all bases are in sequences of length < N
#'
#' Plot CDF of max subread lengths with one horizontal bar at N(k) for each value of k.
#'
#' @param report = use method ggsave to save illustrative plot with CDF and horizontal lines
#' @param maxSubreadLenCDFs = list of data frames, one per condition, with CDFs for max subread lengths.
#' @param perc = desired values of k, in percent form.  Default: c( 0.5, 0.25 ) for N50 and N25
#' @param deNovo = if TRUE then plots will be labeled as de novo.
#' @param searchTags = vector of short strings that would allow this plot to appear in a search
#'
#' @seealso \code{\link{getMaxSubreadLenCDF}} where maxSubreadLenCDFs is defined
#' @return data frame with N(k) for each specified value in perc - one row per condition.
#' @export

plot_N_k_UsingLongestSubreads = function(report,
                                         maxSubreadLenCDFs,
                                         perc,
                                         deNovo,
                                         searchTags)
{
  label = ifelse(deNovo,
                 "de_novo_max_subread_len_cdf_with_N50",
                 "max_subread_len_cdf_with_N50")
  title = ifelse(deNovo,
                 "de Novo Max Subread Length CDFs and N(k)",
                 "Max Subread Length CDFs and N(k)")
  
  loginfo("Plot CDF of max subread lengths with one horizontal bar at N(k) for each value of k:")
  tb = ggplot(bind_rows(maxSubreadLenCDFs),
              aes(x = x, y = y, colour = Condition)) +
    geom_line(lwd = 0.5) +
    plTheme +
    clScale +
    labs(x = "Max Subread Lengths", y = "CDF", title = title)
  for (p in perc)
  {
    tb = tb + geom_hline(yintercept = p)
  }
  
  report$ggsave(
    paste(label, "png", sep = "."),
    tb,
    id = label,
    width = plotwidth,
    height = plotheight,
    title = title,
    caption = title,
    tags = c("N50", "N25", "CDF", searchTags),
    uid  = "0020027"
  )
  
  loginfo("For each condition, compute N(k) for each value of k:")
  res = data.frame(t(sapply(maxSubreadLenCDFs,
                            function(z)
                              vapply(perc, function(p)
                                z$x[which.min(abs(z$y - p))], 0))))
  
  names(res) = paste("N", perc * 100, sep = "")
  res$nZMWs = vapply(maxSubreadLenCDFs, function(z)
    z$nReads[1], 0)
  res
}

#' Plot ( 1 - CDF ) of max subread lengths with one vertical bar at each desired benchmark value
#'
#' @param report = use method ggsave to save illustrative plot with 1 - CDF and vertical lines
#' @param maxSubreadLenCDFs = list of data frames, one per condition, with CDFs for max subread lengths.
#' @param benchmark = max subread length values to mark out on plot
#' @param deNovo = if TRUE then plots will be labeled as de novo.
#' @param searchTags = vector of short strings that would allow this plot to appear in a search
#'
#' @seealso \code{\link{getMaxSubreadLenCDF}} where maxSubreadLenCDFs is defined
#' @return data frame with fraction of reads greater than each benchmark value - one row per condition.
#' @export

plotSurvivalUsingLongestSubreads = function(report,
                                            maxSubreadLenCDFs,
                                            benchmark,
                                            deNovo,
                                            searchTags)
{
  maxSubreadLenSurvival = lapply(maxSubreadLenCDFs, function(z) {
    z$y = 1 - z$y
    z
  })
  
  label = ifelse(deNovo,
                 "de_novo_max_subread_len_survival",
                 "max_subread_len_survival")
  title = ifelse(deNovo,
                 "de Novo Max Subread Length Survival",
                 "Max Subread Length Survival")
  
  loginfo("Plot survival of longest subread per ZMW:")
  tb = ggplot(bind_rows(maxSubreadLenSurvival),
              aes(x = x, y = y, colour = Condition)) +
    geom_line(lwd = 0.5) +
    plTheme +
    clScale +
    labs(x = "Max Subread Length", y = "1 - CDF", title = title)
  for (b in benchmark)
  {
    tb = tb + geom_vline(xintercept = b)
  }
  
  report$ggsave(
    paste(label, "png", sep = "."),
    tb,
    id = label,
    width = plotwidth,
    height = plotheight,
    title = title,
    caption = title,
    tags = c("CDF", "survival", "benchmark", searchTags),
    uid  = "0020028"
  )
  
  loginfo("What percentage of ZMWs have max subread length above each benchmark value?")
  res = data.frame(t(sapply(maxSubreadLenSurvival,
                            function(z)
                              vapply(benchmark,
                                     function(b)
                                     {
                                       w = which(z$x >= b)
                                       ifelse(length(w) == 0, NA, z$y[min(w)])
                                     }, 0))))
  
  names(res) = paste("Greater_Than", benchmark, sep = "_")
  res
}

#' For a single condition, get max subread length per ZMW
#'
#' @param bam - output of pbbamr::loadPBI2 for one condition
#'	with additional columns tlen := tend - tstart and alen.
#'
#' @return data frame with columns MaxSubreadLen and Condition
#' @seealso \code{\link{createLongLibraryPlots}} which calls this function
#' @export

getMaxSubreadLengths = function(bam)
{
  z = setDT(bam)
  setkey(z, hole)
  tmp = z[z[, .I[which.max(tlen)], by = hole]$V1]
  data.frame(Condition = tmp$Condition,
             MaxSubreadLen = tmp$tlen)
}

#' For each condition, get CDF of max subread lengths
#'
#' @param data = output of \code{\link{getMaxSubreadLengths}} for one condition
#' @param nPoints = number of points to use in CDF
#'
#' @return data frame with columns nReads, Condition, x and y
#'
#' @seealso \code{\link{createLongLibraryPlots}} which calls this function
#' @export

getMaxSubreadLenCDF = function(data, nPoints = 1000)
{
  loginfo("For each condition, get CDF of max subread lengths:")
  E = ecdf(data$MaxSubreadLen)
  r = range(data$MaxSubreadLen, na.rm = TRUE)
  x = seq(r[1], r[2], length.out = nPoints)
  y = vapply(x, E, 0)
  data.frame(
    Condition = data$Condition[1],
    nReads = nrow(data),
    x = x,
    y = y
  )
}

#' Generate long library metrics and plots
#'
#' @param report = use write.table and ggsave methods to save tables and plots.
#' @param alnxmls = vector of paths to alignment xml files - one per file per condition.
#' @param cd = data table output of pbbamr::loadPBI2 and \code{\link{combineConditions}}
#' @param perc = vector of percentiles for N(k);  0.5 corresponds to N50, 0.25 to N25.
#' @param benchmark = vector listing benchmark read lengths for comparison
#' @param deNovo = if TRUE then plots will be labeled as de novo
#'
#' @return table with metrics
#' @export

generateLongLibraryMetricsAndPlots = function(report, cd, perc, benchmark, deNovo = FALSE)
{
  searchTags = c(
    "library",
    "diagnostics",
    "lib_diagnostics",
    "subread",
    "max",
    "max_subread",
    "libdiagnostics",
    "subread_length",
    "length"
  )
  
  #' Get and plot density for max subread lengths:
  
  rows = split(1:nrow(cd), cd$Condition)
  maxSubreadLens = lapply(rows, function(r)
    getMaxSubreadLengths(cd[r, ]))
  meanMaxSubread = plotDensityOfMaxSubreadLength(report, maxSubreadLens, deNovo, searchTags)
  
  #' Get and plot CDF and survival for max subread lengths:
  
  maxSubreadLenCDFs = lapply(maxSubreadLens, getMaxSubreadLenCDF)
  N50values = plot_N_k_UsingLongestSubreads(report, maxSubreadLenCDFs, perc, deNovo, searchTags)
  vsBenchmark = plotSurvivalUsingLongestSubreads(report, maxSubreadLenCDFs, benchmark, deNovo, searchTags)
  
  loginfo("Write metrics to table:")
  tbl = merge(N50values, vsBenchmark, by = 0)
  tbl$MeanMaxSubreadLen = meanMaxSubread
  names(tbl)[names(tbl) == "Row.names"] = "Condition"
  row.names(tbl) = NULL
  
  label = ifelse(deNovo,
                 "de_novo_long_library_metrics",
                 "long_library_metrics")
  report$write.table(
    paste(label, "csv", sep = "."),
    tbl,
    id = label,
    title = "Long Library Metrics",
    tags = c("table", "metrics", "long_library_metrics", searchTags)
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
  dfs = lapply(as.character(conditions$MappedSubreads), function(s) {
    loginfo(paste("Loading alignment set:", s))
    loadPBI2(s)
  })
  # Filter out empty data sets, throw a warning if any empty ones exist
  filteredData = filterEmptyDataset(dfs, conditions)
  if (length(filteredData) == 0) {
    warning("No ZMW has been loaded from the alignment set!")
  } else {
    dfs  = filteredData[[1]]
    conditions = filteredData[[2]]
    
    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)
    
    # Now combine into one large data frame
    cd = combineConditions(dfs, as.character(conditions$Condition))
    cd$tlen = as.numeric(cd$tend - cd$tstart)
    cd$alen = as.numeric(cd$aend - cd$astart)
    
    # Make Plots
    try(makeCDFofaStartPlots(report, cd), silent = TRUE)
    try(makeMaxVsUnrolledPlots(report, cd), silent = TRUE)
    try(makeCDFofTemplatePlots(report, cd), silent = TRUE)
    try(plotFirstPassTau(report, cd), silent = TRUE)
    try(generateLongLibraryMetricsAndPlots(
      report,
      cd,
      perc = c(0.5, 0.25, 0.1),
      benchmark = c(5e3, 8e3, 1e4, 1.5e4)
    ),
    silent = TRUE)
  }
  
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
    "Library Diagnostic Plots"
  )
  makeReport(report)
  jsonFile = "reports/LibDiagnosticPlots/report.json"
  uidTagCSV = "reports/uidTag.csv"
  rewriteJSON(jsonFile, uidTagCSV)
  0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()