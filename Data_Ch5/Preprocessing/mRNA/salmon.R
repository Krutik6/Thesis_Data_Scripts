#salmon quant -i index -l IU -1 lib_1_1.fq lib_2_1.fq -2 lib_1_2.fq lib_2_2.fq --validateMappings -o out

code <- "salmon quant -i salmon/MM_index -l A -1 fastq/"
code2 <- " -2 fastq/"
code3 <- " --numBootstraps 5 --seqBias --gcBias --validateMappings -o Salmon/quant/"

list.files("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/mRNA/fastq/") -> L

gsub(x = L, pattern = "_1.fastq", replacement = "") -> O
gsub(x = O, pattern = "_2.fastq", replacement = "") -> O2
O2[! duplicated(O2)] -> code4

as.list(L) -> lst
tapply(lst, ceiling(seq_along(lst)/2), unlist) -> lst2

paste0(code, code2, code3)

lst3 <- list()

for (i in seq_along(names(lst2))) {
    lst2[[i]] -> x
    paste0(code, x[1], code2, x[2], code3, code4[i]) -> lst3[i]
}

lst3

for (i in lst3) {
    print(i)
}

setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/mRNA/")

lst3

for (i in lst3) {
    system(i)
}