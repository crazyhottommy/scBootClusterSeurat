log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library(tidyverse)
rdss<- snakemake@input[["rds"]]

get_ident<- function(rds){
	res<- readRDS(rds)
	original_ident<- res$original_ident
	ident<- res$ident
	k<- res$k
	return(list(k = k, original_ident = original_ident, ident = ident))
}

res<- lapply(rdss, get_ident)

original_idents = purrr::map(res, "original_ident")
idents<- purrr::map(res, "ident")
ks<- purrr::map_chr(res, "k")


## put the idents of the same k into a list
idents<- split(idents, ks)

original_idents<- split(original_idents, ks)

bootstrap_k_idents<- list(original_idents = original_idents, idents = idents)
saveRDS(bootstrap_k_idents, file = "gather_bootstrap_k.rds")

