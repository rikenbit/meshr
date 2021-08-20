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
