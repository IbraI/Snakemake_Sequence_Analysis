rule bwa_mem2_index:
    input:
        ref=config["ref"]
    output:
        idx=multiext(
            "results/bwa_index/reference",
            ".0123", ".amb", ".ann", ".bwt.2bit.64", ".pac"
        )
    log:
        "logs/bwa_mem2/index.log"
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "bwa-mem2 index -p results/bwa_index/reference {input.ref} > {log} 2>&1"


rule bwa_mem2_map:
    input:
        r1=lambda wildcards: cleaned_read(wildcards.sample, "1"),
        r2=lambda wildcards: cleaned_read(wildcards.sample, "2"),
        idx=rules.bwa_mem2_index.output.idx
    output:
        "results/mapping/{sample}.sam"
    log:
        "logs/bwa_mem2/{sample}.log"
    params:
        index="results/bwa_index/reference",
        extra=config.get("bwa_mem2", {}).get("extra", "")
    threads: 8
    conda:
        "../envs/assembly.yaml"
    shell:
        "bwa-mem2 mem -t {threads} {params.extra} {params.index} "
        "{input.r1} {input.r2} > {output} 2> {log}"


rule sam_to_sorted_bam:
    input:
        "results/mapping/{sample}.sam"
    output:
        "results/mapping/{sample}.sorted.bam"
    log:
        "logs/samtools/{sample}.sort.log"
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "samtools view -@ {threads} -bS {input} 2> {log} | "
        "samtools sort -@ {threads} -o {output} - 2>> {log}"


rule index_sorted_bam:
    input:
        "results/mapping/{sample}.sorted.bam"
    output:
        "results/mapping/{sample}.sorted.bam.bai"
    log:
        "logs/samtools/{sample}.index.log"
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "samtools index -@ {threads} {input} {output} 2> {log}"


rule reference_consensus:
    input:
        bam="results/mapping/{sample}.sorted.bam",
        bai="results/mapping/{sample}.sorted.bam.bai"
    output:
        "results/assembly/reference/{sample}.fasta"
    log:
        "logs/samtools/{sample}.consensus.log"
    threads: 4
    conda:
        "../envs/assembly.yaml"
    shell:
        "samtools consensus "
        "-f fasta "
        "{input.bam} "
        "> {output} "
        "2> {log}"

