# scBootClusterSeurat
A snakemake pipeline to scatter and gather bootstrapped Seurat@ident

on `odyssey` cluster(SLURM):

```bash
ssh odyssey

## start a screen session
screen

git clone https://github.com/crazyhottommy/scBootClusterSeurat

conda create n=snakemake python=3.6 snakemake

source activate snakemake

# R3.5.1, make sure you load R after source activate conda environment
module load R

#hdf5
module load hdf5

R
>install.package("Seurat")
>devtools:install_github("crazyhottommy/scclusteval")



```