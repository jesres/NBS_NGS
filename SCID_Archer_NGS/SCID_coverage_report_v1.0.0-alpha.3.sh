#!/usr/bin/env bash
# Be sure to include above #! as the script will be called directly
#
# Author: kkhalsa (kkhalsa@archerdx.com)
# Bash hook example
# Example UI Args: -j ${JOB_ID} -d ${JOB_DIR} -o ${HOOK_OUTPUT_DIR} ${SAMPLE_NAMES_SPACED}

####SCID_coverage_report_v1.0.0-alpha.3.sh
####
####
####This script reports coverage metrics for a NYS Custom ArcherDX VariantPlex  assay
####Change Log:
####		v1.0.0-alpha.1 - initial release

set -eu

usage()
{
   echo "Usage: $0 -o hook_output_dir -d job_dir -j job_id" 1>&2
   exit 1
}

while getopts ":o:d:j:" opt; do
    case "${opt}" in
        o)
            hook_output_dir=${OPTARG}
            ;;
		d)
			job_dir=${OPTARG}
			;;
		j)
			job_id=${OPTARG}
			;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

set +u

if [ -z "${hook_output_dir}" ]; then
   echo "Error: -o hook_output_dir argument is required." >> /dev/stderr
   exit 1
fi
if [ -z "${job_dir}" ]; then
   echo "Error: -d job_dir argument is required." >> /dev/stderr
   exit 1
fi
if [ -z "${job_id}" ]; then
   echo "Error: -j job_id argument is required." >> /dev/stderr
   exit 1
fi

set -u

#define our target bed file for intron exon and UTR
target_bed=/opt/nys_nbs/211108-SCID.bed

#print headers for the '_coverage_report.txt' file we're going to pass to the python script
printf "Sample	Average_Coverage_Overall	Average_Coverage_CDS	Average_Coverage_Intron	Average_Coverage_UTR	Average_Coverage_SNP_Amps	Average_Coverage_Promoter	Uniformity_Overall	Uniformity_CDS	Uniformity_Intron	Uniformity_UTR	Uniformity_SNP_Amps	Uniformity_Promoter\n" > $hook_output_dir/${job_id}_coverage_report.txt

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
	
	python /opt/nys_nbs/scid/scid_coverage_v1.0.0-alpha.3.py -s $sample -i ${temp_mosdepth_out}.per-base.bed.gz -t $target_bed -o $hook_output_dir/${job_id}_coverage_report.txt

done
