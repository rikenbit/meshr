### R code from vignette source 'MeSH.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: MeSH.Rnw:151-152
###################################################
library(MeSH.db)


###################################################
### code chunk number 2: MeSH.Rnw:158-160
###################################################
ls("package:MeSH.db")
MeSH.db


###################################################
### code chunk number 3: MeSH.Rnw:168-169
###################################################
columns(MeSH.db)


###################################################
### code chunk number 4: MeSH.Rnw:176-177
###################################################
keytypes(MeSH.db)


###################################################
### code chunk number 5: MeSH.Rnw:184-187
###################################################
k <- keys(MeSH.db, keytype="MESHID")
length(k)
head(k)


###################################################
### code chunk number 6: MeSH.Rnw:193-195
###################################################
select(MeSH.db, keys=k[1:10], columns=c("MESHID","MESHTERM"),
       keytype="MESHID")


###################################################
### code chunk number 7: MeSH.Rnw:206-209
###################################################
LEU <- select(MeSH.db, keys="Leukemia",
              columns=c("MESHID", "MESHTERM", "CATEGORY", "SYNONYM"), keytype="MESHTERM")
LEU


###################################################
### code chunk number 8: MeSH.Rnw:218-222
###################################################
library("MeSH.AOR.db")
ANC <- select(MeSH.AOR.db, keys="D007938",
        columns=c("ANCESTOR","OFFSPRING"), keytype="OFFSPRING")
ANC


###################################################
### code chunk number 9: MeSH.Rnw:229-230
###################################################
select(MeSH.db, keys=ANC[1,1], columns=c("MESHTERM"), keytype="MESHID")


###################################################
### code chunk number 10: MeSH.Rnw:237-241
###################################################
OFF <- select(MeSH.AOR.db, keys="D007938",
       columns=c("ANCESTOR","OFFSPRING"), keytype="ANCESTOR")
OFF
select(MeSH.db, keys=OFF[,2], columns=c("MESHTERM"), keytype="MESHID")


###################################################
### code chunk number 11: MeSH.Rnw:248-253
###################################################
library("MeSH.PCR.db")
CHI <- select(MeSH.PCR.db, keys=LEU[1,1],
       columns=c("PARENT","CHILD"), keytype="PARENT")
head(CHI)
head(select(MeSH.db, keys=CHI[,2], columns=c("MESHTERM"), keytype="MESHID"))


###################################################
### code chunk number 12: MeSH.Rnw:266-270
###################################################
dbInfo(MeSH.db)
dbfile(MeSH.db)
dbschema(MeSH.db)
dbconn(MeSH.db)


###################################################
### code chunk number 13: MeSH.Rnw:276-297
###################################################
library("RSQLite")
SQL1 <- paste(
  "SELECT MESHTERM, QUALIFIERID, QUALIFIER FROM DATA",
  "WHERE MESHID = 'D000001'",
  "AND QUALIFIERID = 'Q000494'"
)
dbGetQuery(dbconn(MeSH.db), SQL1)
SQL2 <- paste(
  "SELECT ANCESTOR, OFFSPRING FROM DATA",
  "WHERE OFFSPRING = 'D000002'",
  "OR OFFSPRING = 'D000003'",
  "OR OFFSPRING = 'D000004'",
  "OR ANCESTOR = 'D009275'"
)
dbGetQuery(dbconn(MeSH.AOR.db), SQL2)
SQL3 <- paste(
  "SELECT PARENT, CHILD FROM DATA",
  "WHERE PARENT = 'D000005'",
  "AND NOT CHILD = 'D004312'"
)
dbGetQuery(dbconn(MeSH.PCR.db), SQL3)


###################################################
### code chunk number 14: MeSH.Rnw:307-313
###################################################
library("org.MeSH.Hsa.db")
columns(org.MeSH.Hsa.db)
keytypes(org.MeSH.Hsa.db)
key_HSA <- keys(org.MeSH.Hsa.db, keytype="MESHID")
select(MeSH.db, keys=key_HSA[1:10], columns=c("MESHID","MESHTERM"),
       keytype="MESHID")


###################################################
### code chunk number 15: MeSH.Rnw:319-335
###################################################
library("org.MeSH.Aca.db")
library("org.MeSH.Atu.K84.db")
library("org.MeSH.Bsu.168.db")
library("org.MeSH.Syn.db")

species(org.MeSH.Hsa.db)
species(org.MeSH.Aca.db)
species(org.MeSH.Atu.K84.db)
species(org.MeSH.Bsu.168.db)
species(org.MeSH.Syn.db)

nomenclature(org.MeSH.Hsa.db)
nomenclature(org.MeSH.Aca.db)
nomenclature(org.MeSH.Atu.K84.db)
nomenclature(org.MeSH.Bsu.168.db)
nomenclature(org.MeSH.Syn.db)


###################################################
### code chunk number 16: MeSH.Rnw:342-347
###################################################
listDatabases(org.MeSH.Hsa.db)
listDatabases(org.MeSH.Aca.db)
listDatabases(org.MeSH.Atu.K84.db)
listDatabases(org.MeSH.Bsu.168.db)
listDatabases(org.MeSH.Syn.db)


###################################################
### code chunk number 17: MeSH.Rnw:357-359
###################################################
library("MeSHDbi")
example("makeGeneMeSHPackage")


###################################################
### code chunk number 18: MeSH.Rnw:375-378
###################################################
library("meshr")
data(geneid.cummeRbund)
data(sig.geneid.cummeRbund)


###################################################
### code chunk number 19: MeSH.Rnw:386-388
###################################################
dim(geneid.cummeRbund)[1]
dim(sig.geneid.cummeRbund)[1]


###################################################
### code chunk number 20: MeSH.Rnw:395-397
###################################################
library("fdrtool")
library("org.MeSH.Hsa.db")


###################################################
### code chunk number 21: MeSH.Rnw:408-410
###################################################
meshParams <- new("MeSHHyperGParams", geneIds=sig.geneid.cummeRbund[,2], universeGeneIds=geneid.cummeRbund[,2],
                  annotation="org.MeSH.Hsa.db", category="D", database="gendoo", pvalueCutoff=0.05, pAdjust="none")


###################################################
### code chunk number 22: MeSH.Rnw:417-418
###################################################
meshR <- meshHyperGTest(meshParams)


###################################################
### code chunk number 23: MeSH.Rnw:426-427
###################################################
meshR


###################################################
### code chunk number 24: MeSH.Rnw:435-436
###################################################
head(summary(meshR))


###################################################
### code chunk number 25: MeSH.Rnw:444-448
###################################################
category(meshParams) <- "G"
database(meshParams) <- "gene2pubmed"
meshR <- meshHyperGTest(meshParams)
meshR


###################################################
### code chunk number 26: session
###################################################
sessionInfo()


