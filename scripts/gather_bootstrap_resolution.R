rdas<- snakemake@input[["rdas"]]

get_ident<- function(rda){
	load(rda)
	ident<- res$ident
	return(ident)
}

idents<- lapply(rdas, get_ident)

save(idents, file = "gather_bootstrap_resolution.rda")