#!/usr/bin/env bash
# Be sure to include above #! as the script will be called directly
#
# Author: kkhalsa (kkhalsa@archerdx.com)
# Bash hook example
# Example UI Args: -j ${JOB_ID} -d ${JOB_DIR} -o ${HOOK_OUTPUT_DIR} ${SAMPLE_NAMES_SPACED}

####raw_vision_calls_v1.0.0-alpha1.sh
####Author: Bob Sicko robert.sicko@health.ny.gov
####
####
####This script combines all Vision calls above our thresholds (AO >= 5 & UAO >= 3) into a single file
####Change Log:
####		v1.0.0-alpha.1 - Initial release


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

#print headers for the file we're going to pass to awk below
printf "Sample	HGVSp	HGVSc	DP	AO	UAO	AF	position	reference	mutation	quality\n" > $hook_output_dir/${job_id}_vision_calls.txt

for calls in  ${job_dir}/*_L001_R1_001.vcf.summary.tsv
do
	prefix=$(echo ${calls} | sed "s/_L001_R1_\001\.vcf.summary.tsv//")
	awk -v prefix="$prefix" '(FNR>1 && $9 >= 5 && $11 >= 3) {print prefix,"\t",$61,"\t",$60,"\t",$9,"\t",$11,"\t",$15,"\t",$12,"\t",$4,"\t",$5,"\t",$6,"\t",$7}' $calls >> ${job_id}_vision_calls.txt

done


