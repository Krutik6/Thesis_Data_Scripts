setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/bowtie/expression_analyses/")

ListofFiles <- list.files()
ListofFiles <- gsub(ListofFiles, pattern = ".fa", replacement = ".fa/miRNA_expressed.csv")

Filenames <- gsub(ListofFiles, pattern = "expression_analyses_res_", replacement = "")
Filenames <- gsub(Filenames, pattern = ".fa", replacement = "")

L <- list()

ReadFiles <- function(x){
    read.csv(x, sep = "\t") -> X
    as.data.frame(X) -> X
    return(X)
}

for (i in 1:168) {
    L[i] <- Filenames[i]
}

L2 <- list()
for (i in 1:168) {
    L2[[i]] <- ReadFiles(ListofFiles[i])
}

names(L2) <- L
names(L2)[[1]] <- "SRR1794085"

rownames(X) <- X$X.miRNA

saveRDS(object = L2, file = "../Listdata.rds",)
