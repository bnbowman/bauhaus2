#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

if (length(args) == 0)
  stop(
    "Provide same/different, *.zulu.bq_ppv file, output prefix, *.lima.summary file.\n",
    call. = FALSE
  )

library(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
library(Biostrings, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(dtplyr, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(viridis, quietly = TRUE, warn.conflicts = FALSE)
library(scales, quietly = TRUE, warn.conflicts = FALSE)
hasGgrepel = require(ggrepel, quietly = TRUE, warn.conflicts = FALSE)
library(data.table, quietly = TRUE, warn.conflicts = FALSE)
library(cowplot, quietly = TRUE, warn.conflicts = FALSE)

libraryType = args[1]

reportPath = args[2]
report = fread(reportPath, stringsAsFactors = FALSE, sep = " ")

outputprefix = ""
if (length(args) >= 3)
  outputprefix = paste(args[3], ".", sep = "")

report = report %>% mutate(text = ifelse(BQ %% 10 == 0 |
                                           BQ == min(BQ) | BQ == max(BQ), BQ, ""))

numZMWs = 0
filteredZMWs = 0
asymmetricZMWs = 0
symmetricZMWs = 0
noAdapter = 0
if (length(args) >= 4) {
  summary = fread(args[4], blank.lines.skip = TRUE)
  for (i in 1:nrow(summary)) {
    if (grepl("ZMWs input", summary[i, 1]))
      numZMWs = as.integer(unlist(summary[1, 2]))
    if (grepl("ZMWs below any threshold", summary[i, 1]))
      filteredZMWs = as.integer(unlist(strsplit(as.character(summary[i, 2]), ' '))[1])
    if (grepl("With different barcodes", summary[i, 1]))
      asymmetricZMWs = as.integer(unlist(strsplit(as.character(summary[i, 2]), ' '))[1])
    if (grepl("With same barcode", summary[i, 1]))
      symmetricZMWs = as.integer(unlist(strsplit(as.character(summary[i, 2]), ' '))[1])
    if (grepl("Without adapter", summary[i, 1]))
      noAdapter = as.integer(unlist(strsplit(as.character(summary[i, 2]), ' '))[1])
  }
}
filteredZMWs = filteredZMWs - noAdapter

miny = 0.95
barheight = 0.0025
g = ggplot(report, aes(color = BQ)) +
  geom_jitter(aes(YIELD, PPV)) +
  geom_line(aes(YIELD, PPV), alpha = .5) +
  scale_color_viridis() +
  coord_cartesian(ylim = c(miny, 1.0)) +
  scale_x_continuous(limits = c(0, numZMWs), labels = comma) +
  theme_minimal() +
  ylab("Positive Predictive Value") +
  ggtitle(
    "Positive Predictive Value and Sequencing ZMW Yield as a function of the minimum Barcode Score."
  ) +
  theme(plot.title = element_text(hjust = 0.5))
if (length(args) <= 2) {
  g = g + xlab("Input ZMW yield")
} else {
  g = g + xlab("Sequencing ZMW yield")
}
if (hasGgrepel)
  g = g + geom_text_repel(aes(YIELD, PPV, label = text), point.padding = unit(.2, "lines"))
if (filteredZMWs > 0) {
  if (libraryType == "same") {
    g = g + geom_vline(xintercept = numZMWs - noAdapter,
                       lty = 2,
                       color = "black") +
      geom_vline(
        xintercept = numZMWs - noAdapter - filteredZMWs,
        lty = 2,
        color = "#d53e4f"
      ) +
      geom_vline(xintercept = numZMWs,
                 lty = 1,
                 color = "black") +
      geom_vline(
        xintercept = numZMWs - (noAdapter + filteredZMWs + asymmetricZMWs),
        col = "#fc8d59",
        lty = 2,
        alpha = .5
      ) +
      geom_rect(
        aes(fill = "No Adapter", linetype = NA),
        xmin = numZMWs - noAdapter,
        xmax = numZMWs,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Filtered", linetype = NA),
        xmin = numZMWs - filteredZMWs - noAdapter,
        xmax = numZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Different Barcodes", linetype = NA),
        xmin = numZMWs - filteredZMWs - asymmetricZMWs - noAdapter,
        xmax = numZMWs - filteredZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Same Barcodes", linetype = NA),
        xmin = 0,
        xmax = numZMWs - filteredZMWs - asymmetricZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      scale_fill_manual(values = c("#fc8d59", "#d53e4f", "black", "#99d594"),
                        name = "ZMW Yield")
  } else {
    g = g + geom_vline(xintercept = numZMWs - noAdapter,
                       lty = 2,
                       color = "black") +
      geom_vline(
        xintercept = numZMWs - noAdapter - filteredZMWs,
        lty = 2,
        color = "#d53e4f"
      ) +
      geom_vline(xintercept = numZMWs,
                 lty = 1,
                 color = "black") +
      geom_vline(
        xintercept = numZMWs - (noAdapter + filteredZMWs + symmetricZMWs),
        col = "#fc8d59",
        lty = 2,
        alpha = .5
      ) +
      geom_rect(
        aes(fill = "No Adapter", linetype = NA),
        xmin = numZMWs - noAdapter,
        xmax = numZMWs,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Filtered", linetype = NA),
        xmin = numZMWs - filteredZMWs - noAdapter,
        xmax = numZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Same Barcodes", linetype = NA),
        xmin = numZMWs - filteredZMWs - symmetricZMWs - noAdapter,
        xmax = numZMWs - filteredZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      geom_rect(
        aes(fill = "Different Barcodes", linetype = NA),
        xmin = 0,
        xmax = numZMWs - filteredZMWs - symmetricZMWs - noAdapter,
        ymin = miny,
        ymax = miny + barheight,
        alpha = 0.5
      ) +
      scale_fill_manual(values = c("#99d594", "#d53e4f", "black", "#fc8d59"),
                        name = "ZMW Yield")
  }
}

ggsave(
  paste(outputprefix, "yield_vs_ppv.png", sep = ""),
  g,
  width = 30,
  height = 25,
  dpi = 100,
  units = "cm"
)