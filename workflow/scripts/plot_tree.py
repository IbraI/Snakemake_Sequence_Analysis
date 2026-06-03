from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from Bio import Phylo

out = Path(snakemake.output[0])
out.parent.mkdir(parents=True, exist_ok=True)

tree = Phylo.read(str(snakemake.input[0]), "newick")
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(1, 1, 1)
Phylo.draw(tree, axes=ax, do_show=False)
plt.tight_layout()
fig.savefig(out, bbox_inches="tight")
