#!/bin/bash

# Get modern samples.
awk -F '\t' '{
        if ($188 == "Han") {
                print $1;
        }
}' gnomad_meta_updated.tsv > han.txt

awk -F '\t' '{
        if ($188 == "Sardinian") {
                print $1;
        }
}' gnomad_meta_updated.tsv > sardinian.txt

awk -F '\t' '{
        if ($188 == "PapuanHighlands" || $188 == "PapuanSepik") {
                print $1;
        }
}' gnomad_meta_updated.tsv > papuan.txt

cat han.txt sardinian.txt papuan.txt > hsp.txt

python3 extract.py

# Normalize and get biallelic variants for modern samples.
bcftools index -f hsp.vcf.bgz
samtools faidx hg38.analysisSet.fa
bcftools norm -f hg38.analysisSet.fa -Oz -o norm_hsp.vcf.bgz hsp.vcf.bgz
bcftools norm -m +any norm_hsp.vcf.bgz -Oz -o merged_norm_hsp.vcf.bgz
bcftools index -f merged_norm_hsp.vcf.bgz
bcftools view -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 merged_norm_hsp.vcf.bgz -Oz -o auto_merged_norm_hsp.vcf.bgz
bcftools index -f auto_merged_norm_hsp.vcf.bgz
bcftools +fill-tags auto_merged_norm_hsp.vcf.bgz -- -t AC,AN | bcftools view -i 'AN>0 && AC>0 && AC<AN' | bcftools view --trim-alt-alleles | gzip > nomiss_nomono_auto_merged_norm_hsp.vcf.gz
bcftools view -m2 -M2 nomiss_nomono_auto_merged_norm_hsp.vcf.gz | gzip > bi_nomiss_nomono_auto_merged_norm_hsp.vcf.gz

# Get Denisovan and lift over.
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

# Merge modern and ancient samples.
bgzip -c denisova.hg38.vcf > denisova.hg38.vcf.bgz
tabix denisova.hg38.vcf.bgz
gzip -d -c bi_nomiss_nomono_auto_merged_norm_hsp.vcf.gz | bgzip -c > bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz
tabix bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz
bcftools merge --force-samples --missing-to-ref denisova.hg38.vcf.bgz bi_nomiss_nomono_auto_merged_norm_hsp.vcf.bgz | gzip > merged.vcf.gz

# Add outgroup.
zcat < merged.vcf.gz | awk 'BEGIN{OFS="\t"}
/^##/ {print; next}
/^#CHROM/ {print $0, "OUTGROUP"; next}
{print $0, "0/."}' | gzip > outgroup_merged.vcf.gz

# Subsample.
gzip -d -c outgroup_merged.vcf.gz | bgzip -c > outgroup_merged.vcf.bgz
tabix outgroup_merged.vcf.bgz
bcftools view -S subsample_2_2.txt outgroup_merged.vcf.bgz | gzip > subsample_2_2.vcf.gz

mkdir -p merged
mkdir -p subsample_2_2

mv outgroup_merged.vcf.gz* merged
mv subsample_2_2.vcf.gz subsample_2_2
mv *.vcf.gz merged
