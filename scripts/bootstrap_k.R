library(scclusteval)

seurat_obj<- readRDS(snakemake@input[[1]])
k<- snakemake@wildcards[["k"]]
PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]

subset_seurat_obj<- RandomSubsetData(seurat_obj, rate = snakemake@params[["rate"]])

subset_seurat_obj<- eval(parse(text=paste("PreprocessSubsetData", "(", "subset_seurat_obj,", "k=", k, ",", PreprocessSubsetData_pars, ")")))

res<- list(ident = subset_seurat_obj@ident, pc.sig = subset_seurat_obj@meta.data$pc.sig)
run_id<- snakemake@wildcards[["run_id"]]
save(res, file = paste0("bootstrap_k/bootstrap_k_", k, "_round_", run_id, ".rda" ))