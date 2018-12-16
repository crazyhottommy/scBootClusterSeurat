library(tidyverse)
rdss<- snakemake@input[["rds"]]

get_ident<- function(rds){
	res<- readRDS(rds)
	ident<- res$ident
	k<- res$k
	return(list(k = k ,ident = ident))
}

res<- lapply(rdss, get_ident)

idents<- purrr::map(res, "ident")
ks<- purrr::map_chr(res, "k")

## put the idents of the same k into a list
idents<- split(idents, ks)

saveRDS(idents, file = "gather_bootstrap_k.rds")