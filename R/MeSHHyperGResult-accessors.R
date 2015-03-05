##
## Accessor methods for MeSHHyperGResult class
##

setMethod("meshCategory", "MeSHHyperGResult", function(r) r@meshCategory)

setMethod("meshAnnotation", "MeSHHyperGResult", function(r) r@meshAnnotation)

setMethod("meshDatabase", "MeSHHyperGResult", function(r) r@meshDatabase)

## generic is defined in methods/R/AllGenerics.R
setMethod("show", "MeSHHyperGResult", function(object){
	cat("MeSH enrichment analysis for category", object@meshCategory, '\n')
	cat("Annotation package used: ", object@meshAnnotation, '\n')
	cat("The correspondance is retrived from: ", object@meshDatabase, '\n')
	cat("Number of MeSH terms identified: ", length(object@ORA), '\n')
})

## generic is defined in base/R/AllGenerics.R
setMethod("summary", "MeSHHyperGResult", function(object){
	object@ORA
})

.sapply_pb <- function(X, FUN, ...)
{
  env <- environment()
  pb_Total <- length(X)
  counter <- 0
  pb <- txtProgressBar(min = 0, max = pb_Total, style = 3)

  wrapper <- function(...){
    curVal <- get("counter", envir = env)
    assign("counter", curVal +1 ,envir=env)
    setTxtProgressBar(get("pb", envir=env), curVal +1)
    FUN(...)
  }
  res <- sapply(X, wrapper, ...)
  close(pb)
  res
}

.convert_PMID_PMCID <- function(PUBMEDIDs){
	data(PMCID)
	PUBMEDIDs <- as.data.frame(PUBMEDIDs)
	names(PUBMEDIDs) <- "PUBMEDID"
	as.character(merge(PUBMEDIDs, PMCID, by="PUBMEDID")[,2])
}

.download_PMCPDF <- function(pmcid, ftp_list){
	pmcid <- as.data.frame(pmcid)
	names(pmcid) <- "PMCID"
	url <- as.character(merge(ftp_list, pmcid, by="PMCID")$URL)
	id <- as.character(merge(ftp_list, pmcid, by="PMCID")$PMCID)
	if(length(url) != 0){
		.sapply_pb(1:length(url), function(x){download.file(url[x], destfile=paste0(id[x], ".pdf"), quiet = TRUE)})
	}
	cat(paste0(length(url), " PDF files have been downloaded!"))
}

.opendir <- function(dir = getwd()){
	if(.Platform['OS.type'] == "windows"){
		shell.exec(dir)
	}else{
		system(paste(Sys.getenv("R_BROWSER"), dir))
	}
}

setMethod("save.pdf", "MeSHHyperGResult", function(r){
	# Error masage
	if(r@meshDatabase != "gene2pubmed"){
		stop("save.pdf function is available, only when you specify the meshDatabase as 'gene2pubmed'")
	}

	########### Make MeSHR_ORA directory ###########
	d <- getwd()
	if(!file.exists("MeSH_ORA")){
		dir.create(paste0(d, "/MeSH_ORA"))
	}
	setwd(paste0(d, "/MeSH_ORA"))

	########### Fetch PMC File list from NCBI FTP site ###########
	if(!file.exists("file_list.pdf.txt")){
		invisible(download.file("ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/file_list.pdf.txt", destfile="file_list.pdf.txt", quiet = TRUE))
	}
	ftp_list <- read.delim("file_list.pdf.txt", skip=1, header=F)
	colnames(ftp_list) <- c("URL", "Title", "PMCID")
	ftp_list[,1] <- paste0("ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/", ftp_list[,1])

	########### Directry Tree Construction ###########
	path <- c()
	tmp.env <- new.env()
	assign("path", path, envir=tmp.env)

	# MeSHIDs - level
	MeSHIDs <- unique(summary(r)$MESHID)

	# GeneIDs - level
	invisible(sapply(MeSHIDs, function(x){
		my.path <- get("path", envir=tmp.env)
		GeneIDs <- summary(r)[which(summary(r)[,1] == x),]$GENEID
		assign("path", c(my.path, paste0(x, "/", GeneIDs)), envir=tmp.env)
	}))
	path <- unique(get("path", envir=tmp.env))

	# PubMedIDs - level
	invisible(sapply(path, function(x){dir.create(x, recursive = T)}))

	########### Fetch PMC pdf File from NCBI FTP site ###########
	PMCIDs <- .convert_PMID_PMCID(unique(summary(r)$SOURCEID))
	invisible(.download_PMCPDF(PMCIDs,ftp_list))
	Local_PDFs <- list.files(pattern=".pdf")
	Accessible_PMCIDs <- gsub(".pdf", "", Local_PDFs)

	########### Assignment PDF to each directry ###########
	invisible(sapply(Accessible_PMCIDs, function(x){
		Accessible_PUBMEDIDs <- PMCID[which(PMCID$PMCID == x),]$PUBMEDID
		base <- summary(r)[which(summary(r)$SOURCEID == Accessible_PUBMEDIDs), ]

		PDF_path <- paste0(base$MESHID, "/", base$GENEID)
		sapply(PDF_path, function(y){
			file.copy(paste0(x,".pdf"), y)
		})
	}))

	########### Remove PDF files ###########
	invisible(file.remove(Local_PDFs))

	########### Remove Empty directories ###########
	invisible(sapply(path, function(x){
		if(length(list.files(paste0(x,"/"))) == 0){
			file.remove(x)
		}
	}))

	########### Open MeSH_ORA directory ###########
	setwd(d)
	.opendir(paste0(d, "/MeSH_ORA"))
})
