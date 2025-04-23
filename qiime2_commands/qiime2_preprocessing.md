# [QIIME2 v2024.10](https://qiime2.org)
This workflow was developed using a variety of QIIME 2 plugins and command-line tools. It serves as an introductory guide for users interested in reproducing or adapting the analysis.

## 1. Donwload the .fastq Files from NCBI SRA [q2-fondue plugin](https://github.com/bokulich-lab/q2-fondue)
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

## 3. Cut the adapter sequences and primers using [q2-cutadapt](https://github.com/qiime2/q2-cutadapt)
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


