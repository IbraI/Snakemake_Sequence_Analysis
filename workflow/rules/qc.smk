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
        "../envs/qc.yaml"
    shell:
        "multiqc results/fastqc_raw -o results/multiqc_raw -n raw_fastqc_multiqc.html > {log} 2>&1"


rule run_raw_qc:
    input:
        lambda wildcards: [] if SKIP_FASTQC else "results/multiqc_raw/raw_fastqc_multiqc.html"


rule fastp:
    input:
        r1=lambda wildcards: samples.at[wildcards.sample, "fq1"],
        r2=lambda wildcards: samples.at[wildcards.sample, "fq2"],
        adapter=config["fastp"]["adapter_fasta"]
    output:
        r1="results/fastp/{sample}_1.fastq.gz",
        r2="results/fastp/{sample}_2.fastq.gz",
        html="results/fastp/{sample}.fastp.html",
        json="results/fastp/{sample}.fastp.json"
    log:
        "logs/fastp/{sample}.log"
    params:
        extra=config.get("fastp", {}).get("extra", "")
    threads: 4
    conda:
        "../envs/qc.yaml"
    shell:
        "fastp -i {input.r1} -I {input.r2} "
        "-o {output.r1} -O {output.r2} "
        "--html {output.html} --json {output.json} "
        "--adapter_fasta {input.adapter} "
        "--thread {threads} {params.extra} > {log} 2>&1"


rule fastqc_processed:
    input:
        lambda wildcards: cleaned_read(wildcards.sample, wildcards.read)
    output:
        html="results/fastqc_processed/{sample}_{read}_fastqc.html",
        zip="results/fastqc_processed/{sample}_{read}_fastqc.zip"
    params:
        extra="--quiet",
        mem_overhead_factor=0.1
    log:
        "logs/fastqc/processed/{sample}_{read}.log"
    threads: 4
    resources:
        mem_mb=1024
    wrapper:
        "v7.6.0/bio/fastqc"


rule multiqc_full:
    input:
        lambda wildcards: (
            ([] if SKIP_FASTQC else expand(
                "results/fastqc_raw/{sample}_{read}_fastqc.zip",
                sample=SAMPLES,
                read=READS
            ))
            + ([] if SKIP_FASTQC else expand(
                "results/fastqc_processed/{sample}_{read}_fastqc.zip",
                sample=SAMPLES,
                read=READS
            ))
            + ([] if SKIP_PREPROCESSING else expand(
                "results/fastp/{sample}.fastp.json",
                sample=SAMPLES
            ))
            + (expand(
                "results/mapping_qc/{sample}.flagstat.txt",
                sample=SAMPLES
            ) if RUN_REFERENCE else [])
            + (expand(
                "results/qualimap/{sample}",
                sample=SAMPLES
            ) if RUN_REFERENCE else [])
            + (expand(
                "results/quast/reference/{sample}",
                sample=SAMPLES
            ) if RUN_REFERENCE else [])
            + (expand(
                "results/quast/denovo/{sample}",
                sample=SAMPLES
            ) if RUN_DENOVO else [])
            + ["results/phylogeny/tree.nwk"]
            + ["results/variability/window_variability.tsv"]
        )
    output:
        "results/multiqc/multiqc_report.html"
    log:
        "logs/multiqc/multiqc.log"
    conda:
        "../envs/qc.yaml"
    shell:
        "multiqc results logs -o results/multiqc -n multiqc_report.html > {log} 2>&1"