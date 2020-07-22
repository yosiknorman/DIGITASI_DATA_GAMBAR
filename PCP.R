#!/usr/local/bin/Rscript

library(tesseract)
library(EBImage)
library(raster)
library(maps)

system("curl -O 'http://satelit.bmkg.go.id/IMAGE/HIMA/H08_RP_Indonesia.png'")
system("mv H08_RP_Indonesia.png INPUT.png")
PNG = readImage("INPUT.png")
IN = tesseract::ocr_data("INPUT.png") 
KATA_KATA = IN$word[1:grep(IN$word, pattern = "UTC")]

PNGr = as.raster(PNG)
PNGmat = t(apply(as.matrix(PNGr), 2, FUN = rev))
# WARNA = c("#FF2A55", "#ffff55", "#55ff55", "#7fffff")
# COL_TABLE = table(PNGmat)
# COL_TABLE = rev(sort(COL_TABLE))
# head(COL_TABLE, 100L)
# names(COL_TABLE[c(3, 6, 8, 11)])
matX = matrix(0, nc  = ncol(PNGmat), nr = nrow(PNGmat))
WRN = c("#7FFFFFFF", "#55FF55FF", "#FFFF55FF", "#FF2A55FF")
for(i in 1:length(WRN)){
  matX[PNGmat ==  WRN[i]] = i
}

matX[matX == 0]=NA
dim(matX)
RX = raster((apply(t(matX), 2, FUN = rev)))
extent(RX) = c(90, 150, -20, 20)
load("~/Data_riset/kec2.Rda")
eRX = crop(RX, extent(kec))
crs(eRX) = crs(kec)

png(filename = "OUTPUT.png", height = dim(matX)[2], width = dim(matX)[1])
plot(eRX, col = WRN)
dev.off()
# map("world", add = T)