rule collect_assemblies:
    input:
        lambda wildcards: [selected_assembly(sample) for sample in SAMPLES]
    output:
        "results/phylogeny/all_genomes.fasta"
    log:
        "logs/phylogeny/collect_assemblies.log"
    conda:
        "../envs/phylogeny.yaml"
    script:
        "../scripts/collect_assemblies.py"


rule mafft_alignment:
    input:
        "results/phylogeny/all_genomes.fasta"
    output:
        "results/phylogeny/aligned_genomes.fasta"
    log:
        "logs/phylogeny/mafft.log"
    threads: 8
    conda:
        "../envs/phylogeny.yaml"
    shell:
        "mafft --thread {threads} --auto {input} > {output} 2> {log}"


rule iqtree:
    input:
        "results/phylogeny/aligned_genomes.fasta"
    output:
        treefile="results/phylogeny/iqtree/aligned_genomes.fasta.treefile",
        nwk="results/phylogeny/tree.nwk"
    log:
        "logs/phylogeny/iqtree.log"
    threads: 8
    conda:
        "../envs/phylogeny.yaml"
    shell:
        "mkdir -p results/phylogeny/iqtree && "
        "iqtree2 -s {input} -m MFP -B 1000 -T {threads} -redo --prefix results/phylogeny/iqtree/aligned_genomes.fasta > {log} 2>&1 && "
        "cp {output.treefile} {output.nwk}"


rule plot_tree:
    input:
        "results/phylogeny/tree.nwk"
    output:
        "results/phylogeny/tree.pdf"
    log:
        "logs/phylogeny/plot_tree.log"
    conda:
        "../envs/phylogeny.yaml"
    script:
        "../scripts/plot_tree.py"

