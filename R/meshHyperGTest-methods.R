setMethod("meshHyperGTest", signature(p="MeSHHyperGParams"),
          function(p) .meshHyperGTestInternal(p) )

.meshHyperGTestInternal <- function(p) {
  ##
  ## Initialization
  ##

  ##
  ## MeSH enrichment analysis
  ##

  ## Map gene ID to MeSH ID through annotation data
  geneids <- as.data.frame(p@geneIds)
  universe.geneids <- as.data.frame(p@universeGeneIds)
  names(geneids) <- "GENEID"
  names(universe.geneids) <- "GENEID"
  selectedDatabase <- select(eval(parse(text=p@annotation)), keys = p@database, columns = c("GENEID", "MESHID","MESHCATEGORY", "SOURCEID"), keytype = "SOURCEDB")
  selectedDatabase <- selectedDatabase[which(selectedDatabase[,3] == p@category), c(1:2,4)]
  selectedDatabase <- as.data.frame(selectedDatabase)
  selected.mesh <- table(merge(geneids, unique(selectedDatabase[,1:2]), "GENEID")[,2])
  universe.mesh <- table(merge(universe.geneids, unique(selectedDatabase[,1:2]), "GENEID")[,2])

  ## Hypergeometric test
  outputA <- data.frame()
  length(outputA) <- 6
  for(i in 1:length(selected.mesh)){
    numWdrawn <- selected.mesh[i]
    numW <- universe.mesh[which(names(selected.mesh[i])==names(universe.mesh))]
    numB <- length(p@universeGeneIds) - numW
    numDrawn <- length(p@geneIds)
    scores <- Category:::.doHyperGInternal(numW, numB, numDrawn, numWdrawn, over=T)
    ## Assign statistics
    outputA <- rbind(outputA, data.frame(names(selected.mesh[i]), as.numeric(scores$p), as.numeric(scores$odds), as.numeric(scores$expected), as.numeric(numWdrawn), as.numeric(numW), stringsAsFactors = F))
  }
  colnames(outputA) <- c("MESHID", "Pvalue", "OddsRatio", "ExpCount", "Count", "Size")

  ## Multiple testing correction
  Pvalue <- outputA$Pvalue

  stats <- switch(p@pAdjust,
    BH = {
      p.adjust(Pvalue, "BH")},
    QV = {
      non_nan <- which(!is.nan(Pvalue))
      pre_stats <- rep(NaN, length=length(Pvalue))
      pre_stats[non_nan] <- fdrtool(Pvalue[non_nan], statistic="pvalue", plot=FALSE, verbose=FALSE)$qval
      pre_stats},
    lFDR = {
      non_nan <- which(!is.nan(Pvalue))
      pre_stats <- rep(NaN, length=length(Pvalue))
      pre_stats[non_nan] <- fdrtool(Pvalue[non_nan], statistic="pvalue", plot=FALSE, verbose=FALSE)$lfdr
      pre_stats},
    none = {
      Pvalue}
  )

  if(p@pAdjust != "none"){
    outputA <- cbind(outputA, stats)
    colnames(outputA)[which(colnames(outputA) == "stats")]  <- p@pAdjust
    colnames(outputA) <- c("MESHID", "Pvalue", "OddsRatio", "ExpCount", "Count", "Size", p@pAdjust)
  }

  ## Choose siginificantly enriched MeSH terms
  if(length(which(stats < p@pvalueCutoff)) != 0){
      outputA <- outputA[which(stats < p@pvalueCutoff), ]
    }else{
      stop("None of MeSH Term is significant !")
    }

  FromMeSHdb <- select(MeSH.db, keys=names(selected.mesh), columns=c('MESHID', 'MESHTERM'), keytype='MESHID')
  outputB <- merge(FromMeSHdb, selectedDatabase, by = "MESHID")
  output <- merge(outputA, outputB, by = "MESHID")
  output <- output[order(output$Pvalue), ]

  ## Retrieve full name of MeSH category
  switch(p@category,
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
      ORA=as.data.frame(output)
  )
}
