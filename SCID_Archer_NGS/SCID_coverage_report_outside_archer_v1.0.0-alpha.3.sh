#!/usr/bin/env bash
# Be sure to include above #! as the script will be called directly
#
# Author: kkhalsa (kkhalsa@archerdx.com)
# Bash hook example
# Example UI Args: -j ${JOB_ID} -d ${JOB_DIR} -o ${HOOK_OUTPUT_DIR} ${SAMPLE_NAMES_SPACED}

####SCID_coverage_report_v1.0.0-alpha.1.sh
####
####
####This script reports coverage metrics for a NYS Custom ArcherDX VariantPlex  assay
####Change Log:
####		v1.0.0 - initial release

set -eu


hook_output_dir="/opt/nys_nbs/scid/output/5082-2"
job_dir="/opt/nys_nbs/scid/5082-2"
job_id="5082-2"

function log_step () {
  local time_stamp
  time_stamp="$(date)"
  local VERSION
  VERSION="v1.0.3"
  DATESTAMP="$(date "+%Y-%m-%d")"
  echo "[$DATESTAMP]"$'\t'"[$VERSION]" > $hook_output_dir/${job_id}_log.txt
}

#define our target bed file for intron exon and UTR
target_bed=/opt/nys_nbs/scid/200914-SCID_archer_exons_10intron_200utr_final_sorted_1-4.bed

#print headers for the '_coverage_report.txt' 
#combine_out = pd.DataFrame({'Sample':[args.sample],
#							'Average_Coverage_Overall': [Ave_total],
#							'Average_Coverage_Exon': [Ave_exon],
#							'Average_Coverage_Intron': [Ave_intron],
#							'Average_Coverage_UTR': [Ave_utr],
#							'Uniformity_Overall': [per_uni_total],
#							'Uniformity_Exon': [per_uni_exon],
#							'Uniformity_Intron': [per_uni_intron],
#							'Uniformity_UTR': [per_uni_utr]})

printf "Sample	Average_Coverage_Overall	Average_Coverage_Exon	Average_Coverage_Intron	Average_Coverage_UTR	Uniformity_Overall	Uniformity_Exon	Uniformity_Intron	Uniformity_UTR\n" > $hook_output_dir/${job_id}_coverage_report.txt

#print headers for the '_gaps_under10.txt' file we're going to pass to awk below
printf "Sample	Chr	Gap_Start	Gap_Stop	Gap_Size	Region_Name	Cov_Bin\n" > $hook_output_dir/${job_id}_gaps_under10.txt

#print headers for the '_gaps_under25.txt' file we're going to pass to awk below
printf "Sample	Chr	Gap_Start	Gap_Stop	Gap_Size	Region_Name	Cov_Bin\n" > $hook_output_dir/${job_id}_gaps_under25.txt

for bam in ${job_dir}/*.molbar.trimmed.deduped.merged.bam
do
	bam_base=${bam##*/}
	sample=$(echo ${bam_base} | sed "s/_L001_R1_\001\.molbar.trimmed.deduped.merged.bam//") 
	
	# by setting these ENV vars, we can control the output labels (4th column)
	export MOSDEPTH_Q0=NO_COVERAGE   # 0 -- defined by the arguments to --quantize
	export MOSDEPTH_Q1=UNDER10  # 1..9
	export MOSDEPTH_Q2=UNDER25      # 10..24
	export MOSDEPTH_Q3=UNDER50      # 25..49
	export MOSDEPTH_Q4=HIGH_COVERAGE # 50 ...
	
	#create a temp files
	temp_mosdepth_out=${job_dir}/sample
	temp_bedtools_out=${job_dir}/targets.txt
	
	/opt/mosdepth-0.2.5/mosdepth --threads 4 --by $target_bed --quantize 0:1:10:25:50: $temp_mosdepth_out $bam
	
	printf "Region_Chr	Region_Start	Region_Stop	Region_Name	Cov_Chr	Cov_Start	Cov_Stop	Cov_Bin\n" > temp_bedtools_out
	
	bedtools intersect -nonamecheck -a $target_bed -b ${temp_mosdepth_out}.quantized.bed.gz -wa -wb >> temp_bedtools_out
	awk -v sample="$sample" -f /opt/nys_nbs/nys_cftr_gap_print10_v1.0.0.awk temp_bedtools_out >> $hook_output_dir/${job_id}_gaps_under10.txt
	awk -v sample="$sample" -f /opt/nys_nbs/nys_cftr_gap_print25_v1.0.0.awk temp_bedtools_out >> $hook_output_dir/${job_id}_gaps_under25.txt
  
	#temp_cov_overall=$(zcat ${temp_mosdepth_out}.regions.bed.gz | awk '{total+=$5} END {print total/NR}')
  #temp_cov_exon=$(zcat ${temp_mosdepth_out}.regions.bed.gz | grep "exon" | awk '{total+=$5} END {print total/NR}')
  #temp_cov_intron=$(zcat ${temp_mosdepth_out}.regions.bed.gz | grep "intron" | awk '{total+=$5} END {print total/NR}')
  #temp_cov_utr=$(zcat ${temp_mosdepth_out}.regions.bed.gz | grep "utr" | awk '{total+=$5} END {print total/NR}')
  #printf "%s  %0.0f	%0.0f	%0.0f	%0.0f\n" $sample $temp_cov_overall $temp_cov_exon $temp_cov_intron $temp_cov_utr >> $hook_output_dir/${job_id}_coverage_report.txt
  python /opt/nys_nbs/scid/scid_coverage_v1.0.0-alpha.3.py -s $sample -i ${temp_mosdepth_out}.per-base.bed.gz -t $target_bed -o $hook_output_dir/${job_id}_coverage_report.txt
log_step
done
