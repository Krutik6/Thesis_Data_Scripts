#Broken down 30 at a time. Size limitations
# - 302, 333, 360, 388, 419, 440 + failed ones

setwd("~/Documents/sratoolkit.2.10.8-ubuntu64/bin/")
list1 <- read.table("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/mRNA/SRR_backup.txt")


list2 <- rep("./fastq-dump-orig.2.10.8 --outdir /media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/mRNA/fastq --split-3 -I -F -B --skip-technical ", nrow(list1))

list3 <- list()

for (i in list2) {
    for (j in list1) {
        paste0(i, j, sep = "") -> pre_list
        pre_list -> list3
    }
}

list3

#for (i in list3) {
#   system(i)
#}

