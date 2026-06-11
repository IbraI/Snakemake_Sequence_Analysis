rule compute_variability:
    input:
        alignment="results/phylogeny/aligned_genomes.fasta"
    output:
        per_base="results/variability/per_base_variability.tsv",
        table="results/variability/window_variability.tsv",
        plot="results/variability/variability_plot.png"
    log:
        "logs/variability/compute_variability.log"
    params:
        window_size=config.get("variability", {}).get("window_size", 500),
        step_size=config.get("variability", {}).get("step_size", 50),
        ignore_gaps=config.get("variability", {}).get("ignore_gaps", True)
    conda:
        "../envs/phylogeny.yaml"
    script:
        "../scripts/compute_variability.py"
