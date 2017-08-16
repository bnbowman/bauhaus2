#!/usr/bin/env Rscript
# This is file is for plotting metrics we can obtain by loading the indexes with optional parsing of the original BAM
# files as well as plots that can be made by taking a sample of those.
library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dplyr)
library(tidyr, quietly = TRUE)
library(stats)
library(IRanges)
library(stringr)
library(lazyeval)

## FIXME: make a real package
myDir = "./scripts/R"
source(file.path(myDir, "Bauhaus2.R"))

# Define a basic addition to all plots
midTitle <- theme(plot.title = element_text(hjust = 0.5))
plTheme <- theme_bw(base_size = 14) + theme(plot.title = element_text(hjust = 0.5))
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))
plotwidth = 7.2
plotheight = 4.2

# ipd and pw are filtered by maxIPD and maxPW
maxIPD = 1.25
maxPW = 0.25

# Fuction to get p_variable names
variableNames <- function(ct)
{
  nms <- names(ct)
  matches <- str_detect(nms, "(p_.*)")
  nms[matches]
}

### Custom sampler function to sample min(data, sample) which can't be done with dplyr
### it's a modified copy of sample_n.grouped_df
sample_nigel <-
  function(tbl,
           size,
           replace = FALSE,
           weight = NULL)
  {
    #assert_that(is.numeric(size), length(size) == 1, size >= 0)
    weight <- substitute(weight)
    index <- attr(tbl, "indices")
    sizes = sapply(index, function(z)
      min(length(z), size)) # here's my contribution
    sampled <-
      lapply(1:length(index), function(i)
        dplyr:::sample_group(
          index[[i]],
          frac = FALSE,
          tbl = tbl,
          size = sizes[i],
          replace = replace,
          weight = weight
        ))
    idx <- unlist(sampled) + 1
    grouped_df(tbl[idx, , drop = FALSE], vars = groups(tbl))
  }

# Subsample the data set to load SNR values
loadSNRforSubset <- function(cd, SNRsampleSize = 5000) {
  cd <-
    cd %>% group_by(file) %>% mutate(framePerSecond = as.numeric(as.character(
      unique(loadHeader(as.character(file[1]))$readgroups$framerate)
    ))) %>% ungroup()
  cd2 = cd %>% group_by(Condition, framePerSecond) %>% sample_nigel(size = SNRsampleSize) %>% ungroup()
  cd2snr = loadExtras(cd2, loadSNR = TRUE)
  cd2 = cbind(cd2, cd2snr)
  cd2
}

makepColPlots <- function(report, cd, p_Var, conditions) {
  loginfo("Making p_ Column based Plots")
  # when one p_variables show up
  # Make Simple plot with one additional variable, data set merged by p_Var
  cd = as.data.frame(cd)
  
  # Variables that will be plotted against p_variables
  plotVariables = c("tlen", "alen", "Accuracy", "irate", "drate", "mmrate", "snrC")
  
  # Check if any of the plotVariables is empty
  plotVariables = names(Filter(function(x)!all(is.na(x)), cd[, match(plotVariables, names(cd))]))
  
  if (length(p_Var) == 1) {
    # Plot selected variables verses the p variable, groupd by condition
    # Note: When p_Var is categorical, the boxplots will overlap, so the plot is set to transparent with colored border
    for (i in 1:length(plotVariables)) {
      tp <- ggplot(cd, aes_string(
        x = p_Var,
        y = cd[, match(plotVariables[i], names(cd))]
      )) +
        geom_boxplot(aes(color = Condition), position = position_dodge(width = 0.9), alpha = 0) + 
        labs(y = plotVariables[i], title = paste(plotVariables[i], " vs. ", p_Var, sep = "")) + 
        themeTilt + midTitle
      report$ggsave(
        paste(plotVariables[i], "vs", p_Var, sep = ""),
        tp,
        width = plotwidth,
        height = plotheight,
        id = paste(plotVariables[i], "vs", p_Var, sep = ""),
        title = paste(plotVariables[i], " vs. ", p_Var, sep = ""),
        caption = paste(plotVariables[i], " vs. ", p_Var, sep = ""),
        tags = c("sampled", "p_", "titration", plotVariables[i], "boxplot")
      )
    }
  } else if (length(p_Var) == 2)  { # When two p_variables show up
    # First plot both p_variables against plotVariables
    # When numerical variable appears, set as x-axis
    # If both p_variables are numerical or categorical, use the first one as x-axis
    if (!is.numeric(conditions[, match(p_Var[1], names(conditions))]) & is.numeric(conditions[, match(p_Var[2], names(conditions))])) {
      p_Var = c(p_Var[2], p_Var[1])
    } else {
      p_Var = p_Var
    }
    
    # Summerize median for plotVariables
    cdp = list()
    for (i in 1:length(plotVariables)) {
      cdp[[i]] = cd %>% group_by(Condition) %>%
                     summarize_(.dots = as.formula(paste0("~ median(", plotVariables[i], ")")))
      colnames(cdp[[i]])[2] = plotVariables[i]
    }
    cdp <- Reduce(function(...) merge(..., by="Condition", all=TRUE), cdp)
    cdp = merge(cdp, conditions[,c("Condition", p_Var)], by = "Condition")
    
    # Generate plots of each plotVariables verses the p variables
    for (i in 1:length(plotVariables)) {
      tp = ggplot(cdp,
                  aes_string(
                    x = p_Var[1],
                    y = plotVariables[i],
                    color = p_Var[2],
                    group = p_Var[2]
                  )) + geom_point() + geom_line() +
        plTheme + themeTilt + clScale + labs(x = p_Var[1], y = paste0("Median of ", plotVariables[i]), title = paste("Median of ", plotVariables[i], " vs ", p_Var[2], " grouped by ", p_Var[1], sep = ""))
      report$ggsave(
        paste0("median", plotVariables[i], "vs", p_Var[2], "by", p_Var[1]),
        tp,
        width = plotwidth,
        height = plotheight,
        id = paste0("median", plotVariables[i], "vs", p_Var[2], "by", p_Var[1]),
        title = paste("Median of ", plotVariables[i], " vs ", p_Var[2], " grouped by ", p_Var[1], sep = ""),
        caption = paste("Median Template Length vs ", p_Var[2], " grouped by ", p_Var[1], sep = ""),
        tags = c("sampled", "p_", "titration", "median", plotVariables[i])
      )
    }
  } else {
    warning("More than two p_variables show up")
    0
  }
}

