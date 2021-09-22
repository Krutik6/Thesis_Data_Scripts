library(lumi)
library(lumiHumanAll.db)

setwd("/home/b7053098/Documents/Chondrogenesis/raw/mRNA")

lumiR("MSCchondro_raw_data.txt") -> R
plotCDF(R)
plot(R, what="pair", smoothScatter=T)
plot(R, what="MAplot", smoothScatter=T)
plot(R, what="cv")
plot(R, what="sampleRelation")
plot(R, whaat="sampleRelation", method="mds")
LT <- lumiT(R, method = "vst")
tr <- plotVST(LT)
matplot(log2(tr$untransformed), tr$transformed, type='l',
        main='compare VST and log2 transform',
        xlab='log2 transformed', ylab='vST transformed')
abline(a=0, b=1, col=2)
Nu <- lumiN(LT, method = "rsn")
Q <- lumiQ(Nu)
summary(Q, "QC")
plot(Q, what="density")
plot(Q, what="boxplot")
plot(Q, what="sampleRelation")
plot(Q, what= "pair", smoothScatter=T)
plot(Q, what="MAplot", smoothScatter=T)
dataM <- exprs(Q)
Gnames <- read.csv("~/Documents/Barter data/Chondrocytes/normalised/Gnames.csv")
cbind(dataM, Gnames) -> Y
as.matrix(dataM) -> Z
as.matrix(Y) -> X
library(matrixStats)
rowVars(Z) -> varz
cbind(Z, varz, Gnames) -> vary


mat <- vary[order(vary$varz, decreasing = T),]
mat[! duplicated(mat$ILMN_GENE),] -> keep
rownames(keep) <- keep$ILMN_GENE
keep$ProbeID <- keep$ILMN_GENE <- NULL
keep$varz <- NULL

setwd("~/Documents/Barter data/New_analysis/Normalised/")

write.csv(keep, "mRNA_normalised.csv")
