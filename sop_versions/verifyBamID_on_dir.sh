#!/bin/bash

bam_dir=$1
output_dir=$2
reference_vcf=$3


if [ $# -ne 3 ];then
    printf "Usage: $0 bam_dir output_dir reference_vcf\n" 
    exit 1
fi


for bam in $bam_dir/*.bam
do
	sample_base=${bam##*/}
	sample_base_no_ext=${sample_base%%.*}
	out=${output_dir}/${sample_base_no_ext}
	verifyBamID --vcf $reference_vcf --bam $bam --out $out --maxDepth 1000 --precise --ignoreRG
done
