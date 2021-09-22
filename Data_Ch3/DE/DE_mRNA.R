library(limma)
library(matrixStats)
library(splines)
library(prcomp)

############# with repeats
read.csv("~/Documents/Chondrogenesis/Normalised2/mRNA/mRNA_normalised.csv", 
         row.names = 1) -> X
X[- grep("HS.", rownames(X)),] -> X1
X1[- grep("LOC", rownames(X1)),] -> X2
X2[- grep("FLJ", rownames(X2)),] -> X3
X3 -> X

lev <- c(rep(c("D0", "D14"), each =3), "D0", "D1", "D3", "D6", "D10", "D14")
colnames(X) <- lev
pca <- prcomp(t(X), scale=T)
plot(pca$x, type="n", main = "mRNAs - PCA of chondrogenesis dataset")
colour = c(rep(c("red", "violet"), each =3), "red", "sky blue", "green", "pink",
           "orange", "violet")
text(pca$x, rownames(pca$x), cex=1, labels=lev, col = colour)

boxplot(X, las =3, par(mar = c(5.2, 4.7, 2, 1)+ 0.1), 
        col = c(rep("red", 3), rep("violet", 3), 
                rep("red", 1), rep("sky blue", 1),
                rep("green", 1), rep("pink", 1),
                rep("orange", 1), rep("violet", 1)),
        main = "mRNA - Normalised Boxplot", 
        ylab = "Expression Levels", xlab = "Samples", cex.axis = 0.6)

U <- unique(lev)
f <- factor(lev, U)
model.matrix(~0+f) -> MM
rownames(MM) <- colnames(X)
colnames(MM) <- U
fit <- lmFit(X, MM)

T01 <- makeContrasts(D1=(D1-D0),
                     levels = MM)
T01_F <- contrasts.fit(fit, T01)
T01_E <- eBayes(T01_F)
T01_R <- topTable(T01_E, adjust.method = "BH", n=Inf)

T03 <- makeContrasts(D3=(D3-D0),
                     levels = MM)
T03_F <- contrasts.fit(fit, T03)
T03_E <- eBayes(T03_F)
T03_R <- topTable(T03_E, adjust.method = "BH", n=Inf)

T06 <- makeContrasts(D6=(D6-D0),
                     levels = MM)
T06_F <- contrasts.fit(fit, T06)
T06_E <- eBayes(T06_F)
T06_R <- topTable(T06_E, adjust.method = "BH", n=Inf)

T010 <- makeContrasts(D10=(D10-D0),
                     levels = MM)
T010_F <- contrasts.fit(fit, T010)
T010_E <- eBayes(T010_F)
T010_R <- topTable(T010_E, adjust.method = "BH", n=Inf)

T014 <- makeContrasts(D14=(D14-D0),
                      levels = MM)
T014_F <- contrasts.fit(fit, T014)
T014_E <- eBayes(T014_F)
T014_R <- topTable(T014_E, adjust.method = "BH", n=Inf)

################
#volcano plots
require(ggplot2)
library(ggrepel)
setwd("~/Documents/Chondrogenesis/plots_thesis/")

# add a column of NAs
Volc <- function(X, fileString, titleString){
    X$diffexpressed <- "NO"
    X$diffexpressed[X$logFC > 2 & X$adj.P.Val < 0.00001] <- "UP"
    X$diffexpressed[X$logFC < -2 & X$adj.P.Val < 0.00001] <- "DOWN"
    X$delabel <- NA
    X$delabel[X$diffexpressed != "NO"] <- rownames(X)[X$diffexpressed != "NO"] 
    jpeg(filename = paste0(fileString, ".jpg"), width = 6, height = 5, units = "in", res = 300)
    p <- ggplot(data=X, aes(x=logFC, y=-log10(adj.P.Val), 
                           col=diffexpressed, label=delabel)) +
        geom_point() + 
        theme_bw() +
        labs(title = titleString, x = "Log2FC", y = "-log10(Adjusted P Values)")+
        geom_text_repel() +
        scale_color_manual(values=c("blue", "black", "red"))
        show(p)
        dev.off()
}

