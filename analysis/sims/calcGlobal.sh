# Get results for whole segment.

inputDirectory=$1

echo -e "rep\tD\tD+\tD*\tpD\tpD+\tpD*" > "$inputDirectory"/global.tsv

for rep in {1..100}
do
	d=$(tail -n 1 "$inputDirectory"/d_rep"$rep".tsv | cut -f 9)
	dplus=$(tail -n 1 "$inputDirectory"/d_rep"$rep".tsv | cut -f 10)
	dstar=$(tail -n 1 "$inputDirectory"/dstar_rep"$rep".tsv | cut -f 8)
	dP=$(egrep '^#pvalueD=' "$inputDirectory"/d_rep"$rep".tsv | cut -d'=' -f2)
	dplusP=$(egrep '^#pvalueD\+=' "$inputDirectory"/d_rep"$rep".tsv | cut -d'=' -f2)
	dstarP=$(egrep '^#pvalue=' "$inputDirectory"/dstar_rep"$rep".tsv | cut -d'=' -f2)
	printf "%d\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\n" "$rep" "$d" "$dplus" "$dstar" "$dP" "$dplusP" "$dstarP" >> "$inputDirectory"/global.tsv
done
