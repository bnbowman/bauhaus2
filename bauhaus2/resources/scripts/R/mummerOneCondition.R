library(gridExtra)
library(ggplot2)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("--outDir", nargs = 1, default = "", help = "output directory")
parser$add_argument("--inDir", nargs = 1, default = "", help = "input directory")
try(args <- parser$parse_args())

fileName <- paste(args$inDir,'fastalengthfile.txt', sep = "")
string1 = readChar(fileName, file.info(fileName)$size)
pngpath = paste(args$outDir,"myoutput.png", sep="")
png(pngpath, width=4, height=4, units="in", res=300)
plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
text(x = 0.34, y = 0.34, paste(string1), 
     cex = 0.6, col = "black", family="serif", font=1)
dev.off()




