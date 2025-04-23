# QIIME2 v2024.10 (https://qiime2.org)
This workflow was developed using a variety of QIIME 2 plugins and command-line tools. It serves as an introductory guide for users interested in reproducing or adapting the analysis.

## 1. Donwload the .fastq Files from NCBI SRA (q2-fondue plugin) [https://github.com/bokulich-lab/q2-fondue]
To import an existing list of IDs (.tsv) into a NCBIAccessionIDs (.qza)
```bash
qiime tools import \
      --type NCBIAccessionIDs \
      --input-path metadata_file_runs.tsv \
      --output-path metadata_file_runs.qza
```


