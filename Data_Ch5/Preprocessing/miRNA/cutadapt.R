###############cutadapt for FA_miRNA

setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/fasta/")

L <- list.files()

for (i in L) {
  print(i)
}

G <- rep(getwd(), 168)

inlist <- list()

for (i in G) {
  for (j in L) {
    paste0(G, '/', L) -> inlist
  }
}

inlist

I <- unlist(inlist)

I

outdir <- rep(" -o /media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/cutadapt",168)

outdir_list <- list()

for (i in outdir) {
  for (j in L) {
    paste0(outdir, '/', L) -> outdir_list
  }
}

outdir_list

O <- unlist(outdir_list)

code <- "cutadapt --nextseq-trim=20 -u -10 -u 4  -M 22 -m 17 -a TGGAATTCTCGGGT " 

#attempts
#cutadapt  q -10 -a TGGAATTCTCGGGT - ok
#cutadapt --nextseq-trim=20 -a TGGAATTCTCGGGT - better
#"cutadapt --nextseq-trim=20 -u -10 -u 4  -M 22 -m 17 -a TGGAATTCTCGGGTGCCAAGGAACTCC "  - very good I think
codelist <- list()



for (i in inlist) {
  paste0(code, I, O) -> codelist
}

codelist

for (i in codelist) {
  system(i)
}

# fastqc cutadapt/* -o FastQC2

#TGGAATTCTCGGGTGCCAAGGAACTCCAGTCACCACTCAAT
#'TGGAATTCTCGGGT' - common
#'TGGAATTCTCGGGTGCCAAGGAACTCC = 3' small RNA adapter - but not as specific