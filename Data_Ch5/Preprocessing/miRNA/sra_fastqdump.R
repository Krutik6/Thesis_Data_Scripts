setwd("~/Documents/sratoolkit.2.9.4-ubuntu64/bin/")
list1 <- read.table("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/SS_Acc_list2.txt")

list2 <- rep("./fastq-dump --outdir /media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/fasta --split-3 -I -F -B --skip-technical ", 168)

list3 <- list()

for (i in list2) {
    for (j in list1) {
        paste0(i, j, sep = "") -> pre_list
        pre_list -> list3
    }
}

list3

for (i in list3) {
    system(i)
}

SRR1794126 1
SRR1794139 0.6
SRR1794147 1.6
SRR1794148 1.4
SRR1794151 0.3
SRR1794154 0
SRR1794155 0.3
SRR1794156 0.1
SRR1794165 1
SRR1794171 0.3
SRR1794172 0.006
SRR1794176 1.4
SRR1794204 0

list2 <- list.files("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/fasta/")
list2df <- as.data.frame(list2)
list2df$new <- gsub(list2df$list2, pattern = ".fastq", replacement = "")

list1[which(list1$V1 %in% list2df$new == FALSE),]
