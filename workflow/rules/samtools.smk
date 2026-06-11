rule sam_to_bam:
    input:
        "results/sam/{sample}.sam"
    output:
        "results/bam/{sample}.bam"
    log:
        "logs/samtools/{sample}.view.log"
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "samtools view -@ {threads} -bS {input} > {output} 2> {log}"

rule sort_bam:
    input:
        "results/bam/{sample}.bam"
    output:
        "results/bam_sorted/{sample}_sorted.bam"
    log:
        "logs/samtools/{sample}.sort.log"
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "samtools sort -@ {threads} {input} -o {output} 2> {log}"

rule index_bam:
    input:
        "results/bam_sorted/{sample}_sorted.bam"
    output:
        "results/bam_sorted/{sample}_sorted.bam.bai"
    log:
        "logs/samtools/{sample}.index.log"
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "samtools index -@ {threads} {input} {output} 2> {log}"

rule idxstats:
    input:
        bam="results/bam_sorted/{sample}_sorted.bam",
        bai="results/bam_sorted/{sample}_sorted.bam.bai"
    output:
        "results/stats/{sample}.stats"
    log:
        "logs/samtools/{sample}.idxstats.log"
    conda:
        "../envs/bio_env.yaml"
    shell:
        "samtools idxstats {input.bam} > {output} 2> {log}"


rule aggregate_idxstats:
    input:
        expand("results/stats/{sample}.stats", sample=SAMPLES)
    output:
        "results/stats/idxstats_summary.tsv"
    log:
        "logs/aggregate/idxstats_summary.log"
    run:
        dfs = []
        for sample, filename in zip(SAMPLES, input):
            df = pd.read_csv(
                filename,
                sep="\t",
                names=["reference", "length", sample, "unmapped"]
            )
            dfs.append(df.set_index(["reference", "length"])[[sample]])

        summary = pd.concat(dfs, axis=1).reset_index()
        summary.to_csv(output[0], sep="\t", index=False)

        with open(log[0], "w") as logfile:
            logfile.write(f"Aggregated {len(SAMPLES)} samples into {output[0]}\n")
