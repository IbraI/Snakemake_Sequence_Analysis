rule bowtie2_build:
    input:
        ref=config["ref"]
    output:
        idx=multiext(
            "results/bowtie2_index/reference",
            ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2"
        )
    log:
        "logs/bowtie2/build.log"
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "bowtie2-build --threads {threads} {input.ref} results/bowtie2_index/reference > {log} 2>&1"

rule bowtie2_map:
    input:
        r1=lambda wildcards: samples.at[wildcards.sample, "fq1"] if SKIP_TRIMMING else f"results/trimmed/{wildcards.sample}_1.paired.fastq.gz",
        r2=lambda wildcards: samples.at[wildcards.sample, "fq2"] if SKIP_TRIMMING else f"results/trimmed/{wildcards.sample}_2.paired.fastq.gz",
        idx=rules.bowtie2_build.output.idx
    output:
        "results/sam/{sample}.sam"
    log:
        "logs/bowtie2/{sample}.log"
    params:
        index="results/bowtie2_index/reference",
        N=config["bowtie2"]["N"],
        L=config["bowtie2"]["L"],
        D=config["bowtie2"]["D"],
        R=config["bowtie2"]["R"]
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "bowtie2 "
        "-p {threads} "
        "-x {params.index} "
        "-N {params.N} "
        "-L {params.L} "
        "-D {params.D} "
        "-R {params.R} "
        "-1 {input.r1} "
        "-2 {input.r2} "
        "-S {output} "
        "2> {log}"
