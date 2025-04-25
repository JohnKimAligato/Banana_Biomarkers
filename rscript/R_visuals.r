# R scripts used to visualize the figures in our study, aside from 
# [MicrobiomeAnalyst](https://www.microbiomeanalyst.ca) (Figures 3,4,5), [Gephi](https://gephi.org) (Figure 8), and [STAMP](https://beikolab.cs.dal.ca/software/STAMP) (Figure 9) Visualizations.

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
phylum_df <- df$merge_taxa("Phylum")
phylum_df

tmp <- phylum_df$merge_samples("condition")
# tmp is a new microtable object
# create trans_venn object
t1 <- trans_venn$new(tmp, ratio = "numratio")
t1$plot_venn()

# Core microbiome analysis at the genus level identified 110 genera unique to healthy samples, 
# while 280 genera were exclusive to diseased samples. Of the 1018 genera identified, 627 were shared 
# between healthy and diseased samples.
genus_df <- df$merge_taxa("Genus")
genus_df

tmp <- genus_df$merge_samples("condition")
# tmp is a new microtable object
# create trans_venn object
t1 <- trans_venn$new(tmp, ratio = "numratio")
t1$plot_venn()

# Figure.7 LEfSe Volcano Plot
# Load required libraries
library(tidyverse)
library(ggrepel)
library(tidyverse)
library(ggrepel)

# Read the CSV
df <- read.csv("/Users/chris/Documents/researchfiles/step1/lefse-MA-04.18.csv")
head(df)

# define groups
df <- df %>%
  mutate(
    diffexpressed = case_when(
      LDAscore > 2.0 & FDR < 0.05 ~ "UP",
      LDAscore < -2.0 & FDR < 0.05 ~ "DOWN",
      TRUE ~ "NO"
    )
  )


# Get top 5 UP and top 5 DOWN based on LDA score
top_up <- df %>% filter(diffexpressed == "UP") %>% arrange(desc(LDAscore)) %>% slice_head(n = 5)
top_down <- df %>% filter(diffexpressed == "DOWN") %>% arrange(LDAscore) %>% slice_head(n = 5)

# Add labels only for these 10 taxa
df$delabel <- ifelse(df$Taxa %in% c(top_up$Taxa, top_down$Taxa), df$Taxa, NA)

# Create the volcano plot using raw LDA (log10)
volcano_plot <- ggplot(data = df, aes(x = LDAscore, y = -log10(FDR), col = diffexpressed, label = delabel)) +
  geom_vline(xintercept = c(-2.0, 2.0), col = "gray30", linetype = 'dashed') +
  geom_hline(yintercept = -log10(0.05), col = "gray30", linetype = 'dashed') +
  geom_point(
    size = 3,
    alpha = 0.8,
    stroke = 0.9,
    fill = "grey10") +
  scale_color_manual(
    values = c("DOWN" = "brown", "NO" = "darkgray", "UP" = "darkgreen"),
    labels = c("Diseased", "Not significant", "Healthy")
  ) +
  coord_cartesian(ylim = c(0.4, 3.0), xlim = c(-4.5, 4.5)) +
  labs(
    color = 'Expression Change',
    x = expression("LDA (Linear Discriminant Analysis) Score"),
    y = expression("q-values (-log"[10]*")")
  ) +
  scale_x_continuous(breaks = seq(-10, 10, 2)) +
  theme_classic(base_size = 20) +
  theme(
    axis.title.y = element_text(face = "bold", margin = margin(0, 5, 0, 0)),
    axis.title.x = element_text(hjust = 0.5, face = "bold", margin = margin(5, 0, 0, 0)),
    plot.title = element_text(hjust = 0.5)
  ) +
  geom_label_repel(
    max.overlaps = Inf,
    label.size = 0.4, 
    size = 5,
    point.padding = 0.5,
    box.padding = 0.6,
    min.segment.length = 0,
    fill = "#FFFFFF80"
  )

# Show plot
print(volcano_plot)