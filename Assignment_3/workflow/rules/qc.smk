rule fastqc_raw:
    input:
        lambda wildcards: samples.at[wildcards.sample, f"fq{wildcards.read}"]
    output:
        html="results/fastqc_raw/{sample}_{read}_fastqc.html",
        zip="results/fastqc_raw/{sample}_{read}_fastqc.zip"
    params:
        extra="--quiet",
        mem_overhead_factor=0.1
    log:
        "logs/fastqc/raw/{sample}_{read}.log"
    threads: 4
    resources:
        mem_mb=1024
    wrapper:
        "v7.6.0/bio/fastqc"

rule multiqc_raw:
    input:
        lambda wildcards: [] if SKIP_FASTQC else expand(
            "results/fastqc_raw/{sample}_{read}_fastqc.zip",
            sample=SAMPLES,
            read=READS
        )
    output:
        "results/multiqc_raw/raw_fastqc_multiqc.html"
    log:
        "logs/multiqc/raw_fastqc_multiqc.log"
    conda:
        "../envs/bio_env.yaml"
    shell:
        "multiqc results/fastqc_raw -o results/multiqc_raw -n raw_fastqc_multiqc.html > {log} 2>&1"

rule run_raw_qc:
    input:
        lambda wildcards: [] if SKIP_FASTQC else "results/multiqc_raw/raw_fastqc_multiqc.html"

rule trimmomatic:
    input:
        r1=lambda wildcards: samples.at[wildcards.sample, "fq1"],
        r2=lambda wildcards: samples.at[wildcards.sample, "fq2"],
        adapter=config["trimmomatic_adapter"]
    output:
        r1_paired="results/trimmed/{sample}_1.paired.fastq.gz",
        r1_unpaired="results/trimmed/{sample}_1.unpaired.fastq.gz",
        r2_paired="results/trimmed/{sample}_2.paired.fastq.gz",
        r2_unpaired="results/trimmed/{sample}_2.unpaired.fastq.gz"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        options=config["trimmomatic_options"]
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "trimmomatic PE -threads {threads} {input.r1} {input.r2} "
        "{output.r1_paired} {output.r1_unpaired} {output.r2_paired} {output.r2_unpaired} "
        "ILLUMINACLIP:{input.adapter}:2:30:10 {params.options} > {log} 2>&1"

rule fastqc_trimmed:
    input:
        "results/trimmed/{sample}_{read}.paired.fastq.gz"
    output:
        html="results/fastqc_trimmed/{sample}_{read}_paired_fastqc.html",
        zip="results/fastqc_trimmed/{sample}_{read}_paired_fastqc.zip"
    params:
        extra="--quiet",
        mem_overhead_factor=0.1
    log:
        "logs/fastqc/trimmed/{sample}_{read}.log"
    threads: 4
    resources:
        mem_mb=1024
    wrapper:
        "v7.6.0/bio/fastqc"

rule qualimap_bamqc:
    input:
        bam="results/bam_sorted/{sample}_sorted.bam",
        bai="results/bam_sorted/{sample}_sorted.bam.bai"
    output:
        directory("results/qualimap/{sample}")
    log:
        "logs/qualimap/{sample}.log"
    threads: 4
    conda:
        "../envs/bio_env.yaml"
    shell:
        "qualimap bamqc -bam {input.bam} -outdir {output} -nt {threads} --java-mem-size=4G > {log} 2>&1"

rule multiqc_full:
    input:
        lambda wildcards: (
            ([] if SKIP_FASTQC else expand("results/fastqc_raw/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS))
            + ([] if (SKIP_FASTQC or SKIP_TRIMMING) else expand("results/fastqc_trimmed/{sample}_{read}_paired_fastqc.zip", sample=SAMPLES, read=READS))
            + ([] if SKIP_QUALIMAP else expand("results/qualimap/{sample}", sample=SAMPLES))
            + expand("logs/bowtie2/{sample}.log", sample=SAMPLES)
        )
    output:
        "results/multiqc/multiqc_report.html"
    log:
        "logs/multiqc/multiqc.log"
    conda:
        "../envs/bio_env.yaml"
    shell:
        "multiqc results logs -o results/multiqc -n multiqc_report.html > {log} 2>&1"
