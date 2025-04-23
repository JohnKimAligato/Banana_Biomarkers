#!/bin/bash

chmod +x q2_fondue_downloadpt.sh

# To import an existing list of IDs (.tsv) into a NCBIAccessionIDs (.qza)
qiime tools import \
      --type NCBIAccessionIDs \
      --input-path metadata_file_runs.tsv \
      --output-path metadata_file_runs.qza

# Get Sequences
qiime fondue get-sequences \
      --i-accession-ids metadata_file.qza \
      --p-email your_email@somewhere.com \
      --o-single-reads single_reads.qza \
      --o-paired-reads paired_reads.qza \
      --o-failed-runs failed_ids.qza \
      --verbose

