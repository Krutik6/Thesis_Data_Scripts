# Load libraries. Using TimiRGeN v1.0.4 (BioManager 3.12).
setwd("/home/b7053098/Documents/Chondrogenesis/TimiRGeN")
library(TimiRGeN)
library(org.Hs.eg.db)
# Load data
miR <- read.table("miRNA.txt", header = TRUE, sep = ',', row.names = 1)
mRNA <- read.table("mRNA.txt", header = TRUE, sep = ',', row.names = 1)
# Create MAE, filter for significance per time point and separate data 
# into nested dataframes by time point. Using combined analysis.
MAE <- startObject(miR = miR, mRNA = mRNA)
MAE <- getIdsMir(MAE = MAE, miR = assay(MAE, 1), orgDB = org.Hs.eg.db, 
                 miRPrefix = "hsa")
MAE <- getIdsMrna(MAE = MAE, mRNA = assay(MAE, 2), mirror = 'www', 
                  species = "hsapiens")
MAE <- combineGenes(MAE = MAE, miR_data = assay(MAE, 1), 
                    mRNA_data = assay(MAE, 2))
MAE <- genesList(MAE = MAE, method = 'c',
                 genetic_data = assay(MAE, 9),
                 timeString = "D")
MAE <- significantVals(MAE = MAE, method = 'c',
                       geneList =metadata(MAE)[[1]],
                       maxVal = 0.05, stringVal = "adjPval")
MAE <- addIds(MAE = MAE, method = 'c',
              filtered_genelist = metadata(MAE)[[2]],
              miR_IDs = assay(MAE, 3),
              mRNA_IDs = assay(MAE, 7))
MAE <- eNames(MAE = MAE, method = 'c',
              gene_IDs = metadata(MAE)[[3]])
# start MAE2
MAE2 <- MultiAssayExperiment()
MAE2 <- dloadGmt(MAE = MAE2, species = "Homo sapiens")
probes <- read.csv("microarray_genes.csv")
probes$Entrez_Gene_ID <- as.character(probes$Entrez_Gene_ID)
# Overrepresentation analysis
MAE2 <- enrichWiki(MAE = MAE2, method = "c",
                   ID_list = metadata(MAE)[[4]],
                   orgDB = org.Hs.eg.db,
                   path_gene = assay(MAE2, 1),
                   path_name = assay(MAE2, 2),
                   ID = "ENTREZID",
                   universe = probes[[2]])
savePlots(largeList = metadata(MAE2)[[1]], maxInt = 5,fileType = "jpeg")
# quickBar(X = metadata(MAE2)[[1]][[1]], Y = names(metadata(MAE2)[[1]][1]))
# quickBar(X = metadata(MAE2)[[1]][[2]], Y = names(metadata(MAE2)[[1]][2]))
# quickBar(X = metadata(MAE2)[[1]][[3]], Y = names(metadata(MAE2)[[1]][3]))
# quickBar(X = metadata(MAE2)[[1]][[4]], Y = names(metadata(MAE2)[[1]][4]))
# quickBar(X = metadata(MAE2)[[1]][[5]], Y = names(metadata(MAE2)[[1]][5]))
# Temporal Cluster Analaysis
MAE2 <- wikiList(MAE2, stringSpecies = "Homo sapiens", stringSymbol = "L")
MAE2 <- wikiMatrix(MAE = MAE2, ID_list = metadata(MAE)[[4]],
                   wp_list = metadata(MAE2)[[2]])
MAE2 <- turnPercent(MAE = MAE2, wikiMatrix = assay(MAE2, 4))
MAE2 <- createClusters(MAE = MAE2, method = "c",
                       percentMatrix = assay(MAE2, 5),
                       noClusters = 6,
                       variance = 0.99)
clusterCheck(Clusters = metadata(MAE2)[[3]], W = FALSE)
# quickFuzz(Mfuzzdata = experiments(MAE2)[[7]], Clusters = metadata(MAE2)[[3]],
#           W = FALSE, background = "white", subcol = "black", labelcol = "black"
#           ,axiscol = "black", axisline = "black")
MAE2 <- returnCluster(MAE2, clusterData = assay(MAE2, 6), whichCluster = 6,
                      fitCluster = 0.5)
# create dynamic dataframes
MAE2 <- diffExpressRes(MAE = MAE2, df = assay(MAE, 1), dataType = "log2fc",
                       genes_ID = assay(MAE, 3), idColumn = "GENENAME",
                       name = "miR_log2fc")
MAE2 <- diffExpressRes(MAE = MAE2, df = assay(MAE, 2), dataType = "log2fc",
                       genes_ID = assay(MAE, 7), idColumn = "GENENAME",
                       name = "mRNA_log2fc")
