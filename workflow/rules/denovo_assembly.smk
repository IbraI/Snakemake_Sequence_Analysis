rule spades_denovo:
    input:
        r1=lambda wildcards: cleaned_read(wildcards.sample, "1"),
        r2=lambda wildcards: cleaned_read(wildcards.sample, "2")
    output:
        contigs="results/assembly/denovo_contigs/{sample}.fasta",
        outdir=directory("results/spades/{sample}")
    log:
        "logs/spades/{sample}.log"
    params:
        extra=config.get("spades", {}).get("extra", "")
    threads: 8
    conda:
        "../envs/assembly.yaml"
    shell:
        "spades.py -1 {input.r1} -2 {input.r2} "
        "-o {output.outdir} -t {threads} {params.extra} > {log} 2>&1 && "
        "cp {output.outdir}/contigs.fasta {output.contigs}"


rule ragtag_scaffold_denovo:
    input:
        contigs="results/assembly/denovo_contigs/{sample}.fasta",
        ref=config["ref"]
    output:
        assembly="results/assembly/denovo/{sample}.fasta",
        outdir=directory("results/ragtag/{sample}")
    log:
        "logs/ragtag/{sample}.log"
    params:
        extra=config.get("ragtag", {}).get("extra", "")
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "ragtag.py scaffold {params.extra} -t {threads} -o {output.outdir} "
        "{input.ref} {input.contigs} > {log} 2>&1 && "
        "cp {output.outdir}/ragtag.scaffold.fasta {output.assembly}"