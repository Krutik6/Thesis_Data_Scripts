#mapper.pl reads.fa -e -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p cel_cluster \ -s reads_collapsed.fa -t reads_collapsed_vs_genome.arf -v

code <- "mapper.pl cutadapt/"
code2 <- " -e -h -j -l 18 -m -p bowtie/index/index/MM \ -s bowtie/Map/"
code3 <- " -t bowtie/Map/"

list.files("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/cutadapt/") -> L

lapply(L, function(x){gsub(x,  pattern = "fastq", replacement = "arf")}) -> arf
lapply(L, function(x){gsub(x,  pattern = "fastq", replacement = "fa")}) -> fa
List1 <- list()
for (i in 1:168) {
 paste0(code, L[i], code2, fa[i], code3, arf[i]) -> List1[i]
}


setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/")
getwd()

List1

for (i in List1) {
  system(i)
}
#must have -l 18 for miRDeep2.pl to work

##########################################################################################################################################################
#quantifier.pl -p precursors_ref_this_species.fa -m mature_ref_this_species.fa \-r reads_collapsed.fa -t cel -y 16_19
setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/bowtie/")

getwd()

code <- "quantifier.pl -p quant/hairpin_mmu.fa -m quant/mature_mmu.fa \ -r Map/"
code2 <- " -t mmu"
code3 <- " -y res_"

list.files("Map/") -> L
L[grep(L, pattern = "fa")] -> fls


List1 <- list()
for (i in 1:168) {
  paste0(code, fls[i], code2, code3, fls[i]) -> List1[i]
}

List1

for (i in List1) {
  system(i)
}

#try again with mmu_curated fa files
#not a huge difference between clipped and non-clipped data
#############################################################################################################################################################
#miRDeep2.pl reads_collapsed.fa cel_cluster.fa reads_collapsed_vs_genome.arf \ 
#mature_ref_this_species.fa mature_ref_other_species.fa \ 
#precursors_ref_this_species.fa -t C.elegans 2> report.log

code <- "miRDeep2.pl Map/"
code2 <- "Map/"

setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/bowtie/")

list.files("Map/") -> M

M[grep(M, pattern = "fa")] -> fa
M[grep(M, pattern = "arf")] -> arf

ref <- " new_mm_genome.fa "
List1 <- list()
for (i in 1:168) {
  paste0(code, fa[i], ref, code2, arf[i]) -> List1[i]
}

List1

code3 <- " \ quant/new_mature_mmu.fa quant/new_mature_notmmu.fa \ quant/new_hairpin_mmu.fa -t mmu 2> "
code4 <- " -v "
for (i in 1:168) {
  gsub(fa, pattern = ".fa", replacement = ".log")
} -> O
O


List3 <- list()
for (i in 1:168) {
  paste0(List2[i], code3, O[i])
} -> List3[i]
List3

for (i in List3) {
  system(i)
}


