#!/bin/bash

bgzip -c denisova.hg38.vcf > denisova.hg38.vcf.bgz
tabix denisova.hg38.vcf.bgz
gzip -d -c bi_nomiss_nomono_auto_merged_norm_hsp.vcf.gz | bgzip -c > bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz
tabix bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz
bcftools merge --force-samples --missing-to-ref denisova.hg38.vcf.bgz bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz | gzip > merged.vcf.gz

# Add outgroup as reference allele.
zcat < merged.vcf.gz | awk 'BEGIN{OFS="\t"}
/^##/ {print; next}
/^#CHROM/ {print $0, "OUTGROUP"; next}
{print $0, "0/."}' | gzip > outgroup_merged.vcf.gz
