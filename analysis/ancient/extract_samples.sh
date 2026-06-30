#!/bin/bash

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

cat sardinian.txt papuan.txt > hsp.txt

python3 extract.py

