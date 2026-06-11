from pathlib import Path
from collections import Counter
import math

import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from Bio import SeqIO

alignment = Path(snakemake.input.alignment)
out_per_base = Path(snakemake.output.per_base)
out_table = Path(snakemake.output.table)
out_plot = Path(snakemake.output.plot)
out_per_base.parent.mkdir(parents=True, exist_ok=True)
out_table.parent.mkdir(parents=True, exist_ok=True)
out_plot.parent.mkdir(parents=True, exist_ok=True)

window_size = int(snakemake.params.window_size)
step_size = int(snakemake.params.step_size)
ignore_gaps = bool(snakemake.params.ignore_gaps)

records = list(SeqIO.parse(str(alignment), "fasta"))
if len(records) < 2:
    raise ValueError("At least two aligned genomes are required for variability analysis.")

seqs = [str(rec.seq).upper() for rec in records]
lengths = {len(seq) for seq in seqs}
if len(lengths) != 1:
    raise ValueError("All sequences in the alignment must have the same length.")

alignment_length = lengths.pop()
valid_bases = set("ACGT")
max_entropy = math.log2(4)  # maximum Shannon entropy for A/C/G/T

per_position = []
for pos in range(alignment_length):
    chars = [seq[pos] for seq in seqs]

    if ignore_gaps:
        # Only true nucleotide bases contribute to the entropy.
        chars = [c for c in chars if c in valid_bases]
    else:
        # Keep gaps as an additional observed character, but remove ambiguous bases.
        chars = [c for c in chars if c not in {"N", "?"}]

    if len(chars) < 2:
        variability = 0.0
        n_used = len(chars)
    else:
        counts = Counter(chars)
        entropy = 0.0
        for count in counts.values():
            p = count / len(chars)
            entropy -= p * math.log2(p)

        # Normalized Shannon entropy. For DNA bases this raanges from 0 to 1
        # if gaps are ignored. If gaps are included, values are capped at 1
        # to keep the same interpretation.
        variability = min(entropy / max_entropy, 1.0)
        n_used = len(chars)

    per_position.append({
        "position": pos + 1,
        "variability": variability,
        "n_sequences_used": n_used,
    })

per_base_df = pd.DataFrame(per_position)
per_base_df.to_csv(out_per_base, sep="\t", index=False)

rows = []
for start in range(0, alignment_length, step_size):
    end = min(start + window_size, alignment_length)
    values = per_base_df.loc[start:end - 1, "variability"]
    if values.empty:
        continue
    rows.append({
        "window_start": start + 1,
        "window_end": end,
        "avg_variability": values.mean(),
        "n_positions": len(values),
    })
    if end == alignment_length:
        break

df = pd.DataFrame(rows)
df.to_csv(out_table, sep="\t", index=False)

plt.figure(figsize=(10, 5))
plt.plot(df["window_start"], df["avg_variability"])
plt.xlabel("Window start position")
plt.ylabel("Average normalized Shannon entropy")
plt.title(f"Sliding-window sequence variability (window={window_size}, step={step_size})")
plt.tight_layout()
plt.savefig(out_plot, dpi=300)
