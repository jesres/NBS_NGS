#!/bin/bash

input_dir=$1
output_dir=$2
if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir output_dir\n" 
    exit 1
fi

mkdir -p $output_dir

for vcf in $input_dir/*.vcf.gz
do
	vcf_base=${vcf##*/}
	vcf_base_no_ext=${vcf_base%%.*}
	in_intervar=${input_dir}/${vcf_base_no_ext}.avinput
	out_intervar=${output_dir}/${vcf_base_no_ext}
	
	perl /media/sf_BigShare/Tools/annovar/convert2annovar.pl -includeInfo -format vcf4 --outfile $in_intervar $vcf
	#echo $out_intervar
	/media/sf_BigShare/Tools/Intervar_rsicko/InterVar/InterVar.py  --buildver=hg19 --input=$in_intervar --input_type=AVinput --database_intervar=/media/sf_BigShare/Tools/InterVar-0.1.7/intervardb \
	otherinfo=TRUE --convert2annovar=/media/sf_BigShare/Tools/annovar/convert2annovar.pl \
	--table_annovar=/media/sf_BigShare/Tools/annovar/table_annovar.pl \
	--annotate_variation=/media/sf_BigShare/Tools/annovar/annotate_variation.pl \
	--database_locat=/media/sf_BigShare/Tools/annovar/humandb --output=$out_intervar
done
