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

## JSON output function.
## Converted by PubMedQuery and then launch web-browser based visualization.
## Please check : https://github.com/rikenbit/PubMedQuery
setMethod("save.json", "MeSHHyperGResult", function(object){
	# 実装中
})
