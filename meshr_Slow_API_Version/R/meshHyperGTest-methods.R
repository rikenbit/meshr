setMethod("meshHyperGTest", signature(p="MeSHHyperGParams"),
          function(p) .meshHyperGTestInternal(p) )

.meshHyperGTestInternal <- function(p) {
  ##
  ## MeSH enrichment analysis
  ##

  ## Map gene ID to MeSH ID through annotation data
  my.keytype <- c("GENEID")
  my.cols <- c("GENEID", "MESHID")
  my.geneids <- as.data.frame(p@geneIds)
  names(my.geneids) <- "GENEID"
  universe.geneids <- as.data.frame(p@universeGeneIds)
  names(universe.geneids) <- "GENEID"

  ## Retive data of specific database
  selectedDatabase <- select(eval(parse(text=p@annotation)), keys = p@database, columns = c("GENEID", "MESHID","MESHCATEGORY"), keytype = "SOURCEDB")
  selectedDatabase <- selectedDatabase[which(selectedDatabase[,3] == p@category), c(1:2)]

  ## Error against impossible category-database combination was choosed
  if(nrow(selectedDatabase) == 0){
    stop("Impossible MeSH category - database combination was choosed.")
  }

  selected.mesh <- table(merge(my.geneids, selectedDatabase, "GENEID")[, 2])
  universe.mesh <- table(merge(universe.geneids, selectedDatabase, "GENEID")[, 2])
  selected.out <- list()
  length(selected.out) <- length(selected.mesh)
  names(selected.out) <- names(selected.mesh)

  ## Hypergeometric test
  From_MeSH.db <- select(MeSH.db, keys=names(selected.mesh), columns=c('MESHID', 'MESHTERM'), keytype='MESHID')

  # GeneID - PubMedID (GeneID, MeSHIDが必要)
  All_PubMedIDs <- select(eval(parse(text=p@annotation)), keys = names(selected.mesh), columns = c("GENEID", "MESHID", "SOURCEID"), keytype = "MESHID")
  All_PubMedIDs <- All_PubMedIDs[which(!is.na(All_PubMedIDs[,3])), ]

  ##### Fetch All data from NCBI #####
  # GeneID - "GeneName / ProteinName" (GeneIDが必要、かつ500ずつ切らないと無理)
  All_GeneNames <- .efetch.genenames(unique(selectedDatabase[,1]))
  # PubMedID - Cites (PubMedIDが必要)
  All_Cites <- .sapply_pb(unique(All_PubMedIDs[,3]), .elink.count)
  # PubMedID - Title, Year (PubMedIDが必要)
  xml_data <- try(reutils:::content(esummary(unique(All_PubMedIDs[,3]), "pubmed"), "parsed"))
  #############################

  for (i in 1:length(selected.mesh)) {
    print(paste(i, "/", length(selected.mesh)))
    numWdrawn <- selected.mesh[i]
    mesh.index <- which(names(selected.mesh[i])==names(universe.mesh))
    numW <- universe.mesh[mesh.index]
    numB <- length(p@universeGeneIds) - numW
    numDrawn <- length(p@geneIds)
    scores <- Category:::.doHyperGInternal(numW, numB, numDrawn, numWdrawn, over=T)
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$Pvalue <- as.numeric(scores$p)")))
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$OddsRatio <- as.numeric(scores$odds)")))
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$ExpCount <- as.numeric(scores$expected)")))
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$Count <- as.numeric(numWdrawn)")))
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$Size <- as.numeric(numW)")))
    eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$MeSHTerm <- as.character(From_MeSH.db[which(From_MeSH.db[,1] == names(selected.mesh[i])), 2])")))

    # Attach PubMedID, Title, PubDate, Cite
    GeneIDs <- as.vector(selectedDatabase[which(selectedDatabase[,2] == names(selected.mesh[i])),1])

    for(j in 1:length(GeneIDs)){
      GeneName <-as.character(eval(parse(text=paste0("All_GeneNames['", GeneIDs[j], "']"))))
      PubMedID <-All_PubMedIDs[intersect(which(All_PubMedIDs[,1] == GeneIDs[j]), which(All_PubMedIDs[,2] == names(selected.mesh[i]))), ]

      Title <- as.character(sapply(paste0("xml_data$'", PubMedID, "'$Title"), function(x){eval(parse(text=x))}))
      PubDate <- as.character(sapply(paste0("xml_data$'", PubMedID, "'$PubDate"), function(x){eval(parse(text=x))}))

      Cite <-All_Cites[PubMedID]
      eval(parse(text=paste0("selected.out$", names(selected.mesh[i]),
                  "$GeneID$'", GeneIDs[[j]],
                  "' <- list(GeneName = GeneName")))

      index <- 1:length(PubMedID)
      names(index) <- PubMedID
      sapply(PubMedID, function(x){
        eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$GeneID$'", GeneIDs[[j]], "'$'", x, "'", " <- list(GeneName = GeneName", ", Title = xml_data[[index['",x, "']]]$Title", ", PubDate = xml_data[[index['",x, "']]]$PubDate)")))
      })
    }
  }

  ## Multiple testing correction
  Pvalue <- c()
  for(i in 1:length(selected.mesh)){
    eval(parse(text=paste0("Pvalue[i]<- as.numeric(selected.out$", names(selected.mesh[i]), "$Pvalue)"
      )))
  }
  stats <- switch(p@pAdjust,
    BH = {p.adjust(Pvalue, "BH")},
    QV = {suppressWarnings(fdrtool(Pvalue, statistic="pvalue", plot=FALSE, verbose=FALSE)$qval)},
    lFDR = {suppressWarnings(fdrtool(Pvalue, statistic="pvalue", plot=FALSE, verbose=FALSE)$lfdr)},
    none = Pvalue
    )

  if(p@pAdjust != "none"){
    for(i in 1:length(selected.mesh)){
     eval(parse(text=paste0("selected.out$", names(selected.mesh[i]), "$", p@pAdjust, " <- as.numeric(stats[i])")))
   }
  }

  ## Retrieve full name of MeSH category
  mesh.cat <- p@category

  switch(mesh.cat,
    "A" = {mesh.full.cat <- "Anatomy"},
    "B" = {mesh.full.cat <- "Organisms"},
    "C" = {mesh.full.cat <- "Diseases"},
    "D" = {mesh.full.cat <- "Chemicals and Drugs"},
    "E" = {mesh.full.cat <- "Analytical, Diagnostic and Therapeutic Techniques and Equipment"},
    "F" = {mesh.full.cat <- "Psychiatry and Psychology"},
    "G" = {mesh.full.cat <- "Phenomena and Processes"},
    "H" = {mesh.full.cat <- "Disciplines and Occupations"},
    "I" = {mesh.full.cat <- "Anthropology, Education, Sociology and Social Phenomena"},
    "J" = {mesh.full.cat <- "Technology and Food and Beverages"},
    "K" = {mesh.full.cat <- "Humanities"},
    "L" = {mesh.full.cat <- "Information Science"},
    "M" = {mesh.full.cat <- "Persons"},
    "N" = {mesh.full.cat <- "Health Care"},
    "V" = {mesh.full.cat <- "Publication Type"},
    "Z" = {mesh.full.cat <- "Geographical Locations"}
  )

  new("MeSHHyperGResult",
      meshCategory=mesh.full.cat,
      meshAnnotation=p@annotation,
      meshDatabase=p@database,
      ORA=selected.out
  )
}

