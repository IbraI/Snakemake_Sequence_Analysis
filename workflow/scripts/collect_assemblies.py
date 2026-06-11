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

        # Use the longest contig/sequence as the representative assembled genome.
        # For reference-based consensus FASTA files, this will normally be the full consensus genome.
        record = max(records, key=lambda rec: len(rec.seq))
        record.id = sample
        record.name = sample
        record.description = sample
        SeqIO.write(record, handle_out, "fasta")