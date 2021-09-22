library(affy)
library(ExiMiR)

setwd("~/Documents/Chondrogenesis/raw/miRNA/")

make.gal.env(galname = "GalFile.gal", gal.path = getwd())

ebatch <- ReadExi(txtfile.path = getwd(),
                  galname = "GalFile.gal", description = NULL,
                  notes = '', rm.background = F,
                  verbose = T)

X <- rma(ebatch)
as.data.frame(X) -> y
t(y) -> yt

setwd("/home/b7053098/Documents/Chondrogenesis/Normalised2/miRNA")
write.csv(yt, "norm_rma.csv")

library(limma)
setwd("~/Documents/Chondrogenesis/raw/miRNA/")
targets <- readTargets(path = getwd())
RGList <- read.maimages(targets[,c("Cy3", "Cy5")], 
                        source = "imagene", path = getwd())
RGList$genes <- readGAL(path = getwd())
RGList$printer <- getLayout(RGList$genes)
dim(RGList)
colnames(RGList)
show(RGList)

library(ExiMiR)
obatch <- createAB(RGList)
spikein.all <- grep("^spike", featureNames(obatch), value = TRUE)
spikein.subset <- setdiff(spikein.all, "spike_control_f")
eset.spike <- NormiR(obatch, bg.correct=FALSE,
                     normalize.method='spikein',
                     normalize.param=list(probeset.list=spikein.subset),
                     summary.method='medianpolish')
norm <- rma(obatch)
as.data.frame(eset.spike) -> spike
as.data.frame(norm) -> rmanorm
t(rmanorm)-> SP

setwd("/home/b7053098/Documents/Chondrogenesis/Normalised2/miRNA")
write.csv(SP, "non_spiked_miRNA.csv")

read.csv("spiked_miRNA.csv") -> mydata
mydata[-c(1:1219, 2433:2667),] -> M
colnames(M) <- c("gene", "cy3_D0_R1", "cy3_D0_R2", "cy3_D1_R1", "cy3_D1_R2", "cy3_D3_R1", "cy3_D3_R2",
                 "cy3_D6_R1", "cy3_D6_R2", "cy3_D10_R1", "cy3_D10_R2", "cy3_D14_R1", "cy3_D14_R2",
                 "cy5_D0_R1", "cy5_D0_R2", "cy5_D1_R1", "cy5_D1_R2", "cy5_D3_R1", "cy5_D3_R2",
                 "cy5_D6_R1", "cy5_D6_R2", "cy5_D10_R1", "cy5_D10_R2", "cy5_D14_R1", "cy5_D14_R2")
M -> saftey

M$gene<- gsub("[.]", "", M$gene)
M$gene<- gsub("hsalet", "hsa-let-", M$gene)
M$gene<- gsub("hsamiR", "hsa-miR-", M$gene)
M$gene<- gsub("5p", "-5p", M$gene)
M$gene<- gsub("3p", "-3p", M$gene)
M$gene<- gsub("a1", "a-1", M$gene)
M$gene<- gsub("a2", "a-2", M$gene)
M$gene<- gsub("b1", "b-1", M$gene)
M$gene<- gsub("b2", "b-2", M$gene)
as.matrix(M) -> mat
mat[,c(14:25)] -> nums
write.table(nums, "nums_editing.txt", sep = "\t", quote = F)
read.table("nums_editing.txt", header = T) -> X
as.matrix(X) -> X
require(matrixStats)
rowVars(X) -> va
as.data.frame(cbind(mat, va)) -> Vmat
Vord <- Vmat[order(Vmat$va, decreasing = TRUE),]
Vord[! duplicated(Vord$gene),] -> Vdup
rownames(Vdup) <- Vdup$gene
Vdup$gene <- Vdup$va <- NULL

plotMDS(X)
boxplot(X)

#check
mat[,-c(14:25)] -> nums2
rownames(nums2) <- nums2[,1]
nums2[,-c(1)] -> nums2
nums2 <- nums2[!duplicated(rownames(nums2)),]
write.table(nums2, "nums_checking.txt", sep = "\t", quote = F)
read.table("nums_checking.txt", header = T) -> Y
as.matrix(Y) -> Y
plotMDS(Y)
boxplot(Y)

write.csv(Vdup, "miRNA_normalised.csv")
