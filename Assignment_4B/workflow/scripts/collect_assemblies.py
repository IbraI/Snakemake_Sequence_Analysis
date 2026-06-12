from pathlib import Path
from Bio import SeqIO

out = Path(snakemake.output[0])
out.parent.mkdir(parents=True, exist_ok=True)

with out.open("w") as handle_out:
    for fasta in snakemake.input:
        fasta_path = Path(str(fasta))
        sample = fasta_path.stem
        records = list(SeqIO.parse(str(fasta_path), "fasta"))
        if not records:
            raise ValueError(f"No FASTA records found in {fasta_path}")

        ragtag_records = [rec for rec in records if "_RagTag" in rec.id]

        if ragtag_records:
            # For RagTag scaffolded de novo assemblies, use the scaffolded sequence
            # identified by the RagTag header 
            record = max(ragtag_records, key=lambda rec: len(rec.seq))
        else:
            # For reference-based consensus FASTA files, there is normally one full genome.
            record = max(records, key=lambda rec: len(rec.seq))

        record.id = sample
        record.name = sample
        record.description = sample
        SeqIO.write(record, handle_out, "fasta")