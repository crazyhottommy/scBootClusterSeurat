library(scclusteval)

## see https://bitbucket.org/snakemake/snakemake/issues/917/enable-stdout-and-stderr-redirection
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

seurat_obj<- readRDS(snakemake@input[[1]])
k<- snakemake@wildcards[["k"]]
PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]
## this is not subsetted data, but the PreprocessSubsetData function can be used as well for any seurat object
seurat_obj<- eval(parse(text=paste("PreprocessSubsetData", "(", "seurat_obj,", "k.param=", k, ",", PreprocessSubsetData_pars, ")")))
saveRDS(seurat_obj, file = paste0("bootstrap_k_preprocess/bootstrap_k_", k, ".rds"))