# Extract Lung fibrosis
MAE2 <- reduceWiki(MAE = MAE2, path_data = assay(MAE2, 3),
                   stringWiki = "TGF-beta signaling pathway")
MAE2 <- wikiMrna(MAE2, mRNA_express = assay(MAE2, 10),
                 singleWiki = assay(MAE2, 11),
                 stringWiki = "TGF-beta signaling pathway")
# Make MAE3
MAE3 <- MultiAssayExperiment()
# Create correlation plot
MAE3 <- mirMrnaInt(MAE = MAE3, miR_express = assay(MAE2, 9),
                   GenesofInterest = assay(MAE2, 12), maxInt = 5)
# Download database data
MAE3 <- dloadTargetscan(MAE = MAE3, species = "hsa")
MAE3 <- dloadMirdb(MAE = MAE3, species = "hsa", orgDB = org.Hs.eg.db)
MAE3 <- dloadMirtarbase(MAE = MAE3, species = "hsa")
# Add mined data to correlation plot
MAE3 <- dataMiningMatrix(MAE = MAE3,
                         corrTable = assay(MAE3, 1),
                         targetscan = assay(MAE3, 2),
                         mirdb = assay(MAE3, 3),
                         mirtarbase = assay(MAE3, 4))
# Mine out pairs that are "likely" to occur
MAE3 <- matrixFilter(MAE = MAE3, miningMatrix = assay(MAE3, 5),
                     negativeOnly = FALSE, predictedOnly = TRUE, 
                     threshold = 2,
                     maxCor = 1)
x <- MAE3[[6]]
# Plot these miRNA-mRNA pairs
MAE3 <- makeNet(MAE = MAE3, filt_df = assay(MAE3, 6))
# quickNet(net = metadata(MAE3)[[1]])
#Make output for PathVisio
MAE3 <- makeMapp(MAE3, filt_df = assay(MAE3, 6),
                 miR_IDs_adj = assay(MAE,5),
                 dataType = "L")
MAE3 <- makeDynamic(MAE = MAE3, miR_expression = assay(MAE2, 9),
                    mRNA_expression = assay(MAE2, 10),
                    miR_IDs_adj = assay(MAE, 5),
                    dataType = "L")
write.table(assay(MAE3, 7), "MAPP.txt", quote = FALSE,
             row.names = FALSE,
             col.names = FALSE, sep = "\t")
write.csv(assay(MAE3, 8), "Dynamics.csv", row.names = TRUE,
          quote = FALSE)
write.csv(assay(MAE3, 6), "miRNA_interactions.csv", row.names = TRUE,
          quote = FALSE)
#Cytoscape input
library(RCy3)
# cytoscapePing() # must be at least version 3.7
# cytoMake(assay(MAE3, 6), titleString = "Complement+Coagulation",
#          collectionString = "PathwaysforKidneyFibrosis")
# Create H clusters
quickPathwayTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
               mRNA_exp = assay(MAE2, 10), morethan = TRUE, 
               threshold = 1.5, pathwayname = "TGF-beta Sig Path")
quickDendro(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis")
quickDMap(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
          mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis")
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 1)
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 2)
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 3)
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 4)
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 5)
quickHClust(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
            mRNA_exp = assay(MAE2, 10), pathwayname = "Lung fibrosis", 
            k = 6, cluster = 6)
# Longitudinal miRNA-mRNA pair analysis
quickMap(filt_df = assay(MAE3, 6), numpairs = 88)
quickTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
        mRNA_exp = assay(MAE2, 10), pair = 83, scale = FALSE,
        Interpolation = TRUE, timecourse = 14)
quickTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
        mRNA_exp = assay(MAE2, 10), pair = 5, scale = FALSE,
        Interpolation = TRUE, timecourse = 14)

quickTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
        mRNA_exp = assay(MAE2, 10), pair = 85, scale = TRUE,
        Interpolation = TRUE, timecourse = 14)
quickTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
        mRNA_exp = assay(MAE2, 10), pair = 5, scale = TRUE,
        Interpolation = TRUE, timecourse = 14)
quickTC(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
        mRNA_exp = assay(MAE2, 10), pair = 13, scale = TRUE,
        Interpolation = TRUE, timecourse = 14)
quickCrossCorr(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
               mRNA_exp = assay(MAE2, 10), pair = 83, scale = FALSE,
               Interpolation = FALSE)
quickCrossCorr(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
               mRNA_exp = assay(MAE2, 10), pair = 85, scale = FALSE,
               Interpolation = FALSE)
quickCrossCorr(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
               mRNA_exp = assay(MAE2, 10), pair = 5, scale = FALSE,
               Interpolation = FALSE)
quickCrossCorr(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
               mRNA_exp = assay(MAE2, 10), pair = 13, scale = FALSE,
               Interpolation = FALSE)
