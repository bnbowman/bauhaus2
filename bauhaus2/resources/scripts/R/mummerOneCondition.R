library(gridExtra)
library(ggplot2)

fileName <- 'fastalengthfile.txt'
string1 = readChar(fileName, file.info(fileName)$size)
png("myoutput.png", width=4, height=4, units="in", res=300)
plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
text(x = 0.34, y = 0.34, paste(string1), 
     cex = 0.6, col = "black", family="serif", font=1)
dev.off()




