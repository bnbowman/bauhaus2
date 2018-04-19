library(gridExtra)
library(ggplot2)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("--outDir",
                    nargs = 1,
                    default = "",
                    help = "output directory")
parser$add_argument("--inDir",
                    nargs = 1,
                    default = "",
                    help = "input directory")
parser$add_argument(
  "--conditionname",
  nargs = 1,
  default = "",
  help = "condition name"
)
try(args <- parser$parse_args())

fileName <- paste(args$inDir, 'fastalengthfile.txt', sep = "")
string1 = readChar(fileName, file.info(fileName)$size)
pngpath = paste(args$outDir, args$conditionname, "_myoutput.png", sep =
                  "")
png(
  pngpath,
  width = 4,
  height = 4,
  units = "in",
  res = 300
)
plot(
  c(0, 1),
  c(0, 1),
  ann = F,
  bty = 'n',
  type = 'n',
  xaxt = 'n',
  yaxt = 'n'
)
text(
  x = 0.34,
  y = 0.34,
  paste(string1),
  cex = 0.6,
  col = "black",
  family = "serif",
  font = 1
)
dev.off()

snps <-
  paste(args$inDir, "outputs_", args$conditionname, "/snps.csv", sep = "")
errors <-
  read.table(
    snps,
    skip = 5,
    header = FALSE,
    col.names = c(
      'PosR',
      'Rb',
      'Qb',
      'PosQ',
      'X1',
      'Buff',
      'Dist',
      'X2',
      'CtxR',
      'CtxQ',
      'X3',
      'F1',
      'F2',
      'Ref',
      'Unitig'
    )
  )

errors =
  errors[, !(names(errors) %in% c('X1', 'X2', 'X3'))]
errors$CtxR = as.character(errors$CtxR)
errors$CtxQ = as.character(errors$CtxQ)
errors$Error.Type = ifelse(errors$Rb == '.', 'ins', ifelse(errors$Qb == '.', 'del', 'mis'))

Rval = unlist(lapply(errors$CtxR, function(x) {
  rle(unlist(strsplit(substr(
    x, (nchar(x) - 1) / 2 + 1, nchar(x)
  ), split = '')))[[1]][1] +    rle(rev(unlist(strsplit(
    substr(x, 1, (nchar(x) - 1) / 2 + 1), split = ''
  ))))[[1]][1] - 1
}))
Qval = unlist(lapply(errors$CtxQ, function(x) {
  rle(unlist(strsplit(substr(
    x, (nchar(x) - 1) / 2 + 1, nchar(x)
  ), split = '')))[[1]][1] +    rle(rev(unlist(strsplit(
    substr(x, 1, (nchar(x) - 1) / 2 + 1), split = ''
  ))))[[1]][1] - 1
}))
errors$LenHP = ifelse(errors$Rb ==
                        '.', Qval, Rval)
errors$Base = ifelse(errors$Rb ==
                       '.',
                     as.character(errors$Qb),
                     as.character(errors$Rb))
errors$Homopolymer =
  ifelse(errors$LenHP > 1, 'yes', 'no')

numE <-
  errors %>% dplyr::group_by(Error.Type, Base) %>% dplyr::count(Homopolymer)  ##Not sure what this does
######## graph1
pngpath = paste(args$outDir,
                args$conditionname,
                "_residual_error_1.png",
                sep = "")
png(
  pngpath,
  width = 4,
  height = 4,
  units = "in",
  res = 300
)
g <- ggplot(errors, aes(Homopolymer))
g + geom_bar(aes(fill = Base)) + facet_grid(. ~ Error.Type) + ggtitle("Residual Errors by Error Type")
dev.off()
########### graph2
pngpath = paste(args$outDir,
                args$conditionname,
                "_residual_error_2.png",
                sep = "")
png(
  pngpath,
  width = 4,
  height = 4,
  units = "in",
  res = 300
)
qplot(
  data = subset(errors, Homopolymer == "yes"),
  x = LenHP,
  geom = "bar",
  xlim = c(0, 10)
) + facet_grid(. ~ Error.Type)
dev.off()
