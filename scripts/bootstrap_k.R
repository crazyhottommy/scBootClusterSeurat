library(scclusteval)

## see https://bitbucket.org/snakemake/snakemake/issues/917/enable-stdout-and-stderr-redirection
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

seurat_obj<- readRDS(snakemake@input[[1]])
k<- snakemake@wildcards[["k"]]
PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]

subset_seurat_obj<- RandomSubsetData(seurat_obj, rate = snakemake@params[["rate"]])
original_ident<- subset_seurat_obj@ident

## after reprocessing, the ident slot will be updated with the new cluster id
command<- paste("PreprocessSubsetData", "(", "subset_seurat_obj,", "k.param=", k, ",", PreprocessSubsetData_pars, ")")
subset_seurat_obj<- eval(parse(text=command))

res<- list(original_ident = original_ident, ident = Idents(subset_seurat_obj), k = k, pc.use = subset_seurat_obj@meta.data$pc.use, calc.params = subset_seurat_obj@calc.params)
run_id<- snakemake@wildcards[["run_id"]]

outfile<- paste0("bootstrap_k/bootstrap_k_", k, "_round_", run_id, ".rds")
saveRDS(res, file = outfile)

## make sure it is not empty file
info<- file.info(outfile)
if (info$size == 0) {
	quit(status = 1)
}

