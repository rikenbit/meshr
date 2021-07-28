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
  query <- paste0("SELECT GENEID, MESHID, SOURCEID FROM DATA WHERE MESHCATEGORY = '",
    p@category, "' AND SOURCEDB = '", p@database, "';")
  selectedDatabase <- unique(dbGetQuery(dbconn(eval(parse(text=p@annotation))), query))
  selected.mesh <- table(merge(geneids, unique(selectedDatabase[,1:2]), "GENEID")[,2])
  universe.mesh <- table(merge(universe.geneids, unique(selectedDatabase[,1:2]), "GENEID")[,2])

  ## Hypergeometric test
  tmp <- sapply(names(selected.mesh), function(i){
    numWdrawn <- selected.mesh[i]
    numW <- universe.mesh[which(names(selected.mesh[i])==names(universe.mesh))]
    numB <- length(p@universeGeneIds) - numW
    numDrawn <- length(p@geneIds)
    scores <- Category:::.doHyperGInternal(numW, numB, numDrawn, numWdrawn, over=T)
    ## Assign statistics
    list(
      names(selected.mesh[i]),
      as.numeric(scores$p),
      as.numeric(scores$odds),
      as.numeric(scores$expected),
      as.numeric(numWdrawn),
      as.numeric(numW)
      )
   })
   outputA <- data.frame(
      MESHID = as.character(unlist(tmp[1,])),
      Pvalue = as.numeric(unlist(tmp[2,])),
      OddsRatio = as.numeric(unlist(tmp[3,])),
      ExpCount = as.numeric(unlist(tmp[4,])),
      Count = as.numeric(unlist(tmp[5,])),
      Size = as.numeric(unlist(tmp[6,]))
      )

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
      outputA <- outputA[1,]
      outputA[,] <- NA
      warning("None of MeSH Term is significant !")
    }

  out2 <- dbGetQuery(dbconn(MeSH.db), "SELECT * FROM DATA;")
  tmp2 <- sapply(names(selected.mesh), function(i){
    target <- which(out2$MESHID == i)
    unique(out2[target, c("MESHID", "MESHTERM")])
  })
  FromMeSHdb <- data.frame(
    MESHID=unlist(tmp2["MESHID", ]),
    MESHTERM=unlist(tmp2["MESHTERM", ]))

  # FromMeSHdb <- select(MeSH.db, keys=names(selected.mesh), columns=c('MESHID', 'MESHTERM'), keytype='MESHID')
  outputB <- merge(FromMeSHdb, selectedDatabase, by = "MESHID")
  output <- merge(outputA, outputB, by = "MESHID")
  output <- output[order(output$Pvalue), ]

  ## Retrieve full name of MeSH category
  mesh.full.cat <- c(
     "Anatomy",
     "Organisms",
     "Diseases",
     "Chemicals and Drugs",
     "Analytical, Diagnostic and Therapeutic Techniques and Equipment",
     "Psychiatry and Psychology",
     "Phenomena and Processes",
     "Disciplines and Occupations",
     "Anthropology, Education, Sociology and Social Phenomena",
     "Technology and Food and Beverages",
     "Humanities",
     "Information Science",
     "Persons",
     "Health Care",
     "Publication Type",
     "Geographical Locations"
  )
  names(mesh.full.cat) <- c(
     "A", "B", "C", "D", "E", "F", "G", "H",
     "I", "J", "K", "L", "M", "N", "V", "Z"
  )
  mesh.full.cat <- mesh.full.cat[p@category]

  new("MeSHHyperGResult",
      meshCategory=mesh.full.cat,
      meshAnnotation=p@annotation,
      meshDatabase=p@database,
      ORA=as.data.frame(output)
  )
}
