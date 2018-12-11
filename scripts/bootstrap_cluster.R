library(scclusteval)

seurat_obj<- readRDS(snakemake@input[[1]])
PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]
subset_seurat_obj<- RandomSubsetData(seurat_obj, rate = snakemake@params[["rate"]])
subset_seurat_obj<- PreprocessSubsetData(subset_seurat_obj, PreprocessSubsetData_pars)

res<- list(ident = object@ident, pc.sig = object@meta.data$pc.sig))
run_id<- snakemake@wildcards[["run_id"]]
save(res, file = paste0("bootstrap_cluster/bootstrap_cluster_", run_id, ".rda" )