#!/bin/bash

gzip -d -c outgroup_merged.vcf.gz | bgzip -c > outgroup_merged.vcf.bgz
tabix outgroup_merged.vcf.bgz
bcftools view -S subsample_2_2.txt outgroup_merged.vcf.bgz | gzip > subsample_2_2.vcf.gz
