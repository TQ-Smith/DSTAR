#!/bin/bash

bcftools index -f hsp.vcf.bgz
samtools faidx hg38.analysisSet.fa
bcftools norm -f hg38.analysisSet.fa -Oz -o norm_hsp.vcf.bgz hsp.vcf.bgz
bcftools norm -m +any norm_hsp.vcf.bgz -Oz -o merged_norm_hsp.vcf.bgz
bcftools index -f merged_norm_hsp.vcf.bgz
bcftools view -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 merged_norm_hsp.vcf.bgz -Oz -o auto_merged_norm_hsp.vcf.bgz
bcftools index -f auto_merged_norm_hsp.vcf.bgz
bcftools +fill-tags auto_merged_norm_hsp.vcf.bgz -- -t AC,AN | bcftools view -i 'AN>0 && AC>0 && AC<AN' | bcftools view --trim-alt-alleles | gzip > nomiss_nomono_auto_merged_norm_hsp.vcf.gz
bcftools view -m2 -M2 nomiss_nomono_auto_merged_norm_hsp.vcf.gz | gzip > bi_nomiss_nomono_auto_merged_norm_hsp.vcf.gz
