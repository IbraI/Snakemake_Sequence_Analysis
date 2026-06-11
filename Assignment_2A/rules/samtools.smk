rule sam_to_bam:
    input: "results/sam/{sample}.sam"
    output: "results/bam/{sample}.sorted.bam"
    conda: "../envs/bio_env.yaml"
    shell: "samtools sort {input} -o {output}"

rule index_bam:
    input: "results/bam/{sample}.sorted.bam"
    output: "results/bam/{sample}.sorted.bam.bai"
    conda: "../envs/bio_env.yaml"
    shell: "samtools index {input}"
