## [PICRUSt2](https://github.com/picrust/picrust2)
This set of commands was used to predict and annotate the functional capabilities of the Amplicon Sequence Variants.

## 1. Run the PICRUSt2 pipeline using the Representative Sequences
```bash
picrust2_pipeline.py \
-s study_seqs.fna  \
-i study_table.tsv \
-o picrust2_out_pipeline \
-p 8

add_descriptions.py -i EC_metagenome_out/pred_metagenome_unstrat.tsv.gz -m EC \
-o EC_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz

add_descriptions.py -i pathways_out/path_abun_unstrat.tsv.gz -m METACYC \
-o pathways_out/path_abun_unstrat_descrip.tsv.gz

add_descriptions.py -i KO_metagenome_out/pred_metagenome_unstrat.tsv.gz -m KO \
-o KO_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz
```