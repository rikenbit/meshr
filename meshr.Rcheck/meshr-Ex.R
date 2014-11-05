pkgname <- "meshr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('meshr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
cleanEx()
nameEx("PMCID")
### * PMCID

flush(stderr()); flush(stdout())

### Name: PMCID
### Title: PUBMEDID - PMCID correspondence
### Aliases: PMCID
### Keywords: datasets

### ** Examples

data(PMCID)
names(PMCID)



cleanEx()
nameEx("geneid.cummeRbund")
### * geneid.cummeRbund

flush(stderr()); flush(stdout())

### Name: geneid.cummeRbund
### Title: Test data of significant differentially expressed genes used in
###   cummeRbund package.
### Aliases: geneid.cummeRbund
### Keywords: datasets

### ** Examples

data(geneid.cummeRbund)
names(geneid.cummeRbund)

## This data is also available by following scripts.
if(interactive()){
library(cummeRbund)
library(org.Hs.eg.db)
cuff <- readCufflinks(dir = system.file("extdata", package = "cummeRbund"))

gene.symbols <- annotation(genes(cuff))[,4]
mySigGeneIds <- getSig(cuff,x='hESC',y='iPS',alpha=0.05,level='genes')
mySigGenes <- getGenes(cuff,mySigGeneIds)

sig.gene.symbols <- annotation(mySigGenes)[,4]
gene.symbols <- gene.symbols[!is.na(gene.symbols)]
sig.gene.symbols <- sig.gene.symbols[!is.na(sig.gene.symbols)]

geneid.cummeRbund <- select(org.Hs.eg.db, keys=gene.symbols, keytype="SYMBOL", columns="ENTREZID")
sig.geneid.cummeRbund <- select(org.Hs.eg.db, keys=sig.gene.symbols, keytype="SYMBOL", columns="ENTREZID")

na.index1 <- which(is.na(geneid.cummeRbund[,2]))
for (i in na.index1){
s <- unlist(strsplit(as.character(geneid.cummeRbund[i,][1]), ","))[1]
sym <- get(s, org.Hs.egALIAS2EG)[1]
geneid.cummeRbund[i,2] <- as.integer(sym)
}

na.index2 <- which(is.na(sig.geneid.cummeRbund[,2]))
for (i in na.index2){
	s <- unlist(strsplit(as.character(sig.geneid.cummeRbund[i,][1]), ","))[1]
	sym <- get(s, org.Hs.egALIAS2EG)[1]
	sig.geneid.cummeRbund[i,2] <- as.integer(sym)
}

geneid.cummeRbund <- geneid.cummeRbund[!duplicated(geneid.cummeRbund[,2]), ]
sig.geneid.cummeRbund <- sig.geneid.cummeRbund[!duplicated(sig.geneid.cummeRbund[,2]), ]
}



cleanEx()
nameEx("meshHyperGTest")
### * meshHyperGTest

flush(stderr()); flush(stdout())

### Name: meshHyperGTest
### Title: Hypergeometric Tests for MeSH term association
### Aliases: meshHyperGTest meshHyperGTest,MeSHHyperGParams-method
### Keywords: models

### ** Examples

data(geneid.cummeRbund)
data(sig.geneid.cummeRbund)

meshParams <- new("MeSHHyperGParams", geneIds=sig.geneid.cummeRbund[,2], universeGeneIds=geneid.cummeRbund[,2], annotation="org.MeSH.Hsa.db", category="D", database="gendoo", pvalueCutoff=0.05, pAdjust="none")

meshR <- meshHyperGTest(meshParams)



cleanEx()
nameEx("meshr-package")
### * meshr-package

flush(stderr()); flush(stdout())

### Name: meshr-package
### Title: Enrichment analysis for MeSH terms.
### Aliases: meshr-package meshr
### Keywords: package

### ** Examples

ls("package:meshr")



cleanEx()
nameEx("sig.geneid.cummeRbund")
### * sig.geneid.cummeRbund

flush(stderr()); flush(stdout())

### Name: sig.geneid.cummeRbund
### Title: Test data of significant differentially expressed genes used in
###   cummeRbund package.
### Aliases: sig.geneid.cummeRbund
### Keywords: datasets

### ** Examples

data(sig.geneid.cummeRbund)
names(sig.geneid.cummeRbund)

## This data is also available by following scripts.
if(interactive()){
library(cummeRbund)
library(org.Hs.eg.db)
cuff <- readCufflinks(dir = system.file("extdata", package = "cummeRbund"))

gene.symbols <- annotation(genes(cuff))[,4]
mySigGeneIds <- getSig(cuff,x='hESC',y='iPS',alpha=0.05,level='genes')
mySigGenes <- getGenes(cuff,mySigGeneIds)

sig.gene.symbols <- annotation(mySigGenes)[,4]
gene.symbols <- gene.symbols[!is.na(gene.symbols)]
sig.gene.symbols <- sig.gene.symbols[!is.na(sig.gene.symbols)]

geneid.cummeRbund <- select(org.Hs.eg.db, keys=gene.symbols, keytype="SYMBOL", columns="ENTREZID")
sig.geneid.cummeRbund <- select(org.Hs.eg.db, keys=sig.gene.symbols, keytype="SYMBOL", columns="ENTREZID")

na.index1 <- which(is.na(geneid.cummeRbund[,2]))
for (i in na.index1){
s <- unlist(strsplit(as.character(geneid.cummeRbund[i,][1]), ","))[1]
sym <- get(s, org.Hs.egALIAS2EG)[1]
geneid.cummeRbund[i,2] <- as.integer(sym)
}

na.index2 <- which(is.na(sig.geneid.cummeRbund[,2]))
for (i in na.index2){
	s <- unlist(strsplit(as.character(sig.geneid.cummeRbund[i,][1]), ","))[1]
	sym <- get(s, org.Hs.egALIAS2EG)[1]
	sig.geneid.cummeRbund[i,2] <- as.integer(sym)
}

geneid.cummeRbund <- geneid.cummeRbund[!duplicated(geneid.cummeRbund[,2]), ]
sig.geneid.cummeRbund <- sig.geneid.cummeRbund[!duplicated(sig.geneid.cummeRbund[,2]), ]
}



### * <FOOTER>
###
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
