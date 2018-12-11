shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

CLUSTER = json.load(open(config['CLUSTER_JSON']))

NUM_OF_BOOTSTRAP = config["num_of_bootstrap"]
ks = config["bootstrap_ks"].split()
resolutions = config["bootstrap_resolutions"].split()

BOOTSTRAP_CLUSTER = []
BOOTSTRAP_CLUSTER = expand("bootstrap_cluster/bootstrap_cluster_{run_id}.rda", run_id = range(NUM_OF_BOOTSTRAP))

BOOTSTRAP_K = []
BOOTSTRAP_RESOLUTION = []
BOOTSTRAP_K_and_RESOLUTION = []

BOOTSTRAP_K = expand("bootstrap_k/bootstrap_k_{k}.rda", k = ks)

BOOTSTRAP_RESOLUTION = expand("bootstrap_resolution/bootstrap_resolution_{resolution}.rda", \
		resolution = resolutions)

BOOTSTRAP_K_and_RESOLUTION = expand("bootstrap_k_and_resolution/bootstrap_k_{k}_resolution_{resolution}.rda", \
	k = ks, resolution = resolutions)


TARGETS = []
if config["bootstrap_cluster"]:
	TARGETS.extend(BOOTSTRAP_CLUSTER)
	TARGETS.append("gather_bootstrap_cluster.rda")
if config["bootstrap_k"]:
	TARGETS.extend(BOOTSTRAP_K)
if config["bootstrap_resolution"]:
	TARGETS.extend(BOOTSTRAP_RESOLUTION)
if config["bootstrap_k_and_resolution"]:
	TARGETS.extend(BOOTSTRAP_K_and_RESOLUTION)


localrules: all, gather_cluster
rule all:
    input: TARGETS


if config["bootstrap_cluster"]:
	rule bootstrap_cluster:
		input: "seurat_obj.rds" 
		output: "bootstrap_cluster/bootstrap_cluster_{run_id}.rda"
		log: "00log/bootstrap_cluster_{run_id}.log"
		threads: CLUSTER["bootstrap_cluster"]["n"]
		params: jobname = "bootstrap_cluster_{run_id}",
				rate = config["subsample_rate"],
				PreprocessSubsetData_pars = config.get("PreprocessSubsetData_pars", "")
		message: "bootstrapping cluster for round {wildcards.run_id} using {threads} threads"
		script: "scripts/bootstrap_cluster.R"

if config["bootstrap_k"]:
	rule bootstrap_k:
		input: "seurat_obj.rds"
		output: "bootstrap_k/bootstrap_k_{k}.rda"
		log: "00log/bootstrap_k_{k}.log"
		threads: CLUSTER["bootstrap_cluster"]["n"]
		params: jobname = "bootstrap_k_{k}"
		message: "bootstrapping k for round {wildcards.k} using {threads} threads"
		script: "scripts/bootstrap_k.R"

if config["bootstrap_resolution"]:
	rule bootstrap_resolution:
		input: "seurat_obj.rds"
		output: "bootstrap_resolution/bootstrap_resolution_{resolution}.rda"
		log: "00log/bootstrap_resolution_{resolution}.log"
		threads: CLUSTER["bootstrap_cluster"]["n"]
		params: jobname = "bootstrap_resolution_{resolution}"
		message: "bootstrapping resolution for round {wildcards.resolution} using {threads} threads"
		script: "scripts/bootstrap_resolution.R"

if config["bootstrap_k_and_resolution"]:
	rule bootstrap_resolution:
		input: "seurat_obj.rds"
		output: "bootstrap_k_and_resolution/bootstrap_k_{k}_resolution_{resolution}.rda"
		log: "00log/bootstrap_k_{k}_resolution_{resolution}.log"
		threads: CLUSTER["bootstrap_cluster"]["n"]
		params: jobname = "bootstrap_k_{k}_resolution_{resolution}"
		message: "bootstrapping k {wildcards.k} resolution {wildcards.resolution} using {threads} threads"
		script: "scripts/bootstrap_k_and_resolution.R"


if config["bootstrap_cluster"]:
	rule gather_cluster:
		input: rdas = BOOTSTRAP_CLUSTER
		output: "gather_bootstrap_cluster.rda"
		log: "00log/gather_bootstrap_cluster.log"
		threads: 1
		message: "gathering idents for bootstrap cluster"
		script: "scripts/gather_bootstrap.R"


