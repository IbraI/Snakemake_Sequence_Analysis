# Assignment 4: Human Adenovirus Snakemake Workflow

This workflow is planned for Human Adenovirus sequencing analysis. It extends the earlier QC/mapping workflow and adds genome assembly, phylogenetic reconstruction, and sliding-window variability analysis.

## Main outputs

- assembled genomes for each sample
- multiple sequence alignment
- phylogenetic tree in Newick format
- tree visualization as PDF/PNG
- average sequence variability per window
- variability plot along the genome

## Typical commands

Dry run:

```bash
snakemake -s workflow/Snakefile -n -p --use-conda --cores 8
```

Run raw QC only:

```bash
snakemake -s workflow/Snakefile --use-conda --cores 8 run_raw_qc
```

Run full workflow:

```bash
snakemake -s workflow/Snakefile --use-conda --cores 8
```

Before running, edit `config/config.yaml` and `config/samples.tsv`.


## Portability notes

Run Snakemake from the project root directory. The main Snakefile is located at `workflow/Snakefile`, so either run `snakemake` from the root directory if your Snakemake version detects `workflow/Snakefile`, or explicitly use:

```bash
snakemake -s workflow/Snakefile --use-conda --cores 8
```

The workflow does not ship generated `results/`, `logs/`, or `.snakemake/` directories. They will be generated automatically during execution. Adapter resources are provided under `resources/adapters/`.
