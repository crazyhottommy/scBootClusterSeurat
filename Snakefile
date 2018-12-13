shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

CLUSTER = json.load(open(config['CLUSTER_JSON']))

NUM_OF_BOOTSTRAP = config["num_of_bootstrap"]
ks = config["bootstrap_ks"].strip().split()
resolutions = config["bootstrap_resolutions"].strip().split()


BOOTSTRAP_K = []
BOOTSTRAP_RESOLUTION = []
BOOTSTRAP_K_and_RESOLUTION = []

BOOTSTRAP_K = expand("bootstrap_k/bootstrap_k_{k}_round_{run_id}.rda", k = ks, run_id = range(NUM_OF_BOOTSTRAP))

BOOTSTRAP_RESOLUTION = expand("bootstrap_resolution/bootstrap_resolution_{resolution}_round_{run_id}.rda", \
		resolution = resolutions, run_id = range(NUM_OF_BOOTSTRAP))

BOOTSTRAP_K_and_RESOLUTION = expand("bootstrap_k_and_resolution/bootstrap_k_{k}_resolution_{resolution}_round_{run_id}.rda", \
	k = ks, resolution = resolutions, run_id = range(NUM_OF_BOOTSTRAP))


TARGETS = []
if config["bootstrap_k"]:
	TARGETS.extend(BOOTSTRAP_K)
	TARGETS.append("gather_bootstrap_k.rda")
if config["bootstrap_resolution"]:
	TARGETS.extend(BOOTSTRAP_RESOLUTION)
	TARGETS.append("gather_bootstrap_resolution.rda")
if config["bootstrap_k_and_resolution"]:
	TARGETS.extend(BOOTSTRAP_K_and_RESOLUTION)
	TARGETS.append("gather_bootstrap_k_and_resolution.rda")


localrules: all, gather_bootstrap_k, gather_bootstrap_resolution, gather_bootstrap_k_and_resolution
rule all:
    input: TARGETS


if config["bootstrap_k"]:
	rule bootstrap_k_preprocess:
		input: "seurat_obj.rds"
		output: "bootstrap_k_preprocess/bootstrap_k_{k}.rds"
		log: "00log/bootstrap_k_{k}.log"
		threads: CLUSTER["bootstrap_k_preprocess"]["n"]
		params: jobname = "bootstrap_k_{k}",
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_k_pars", "")
		message: "preprocessing original seurat object using k of {wildcards.k} with {threads} threads"
		script: "scripts/preprocess_k.R"
	
	rule bootstrap_k:
		input: "bootstrap_k_preprocess/bootstrap_k_{k}.rds"
		output: "bootstrap_k/bootstrap_k_{k}_round_{run_id}.rda"
		log: "00log/bootstrap_k_{k}_round_{run_id}.log"
		threads: CLUSTER["bootstrap_k"]["n"]
		params: jobname = "bootstrap_k_{k}_round_{run_id}",
				rate = config["subsample_rate"],
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_k_pars", "")
		message: "bootstrapping k {wildcards.k} for round {wildcards.run_id} using {threads} threads"
		script: "scripts/bootstrap_k.R"


if config["bootstrap_resolution"]:
	rule bootstrap_resolution_preprocess:
		input: "seurat_obj.rds"
		output: "bootstrap_resolution_preprocess/bootstrap_resolution_{resolution}.rds"
		log: "00log/bootstrap_resolution_{resolution}.log"
		threads: CLUSTER["bootstrap_resolution_preprocess"]["n"]
		params: jobname = "bootstrap_resolution_{resolution}",
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_resolution_pars", "")
		message: "preprocessing original seurat object using resolution of {wildcards.resolution} with {threads} threads"
		script: "scripts/preprocess_resolution.R"

	rule bootstrap_resolution:
		input: "bootstrap_resolution_preprocess/bootstrap_resolution_{resolution}.rds"
		output: "bootstrap_resolution/bootstrap_resolution_{resolution}_round_{run_id}.rda"
		log: "00log/bootstrap_resolution_{resolution}_round_{run_id}.log"
		threads: CLUSTER["bootstrap_resolution"]["n"]
		params: jobname = "bootstrap_resolution_{resolution}_round_{run_id}",
				rate = config["subsample_rate"],
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_resolution_pars", "")
		message: "bootstrapping resolution {wildcards.resolution} for round {wildcards.run_id} using {threads} threads"
		script: "scripts/bootstrap_resolution.R"



if config["bootstrap_k_and_resolution"]:
	rule bootstrap_k_and_resolution_preprocess:
		input: "seurat_obj.rds"
		output: "bootstrap_k_and_resolution_preprocess/bootstrap_k_{k}_resolution_{resolution}.rds"
		log: "00log/bootstrap_k_{k}_resolution_{resolution}.log"
		threads: CLUSTER["bootstrap_k_and_resolution_preprocess"]["n"]
		params: jobname = "bootstrap_k_{k}_resolution_{resolution}",
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_k_and_resolution_pars", "")
		message: "preprocessing original seurat object using k {wildcards.k} resolution {wildcards.resolution} with {threads} threads"
		script: "scripts/preprocess_k_and_resolution.R"

	rule bootstrap_k_and_resolution:
		input: "bootstrap_resolution_preprocess/bootstrap_resolution_{resolution}.rds"
		output: "bootstrap_k_and_resolution/bootstrap_k_{k}_resolution_{resolution}_round_{run_id}.rda"
		log: "00log/bootstrap_k_{k}_resolution_{resolution}_round_{run_id}.log"
		threads: CLUSTER["bootstrap_k_and_resolution"]["n"]
		params: jobname = "bootstrap_k_{k}_resolution_{resolution}_round_{run_id}",
				rate = config["subsample_rate"],
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_bootstrap_k_and_resolution_pars", "")
		message: "bootstrapping k {wildcards.k} resolution {wildcards.resolution} for round {wildcards.run_id} using {threads} threads"
		script: "scripts/bootstrap_k_and_resolution.R"

if config["bootstrap_k"]:
	rule gather_bootstrap_k:
		input: rdas = BOOTSTRAP_K
		output: "gather_bootstrap_k.rda"
		log: "00log/gather_bootstrap_k.log"
		threads: 1
		message: "gathering idents for bootstrap k"
		script: "scripts/gather_bootstrap_k.R"


if config["bootstrap_resolution"]:
	rule gather_bootstrap_resolution:
		input: rdas = BOOTSTRAP_RESOLUTION
		output: "gather_bootstrap_resolution.rda"
		log: "00log/gather_bootstrap_resolution.log"
		threads: 1
		message: "gathering idents for bootstrap resolution"
		script: "scripts/gather_bootstrap_resolution.R"

if config["bootstrap_k"]:
	rule gather_bootstrap_k_and_resolution:
		input: rdas = BOOTSTRAP_K_and_RESOLUTION
		output: "gather_bootstrap_k_and_resolution.rda"
		log: "00log/gather_bootstrap_k_and_resolution.log"
		threads: 1
		message: "gathering idents for bootstrap k and resolution"
		script: "scripts/gather_bootstrap_k_and_resolution.R"

