#!/bin/bash

input_dir=$1
target_bed=$2
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}
exons=/media/sf_BigShare/SCID/reference/Homo_sapiens.GRCh37.87.with_chr_pre_exon_merged.bed.gz
introns=/media/sf_BigShare/SCID/reference/Homo_sapiens.GRCh37.87.with_chr_pre_intron.bed.gz
utrs=/media/sf_BigShare/SCID/reference/Homo_sapiens.GRCh37.87.with_chr_pre_utr_merged.bed.gz
out_file=$input_dir/all_samples_gaps_fixed.txt

if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir_with_beds_from_gvcf target_bed\n" 
    exit 1
fi

echo -e "Sample\tChr\tStart\tEnd\tSize\tRegion\tStrand\tGTF-Type\tGTF-chr\tGTF-start\tGTF-end" > $out_file
for bed in $input_dir/*.bed
do
	base_sample=${bed##*/}
	sample=${base_sample%%-*}
	bedtools subtract -a $target_bed -b $bed | \
	bedtools intersect -a - -b $exons $introns $utrs -names exons introns utr -loj | \
	awk -F '\t' -v awksample="$sample" '{print awksample "\t" $1 "\t" $2 "\t" $3 "\t" $3-$2 "\t" $4 "\t" $6 "\t" $8 "\t" $9 "\t" $10 "\t" $11}' - >> $out_file
done
