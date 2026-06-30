#!/bin/bash

mkdir -p popFiles
echo -e "P1_0\tpop1\nP2_0\tpop2\nP3_0\tpop3\nP4_0\tpop4" > popFiles/1pop1.2pop1.3pop1.tsv

create_pop_file() {
    pop1=$1
    pop2=$2
    pop3=$3
    pop4=$4
    touch popFiles/1pop$pop1.2pop$pop2.3pop$pop3.4pop$pop4.tsv
    seq 0 $(($pop1-1)) | awk '{print "P1_"$1"\tpop1"}' >> popFiles/1pop$pop1.2pop$pop2.3pop$pop3.4pop$pop4.tsv
    seq 0 $(($pop2-1)) | awk '{print "P2_"$1"\tpop2"}' >> popFiles/1pop$pop1.2pop$pop2.3pop$pop3.4pop$pop4.tsv
    seq 0 $(($pop3-1)) | awk '{print "P3_"$1"\tpop3"}' >> popFiles/1pop$pop1.2pop$pop2.3pop$pop3.4pop$pop4.tsv
    seq 0 $(($pop4-1)) | awk '{print "P4_"$1"\tpop4"}' >> popFiles/1pop$pop1.2pop$pop2.3pop$pop3.4pop$pop4.tsv
}

for pop2 in 2 5 10 25
do
	create_pop_file 25 $pop2 2 2
done

create_pop_file 12 12 2 1
