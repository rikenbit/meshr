##
## Accessor methods for MeSHHyperParams class
##


## check MeSHHyperParams instance for validity.
## If we can fix it, we do (and issue a warning)
## Return a more valid instance or error
## Based on Category/R/HyperGParams-accessors.R
.makeValidMeSHParams <- function(object) {
  ##
  ## Validation of MeSH version
  ##
  MeSH.db <- eval(parse(text=object@meshdb))
  MeSH.XXX.eg.db <- eval(parse(text=object@annotation))
  if(meshVersion(MeSH.db)[1,2] != meshVersion(MeSH.XXX.eg.db)[1,2]){
    stop("\n#############################################################################\nMeSH-version of MeSH.db and MeSH.XXX.eg.db-type packages must be coincided!\nPlease confirm the version of MeSH by typing\n\n'meshVersion(MeSH.db)'\n\n'meshVersion(MeSH.XXX.eg.db)'\n\nand then install appropriate version of these packages\n#############################################################################")
  }
  ##
  ##
  ##

  sel <- geneIds(object)
  if (is.list(sel)) {
    warning("converting geneIds from list to atomic vector via unlist")
    sel <- unlist(sel)
  }
  if (any(duplicated(sel))) {
    warning("removing duplicate IDs in geneIds")
    sel <- unique(sel)
  }
  geneIds(object) <- sel
  univ <- universeGeneIds(object)
  if (length(univ)) {
    if (is.list(univ)) {
      warning("converting univ from list to atomic vector via unlist")
      univ <- unlist(univ)
    }
        if (typeof(sel) != typeof(univ))
          stop(paste("geneIds and universeGeneIds must have the same mode\n",
                     "geneIds:", typeof(sel), "\n",
                     "universeGeneIds:", typeof(univ)), .Call=FALSE)
    if (any(duplicated(univ))) {
      warning("removing duplicate IDs in universeGeneIds")
      univ <- unique(univ)
    }
    universeGeneIds(object) <- univ
    if (!all(sel %in% univ)) {
      warning("removing geneIds not in universeGeneIds")
      sel <- intersect(sel, univ)
      if (!length(sel))
        stop("no geneIds in universeGeneIds", .Call=FALSE)
      geneIds(object) <- sel
    }
  }
  pv <- pvalueCutoff(object)
  if (pv > 1 || pv < 0){
    stop("invalid pvalueCutoff, must be between 0 and 1", .Call=FALSE)}
  return(object)
}

## Based on Category/R/HyperGParams-accessors.R
## Generic is defiend in Category/R/AllGenerics.R
setMethod("makeValidParams", "MeSHHyperGParams", .makeValidMeSHParams)

## Based on Category/R/HyperGParams-accessors.R
## Generic is defined in GSEABase/R/AllGenerics.R
setMethod("geneIds", "MeSHHyperGParams", function(object, ...) object@geneIds)
setReplaceMethod("geneIds", "MeSHHyperGParams", function(object, value) {
    object@geneIds <- value
    object
  })

## Based on Category/R/HyperGParams-accessors.R
## Generic is defiend in Category/R/AllGenerics.R
setMethod("universeGeneIds", "MeSHHyperGParams", function(r) r@universeGeneIds)
setReplaceMethod("universeGeneIds", "MeSHHyperGParams", function(r, value) {
    r@universeGeneIds <- value
    r
  })

## Based on Category/R/HyperGParams-accessors.R
## Generic is defiend in Category/R/AllGenerics.R
setMethod("annotation", "MeSHHyperGParams", function(object) object@annotation)
setReplaceMethod("annotation", c("MeSHHyperGParams", "character"),
                 function(object, value) {
                   object@annotation <- value
                   object
                 })

## Our original
setMethod("category", "MeSHHyperGParams", function(r) r@category)
setReplaceMethod("category", c("MeSHHyperGParams", "character"),
    function(r, value) {
    r@category <- value
    r
  })

## Our original
setMethod("database", "MeSHHyperGParams", function(r) r@database)
setReplaceMethod("database", c("MeSHHyperGParams", "character"),
    function(r, value) {
    r@database <- value
    r
  })


setMethod("pAdjust", "MeSHHyperGParams", function(r) r@pAdjust)
setReplaceMethod("pAdjust", c("MeSHHyperGParams", "character"),
    function(r, value) {
    r@pAdjust <- value
    r
  })


## Based on Category/R/HyperGParams-accessors.R
## Generic is defined in Category/R/AllGeneric.R
setMethod("pvalueCutoff", "MeSHHyperGParams", function(r) r@pvalueCutoff)
setReplaceMethod("pvalueCutoff", "MeSHHyperGParams", function(r, value) {
    r@pvalueCutoff <- value
    r
})

