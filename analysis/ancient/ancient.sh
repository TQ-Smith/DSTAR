#!/bin/bash

java -jar ~/bin/picard.jar CreateSequenceDictionary \
    R=hg38.analysisSet.fa \
    O=hg38.analysisSet.dict

module load openjdk/17.0.11_9
bcftools view -r 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 v62.1240k.vcf.gz | bgzip -c > ancient.vcf.bgz
tabix ancient.vcf.bgz
bcftools view -s Denisova3_snpAD.DG ancient.vcf.bgz | bgzip -c > denisova.vcf.bgz
tabix denisova.vcf.bgz
bcftools annotate --rename-chrs chr_map.txt denisova.vcf.bgz > denisova.hg19.vcf

java -jar ~/bin/picard.jar LiftoverVcf \
    I=denisova.hg19.vcf \
    O=denisova.hg38.vcf \
    CHAIN=hg19ToHg38.over.chain.gz \
    REJECT=rejected_variants.vcf \
    R=hg38.analysisSet.fa \
    WARN_ON_MISSING_CONTIG=true
