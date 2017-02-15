library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR, quietly = TRUE)
library(uuid, quietly = TRUE)
library(gridExtra)
library(dtplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)

# Define a basic addition to all plots
plTheme <- theme_bw(base_size = 14)
clScale <- scale_colour_brewer(palette = "Set1")
clFillScale <- scale_fill_brewer(palette = "Set1")
themeTilt = theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Make fake data - for debugging
condFile = "/pbi/dept/secondary/siv/smrtlink/smrtlink-internal/userdata/jobs-root/000/000318/tasks/pbcommandR.tasks.pbiplot_reseq_condition-0/resolved-tool-contract.json"
condjson = jsonlite::fromJSON(condFile)
input = condjson$resolved_tool_contract$input_files
decoded <- loadReseqConditionsFromPath(input)
conds = decoded@conditions
tmp = lapply(conds, function(z) data.frame(condition = z@condId,subreadset = z@subreadset, alignmentset = z@alignmentset, referenceset = z@referenceset))
conditions = do.call(rbind, tmp)[1:2,]
# end making fake data

# Load the pbi index for each data frame
dfs = lapply(as.character(conditions$alignmentset), function(s) {
  loginfo(paste("Loading alignment set:", s))
  loadPBI(s, loadSNR = TRUE, loadRQ = TRUE)
})
# Now combine into one large data frame
cd = combineConditions(dfs, as.character(conditions$condition))

#detach("package:plyr", unload=TRUE)

# Rearrange the data into SNR bins and get summaries
cd2 = cd %>% dplyr::mutate(snrCfac = cut(snrC, breaks = c(0, seq(3, 20), 50))) %>%
  dplyr::mutate(mmrate = mismatches / (tend - tstart),
                insrate = inserts / (tend - tstart),
                delrate = dels / (tend - tstart),
                acc = 1 - (mismatches + inserts + dels) / (tend - tstart)) %>%
  dplyr::mutate(insdelrat = insrate / delrate) %>%
  dplyr::group_by(Condition, snrCfac) %>%
  dplyr::summarise(
    mmratemean = mean(mmrate),
    mmrateci = sd(mmrate)/sqrt(n()) * qt(0.975, n()-1),
    insratemean = mean(insrate),
    insrateci = sd(insrate)/sqrt(n()) * qt(0.975, n()-1),
    delratemean = mean(delrate),
    delrateci = sd(delrate)/sqrt(n()) * qt(0.975, n()-1),
    accmean = mean(acc),
    accci = sd(acc)/sqrt(n()) * qt(0.975, n()-1),
    insdelratmean = mean(insdelrat[is.finite(insdelrat)]),
    insdelratci = sd(insdelrat[is.finite(insdelrat)])/sqrt(n()) * qt(0.975, n()-1)) %>%
  dplyr::ungroup()

# Add error bars
# The errorbars overlapped, so use position_dodge to move them horizontally
pd <- position_dodge(0.2) # move them .05 to the left and right

tp1 = ggplot(cd2, aes(x = snrCfac, y = accmean, color = Condition, group = Condition)) + geom_point() + geom_line() +
  geom_errorbar(aes(ymin=accmean-accci, ymax=accmean+accci), width=.1, position=pd) +
  plTheme + themeTilt + clScale + labs(x= "SNR C Bin", y ="Accuracy (1 - errors per template pos)")
tp1

tp2 = ggplot(cd2, aes(x = snrCfac, y = insratemean, color = Condition, group = Condition)) + geom_point() + geom_line() +
  geom_errorbar(aes(ymin=insratemean-insrateci, ymax=insratemean+insrateci), width=.1, position=pd) +
  plTheme + themeTilt + clScale + labs(x= "SNR C Bin", y ="Insertion Rate")
tp2

tp3 = ggplot(cd2, aes(x = snrCfac, y = delratemean, color = Condition, group = Condition)) + geom_point() + geom_line() +
  geom_errorbar(aes(ymin=delratemean-delrateci, ymax=delratemean+delrateci), width=.1, position=pd) +
  plTheme + themeTilt + clScale + labs(x= "SNR C Bin", y ="Deletion Rate")
tp3

tp4 = ggplot(cd2, aes(x = snrCfac, y = mmratemean, color = Condition, group = Condition)) + geom_point() + geom_line() +
  geom_errorbar(aes(ymin=mmratemean-mmrateci, ymax=mmratemean+mmrateci), width=.1, position=pd) +
  plTheme + themeTilt + clScale + labs(x= "SNR C Bin", y ="Mismatch Rate")
tp4

tp5 = ggplot(cd2, aes(x = snrCfac, y = insdelratmean, color = Condition, group = Condition)) + geom_point() + geom_line() +
  geom_errorbar(aes(ymin=insdelratmean-insdelratci, ymax=insdelratmean+insdelratci), width=.1, position=pd) +
  plTheme + themeTilt + clScale + labs(x= "SNR C Bin", y ="Insertion Rate / Deletion Rate")
tp5
