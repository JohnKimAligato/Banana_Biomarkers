# R scripts used to visualize the figures in our study, aside from MicrobiomeAnalyst Visualizations

library(file2meco) # package
library(microeco) # package

df <- qiime2meco(
  feature_table = "gg24_nonv4_table.qza",
  sample_table = "qiime2-metadata.tsv",
  match_table = NULL,
  taxonomy_table = "gg24_nonv4_taxonomy.qza",
  phylo_tree = "filtered-2024.09.phylogeny.asv.nwk.qza",
  rep_fasta = "gg24_nonv4_seqs.qza")

# Figure 6. Venn Diagram
tmp <- df$merge_samples("condition")
# tmp is a new microtable object
# create trans_venn object
t1 <- trans_venn$new(tmp, ratio = "numratio")
t1$plot_venn()

# At the phylum level, 34 phyla were identified — 29 of which were common in both states

