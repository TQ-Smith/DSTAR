#!/bin/bash

bash normalize.sh
bash ancient.sh
bash merge.sh
bash subsample.sh

dplus -b 50000 outgroup_merged.vcf.gz pop_labels.txt Sardinian,Papuan,Denisova,Outgroup > dplus.tsv
dstar -b 50000 outgroup_merged.vcf.gz pop_labels.txt Sardinian,Papuan,Denisova > dstar.tsv

dplus -b 50000 subsample_2_2.vcf.gz subsample_2_2.tsv Sardinian,Papuan,Denisova,Outgroup > subsample_2_2_dplus.tsv
dstar -b 50000 subsample_2_2.vcf.gz subsample_2_2.tsv Sardinian,Papuan,Denisova > subsample_2_2_dstar.tsv
