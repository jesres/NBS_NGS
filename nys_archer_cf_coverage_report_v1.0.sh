#!/bin/bash

input_dir=$1
output_dir=$2
target_bed=$3
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 3 ];then
    printf "nys_archer_cf_coverage_report_v1.0.sh - Usage: $0 input_dir output_dir target_bed\n" 
    exit 1
fi


for bam in $input_dir/*.molbar.trimmed.deduped.merged.bam
do
	bam_base=${bam##*/}
	bam_base_no_ext=${bam_base%%.*}
	mkdir -p $output_dir
	out=${output_dir}/${bam_base_no_ext}
	
	# by setting these ENV vars, we can control the output labels (4th column)
	export MOSDEPTH_Q0=NO_COVERAGE   # 0 -- defined by the arguments to --quantize
	export MOSDEPTH_Q1=UNDER10  # 1..9
	export MOSDEPTH_Q2=UNDER25      # 10..24
	export MOSDEPTH_Q3=UNDER50      # 25..49
	export MOSDEPTH_Q4=HIGH_COVERAGE # 50 ...
	/media/sf_BigShare/Tools/mosdepth-0.2.5/mosdepth --threads 4 --by $target_bed --quantize 0:1:10:25:50: $out $bam
	printf "Region_Chr	Region_Start	Region_Stop	Region_Name	Cov_Chr	Cov_Start	Cov_Stop	Cov_Bin\n" > ${out}_${target_base_no_ext}.txt
	bedtools intersect -nonamecheck -a $target_bed -b ${out}.quantized.bed.gz -wa -wb >> ${out}_${target_base_no_ext}.txt
	awk -f nys_cftr_gap_print10.awk ${out}_${target_base_no_ext}.txt > ${out}_${target_base_no_ext}_gaps_under10.txt
	awk -f nys_cftr_gap_print25.awk ${out}_${target_base_no_ext}.txt > ${out}_${target_base_no_ext}_gaps_under25.txt
	python nys_archer_cf_coverage.py -i ${out}.per-base.bed.gz -t $target_bed -o ${out}
	
done