# Regression and expression prediction
# Plau is used as the example because it had the interactions with the most
# negative correlations
MAE3 <- multiReg(MAE = MAE3, gene_interest = "CAV1", mRNAreg = TRUE,
                 filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
                 mRNA_exp = assay(MAE2, 10))
MAE3 <- multiReg(MAE = MAE3, gene_interest = "RHOA", mRNAreg = TRUE,
                 filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
                 mRNA_exp = assay(MAE2, 10))
x <- MAE3[[9]]
# make models
model1 <- linearRegr(mreg = assay(MAE3, 9), alterpairs = 3:4)
model2 <- linearRegr(mreg = assay(MAE3, 9), alterpairs = 3)
model3 <- linearRegr(mreg = assay(MAE3, 9), alterpairs = 4)
summary(model1$regression)
quickTCPred(model = model1, reg_df = assay(MAE3, 9))
quickTCPred(model = model2, reg_df = assay(MAE3, 9))
quickTCPred(model = model3, reg_df = assay(MAE3, 9))
# Contrast Igf1 with the selected interacting miRNAs
quickReg(reg_df = assay(MAE3, 9), colselect = 3)
quickReg(reg_df = assay(MAE3, 9), colselect = 4)


library(reshape2)
library(ggplot2)
pickPair <- function(filt_df, pair, miRNA_exp, mRNA_exp, scale = TRUE){
    Ranks <- filt_df[,c(1,2,3)][order(filt_df$corr, decreasing = FALSE),]
    miRNA_target <- Ranks[[2]][pair]
    mRNA_target <- Ranks[[3]][pair]
    miR_tc <- miRNA_exp[which(rownames(miRNA_exp) == miRNA_target),]
    mRNA_tc <- mRNA_exp[which(rownames(mRNA_exp) == mRNA_target),]
    miR_tc$ID <- NULL
    mRNA_tc$ID <- NULL
    times <- as.integer(gsub(colnames(miR_tc), pattern = "[^0-9.-]", 
                             replacement = ""))
    times <- as.numeric(times)
    miR_tc <- as.numeric(miR_tc)
    mRNA_tc <- as.numeric(mRNA_tc)
    if (scale == TRUE) {
        miR_tc <- scale(miR_tc)
        mRNA_tc <- scale(mRNA_tc)
        miR_tc <- as.numeric(miR_tc)
        mRNA_tc <- as.numeric(mRNA_tc)
    } else if(scale == FALSE) { 
        miR_tc <- miR_tc
        mRNA_tc <- mRNA_tc
    }
    Y <- cbind(miR_tc, mRNA_tc, times)
    colnames(Y) <- c(miRNA_target, mRNA_target, "Time")
    return(Y)
}


Int <- pickPair(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
                mRNA_exp = assay(MAE2, 10), pair = 5)
Int2 <- pickPair(filt_df = assay(MAE3, 6), miRNA_exp = assay(MAE2, 9),
                 mRNA_exp = assay(MAE2, 10), pair = 83)


Time <- Expression <- Gene <- NULL
Int <- pickPair(filt_df, pair, miRNA_exp, mRNA_exp, scale)
Int <- FreqProf::approxm(as.data.frame(Int), timecourse, 
                         method = "spline")


Ranks <- MAE3[[6]][, c(1, 2, 3)][order(MAE3[[6]]$corr, decreasing = FALSE),]
Corr <- round(Ranks[1][5, ], 2)
X <- as.data.frame(Int)
rownames(X) <- X$Time
X$Time <- NULL
Melted <- melt(as.matrix(X), varnames = c("Time", "Gene"))
colnames(Melted)[3] <- "Expression"
miR <- as.character(unique(Melted$Gene)[[1]])
mRNA <- as.character(unique(Melted$Gene)[[2]])
ggplot(Melted, aes(x = Time, y = Expression, group = Gene, color = Gene)) +
    geom_line(data = ~subset(., Gene == paste(miR)), size = 2) +
    geom_line(data = ~subset(., Gene == paste(mRNA)), size = 2) + 
    scale_colour_manual(values = c("Red", "Blue")) + 
    theme_classic() + 
    labs(title = paste0(miR, ":", mRNA, " Expression"), x = "Time", y = "Expression", 
         subtitle = paste0("Corr = ", Corr)) + theme(plot.title = element_text(size = 20, 
                                                                               face = "bold", hjust = 0.5), axis.text.x = element_text(size = 15), 
                                                     axis.text.y = element_text(size = 15), axis.title.x = element_text(size = 20), 
                                                     axis.title.y = element_text(size = 20), legend.text = element_text(size = 12)) + 
    theme(plot.subtitle = element_text(size = 25, hjust = 1.2, 
                                       face = "italic", color = "black"))
