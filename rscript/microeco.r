setwd("~/Documents/researchfiles/step1")

if(!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if(!require("file2meco")) install.packages("file2meco", repos = BiocManager::repositories())
devtools::install_github("mattflor/chorddiag")
# require WGCNA package
if(!require("WGCNA")) install.packages("WGCNA", repos = BiocManager::repositories())

library(file2meco)
library(microeco)
library(chorddiag)
library(circlize)
library(ggraph)
library(networkD3)
library(WGCNA)

df <- qiime2meco(
  feature_table = "gg24_nonv4_table.qza",
  sample_table = "qiime2-metadata.tsv",
  match_table = NULL,
  taxonomy_table = "gg24_nonv4_taxonomy.qza",
  phylo_tree = "filtered-2024.09.phylogeny.asv.nwk.qza",
  rep_fasta = "gg24_nonv4_seqs.qza")

df$tidy_dataset()

df$cal_abund()

group_Healthy <- clone(df)
group_Healthy$sample_table <- subset(group_Healthy$sample_table, Group == "Healthy")
# or: group_CW$sample_table <- subset(group_CW$sample_table, grepl("CW", Group))
# trim all the data
group_CW$tidy_dataset()
group_CW

group_CW$sample_table <- subset(group_CW$sample_table, Group == "CW")
# or: group_CW$sample_table <- subset(group_CW$sample_table, grepl("CW", Group))
# trim all the data
group_CW$tidy_dataset()
group_CW

tmp <- trans_norm$new(dataset = df)
mt_TSS <- tmp$norm(method = "TSS")

mt_TSS$cal_abund()

t1 <- trans_diff$new(dataset = mt_TSS, 
                     method = "lefse",
                     group = "condition",
                     remove_unknown = TRUE,
                     taxa_level = "Genus",
                     alpha = 0.05, 
                     p_adjust_method = "BH",
                     lefse_subgroup = NULL)

# From v0.8.0, threshold is used for the LDA score selection.
t1$plot_diff_bar(threshold = 1)
# we show 20 taxa with the highest LDA (log10)
t1$plot_diff_bar(use_number = 1:100, width = 0.8, group_order = c("Healthy", "Diseased"))


####

t1 <- trans_abund$new(dataset = df, taxrank = "Phylum", ntaxa = 10, groupmean = "condition")
g1 <- t1$plot_bar(others_color = "grey70", legend_text_italic = TRUE)
g1 + theme_classic() + theme(axis.title.y = element_text(size = 18))
print (g1)

t1 <- trans_abund$new(dataset = df, taxrank = "Phylum", ntaxa = 10)
t1$plot_box(group = "condition", xtext_angle = 30)

t1 <- trans_abund$new(dataset = mt_TSS, taxrank = "Phylum", ntaxa = 8, groupmean = "condition")
t1$plot_donut(label = TRUE)

# first clone the data
df_rarefied <- clone(df)
# use sample_sums to check the sequence numbers in each sample
df_rarefied$sample_sums() %>% range
# As an example, use 10000 sequences in each sample
df_rarefied$rarefy_samples(sample.size = 8169)

tmp <- df_rarefied$merge_samples("condition")
# tmp is a new microtable object
# create trans_venn object
t1 <- trans_venn$new(tmp, ratio = "seqratio")
t1$plot_venn()



###

t1 <- t1 <- trans_diff$new(dataset = mt_TSS, 
                           method = "rf",
                           group = "condition",
                           remove_unknown = TRUE,
                           taxa_level = "Genus",
                           alpha = 0.05, 
                           p_adjust_method = "BH")
# plot the MeanDecreaseGini bar
# group_order is designed to sort the groups
g1 <- t1$plot_diff_bar(use_number = 1:60, group_order = c("Healthy", "Diseased"))
# plot the abundance using same taxa in g1
g2 <- t1$plot_diff_abund(group_order = c("Healthy", "Diseased"), select_taxa = t1$plot_diff_bar_taxa, plot_type = "barerrorbar", add_sig = TRUE, errorbar_addpoint = FALSE, errorbar_color_black = TRUE)
# now the y axis in g1 and g2 is same, so we can merge them
# remove g1 legend; remove g2 y axis text and ticks
g1 <- g1 + theme(legend.position = "none")
g2 <- g2 + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(), panel.border = element_blank())
p <- g1 %>% aplot::insert_right(g2)
p

############
# The parameter cor_method in trans_network is used to select correlation calculation method.
# default pearson or spearman correlation invoke R base cor.test, a little slow
t1 <- trans_network$new(dataset = df, cor_method = "spearman", use_WGCNA_pearson_spearman = TRUE, filter_thres = 0.0001)
# return t1$res_cor_p list, containing two tables: correlation coefficient table and p value table

# construct network; require igraph package
t1$cal_network(COR_p_thres = 0.01, COR_optimization = TRUE)
# use arbitrary coefficient threshold to contruct network
t1$cal_network(COR_p_thres = 0.01, COR_cut = 0.7)
# return t1$res_network

# default parameter represents using igraph plot.igraph function
t2$plot_network()
# use ggraph method; require ggraph package
# If ggraph is not installed; first install it with command: install.packages("ggraph")
t2$plot_network(method = "ggraph", node_color = "Phylum")
# use networkD3 package method for the dynamic network visualization in R
# If networkD3 is not installed; first install it with command: install.packages("networkD3")
t1$plot_network(method = "networkD3", node_color = "module")
t1$plot_network(method = "networkD3", node_color = "Phylum")

# use_col is used to select a column of t1$res_node_table
tmp <- t1$trans_comm(use_col = "module", abundance = FALSE)
tmp
tmp$otu_table[tmp$otu_table > 0] <- 1
tmp$tidy_dataset()
tmp$cal_abund()
tmp2 <- trans_abund$new(tmp, taxrank = "Genus", ntaxa = 10)
tmp2$data_abund$Sample %<>% factor(., levels = rownames(tmp$sample_table))
tmp2$plot_line(xtext_angle = 30, color_values = RColorBrewer::brewer.pal(12, "Paired")) + ylab("OTUs ratio (%)")


#CHORD DIAGRAM
t1$cal_sum_links(taxa_level = "Phylum")
# interactive visualization; require chorddiag package; see https://github.com/mattflor/chorddiag
t1$plot_sum_links(method = "chorddiag", plot_pos = TRUE, plot_num = 10)
# From v1.2.0, method = "circlize" is available for conveniently saving the static plot
# If circlize package is not installed, first run: install.packages("circlize")
t1$plot_sum_links(method = "chorddiag", transparency = 0.2, annotationTrackHeight = circlize::mm_h(c(5, 5)))