.div2 <- function(x,num=1){
  y <- list()
  iter <- ceiling(length(x)/num)
  for(i in 1:iter){
    start <- num*(i-1) + 1
    end <- num*(i-1) + num
    if(end > length(x)){
    end <- length(x)
    }
    y[[i]] <-  start : end
  }
  return(y)
}

.efetch.genenames <- function(id){
  index <- .div2(1:length(id), 500)

  out <- unlist(.lapply_pb(index, function(x){
    pre_data <- efetch(id[index[[i]]], db="gene")
    paste0(pre_data$xmlValue("////Gene-ref_locus"), " / ", pre_data$xmlValue("////Gene-ref_desc"))
    }))
  names(out) <- id
  out
}

.elink.count <- function(PubMedID){
  return(length(elink(PubMedID, dbFrom="pubmed", dbTo="pubmed")["pubmed_pubmed"]))
}

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

.lapply_pb <- function(X, FUN, ...)
{
 env <- environment()
 pb_Total <- length(X)
 counter <- 0
 pb <- txtProgressBar(min = 0, max = pb_Total, style = 3)

 # wrapper around FUN
 wrapper <- function(...){
   curVal <- get("counter", envir = env)
   assign("counter", curVal +1 ,envir=env)
   setTxtProgressBar(get("pb", envir=env), curVal +1)
   FUN(...)
 }
 res <- lapply(X, wrapper, ...)
 close(pb)
 res
}
