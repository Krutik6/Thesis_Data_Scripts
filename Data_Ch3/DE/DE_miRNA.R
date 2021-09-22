library(limma)
library(matrixStats)
setwd("~/Documents/Chondrogenesis/Normalised/")
read.csv("miRNA_normalised_cy5.csv", row.names = 1) -> miR

par(oma = c(0.5, 0.5, 0, 0))
par(mgp = c(4, 1, 0))
boxplot(miR, las =3, par(mar = c(5.2, 4.7, 2, 1)+ 0.1), 
        col = c(rep("red", 2), rep("sky blue", 2), 
                rep("green", 2), rep("pink", 2),
                rep("orange", 2),rep("violet", 2)),
        main = "miRNA - Normalised Boxplot", 
        ylab = "Expression Levels", xlab = "Samples", cex.axis = 0.6)


Lev <- c(rep(c("D0", "D1", "D3", "D6", "D10", "D14"), each=2))
colnames(miR) <- Lev
colour = c(rep("red", 2), rep("sky blue", 2), 
        rep("green", 2), rep("pink", 2),
        rep("orange", 2),rep("violet", 2))
pca <- prcomp(t(miR), scale=T)
plot(pca$x, type="n", main = "miRNAs - PCA of chondrogenesis dataset")
text(pca$x, rownames(pca$x), cex=1, labels=Time, col = colour)



U <- unique(Lev)
f <- factor(Lev, levels = U)
DM <- model.matrix(~0+f)
rownames(DM) <- colnames(miR)
colnames(DM) <- U
fit <- lmFit(miR, DM)

T01 <- makeContrasts(Log2FC=(D1-D0),
                     levels = DM)
T01_F <- contrasts.fit(fit, T01)
T01_E <- eBayes(T01_F)
T01_R <- topTable(T01_E, adjust.method = "BH", n=Inf)

T03 <- makeContrasts(Log2FC=(D3-D0),
                     levels = DM)
T03_F <- contrasts.fit(fit, T03)
T03_E <- eBayes(T03_F)
T03_R <- topTable(T03_E, adjust.method = "BH", n=Inf)

T06 <- makeContrasts(Log2FC=(D6-D0),
                     levels = DM)
T06_F <- contrasts.fit(fit, T06)
T06_E <- eBayes(T06_F)
T06_R <- topTable(T06_E, adjust.method = "BH", n=Inf)

T010 <- makeContrasts(Log2FC=(D10-D0),
                      levels = DM)
T010_F <- contrasts.fit(fit, T010)
T010_E <- eBayes(T010_F)
T010_R <- topTable(T010_E, adjust.method = "BH", n=Inf)

T014 <- makeContrasts(Log2FC=(D14-D0),
                      levels = DM)
T014_F <- contrasts.fit(fit, T014)
T014_E <- eBayes(T014_F)
T014_R <- topTable(T014_E, adjust.method = "BH", n=Inf)
setwd("~/Documents/Chondrogenesis/plots_thesis/")
T01_R[which(T01_R$adj.P.Val < 0.05),] -> P1
T03_R[which(T03_R$adj.P.Val < 0.05),] -> P3
T06_R[which(T06_R$adj.P.Val < 0.05),] -> P6
T010_R[which(T010_R$adj.P.Val < 0.05),] -> P10
T014_R[which(T014_R$adj.P.Val < 0.05),] -> P14
#################
#Volcano
Volc <- function(X, fileString, titleString){
    X$diffexpressed <- "NO"
    X$diffexpressed[X$logFC > 0.5 & X$adj.P.Val < 0.001] <- "UP"
    X$diffexpressed[X$logFC < -0.5 & X$adj.P.Val < 0.001] <- "DOWN"
    X$delabel <- NA
    X$delabel[X$diffexpressed != "NO"] <- rownames(X)[X$diffexpressed != "NO"] 
    jpeg(filename = paste0(fileString, ".jpg"), width = 5, height = 4, 
         units = "in", res = 300)
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


Volc(X = T01_R, fileString = "miRNA_D1_volcano", titleString = "miRNA_D1")
Volc(X = T03_R, fileString = "miRNA_D3_volcano", titleString = "miRNA_D3")
Volc(X = T06_R, fileString = "miRNA_D6_volcano", titleString = "miRNA_D6")
Volc(X = T010_R, fileString = "miRNA_D10_volcano", titleString = "miRNA_D10")
Volc(X = T014_R, fileString = "miRNA_D14_volcano", titleString = "miRNA_D14")

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
#AveExp is incorrect - takes all data into account 
#colnames(O1)[2] <- "D1.AveExp"
#colnames(O3)[2] <- "D3.AveExp"
#colnames(O6)[2] <- "D6.AveExp"
#colnames(O10)[2] <- "D10.AveExp"
#colnames(O14)[2] <- "D14.AveExp"

colnames(O1)[5] <- "D1.adjPval"
colnames(O3)[5] <- "D3.adjPval"
colnames(O6)[5] <- "D6.adjPval"
colnames(O10)[5] <- "D10.adjPval"
colnames(O14)[5] <- "D14.adjPval"

cbind(O1, O3, O6, O10, O14) -> L

colnames(L)
L[,-c(2,3, 4, 7,8, 9, 12, 13, 14, 17, 18, 19, 22, 23, 24)] -> lx
colnames(lx)
#L[,c(1,2,5,6,7,10,11,12,15,16,17,20,21,22,25)] -> lo

colnames(miR)
miR <- miR[order(rownames(miR)),]
miR[which(rownames(miR) %in% rownames(lx) == TRUE),] -> tmiR
omiR <- tmiR[order(rownames(tmiR)),]
lx$D1.AveExp <- rowMeans(omiR[3:4])
lx$D3.AveExp <- rowMeans(omiR[5:6])
lx$D6.AveExp <- rowMeans(omiR[7:8])
lx$D10.AveExp <- rowMeans(omiR[9:10])
lx$D14.AveExp <- rowMeans(omiR[11:12])
setwd("~/Documents/Chondrogenesis/DE/")
write.table(lx, "miR_diffexp_data.txt", quote = F, sep = "\t")

#############processed SDEG data
#miR[which(rownames(miR) %in% rownames(lx) == T),] -> xo
#write.table(xo, "SDEG_processed_miRNA.txt", quote = F, sep = "\t")













