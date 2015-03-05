desc "全てのtaskを実行する"
task :default do
	sh "rake BUILD"
	sh "rake CHECK"
	sh "rake INSTALL"
end

desc "CLEAN"
task :CLEAN do
	sh "rm meshr/.*&"
	sh "rm meshr/*/.*&"
	sh "rm meshr/*/*/.*&"
	sh "rm meshr/*/*/*/.*&"
	sh "rm meshr/._*&"
	sh "rm meshr/*/._*&"
	sh "rm meshr/*/*/._*&"
	sh "rm meshr/*/*/*/._*&"
end

desc "VIGNETTE"
task :VIGNETTE do
	sh "echo 'library(\"utils\");Stangle(\"meshr/vignettes/MeSH.Rnw\")' | R --no-save --no-restore"
	sh "cp MeSH.R meshr/vignettes"
	sh "cp MeSH.R meshr/inst/doc"
	sh "echo 'library(\"utils\");Sweave(\"meshr/vignettes/MeSH.Rnw\")' | R --no-save --no-restore"
	sh "cp MeSH.pdf meshr/vignettes"
	sh "cp MeSH.pdf meshr/inst/doc"
	sh "cp MeSH.tex meshr/vignettes"
	sh "cp MeSH.tex meshr/inst/doc"
	sh "cp MeSH-concordance.tex meshr/vignettes"
	sh "cp MeSH-concordance.tex meshr/inst/doc"
end

desc "BUILD"
task :BUILD do
	sh "R CMD BUILD --resave-data meshr"
end

desc "CHECK"
task :CHECK do
	sh "R CMD CHECK meshr_1.2.5.tar.gz"
end

desc "INSTALL"
task :INSTALL do
	sh "R CMD INSTALL meshr_1.2.5.tar.gz"
end
