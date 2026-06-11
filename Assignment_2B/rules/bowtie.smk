# Build bowtie2 index inside results/, not in the user-provided reference directory.
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
        r1=get_fq1,
        r2=get_fq2,
        idx=rules.bowtie2_build.output.idx
    output:
        "results/sam/{sample}.sam"
    log:
        "logs/bowtie2/{sample}.log"
    params:
        index="results/bowtie2_index/reference",
        preset=config["bt2_preset"],
        extra=config["bt2_extra"]
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "bowtie2 {params.preset} {params.extra} -p {threads} -x {params.index} "
        "-1 {input.r1} -2 {input.r2} -S {output} 2> {log}"