makeSamplingPlots <-
  function(report,
           cd,
           conditions,
           sampleSize = 1000) {
    loginfo("Making Sampling plots")
    
    load_alns <- function(tbl) {
      names(tbl)[names(tbl) == "ref"] <- "refName"
      curCondition = tbl$Condition[1]
      rsfname = as.character(conditions$Reference[as.character(conditions$Condition) == as.character(curCondition)][1])
      fasta = pbbamr::getReferencePath(rsfname)
      loginfo(paste("Loading fasta file:", fasta))
      alns = loadAlnsFromIndex(tbl, fasta)
      sampleSize = min(nrow(tbl), sampleSize)
      for (i in (1:sampleSize)) {
        alns[[i]]$hole = as.factor(as.character(tbl$hole))[i]
        alns[[i]]$refName = as.factor(as.character(tbl$refName))[i]
      }
      alnsTotal = data.table::rbindlist(alns)
      alnsTotal$Condition = curCondition
      grouped_df(alnsTotal, vars = groups(tbl))
    }
    cd2 = cd %>% group_by(Condition, framePerSecond) %>% sample_nigel(size = sampleSize) %>% do(load_alns(.)) %>% ungroup()
    if ((("ipd" %in% colnames(cd2)) & ("pw" %in% colnames(cd2)))) {
      cd2$ipd = cd2$ipd / cd2$framePerSecond
      cd2$pw = cd2$pw / cd2$framePerSecond
      cd2$AccuBases <- "Inaccurate"
      cd2$AccuBases[cd2$read == cd2$ref] = "Accurate"
      cd2$DC <- cd2$ipd + cd2$pw
      
      # Set a boolean variable to see if all the conditions are internal mode
      # Only when all the conditions are internal mode, the variable is set to TRUE
      internalBAM = TRUE
      if (!("sf" %in% colnames(cd2))) {
        internalBAM = FALSE
      } else {
        cd2internal = cd2 %>% group_by(Condition) %>% summarise(sf = all(unique(sf) %in% NA))
        if (any(cd2internal$sf) == TRUE) {
          internalBAM = FALSE
        }
      }
      
      # For internal mode and non-internal mode produce different dataframes
      # For internal mode, the dataframs contain time information
      if (internalBAM) {
        cd2 = cd2 %>% group_by(Condition, framePerSecond) %>% mutate(
          snrCfac = cut(snrC, breaks = c(0, seq(3, 20), 50)),
          time = cut(sf / framePerSecond, breaks = c(seq(
            0, ceiling(max(cd2$sf) / min(framePerSecond) / 600)
          ) * 600))
        ) %>% ungroup()
        cd3 = cd2[!cd2$read == "-", ] %>% group_by(Condition, framePerSecond, hole, refName) %>% summarise(
          medianpw = median(pw),
          medianipd = median(ipd),
          PolRate = mean(ipd + pw),
          startTime = min(sf) / unique(framePerSecond),
          # Here we group by condition, frame rate and hole, so there should be only one unique frame rate
          endTime = max(sf) / unique(framePerSecond)
        )
        cd3temp = cd2[!cd2$ref == "-", ] %>% group_by(Condition, framePerSecond, hole, refName) %>% summarise(
          tlen = n()
        )
        cd3 <- merge(cd3, cd3temp, by = c("Condition", "framePerSecond", "hole", "refName"))
        cd3$basepersecond = cd3$tlen / (cd3$endTime - cd3$startTime)
      } else {
        # Write a tabel for the missing plots due to non-internal BAM files
        missingPlots = c("Active ZMW - Normalized",
                         "pkMid Box Plot - all reference reads",
                         "pkMid Box Plot - accurate reference reads",
                         "pkMid Box Plot - inaccurate reference reads",
                         "pkMid Density Plot - all reference reads",
                         "pkMid Density Plot - accurate reference reads",
                         "pkMid Density Plot - inaccurate reference reads",
                         "pkMid CDF - all reference reads",
                         "pkMid CDF - accurate reference reads",
                         "pkMid CDF - inaccurate reference reads",
                         "pkMid Histogram - all reference reads",
                         "pkMid Histogram - accurate reference reads",
                         "pkMid Histogram - inaccurate reference reads",
                         "pkMid Density Plot - Accurate vs Inaccurate bases",
                         "PW Trend by Time",
                         "PolRate Trend by Time",
                         "IPD Trend by Time",
                         "Mean Pulse Width by Time",
                         "Mean Pkmid by Time",
                         "Median Pkmid by Time",
                         "Median Pkmid by Time (Normalized)",
                         "John Eid's Global/Local Ploymerization Rate")
        noninternalBAM = as.data.frame(missingPlots)
        report$write.table("noninternalBAM.csv",
                           noninternalBAM,
                           id = "noninternalBAM",
                           title = "Missing plots that require internal BAM files")
        cd2 = cd2 %>% group_by(Condition, framePerSecond) %>% mutate(snrCfac = cut(snrC, breaks = c(0, seq(3, 20), 50))) %>% ungroup()
        cd3 = cd2[!cd2$read == "-", ] %>% group_by(Condition, framePerSecond, hole, refName) %>% summarise(
          medianpw = median(pw),
          medianipd = median(ipd),
          PolRate = mean(ipd + pw)
        )
      }
      
      cd3$DC <- cd3$medianipd + cd3$medianpw
      cd3$DutyCycle  = cd3$medianpw / (cd3$medianpw + cd3$medianipd)
      
      # cd4 is used to generate the plot of template span ove time
      cd4 = cd2 %>% group_by(Condition, framePerSecond, hole) %>% summarise(
        sumpw = sum(pw),
        sumipd = sum(ipd),
        templateSpan = length(ref[!ref == "-"])
      )
      
      # Plots based on startFrame (Only produced when "sf" is loaded)
      if (internalBAM) {
        # Global/Local PolRate plot
        tp = ggplot(cd3, aes(
          x = basepersecond * (medianpw + medianipd) / log(2),
          colour = Condition
        )) + geom_density(alpha = .5) + xlim(0, 1) +
          labs(
            y = "density",
            x = "PolRate*(median(PW) + median(IPD))/ln(2)",
            title = paste(
              "John Eid's Global/Local Ploymerization Rate\n(From ",
              sampleSize,
              "Sampled Alignments)"
            )
          ) + plTheme + themeTilt + clScale
        report$ggsave(
          "global_localpolrate.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "global_localpolrate",
          title = "Global/Local PolRate",
          caption = "Global/Local PolRate",
          tags = c("sampled", "polrate", "john eid")
        )
        
        # ActiveZMWs
        activeZMW <- function(rngs) {
          dta <- as.data.frame(rngs)
          dta$time <- 1:dim(dta)[1]
          dtm <-
            melt(as.data.frame(dta),
                 id.vars = "time",
                 variable.name = "condition")
          dtm
        }
        m <- ceiling(max(cd3$endTime))
        # rngs_unnorm <-
        #   do.call(cbind, tapply(seq.int(1, nrow(cd3)), factor(cd3$Condition), function(idxs) {
        #     x <-
        #       as(coverage(IRanges(cd3$startTime[idxs], cd3$endTime[idxs]), width = m), "vector")
        #   }))
        rngs_norm <-
          do.call(cbind, tapply(seq.int(1, nrow(cd3)), factor(cd3$Condition), function(idxs) {
            x <-
              as(coverage(IRanges(cd3$startTime[idxs], cd3$endTime[idxs]), width = m), "vector")
            x / length(idxs)
          }))
        #    dtm_unnorm = activeZMW(rngs_unnorm)
        dtm_norm = activeZMW(rngs_norm)
        
        # tp = ggplot(dtm_unnorm, aes(x=time,y=value,color=condition,group=condition)) +
        #   geom_line(lty=1,lwd=1) + xlab("Seconds") + ylab("Percentage of Alignments") +
        #   labs(title = "Alignment Percentage by Time: Unnormalized")
        # report$ggsave("active_zmw_unnormalized.png", tp, id = "active_zmw_unnormalized.png", title = "Active ZMW - Unnormalized", caption = "Active ZMW - Unnormalized")
        
        tp = ggplot(dtm_norm,
                    aes(
                      x = time,
                      y = value,
                      color = condition,
                      group = condition
                    )) +
          geom_line(lty = 1, lwd = 1) + xlab("Seconds") + ylab("Percentage of Alignments") +
          labs(title = "Alignment Percentage by Time: Normalized") + plTheme
        report$ggsave(
          "active_zmw_normalized.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "active_zmw_normalized.png",
          title = "Active ZMW - Normalized",
          caption = "Active ZMW - Normalized",
          tags = c("sampled", "active ZMW", "time")
        )
        
        # pkMid for complete data set, accurate bases, and inaccurate bases
        
        cd2.1 <- cd2[cd2$AccuBases == "Accurate", ]
        cd2.2 <- cd2[cd2$AccuBases == "Inaccurate", ]
        reads <- list(cd2, cd2.1, cd2.2)
        variableTitle <-
          c("all reference reads",
            "accurate reference reads",
            "inaccurate reference reads")
        
        for (i in 1:3) {
          img_height = min(49.5, 3 * length(levels(reads[[i]]$ref)))
          
          tp = ggplot(reads[[i]], aes(x = Condition, y = pkmid, fill = Condition)) +
            geom_boxplot() + stat_summary(
              fun.y = median,
              colour = "black",
              geom = "text",
              show.legend = FALSE,
              vjust = -0.8,
              aes(label = round(..y.., digits = 3))
            ) + plTheme + themeTilt  + clFillScale +
            facet_wrap( ~ ref, nrow = length(levels(reads[[i]]$ref)))
          report$ggsave(
            paste("pkMid_Box_", variableTitle[i], ".png", sep = ""),
            tp,
            width = plotwidth,
            height = img_height,
            id = paste("pkMid_boxplot_", variableTitle[i], sep = ""),
            title = paste("pkMid Box Plot - ", variableTitle[i], sep = ""),
            caption = paste(
              "Distribution of pkMid for ",
              variableTitle[i],
              " (Boxplot)",
              sep = ""
            ),
            tags = c("sampled", "pkmid", "boxplot", variableTitle[i])
          )
          
          # tp = ggplot(reads[[i]], aes(x = Condition, y = pkmid, fill = Condition)) + geom_violin() +
          #   geom_boxplot(width = 0.1, fill = "white") + plTheme + themeTilt  + clFillScale +
          #   facet_wrap( ~ ref)
          # report$ggsave(
          #   paste("pkMid_Violin_", variableTitle[i], ".png", sep = ""),
          #   tp,
          #   id = paste("pkMid_violinplot_", variableTitle[i], sep = ""),
          #   title = paste("pkMid Violin Plot - ", variableTitle[i], sep = ""),
          #   caption = paste(
          #     "Distribution of pkMid for ",
          #     variableTitle[i],
          #     " (Violin plot)",
          #     sep = ""
          #   ),
          #   tags = c("sampled", "pkmid", "violin", variableTitle[i])
          # )
          
          tp = ggplot(reads[[i]], aes(x = pkmid, colour = Condition)) + geom_density(alpha = .5) +
            plTheme + themeTilt  + clScale + facet_wrap( ~ ref, nrow = length(levels(reads[[i]]$ref))) +
            labs(x = "pkMid (after normalization)", title = "pkMid by Condition")
          report$ggsave(
            paste("pkMid_Dens_", variableTitle[i], ".png", sep = ""),
            tp,
            width = plotwidth,
            height = img_height,
            id = paste("pkMid_densityplot_", variableTitle[i], sep = ""),
            title = paste("pkMid Density Plot - ", variableTitle[i], sep = ""),
            caption = paste(
              "Distribution of pkMid for ",
              variableTitle[i],
              " (Density plot)",
              sep = ""
            ),
            tags = c("sampled", "pkmid", "density", variableTitle[i])
          )
          
          tp = ggplot(reads[[i]], aes(x = pkmid, colour = Condition)) + stat_ecdf() +
            plTheme + themeTilt  + clScale + facet_wrap( ~ ref, nrow = length(levels(reads[[i]]$ref))) +
            labs(x = "pkMid", y = "CDF", title = "pkMid by Condition (CDF)")
          report$ggsave(
            paste("pkMid_CDF_", variableTitle[i], ".png", sep = ""),
            tp,
            width = plotwidth,
            height = img_height,
            id = paste("pkMid_cdf_", variableTitle[i], sep = ""),
            title = paste("pkMid CDF - ", variableTitle[i], sep = ""),
            caption = paste("Distribution of pkMid for ", variableTitle[i],  " (CDF)", sep = ""),
            tags = c("sampled", "pkmid", "cdf", variableTitle[i])
          )
          
          tp = ggplot(reads[[i]], aes(x = pkmid, fill = Condition)) + geom_histogram() +
            plTheme + themeTilt  + clFillScale + facet_wrap( ~ ref, nrow = length(levels(reads[[i]]$ref))) +
            labs(x = "pkMid", title = "pkMid by Condition")
          report$ggsave(
            paste("pkMid_Hist_", variableTitle[i], ".png", sep = ""),
            tp,
            width = plotwidth,
            height = img_height,
            id = paste("pkMid_histogram_", variableTitle[i], sep = ""),
            title = paste("pkMid Histogram - ", variableTitle[i], sep = ""),
            caption = paste(
              "Distribution of pkMid for ",
              variableTitle[i],
              " (Histogram)",
              sep = ""
            ),
            tags = c("sampled", "pkmid", "histogram", variableTitle[i])
          )
        }
        
        # Density plots to compare pkMid for accurate bases and inaccurate bases
        
        tp = ggplot(cd2, aes(x = pkmid, colour = AccuBases)) + geom_density(alpha = .5) +
          plTheme + themeTilt  + clScale + facet_wrap( ~ Condition + ref, ncol = 5) +
          labs(x = "pkMid", title = "pkMid for accurate bases and inaccurate bases")
        report$ggsave(
          "pkMid_Accu_vs_Inaccu_Dens.png",
          tp,
          width = plotwidth * 5,
          height = img_height,
          id = "pkMid_Accu_Inaccu_densityplot",
          title = "pkMid Density Plot - Accurate vs Inaccurate bases",
          caption = "Distribution of pkMid for Accurate vs inaccurate bases (Density plot)",
          tags = c("sampled", "pkmid", "density")
        )
        
        # Make Pkmid / PW / PolRate by time plot
        cd2time = cd2 %>% group_by(Condition) %>% mutate(PKMID.Median.Con = median(pkmid)) %>% ungroup() %>% group_by(Condition, time) %>% summarise(
          PW.Mean = mean(pw),
          PKMID.Median = median(pkmid),
          PKMID.Mean = mean(pkmid),
          IPD.Median = median(ipd),
          PolRate = mean(ipd + pw),
          PKMID.Median.Con = median(PKMID.Median.Con)
        )
        cd2time$time = as.numeric(cd2time$time) * 10
        
        # Also make filtered data set by maxIPD and maxPW
        cd2timeFiltered = cd2[cd2$ipd < maxIPD & cd2$pw < maxPW,] %>% group_by(Condition) %>% mutate(PKMID.Median.Con = median(pkmid)) %>% ungroup() %>% group_by(Condition, time) %>% summarise(
          PW.Mean = mean(pw),
          PKMID.Median = median(pkmid),
          PKMID.Mean = mean(pkmid),
          IPD.Median = median(ipd),
          PolRate = mean(ipd + pw),
          PKMID.Median.Con = median(PKMID.Median.Con)
        )
        cd2timeFiltered$time = as.numeric(cd2timeFiltered$time) * 10
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = PW.Mean,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "Mean Pulse Width",
                                                              x = "Minute",
                                                              title = "PW Trend by Time")
        report$ggsave(
          "pw_mean_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "pw_mean_by_time",
          title = "Mean Pulse Width by Time",
          caption = "Mean Pulse Width by Time",
          tags = c("sampled", "pw", "time")
        )
        
        tp = ggplot(cd2timeFiltered,
                    aes(
                      x = time,
                      y = PW.Mean,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = paste("Mean PW (Truncated < ", maxPW, ")", sep = ""),
                                                              x = "Minute",
                                                              title = "Filtered PW Trend by Time")
        report$ggsave(
          "filtered_pw_mean_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "filtered_pw_mean_by_time",
          title = "Filtered Mean Pulse Width by Time",
          caption = "Filtered Mean Pulse Width by Time",
          tags = c("sampled", "pw", "time", "filtered")
        )
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = IPD.Median,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "Median IPD",
                                                              x = "Minute",
                                                              title = "IPD Trend by Time")
        report$ggsave(
          "ipd_median_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "ipd_median_by_time",
          title = "Median IPD by Time",
          caption = "Median IPD by Time",
          tags = c("sampled", "ipd", "time")
        )
        
        tp = ggplot(cd2timeFiltered,
                    aes(
                      x = time,
                      y = IPD.Median,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = paste("Median IPD (Truncated < ", maxIPD, ")", sep = ""),
                                                              x = "Minute",
                                                              title = "Filtered IPD Trend by Time")
        report$ggsave(
          "filtered_ipd_median_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "filtered_ipd_median_by_time",
          title = "Filtered Median IPD by Time",
          caption = "Filtered Median IPD by Time",
          tags = c("sampled", "ipd", "time", "filtered")
        )
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = PolRate,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "PolRate",
                                                              x = "Minute",
                                                              title = "PolRate Trend by Time")
        report$ggsave(
          "PolRate_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "PolRate_by_time",
          title = "PolRate by Time",
          caption = "PolRate by Time",
          tags = c("sampled", "polrate", "time")
        )
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = PKMID.Mean,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "Mean Pkmid",
                                                              x = "Minute",
                                                              title = "Pkmid Trend by Time")
        report$ggsave(
          "pkmid_mean_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "pkmid_mean_by_time",
          title = "Mean Pkmid by Time",
          caption = "Mean Pkmid by Time",
          tags = c("sampled", "pkmid", "time")
        )
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = PKMID.Median,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "Median Pkmid",
                                                              x = "Minute",
                                                              title = "Pkmid Trend by Time")
        report$ggsave(
          "pkmid_median_by_time.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "pkmid_median_by_time",
          title = "Median Pkmid by Time",
          caption = "Median Pkmid by Time",
          tags = c("sampled", "pkmid", "time")
        )
        
        tp = ggplot(cd2time,
                    aes(
                      x = time,
                      y = PKMID.Median / PKMID.Median.Con,
                      color = Condition,
                      group = Condition
                    )) + geom_point() +
          geom_line()  + clScale + plTheme + themeTilt + labs(y = "Median Pkmid (Normalized)",
                                                              x = "Minute",
                                                              title = "Pkmid Trend by Time (Normalized)")
        report$ggsave(
          "pkmid_median_by_time_normalized.png",
          tp,
          width = plotwidth,
          height = plotheight,
          id = "pkmid_median_by_time_normalized",
          title = "Median Pkmid by Time (Normalized)",
          caption = "Median Pkmid by Time (Normalized)",
          tags = c("sampled", "pkmid", "time")
        )
      }
      
      # Polymerization Rate measured by template bases per second
      tp = ggplot(cd4, aes(x = Condition, y = templateSpan / (sumpw + sumipd), fill = Condition)) + geom_boxplot(position = "dodge") + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) + 
        plTheme + themeTilt  + clFillScale + 
        labs(x = "Condition", y = "Polymerization Rate (template bases per second)", title = "Polymerization Rate (template bases per second)")
      
      report$ggsave(
        "polrate_template_per_second.png",
        tp,
        width = plotwidth,
        height = plotheight,
        id = "polrate_template_per_second",
        title = "Polymerization Rate (template bases per second)",
        caption = "Polymerization Rate (template bases per second)",
        tags = c("sampled", "boxplot", "polrate", "template", "time")
      )
      
      # Polymerization Rate by Reference
      tp <- ggplot(data = cd3, aes(x = refName, y = PolRate, fill = Condition)) +
        geom_boxplot(position = position_dodge(width = 0.9)) 
      a <- aggregate(PolRate ~ refName + Condition , cd3, function(i) round(median(i), digits = 4))
      tp <- tp +  geom_text(data = a, aes(label = PolRate), 
                            position = position_dodge(width = 0.9), vjust = -0.8) + 
        plTheme + themeTilt  + clFillScale + 
        labs(x = "Reference", y = "Polymerization Rate", title = "Polymerization Rate by Reference")
      
      report$ggsave(
        "polrate_ref_box.png",
        tp,
        width = plotwidth,
        height = plotheight,
        id = "polrate_ref_box",
        title = "Polymerization Rate by Reference",
        caption = "Polymerization Rate by Reference",
        tags = c("sampled", "boxplot", "polrate", "reference")
      )
      
      img_height = min(49.5, 3 * length(levels(cd2$ref)))
      
      # PW by Template Base
      tp = ggplot(cd2, aes(x = pw, colour = Condition)) + geom_density(alpha = .5) + xlim(0, 2) + 
        labs(
          y = "frequency",
          x = "seconds",
          title = paste("Pulse Width\n(From ", sampleSize, "Sampled Alignments)")
        ) + plTheme + themeTilt + clScale + facet_wrap( ~ ref, nrow = length(levels(cd2$ref)))
      report$ggsave(
        "pw_by_template.png",
        tp,
        width = plotwidth,
        height = img_height,
        id = "pw_by_template.png",
        title = "Pulse Width by Template Base",
        caption = "Pulse Width by Template Base",
        tags = c("sampled", "density", "pw")
      )
      
      tp = ggplot(cd2, aes(x = pw, colour = Condition)) + stat_ecdf() + xlim(0, 2) +
        labs(
          y = "CDF",
          x = "seconds",
          title = paste("Pulse Width_CDF\n(From ", sampleSize, "Sampled Alignments)")
        ) + plTheme + themeTilt + clScale + facet_wrap( ~ ref, nrow = length(levels(cd2$ref)))
      report$ggsave(
        "pw_by_template_cdf.png",
        tp,
        width = plotwidth,
        height = img_height,
        id = "pw_by_template_cdf.png",
        title = "Pulse Width by Template Base (CDF)",
        caption = "Pulse Width by Template Base (CDF)",
        tags = c("sampled", "pw", "cdf")
      )
      
      # # Local Polymerization Rate
      # # Note that thsi plot only works for the unrolled data set (one read per ZMW)
      # if (length(cd$hole) = length(unique(cd$hole))) {
      #   cd2Unrolled = cd2 %>% group_by(hole, Condition) %>% mutate(UnrolledTemplateLocation = seq_len(n())) %>% ungroup() %>% mutate(UnrolledTemplateGroup = cut(UnrolledTemplateLocation, breaks = c((seq(0, 1000) * 50), max(UnrolledTemplateLocation)))) %>% group_by(UnrolledTemplateGroup, Condition) %>% summarise(mdPolRate = median(1/(ipd + pw)))
      #   pd <- position_dodge(0.2) # move them .05 to the left and right
      #   tp = ggplot(cd2Unrolled, aes(x = UnrolledTemplateGroup, y = mdPolRate, color = Condition, group = Condition)) + geom_point() + geom_line() +
      #     # geom_errorbar(aes(ymin = mdPolRate - madPolRate, ymax = mdPolRate + madPolRate), width = .1, position = pd) +
      #     plTheme + themeTilt + clScale + labs(x = "Position Bin of Unrolled Template Span", y = "Median Polymerization Rate (50bp bins)")
      #   report$ggsave("localpolrate.png", tp,
      #                 id = "local_polrate",
      #                 title = "Local Polymerization Rate", caption = "Local Polymerization Rate")
      # }
      
      # IPD Plots
      # tp = ggplot(cd2[cd2$ipd < maxIPD,], aes(x = Condition, y = ipd, fill = Condition)) + geom_violin() + geom_boxplot(width = 0.1, fill = "white") +
      #   labs(
      #     y = paste("IPD (Truncated < ", maxIPD, ")", sep = ""),
      #     title = paste("IPD Distribution\n(From ", sampleSize, "Sampled Alignments)")
      #   ) +
      #   plTheme + themeTilt + clFillScale
      # report$ggsave("ipddist.png",
      #               tp,
      #               id = "ipd_violin",
      #               title = "IPD Distribution - Violin Plot",
      #               caption = "IPD Distribution - Violin Plot",
      #               tags = c("sampled", "violin", "ipd"))
      
      # tp = ggplot(cd2[cd2$ipd < maxIPD,], aes(x = Condition, y = ipd, fill = Condition)) + geom_violin() + geom_boxplot(width = 0.1, fill = "white") +
      #   labs(
      #     y = paste("IPD (Truncated < ", maxIPD, ")", sep = ""),
      #     title = paste("IPD Distribution\n(From ", sampleSize, "Sampled Alignments)")
      #   ) +
      #   plTheme + themeTilt + clFillScale + facet_wrap( ~ ref)
      # report$ggsave(
      #   "ipddistbybase_violin.png",
      #   tp,
      #   id = "ipd_violin_by_base",
      #   title = "IPD Distribution by Ref Base - Violin Plot",
      #   caption = "IPD Distribution by Ref Base - Violin Plot",
      #   tags = c("sampled", "violin", "ipd")
      # )
      
      tp = ggplot(cd2[cd2$ipd < maxIPD,], aes(x = Condition, y = ipd, fill = Condition)) + geom_boxplot() + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) +
        labs(
          y = paste("IPD (Truncated < ", maxIPD, ")", sep = ""),
          title = paste("IPD Distribution\n(From ", sampleSize, "Sampled Alignments)")
        ) +
        plTheme + themeTilt + clFillScale + facet_wrap( ~ ref, nrow = length(levels(cd2$ref)))
      report$ggsave(
        "ipddistbybase_boxplot.png",
        tp,
        width = plotwidth,
        height = img_height,
        id = "ipd_boxplot_by_base",
        title = "IPD Distribution by Ref Base - Boxplot",
        caption = "IPD Distribution by Ref Base - Boxplot",
        tags = c("sampled", "boxplot", "ipd")
      )
      
      # PW Plots
      cd2$Insertion = cd2$ref == "-"
      # tp = ggplot(cd2[cd2$pw < maxPW,], aes(x = Condition, y = pw, fill = Insertion)) + geom_violin() +
      #   labs(
      #     y = paste("PW (Truncated < ", maxPW, ")", sep = ""),
      #     title = paste("PW Distribution\n(From ", sampleSize, "Sampled Alignments)")
      #   ) +
      #   stat_summary(
      #     fun.y = median,
      #     colour = "black",
      #     geom = "text",
      #     show.legend = FALSE,
      #     vjust = -0.8,
      #     aes(label = round(..y.., digits = 3))
      #   ) +
      #   plTheme + themeTilt + clFillScale
      # report$ggsave(
      #   "pw_violin.png",
      #   tp,
      #   id = "pw_violin",
      #   title = "PW Distribution - Violin Plot",
      #   caption = "PW Distribution - Violin Plot",
      #   tags = c("sampled", "violin", "pw")
      # )
      
      tp <- ggplot(data = cd2[cd2$pw < maxPW,], aes(x = Condition, y = pw, fill = Insertion)) +
        geom_boxplot(position = position_dodge(width = 0.9)) 
      a <- aggregate(pw ~ Condition + Insertion, cd2[cd2$pw < maxPW,], function(i) round(median(i), digits = 4))
      tp2 <- tp +  geom_text(data = a, aes(label = pw), 
                             position = position_dodge(width = 0.9), vjust = -0.8) +
        labs(
          y = paste("PW (Truncated < ", maxPW, ")", sep = ""),
          title = paste("PW Distribution\n(From ", sampleSize, "Sampled Alignments)")
        ) +
        plTheme + themeTilt + clFillScale
      report$ggsave(
        "pw_boxplot.png",
        tp2,
        width = plotwidth,
        height = plotheight,
        id = "pw_boxplot",
        title = "PW Distribution - Boxplot",
        caption = "PW Distribution - Boxplot",
        tags = c("sampled", "boxplot", "pw")
      )
      
      tp3 = tp + facet_wrap( ~ ref, nrow = length(levels(cd2[cd2$pw < maxPW,]$ref)))
      
      b <- aggregate(pw ~ Condition + ref + Insertion, cd2[cd2$pw < maxPW,], function(i) round(median(i), digits = 4))
      tp4 <- tp3 +  geom_text(data = b, aes(label = pw), 
                              position = position_dodge(width = 0.9), vjust = -0.8) +
        labs(
          y = paste("PW (Truncated < ", maxPW, ")", sep = ""),
          title = paste("PW Distribution (with Median)\n(From ", sampleSize, "Sampled Alignments)")
        ) +
        plTheme + themeTilt + clFillScale
      
      report$ggsave(
        "median_pw_boxplot_by_base.png",
        tp4,
        width = plotwidth,
        height = img_height,
        id = "median_pw_boxplot_by_base",
        title = "Median PW Distribution By Base",
        caption = "Median PW Distribution",
        tags = c("sampled", "pw", "boxplot", "median")
      )
      
      c <- aggregate(pw ~ Condition + ref + Insertion, cd2[cd2$pw < maxPW,], function(i) round(mean(i), digits = 4))
      tp5 <- tp3 +  geom_text(data = c, aes(label = pw), 
                              position = position_dodge(width = 0.9), vjust = -0.8) +
        labs(
          y = paste("PW (Truncated < ", maxPW, ")", sep = ""),
          title = paste("PW Distribution (with Mean)\n(From ", sampleSize, "Sampled Alignments)")
        ) +
        plTheme + themeTilt + clFillScale
      
      report$ggsave(
        "mean_pw_boxplot_by_base.png",
        tp5,
        width = plotwidth,
        height = img_height,
        id = "mean_pw_boxplot_by_base",
        title = "Mean PW Distribution By Base",
        caption = "Mean PW Distribution",
        tags = c("sampled", "pw", "boxplot", "mean")
      )
      
      # Make a median PW plot
      summaries = cd2[cd2$ipd < maxIPD,] %>% group_by(Condition, ref) %>% summarise(PW.Median = median(pw), IPD.Median = median(ipd)) %>% ungroup()
      
      report$write.table("medianIPD.csv",
                         data.frame(summaries),
                         id = "medianIPD",
                         title = "Median IPD/PW Values by Reference")
      
      # Duty Cycle plot
      tp = ggplot(cd3, aes(x = Condition, y = DutyCycle, fill = Condition)) + geom_boxplot() + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) +
        labs(
          y = "median(PW)/(median(PW) + median(IPD))",
          title = paste("Duty Cycle\n(From ", sampleSize, "Sampled Alignments)")
        ) + plTheme + themeTilt + clFillScale
      report$ggsave(
        "dutycycle_boxplot.png",
        tp,
        width = plotwidth,
        height = plotheight,
        id = "dutycycle_boxplot",
        title = "Duty Cycle - Boxplot",
        caption = "Duty Cycle - Boxplot",
        tags = c("sampled", "boxplot", "duty cycle")
      )
      
      # Local PolRate plot
      tp = ggplot(cd3, aes(x = Condition, y = 1 / DC, fill = Condition)) + geom_boxplot() + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) +
        labs(
          y = "1/(median(PW) + median(IPD))",
          title = paste(
            "Local Ploymerization Rate\n(From ",
            sampleSize,
            "Sampled Alignments)"
          )
        ) + plTheme + themeTilt + clFillScale
      report$ggsave(
        "localpolrate_boxplot.png",
        tp,
        width = plotwidth,
        height = plotheight,
        id = "localpolrate_boxplot",
        title = "Local PolRate - Boxplot",
        caption = "Local PolRate - Boxplot",
        tags = c("sampled", "boxplot", "polrate")
      )
      
      # Now mismatch insertions
      errorRates = cd2[cd2$read != "-",] %>%
        group_by(Condition, snrCfac, read) %>%
        summarise(correct = sum(read == ref),
                  incorrect = sum(read != ref)) %>%
        mutate(erate = incorrect / (correct + incorrect)) %>%
        ungroup()
      
      img_height = min(49.5, 3 * length(levels(errorRates$read)))
      
      tp = ggplot(errorRates,
                  aes(
                    x = snrCfac,
                    y = erate,
                    color = Condition,
                    group = Condition
                  )) + geom_point() +
        geom_line()  + clScale + plTheme + themeTilt + labs(y = "Error Rate (per called BP)\nFrom Sampled Alignments",
                                                            x = "SNR C Bin",
                                                            title = "Error Rates By Called Base") + facet_wrap(~read, nrow = length(levels(errorRates$read)))
      report$ggsave(
        "bperr_rate_by_snr.png",
        tp,
        width = plotwidth,
        height = img_height,
        id = "bp_err_rate_by_snr",
        title = "BP Error Rates by SNR",
        caption = "BP Error Rates by SNR",
        tags = c("sampled", "error rate", "base")
      )
      
      # Now for mismatch rates
      mmRates = cd2[cd2$read != "-" & cd2$ref != "-",] %>%
        group_by(Condition, snrCfac, ref) %>%
        summarise(correct = sum(read == ref),
                  incorrect = sum(read != ref)) %>%
        mutate(erate = incorrect / (correct + incorrect)) %>%
        ungroup()
      
      img_height = min(49.5, 3 * length(levels(mmRates$ref)))
      
      tp = ggplot(mmRates,
                  aes(
                    x = snrCfac,
                    y = erate,
                    color = Condition,
                    group = Condition
                  )) + geom_point() +
        geom_line()  + clScale + plTheme + themeTilt + labs(y = "Mismatch Rate (per ref BP)\nFrom Sampled Alignments",
                                                            x = "SNR C Bin",
                                                            title = "Mismatch Rates By Template Base") + facet_wrap(~ ref, nrow = length(levels(mmRates$ref)))
      report$ggsave(
        "bpmm_rate_by_snr.png",
        tp,
        width = plotwidth,
        height = img_height,
        id = "bp_mm_err_rate_by_snr",
        title = "Mismatch Rates by SNR",
        caption = "Mismatch Rates by SNR",
        tags = c("sampled", "mismatch", "error rate")
      )
      
      # Table of the polymerization rate
      
      pr <- aggregate(DC ~ ref + Condition, cd2, median)
      pr.rs <-
        reshape(pr,
                idvar = 'Condition',
                timevar = 'ref',
                direction = 'wide')
      report$write.table("medianPolymerizationRate.csv",
                         pr.rs,
                         id = "medianPolymerizationRate",
                         title = "Median Polymerization Rate")
    } else {
     warning("ipd or pw information not available!") 
     0
    }
  }


