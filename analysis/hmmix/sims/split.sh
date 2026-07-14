#!/bin/bash

for rep in {1..100}
do
	gzip -d intro/rep${rep}.vcf.gz
	bgzip intro/rep${rep}.vcf
	tabix intro/rep${rep}.vcf.gz
	bcftools view -S outgroupSamples.txt intro/rep${rep}.vcf.gz | gzip > intro/outgroup_rep${rep}.vcf.gz
	bcftools view -S ingroupSamples.txt intro/rep${rep}.vcf.gz | gzip > intro/ingroup_rep${rep}.vcf.gz
done

