###############################################################################
#Load libraries
library(reshape2)
library(ggplot2)
###############################################################################
#FUNCTIONS
###############################################################################
#
renamer <- function(X){
    colnames(X) <- sub(colnames(X), pattern = "X.", replacement = "")
    colnames(X) <- sub(colnames(X), pattern = ".$", replacement = "")
    return(X)
}
#
melter <- function(X){
    DF <- melt(as.matrix(X), varnames = c("Time", "Genes"))
    names(DF)[[3]] <- "Values"
    return(DF)
}
#
plotter <- function(DF1, DF2, Gene, pheno1, pheno2){
    df1 <- DF1[which(DF1$Genes == Gene),]
    df2 <- DF2[which(DF2$Genes == Gene),]
    df1$Genes <- gsub(df1$Genes, pattern = Gene, 
                      replacement = paste(Gene, pheno1))
    df2$Genes <- gsub(df2$Genes, pattern = Gene,
                      replacement = paste(Gene, pheno2))
    Data <- rbind(df1, df2)
    ggplot(Data, aes(x = Time, y = Values, color = Genes, group = Genes)) +
        geom_line(data = ~ subset(., Genes == paste(Gene, pheno1)), size =2) +
        geom_line(data = ~ subset(., Genes == paste(Gene, pheno2)), size =2,
                  linetype = "dashed") +
        theme_classic()+
        labs(title= paste("Model:", Gene, "activity"),
             x="Time",
             y="Relative Expression")+
        theme(plot.title=element_text(size=20, face="bold",hjust = 0.5), 
              axis.text.x=element_text(size=10), 
              axis.text.y=element_text(size=10),
              axis.title.x=element_text(size=15),
              axis.title.y=element_text(size=15),
              legend.text=element_text(size=10))
}
plotter2 <- function(DF1, Gene, pheno1){
    df1 <- DF1[which(DF1$Genes == Gene),]
    df1$Genes <- gsub(df1$Genes, pattern = Gene, 
                      replacement = paste(Gene, pheno1))
    ggplot(df1, aes(x = Time, y = Values, color = Genes, group = Genes)) +
        geom_line(data = ~ subset(., Genes == paste(Gene, pheno1)), size =2,
                  linetype = "dashed", color="skyblue") +
        theme_classic()+
        labs(title= paste("Model:", Gene, "activity"),
             x="Time",
             y="Relative Expression")+
        theme(plot.title=element_text(size=20, face="bold",hjust = 0.5), 
              axis.text.x=element_text(size=10), 
              axis.text.y=element_text(size=10),
              axis.title.x=element_text(size=15),
              axis.title.y=element_text(size=15),
              legend.text=element_text(size=10))
}
#
lazyBarer <- function(Data, Gene){
    ggplot(data = Data, aes(x = Time, y = Values))+
        geom_bar(stat="identity", color="blue", fill="white") +
        theme_classic()+
        labs(title = Gene,
             x="Time",
             y="Relative Expression")+
        theme(plot.title=element_text(size=20, face="bold"
                                      ,hjust = 0.5), 
              axis.text.x=element_text(size=10), 
              axis.text.y=element_text(size=10),
              axis.title.x=element_text(size=15),
              axis.title.y=element_text(size=15),
              legend.text=element_text(size=10))
}    
###############################################################################
#get Experimental data and data from Copasi
setwd("~/Documents/miR199bModelInformation/CopasiToR")
Experiment1 <- read.csv("Experiment1.csv", row.names = 1)
Experiment2 <- read.csv("Experiment2.csv", row.names = 1)

Normal <- read.table("Normal.txt", header = TRUE, row.names = 1)
KD199a <- read.table("199aKD.txt", header = TRUE, row.names = 1)
KD199b <- read.table("199bKD.txt", header = TRUE, row.names = 1)
################################################################################
# Rename copasi files
Normal <- renamer(Normal)
KD199a <- renamer(X = KD199a)
KD199b <- renamer(X = KD199b)
################################################################################
# reshape dataframes into ggplot friendly dataframes
N_DF <- melter(X = Normal)
KDA_DF <- melter(X = KD199a)
KDB_DF <- melter(X = KD199b)
E1_DF <- melter(X = Experiment1)
E2_DF <- melter(X = Experiment2)
################################################################################
# Compare N and E1
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "Cav1", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "MIR199b_5p", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "Sox9mRNA", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "Col2a1", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "Acan", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "MIR140_5p", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
plotter2(DF1 = N_DF, Gene = "GAG", pheno1 = "Simulation of Chondrogenesis")
plotter(DF1 = E1_DF, DF2 = N_DF, Gene = "MIR199a_5p", pheno1 = "Experiment 1",
        pheno2 = "Simulation of Chondrogenesis")
# Compare KDB_DF and E2
plotter(DF1 = E2_DF, DF2 = KDB_DF, Gene = "Cav1", pheno1 = "Experiment 2",
        pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDB_DF, Gene = "MIR199b_5p", pheno1 = "Experiment 2",
        pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDB_DF, Gene = "Sox9mRNA", pheno1 = "Experiment 2",
        pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDB_DF, Gene = "Col2a1", pheno1 = "Experiment 2",
        pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDB_DF, Gene = "Acan", pheno1 = "Experiment 2",
        pheno2 = "Simulation of MIR199b KD")
plotter2(DF1 = KDB_DF, Gene = "MIR140_5p", pheno1 = "Simulation of MIR199b KD")
plotter2(DF1 = KDB_DF, Gene = "GAG", pheno1 = "Simulation of MIR199b KD")
# Compare KDA_DF and E2
plotter(DF1 = E2_DF, DF2 = KDA_DF, Gene = "Cav1",
        pheno1 = "Experiment 2", pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDA_DF, Gene = "MIR199a_5p",
        pheno1 = "Experiment 2", pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDA_DF, Gene = "Sox9mRNA",
        pheno1 = "Experiment 2", pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDA_DF, Gene = "Col2a1",
        pheno1 = "Experiment 2", pheno2 = "Simulation of MIR199b KD")
plotter(DF1 = E2_DF, DF2 = KDA_DF, Gene = "Acan",
        pheno1 = "Experiment 2", pheno2 = "Simulation of MIR199b KD")
plotter2(DF1 = KDA_DF, Gene = "MIR140_5p", pheno1 = "Simulation of MIR199a KD")
plotter2(DF1 = KDA_DF, Gene = "GAG", pheno1 = "Simulation of MIR199a KD")
################################################################################
# Reproduce Validation data
lazyBarer(Data = E2_DF[c(7:10),], Gene = "Cav1")
lazyBarer(Data = E2_DF[c(13:16),], Gene = "Sox9")
lazyBarer(Data = E2_DF[c(19:22),], Gene = "Col2a1")
lazyBarer(Data = E2_DF[c(25:28),], Gene = "Acan")
