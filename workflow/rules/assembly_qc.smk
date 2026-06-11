rule quast_reference:
    input:
        assembly="results/assembly/reference/{sample}.fasta",
        ref=config["ref"]
    output:
        directory("results/quast/reference/{sample}")
    log:
        "logs/quast/reference/{sample}.log"
    threads: 4
    conda:
        "../envs/assembly_qc.yaml"
    shell:
        "quast.py {input.assembly} -r {input.ref} -o {output} -t {threads} > {log} 2>&1"


rule quast_denovo:
    input:
        assembly="results/assembly/denovo/{sample}.fasta",
        ref=config["ref"]
    output:
        directory("results/quast/denovo/{sample}")
    log:
        "logs/quast/denovo/{sample}.log"
    threads: 4
    conda:
        "../envs/assembly_qc.yaml"
    shell:
        "quast.py {input.assembly} -r {input.ref} -o {output} -t {threads} > {log} 2>&1"


rule samtools_flagstat:
    input:
        bam="results/mapping/{sample}.sorted.bam",
        bai="results/mapping/{sample}.sorted.bam.bai"
    output:
        "results/mapping_qc/{sample}.flagstat.txt"
    log:
        "logs/samtools/{sample}.flagstat.log"
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "samtools flagstat -@ {threads} {input.bam} > {output} 2> {log}"
        

rule qualimap_bamqc:
    input:
        bam="results/mapping/{sample}.sorted.bam",
        bai="results/mapping/{sample}.sorted.bam.bai"
    output:
        directory("results/qualimap/{sample}")
    log:
        "logs/qualimap/{sample}.log"
    threads: 4
    conda:
        "../envs/assembly_qc.yaml"
    shell:
        "qualimap bamqc "
        "-bam {input.bam} "
        "-outdir {output} "
        "-nt {threads} "
        "--java-mem-size=4G "
        "> {log} 2>&1"    