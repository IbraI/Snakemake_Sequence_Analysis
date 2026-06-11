rule bowtie2_map:
    input:
        ref = config["ref"],
        r1 = config["fastq_dir"] + "/{sample}_1.fastq.gz",
        r2 = config["fastq_dir"] + "/{sample}_2.fastq.gz"
    output:
        "results/sam/{sample}.sam"
    conda:
        "../envs/bio_env.yaml"
    shell:
        "bowtie2 -x {input.ref} -1 {input.r1} -2 {input.r2} -S {output}"
