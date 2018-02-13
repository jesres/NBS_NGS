#!/bin/bash

input_dir=$1
output_dir=$2
scripts_dir=$3

if [ $# -ne 3 ];then
    printf "Usage: $0 input_dir results_dir scripts_dir\n" 
    exit 1
fi

for sample in $input_dir/*_171207-SCID_final_roi.txt
do
	sample_base=${sample##*/}
	sample_base_no_ext=${sample_base%%.*}
	sample_base_no_ext=${sample_base_no_ext%%_171207-SCID_final_roi*}
	out=${output_dir}/${sample_base_no_ext}_Regions_to_Sanger.txt
	primer_finder_out=${scripts_dir}/sanger_primer_finder/data_store/${sample_base_no_ext}_for_primer_finder.input
	awk -f OutputSangerRegions.awk $sample > $out
	awk -f OutputSangerRegionsFormattedForPrimerFinder.awk $sample > $primer_finder_out
done
