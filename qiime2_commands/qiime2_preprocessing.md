# [QIIME2 v2024.10](https://qiime2.org)
This workflow was developed using a variety of QIIME 2 plugins and command-line tools. It serves as an introductory guide for users interested in reproducing or adapting the analysis.

## 1. Download the .fastq Files from NCBI SRA [q2-fondue plugin](https://github.com/bokulich-lab/q2-fondue)
To import an existing list of IDs (.tsv) into a NCBI AccessionIDs (.qza)
```bash
qiime tools import \
      --type NCBIAccessionIDs \
      --input-path metadata_file_runs.tsv \
      --output-path metadata_file_runs.qza
```
```bash
Get Sequences
qiime fondue get-sequences \
      --i-accession-ids metadata_file.qza \
      --p-email your_email@somewhere.com \
      --o-single-reads single_reads.qza \
      --o-paired-reads paired_reads.qza \
      --o-failed-runs failed_ids.qza \
      --verbose
```

## 2. View the Sequencing Data Summary of the Reads [q2-demux](https://github.com/qiime2/q2-demux)
Sequencing Data Summary for Single Reads
```bash
qiime demux summarize \
      --i-data fondue-output/single_reads.qza \
      --o-visualization fondue-output/single_reads.qzv
```
Sequencing Data Summary for Paired Reads
```bash
qiime demux summarize \
      --i-data fondue-output/paired_reads.qza \
      --o-visualization fondue-output/paired_reads.qzv
```

## 3. Cut the adapter sequences and/or primers using [q2-cutadapt](https://github.com/qiime2/q2-cutadapt)
```bash
qiime cutadapt trim-paired \
--i-demultiplexed-sequences PRJNA827236_diseased.qza \
--p-front-f CCTACGGGNBGCASCAN \
--p-adapter-r NCTGSTGCVNCCCGTAGG \
--p-front-r GRMYWMNVGGGTATCTAAT \
--p-adapter-f ATTAGATACCCBNKWRKYC \
--p-discard-untrimmed \
--p-match-adapter-wildcards \
--p-cores 10 \
--o-trimmed-sequences trimmed/diseased/PRJNA827236_diseased_trimmed-seq.qza \
--verbose
```

## 4. Merge the `paired-end reads` using [q2-vsearch](https://github.com/qiime2/q2-vsearch)
```bash
qiime vsearch merge-pairs \
--i-demultiplexed-seqs trimmed/diseased/PRJNA827187_diseased_trimmed-seq.qza \
--output-dir merged/PRJNA827187_diseased_merged-trimmed-seq \
--p-threads 4 \
--verbose
```

## 5. Denoise the merged `paired-end reads` using [q2-deblur](https://github.com/qiime2/q2-deblur)
```bash
qiime deblur denoise-16S \
--i-demultiplexed-seqs merged/PRJNA827236_healthy_merged-trimmed-seq/merged_sequences.qza \
--p-trim-length 404 \
--p-sample-stats \
--o-representative-sequences deblur/rep-seqs/PRJNA827236_healthy.qza \
--o-table deblur/table/PRJNA827236_healthy.qza \
--o-stats deblur/stats/PRJNA827236_healthy.qza \
--verbose
```

## 6. Combine/merge the `feature tables` and `representative sequences` produced after denoising using [q2-feature-table](https://github.com/qiime2/q2-feature-table)
Merging Feature-tables:
```bash
qiime feature-table merge \
--i-tables deblur/table/PRJNA827195_healthy.qza \
--i-tables deblur/table/PRJNA827244_healthy.qza \
--i-tables deblur/table/PRJNA725994_healthy.qza \
--i-tables deblur/table/PRJNA827236_healthy.qza \
--i-tables deblur/table/PRJNA494050_healthy.qza \
--i-tables deblur/table/PRJNA827187_healthy.qza \
--o-merged-table healthy_merged_table.qza
```
Visualizing the feature-table summary incorporated with metadata:
```bash
qiime feature-table merge \
--i-tables deblur/table/PRJNA827195_healthy.qza \
--i-tables deblur/table/PRJNA827244_healthy.qza \
--i-tables deblur/table/PRJNA725994_healthy.qza \
--i-tables deblur/table/PRJNA827236_healthy.qza \
--i-tables deblur/table/PRJNA494050_healthy.qza \
--i-tables deblur/table/PRJNA827187_healthy.qza \
--o-merged-table healthy_merged_table.qza
```

Merging Representative sequences:
```bash
qiime feature-table merge-seqs \
--i-data deblur/rep-seqs/PRJNA827195_healthy.qza \
--i-data deblur/rep-seqs/PRJNA827244_healthy.qza \
--i-data deblur/rep-seqs/PRJNA725994_healthy.qza \
--i-data deblur/rep-seqs/PRJNA827236_healthy.qza \
--i-data deblur/rep-seqs/PRJNA494050_healthy.qza \
--i-data deblur/rep-seqs/PRJNA827187_healthy.qza \
--o-merged-data healthy_merged_seqs.qza
```
Visualizing the representative sequences summary:
```bash
qiime feature-table tabulate-seqs \
--i-data all_merged_seqs.qza \
--o-visualization all_merged_seqs.qzv \
—verbose
```

## 7. Taxonomic Classification of Representative Sequences using [Greengenes database v2024.09](https://ftp.microbio.me/greengenes_release/current/)
Backbone mapping:
```bash
qiime greengenes2 non-v4-16s \
--i-table all_merged_table.qza \
--i-sequences all_merged_seqs.qza \
--i-backbone 2024.09.backbone.full-length.fna.qza \
--o-mapped-table gg24_nonv4_table.qza \
--o-representatives gg24_nonv4_seqs.qza
```
Classification:
```bash
qiime greengenes2 taxonomy-from-table \
--i-reference-taxonomy 2024.09.taxonomy.asv.nwk.qza \
 --i-table gg24_nonv4_table.qza \
--o-classification gg24_nonv4_taxonomy.qza
```
Visualization:
```bash
qiime taxa barplot \
--i-table gg24_nonv4_table.qza \
--i-taxonomy gg24_nonv4_taxonomy.qza \
--m-metadata-file q2-metadata.tsv \
--o-visualization gg24_nonv4_taxonomy-bar-plots.qzv
```

## 8. Generate a Phylogenetic Tree using [Greengenes database v2024.09](https://ftp.microbio.me/greengenes_release/current/)
Phylogenetic Tree Filtration and Generation:
```bash
qiime phylogeny filter-tree \
--i-tree 2024.09.phylogeny.asv.nwk.qza \
--i-table gg24_nonv4_table.qza \
--o-filtered-tree filtered-2024.09.phylogeny.asv.nwk.qza
```
Exporting the Phylogenetic Tree:
```bash
qiime tools export \
--input-path filtered-2024.09.phylogeny.asv.nwk.qza \
--output-path filtered-2024.09.phylogeny.asv.nwk
```