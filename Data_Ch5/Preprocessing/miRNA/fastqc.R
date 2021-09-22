#run fastqc interactively

setwd("/media/b7053098/104a6831-0260-48e8-ab8d-d717ff7c8e8f/HD/miRNA/cutadapt/")

code <- ("fastqc * --outdir=../fastqc")

system(code)