makeErrorsBySNRPlots <- function(report, cd, conLevel = 0.95) {
  # Rearrange the data into SNR bins and get summaries
  CI = conLevel / 2 + 0.5
  cd$alnLength = as.numeric(cd$tend - cd$tstart)
  cd2 = cd %>% dplyr::mutate(snrCfac = cut(snrC, breaks = c(0, seq(3, 20), 50))) %>%
    dplyr::mutate(
      mmrate = mismatches / alnLength,
      insrate = inserts / alnLength,
      delrate = dels / alnLength,
      acc = 1 - (mismatches + inserts + dels) / alnLength
    ) %>%
    dplyr::group_by(Condition, snrCfac) %>%
    dplyr::summarise(
      mmratemean = mean(mmrate),
      mmrateci = sd(mmrate) / sqrt(n()) * qt(CI, n() - 1),
      insratemean = mean(insrate),
      insrateci = sd(insrate) / sqrt(n()) * qt(CI, n() - 1),
      delratemean = mean(delrate),
      delrateci = sd(delrate) / sqrt(n()) * qt(CI, n() - 1),
      accmean = mean(acc),
      accci = sd(acc) / sqrt(n()) * qt(CI, n() - 1),
      insdelratmean = sum(inserts) / sum(dels),
      insdelratci = sqrt(1 / (mean(insrate) ^ 2) * ((mean(delrate) / mean(insrate)) ^
                                                      2 * sd(insrate) ^ 2
                                                    + sd(delrate) ^ 2 - 2 * mean(delrate) /
                                                      mean(insrate)
                                                    * cov(insrate, delrate)
      )) / n() * qt(CI, n() - 1)
    ) %>%
    dplyr::ungroup()
  
  # Add error bars
  # The errorbars overlapped, so use position_dodge to move them horizontally
  pd <- position_dodge(0.2) # move them .05 to the left and right
  
  tp = ggplot(cd2,
              aes(
                x = snrCfac,
                y = accmean,
                color = Condition,
                group = Condition
              )) + geom_point() + geom_line() +
    geom_errorbar(
      aes(ymin = accmean - accci, ymax = accmean + accci),
      width = .1,
      position = pd
    ) +
    plTheme + themeTilt + clScale + labs(x = "SNR C Bin", y = "Accuracy (1 - errors per template pos)")
  report$ggsave(
    "snrvsacc.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "snr_vs_acc",
    title = "SNR vs Accuracy",
    caption = "SNR vs. Accuracy",
    tags = c("sampled", "snr", "accuracy")
  )
  
  tp = ggplot(cd2,
              aes(
                x = snrCfac,
                y = insratemean,
                color = Condition,
                group = Condition
              )) + geom_point() + geom_line() +
    geom_errorbar(
      aes(ymin = insratemean - insrateci, ymax = insratemean + insrateci),
      width = .1,
      position = pd
    ) +
    plTheme + themeTilt + clScale + labs(x = "SNR C Bin", y = "Insertion Rate")
  report$ggsave(
    "snrvsinsertion.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "snr_vs_ins",
    title = "SNR vs Insertion Rate",
    caption = "SNR vs. Insertion Rate",
    tags = c("sampled", "snr", "insertion")
  )
  
  tp = ggplot(cd2,
              aes(
                x = snrCfac,
                y = delratemean,
                color = Condition,
                group = Condition
              )) + geom_point() + geom_line() +
    geom_errorbar(
      aes(ymin = delratemean - delrateci, ymax = delratemean + delrateci),
      width = .1,
      position = pd
    ) +
    plTheme + themeTilt + clScale + labs(x = "SNR C Bin", y = "Deletion Rate")
  report$ggsave(
    "snrvsdeletion.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "snr_vs_del",
    title = "SNR vs Deletion Rate",
    caption = "SNR vs. Deletion Rate",
    tags = c("sampled", "snr", "deletion")
  )
  
  tp = ggplot(cd2,
              aes(
                x = snrCfac,
                y = mmratemean,
                color = Condition,
                group = Condition
              )) + geom_point() + geom_line() +
    geom_errorbar(
      aes(ymin = mmratemean - mmrateci, ymax = mmratemean + mmrateci),
      width = .1,
      position = pd
    ) +
    plTheme + themeTilt + clScale + labs(x = "SNR C Bin", y = "Mismatch Rate")
  report$ggsave(
    "snrvsmismatch.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "snr_vs_mm",
    title = "SNR vs Mismatch Rate",
    caption = "SNR vs. Mismatch Rate",
    tags = c("sampled", "snr", "mismatch")
  )
  
  tp = ggplot(cd2,
              aes(
                x = snrCfac,
                y = insdelratmean,
                color = Condition,
                group = Condition
              )) + geom_point() + geom_line() +
    geom_errorbar(
      aes(ymin = insdelratmean - insdelratci, ymax = insdelratmean + insdelratci),
      width = .1,
      position = pd
    ) +
    plTheme + themeTilt + clScale + labs(x = "SNR C Bin", y = "Insertion Rate / Deletion Rate")
  report$ggsave(
    "snrvsindelrat.png",
    tp,
    width = plotwidth,
    height = plotheight,
    id = "snr_vs_indel_rat",
    title = "SNR vs Relative Indels",
    caption = "SNR vs. Indel Rate / Deletion Rate",
    tags = c("sampled", "snr", "deletion")
  )
}

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {

  # Let's load all the conditions with SNR data
  conditions = report$condition.table
  p_Var = variableNames(conditions)
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
    
    # Now combine into one large data frame
    ##browser()
    cd = combineConditions(dfs, as.character(conditions$Condition))
    
    # Add p_ columns if any exists
    if (length(p_Var) > 0) {
      cd = merge(cd, conditions[,c("Condition", p_Var)], by = "Condition")
    }
    cd$tlen = as.numeric(cd$tend - cd$tstart)
    cd$alen = as.numeric(cd$aend - cd$astart)
    cd$errors = as.numeric(cd$mismatches + cd$inserts + cd$dels)
    cd$Accuracy = 1 - cd$errors / cd$tlen
    cd$mmrate = cd$mismatches / cd$tlen
    cd$irate  = cd$inserts / cd$tlen
    cd$drate  = cd$dels / cd$tlen
    cd$qrlen = as.numeric(cd$qend - cd$qstart)
    
    ## Let's set the graphic defaults
    n = length(levels(conditions$Condition))
    clFillScale <<- getPBFillScale(n)
    clScale <<- getPBColorScale(n)
    # Subsample cd to get a smaller data frame, load SNR values for this dataframe
    cd = loadSNRforSubset(cd)
    cd = as.data.table(cd)
    
    # Let's look at SNR distributions
    logging::loginfo("Making SNR Distribution Plots")
    snrs = cd[, .(Condition, hole, snrA, snrC, snrG, snrT)]
    colnames(snrs) = sub("snr", "", colnames(snrs))
    snrs = snrs %>% gather(channel, SNR, A, C, G, T)
    
    img_height = min(49.5, 3 * length(levels(as.factor(snrs$channel))))
    
    # tp = ggplot(snrs, aes(x = Condition, y = SNR, fill = Condition)) + geom_violin() +
    #   geom_boxplot(width = 0.1, fill = "white") + plTheme + themeTilt  + clFillScale +
    #   facet_wrap(~ channel)
    # report$ggsave(
    #   "snrViolin.png",
    #   tp,
    #   id = "snr_violin",
    #   title = "SNR Violin Plot",
    #   caption = "Distribution of SNR in Aligned Files (Violin plot)",
    #   tags = c("sampled", "snr", "violin")
    # )
    
    tp = ggplot(snrs, aes(x = SNR, colour = Condition)) + geom_density(alpha = .5) +
      plTheme + themeTilt  + clScale + facet_wrap(~ channel, nrow = length(levels(as.factor(snrs$channel)))) +
      labs(x = "SNR", title = "Distribution of SNR in Aligned Files (Density plot)")
    report$ggsave(
      "snrDensity.png",
      tp,
      width = plotwidth,
      height = img_height,
      id = "snr_density",
      title = "SNR Density Plot",
      caption = "Distribution of SNR in Aligned Files (Density plot)",
      tags = c("sampled", "snr", "density")
    )
    
    tp = ggplot(snrs, aes(x = Condition, y = SNR, fill = Condition)) +
      geom_boxplot() + stat_summary(
        fun.y = median,
        colour = "black",
        geom = "text",
        show.legend = FALSE,
        vjust = -0.8,
        aes(label = round(..y.., digits = 4))
      ) + plTheme + themeTilt  + clFillScale +
      facet_wrap( ~ channel, nrow = length(levels(as.factor(snrs$channel))))
    report$ggsave(
      "snrBoxNoViolin.png",
      tp,
      width = plotwidth,
      height = img_height,
      id = "snr_boxplot",
      title = "SNR Box Plot",
      caption = "Distribution of SNR in Aligned Files (Boxplot)",
      tags = c("sampled", "snr", "boxplot")
    )
    
    snrs = NULL # make available for GC
    tp = NULL
    
    # Make p_variavle plots
    if (length(p_Var) > 0) {
      makepColPlots(report,cd,p_Var, conditions)
      
      # When there are two p_columns and both of them are numerical or categorical
      # Switch the p_columns and generate the p_ variables plots again
      if (length(p_Var) == 2) {
        if (is.numeric(conditions[, match(p_Var[1], names(conditions))]) == is.numeric(conditions[, match(p_Var[2], names(conditions))])) {
          p_Var = c(p_Var[2], p_Var[1])
          makepColPlots(report,cd,p_Var, conditions)
        }
      }
    }
    
    # Get Errors by SNR plot
    makeErrorsBySNRPlots(report, cd)
    
    # Now plots from sampling alignments
    makeSamplingPlots(report, cd, conditions, sampleSize = 1000)
    
    # Make a median SNR table
    summaries = cd[, .(
      A.Median = median(snrA),
      C.Median = median(snrC),
      G.Median = median(snrG),
      T.Median = median(snrT)
    ),  by = Condition]
    report$write.table("medianSNR.csv",
                       summaries,
                       id = "medianSNR",
                       title = "Median SNR values")
  }
  
  # Save the report object for later debugging
  save(report, file = file.path(report$outputDir, "report.Rd"))
  
  # Output error rates by SNR
  loginfo("Examining error rates by SNR Bin")
  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}

main <- function()
{
    report <- bh2Reporter(
        "condition-table.csv",
        "reports/PbiSampledPlots/report.json",
        "Sampled ZMW metrics")
    makeReport(report)
    0
}

## Leave this as the last line in the file.
logging::basicConfig()
main()