Volc(X = T01_R, fileString = "mRNA_D1_volcano", titleString = "mRNA_D1")
Volc(X = T03_R, fileString = "mRNA_D3_volcano", titleString = "mRNA_D3")
Volc(X = T06_R, fileString = "mRNA_D6_volcano", titleString = "mRNA_D6")
Volc(X = T010_R, fileString = "mRNA_D10_volcano", titleString = "mRNA_D10")
Volc(X = T014_R, fileString = "mRNA_D14_volcano", titleString = "mRNA_D14")

##################
#process for TimiRGeN
T01_R[which(T01_R$adj.P.Val < 0.05),] -> P1
T03_R[which(T03_R$adj.P.Val < 0.05),] -> P3
T06_R[which(T06_R$adj.P.Val < 0.05),] -> P6
T010_R[which(T010_R$adj.P.Val < 0.05),] -> P10
T014_R[which(T014_R$adj.P.Val < 0.05),] -> P14

P1$newcol <- rownames(P1)
P3$newcol <- rownames(P3)
P6$newcol <- rownames(P6)
P10$newcol <- rownames(P10)
P14$newcol <- rownames(P14)

rbind(P1, P3, P6, P10, P14)-> Ps
Ps[! duplicated(Ps$newcol),] -> Us

T01_R[which(rownames(T01_R) %in% rownames(Us) == T),] -> S1
T03_R[which(rownames(T03_R) %in% rownames(Us) == T),] -> S3
T06_R[which(rownames(T06_R) %in% rownames(Us) == T),] -> S6
T010_R[which(rownames(T010_R) %in% rownames(Us) == T),] -> S10
T014_R[which(rownames(T014_R) %in% rownames(Us) == T),] -> S14

O1 <- S1[order(rownames(S1)),]
O3 <- S3[order(rownames(S3)),]
O6 <- S6[order(rownames(S6)),]
O10 <-S10[order(rownames(S10)),]
O14 <- S14[order(rownames(S14)),]

colnames(O1)[1] <- "D1.log2fc"
colnames(O3)[1] <- "D3.log2fc"
colnames(O6)[1] <- "D6.log2fc"
colnames(O10)[1] <- "D10.log2fc"
colnames(O14)[1] <- "D14.log2fc"

colnames(O1)[2] <- "D1.AveExp"
colnames(O3)[2] <- "D3.AveExp"
colnames(O6)[2] <- "D6.AveExp"
colnames(O10)[2] <- "D10.AveExp"
colnames(O14)[2] <- "D14.AveExp"

colnames(O1)[5] <- "D1.adjPval"
colnames(O3)[5] <- "D3.adjPval"
colnames(O6)[5] <- "D6.adjPval"
colnames(O10)[5] <- "D10.adjPval"
colnames(O14)[5] <- "D14.adjPval"

cbind(O1, O3, O6, O10, O14) -> L
X -> mRNA
colnames(L)
L[,-c(2, 3, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24, 26, 27, 28, 30)] -> lx
colnames(lx)
colnames(mRNA)
mRNA <- mRNA[order(rownames(mRNA)),]
mRNA[which(rownames(mRNA) %in% rownames(lx) == TRUE),] -> tmRNA
omRNA <- tmRNA[order(rownames(tmRNA)),]
lx$D1.AveExp <- rowMeans(omRNA[8])
lx$D3.AveExp <- rowMeans(omRNA[9])
lx$D6.AveExp <- rowMeans(omRNA[10])
lx$D10.AveExp <- rowMeans(omRNA[11])
lx$D14.AveExp <- rowMeans(omRNA[c(4:6, 12)])

setwd("~/Documents/Chondrogenesis/Normalised2/mRNA/")

write.table(lx, "mRNA_DE.txt", quote = F, sep = "\t")
