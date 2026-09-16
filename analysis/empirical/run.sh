#!/bin/bash

dplus -b 50000 merged/outgroup_merged.vcf.gz merged/pop_labels.txt Sardinian,Papuan,Denisova,Outgroup > merged/dplus.tsv
dstar -b 50000 merged/outgroup_merged.vcf.gz merged/pop_labels.txt Sardinian,Papuan,Denisova > merged/dstar.tsv
hmmix create_outgroup -ind=merged/individuals.json -vcf=merged/merged.vcf.gz -weights=hg38_strick_callability_mask.bed -out=merged/outgroup.tsv
hmmix create_ingroup -ind=merged/individuals.json -vcf=merged/merged.vcf.gz -weights=hg38_strick_callability_mask.bed -outgroup=merged/outgroup.tsv -out=merged/obs
for sample in $(egrep "Papuan" merged/pop_labels.txt | cut -f 1)
do
	hmmix train -obs=merged/obs.${sample}.txt -weights=hg38_strick_callability_mask.bed -mutrates=hg38_mutationrate.bed -out=merged/trained.${sample}.json
	hmmix decode -posterior_probs=merged/${sample}.posterior.txt -obs=merged/obs.${sample}.txt -weights=hg38_strick_callability_mask.bed -mutrates=hg38_mutationrate.bed -out=merged/decoded.${sample} -param=merged/trained.${sample}.json
done
python3 average_hmmix.py merged/ > merged/hmmix.tsv

dplus -b 50000 subsample_2_2/subsample_2_2.vcf.gz subsample_2_2/subsample_2_2.tsv Sardinian,Papuan,Denisova,Outgroup > subsample_2_2/dplus.tsv
dstar -b 50000 subsample_2_2/subsample_2_2.vcf.gz subsample_2_2/subsample_2_2.tsv Sardinian,Papuan,Denisova > subsample_2_2/dstar.tsv
hmmix create_outgroup -ind=subsample_2_2/individuals.json -vcf=subsample_2_2/subsample_2_2.vcf.gz -weights=hg38_strick_callability_mask.bed -out=subsample_2_2/outgroup.tsv
hmmix create_ingroup -ind=subsample_2_2/individuals.json -vcf=subsample_2_2/subsample_2_2.vcf.gz -weights=hg38_strick_callability_mask.bed -outgroup=subsample_2_2/outgroup.tsv -out=subsample_2_2/obs
for sample in $(egrep "Papuan" subsample_2_2/subsample_2_2.tsv | cut -f 1)
do
	hmmix train -obs=subsample_2_2/obs.${sample}.txt -weights=hg38_strick_callability_mask.bed -mutrates=hg38_mutationrate.bed -out=subsample_2_2/trained.${sample}.json
	hmmix decode -posterior_probs=subsample_2_2/${sample}.posterior.txt -obs=subsample_2_2/obs.${sample}.txt -weights=hg38_strick_callability_mask.bed -mutrates=hg38_mutationrate.bed -out=subsample_2_2/decoded.${sample} -param=subsample_2_2/trained.${sample}.json
done
python3 average_hmmix.py subsample_2_2/ > subsample_2_2/hmmix.tsv
