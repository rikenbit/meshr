library("jsonlite")
library("reutils")

meshParams <- new("MeSHHyperGParams", geneIds=sig.geneid.cummeRbund[,2], universeGeneIds=geneid.cummeRbund[,2],
                  annotation="org.MeSH.Hsa.db", category="D", database="gene2pubmed", pvalueCutoff=0.05, pAdjust="none")
meshR <- meshHyperGTest(meshParams)

save.json <- function(x, output="./mesh.json", type="Type4"){

	# Extract only list object
	list_data <- summary(x)

	if(meshR@meshDatabase != "gene2pubmed"){
		stop("PubMed ID retreival is possible when users specify\ndatabase as 'gene2pubmed' at the moment...")
	}

	switch(type,
		# Type 1 : PubMed ID
		"Type1" = {
			hierarchy <- "PubMedID"
			out <- list()
		},
		# Type 2 : Gene ID - PubMed ID
		"Type2" = {
			hierarchy <- list(GeneID="PubMedID")
			out <- list(list())
		},
		# Type 3 : MeSH ID - PubMed ID
		"Type3" = {
			hierarchy <- list(MeSHID="PubMedID")
			out <- list(list())
		},
		# Type 4 : MeSH ID - Gene ID - PubMed ID
		"Type4" = {
			hierarchy <- list(MeSHID= list(GeneID = "PubMedID"))
			out <- list(list(list()))
		},
		# Type 5 : Gene ID - MeSH ID - PubMed ID
		"Type5" = {
			hierarchy <- list(GeneID= list(MeSHID = "PubMedID"))
			out <- list(list(list()))
		}
	)


	# Gene Name <- Gene ID  (over write)

	# MeSH Name <- MeSH ID  (over write)


	# Output
	sink(output)
	toJSON(out)
	sink()
}

PubMedID <- c("19148276", "11080476")

# Attach PubMed ID
.Attach_PubMedID <- function(x){
	out <- c()
	for(i in 1:length(x)){
		print(paste0(i, " / ", length(x)))
		pre_data <- select(
				eval(parse(text=meshR@meshAnnotation)),
				keys = names(x)[[i]],
				columns = c("GENEID", "SOURCEID"),
				keytype = "MESHID"
				)
		pre_data <- pre_data[!is.na(pre_data[,2]), ]

		for(j in 1:length(x[[i]]$GeneID)){
			out <- rbind(out, pre_data[which(pre_data[,1] == x[[i]]$GeneID[[j]]), ])
		}
	}
	return(out)
}



.Attach_Title_Date_Cite <- function(PubMedID){
	xml_data <- try(content(esummary(PubMedID, "pubmed"), "parsed"))

	##### Attach Title, Date, and Cite #####
	Title_Date_Cite <- sapply(PubMedID, function(x){
		return(
			list(
				Title = eval(parse(text=paste0("xml_data$'",x, "'$Title"))),
				Date = eval(parse(text=paste0("xml_data$'",x, "'$PubDate")))
			)
		)
	}
	)
}





out <- list(
	####### 階層情報 #######
	hierarchy = hierarchy,

	####### データ #######
	data = list(
		# MeSH ID
		"D00241" = list(
			#Gene ID
			"23523" = list(
				# PubMed ID
				"42525" = list(
					Title = "hoge1",
					Year = "2011",
					Cite =  "3"
				),
				"352345" = list(
					Title = "hoge2",
					Year = "2012",
					Cite =  "45"
				),
				"564868" = list(
					Title = "hoge3",
					Year = "2013",
					Cite =  "32"
				)
			),
			#Gene ID
			"32323" = list(
				# PubMed ID
				"3212" = list(
					Title = "hoge4",
					Year = "2001",
					Cite =  "324"
				),
				"6436534" = list(
					Title = "hoge5",
					Year = "2014",
					Cite =  "44"
				),
				"23543462" = list(
					Title = "hoge6",
					Year = "2014",
					Cite =  "23"
				)
			)
		)
	)
)
