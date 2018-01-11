#!/bin/bash
#set -x

input=$1
output=$2
output_cs="${output}.clinsig.vcf"
output_cs_tab="${output}.clinsig.txt"
output_rare="${output}.rare.vcf"
output_rare_tab="${output}.rare.txt"
output_imp="${output}.impactful.vcf"
output_imp_tab="${output}.impactful.txt"



if [ $# -ne 2 ];then
    printf "Usage: $0 input_file output_file\n" 
    exit 1
fi


#output any clinically sig variant, even if they didn't pass upstream filters
echo -e "filtering for clinically significant variants\n"
java -Xmx4g -jar ~/bin/snpEff-4.2/SnpSift.jar \
filter "( (exists CLNSIG) & ((CLNSIG has '4') | (CLNSIG has '5')"\
" | (CLNSIG has '-4') | (CLNSIG has '-5') ) )" \
$input > $output_cs
~/bin/vcflib/bin/vcf2tsv -n NA $output_cs > $output_cs_tab
echo -e "clinically significant variants output to $output_cs \n"

#output rare variants (<1% AF) that passed upstream filters
echo -e "filtering for rare variants\n"
java -Xmx4g -jar ~/bin/snpEff-4.2/SnpSift.jar \
filter "( ((na dbNSFP_1000Gp3_AFR_AF[ANY]) | (dbNSFP_1000Gp3_AFR_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_1000Gp3_AMR_AF[ANY]) | (dbNSFP_1000Gp3_AMR_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_1000Gp3_EAS_AF[ANY]) | (dbNSFP_1000Gp3_EAS_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_1000Gp3_SAS_AF[ANY]) | (dbNSFP_1000Gp3_SAS_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_1000Gp3_EUR_AF[ANY]) | (dbNSFP_1000Gp3_EUR_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_TWINSUK_AF[ANY]) | (dbNSFP_TWINSUK_AF[ANY] < 0.01 ))"\
" & ((na dbNSFP_ESP6500_AA_AF[ANY]) | (dbNSFP_ESP6500_AA_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ESP6500_EA_AF[ANY]) | (dbNSFP_ESP6500_EA_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_AFR_AF[ANY]) | (dbNSFP_ExAC_AFR_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_AMR_AF[ANY]) | (dbNSFP_ExAC_AMR_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_EAS_AF[ANY]) | (dbNSFP_ExAC_EAS_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_FIN_AF[ANY]) | (dbNSFP_ExAC_FIN_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_NFE_AF[ANY]) | (dbNSFP_ExAC_NFE_AF[ANY] < 0.01))"\
" & ((na dbNSFP_ExAC_SAS_AF[ANY]) | (dbNSFP_ExAC_SAS_AF[ANY] < 0.01)) )"\
 $input > $output_rare
 ~/bin/vcflib/bin/vcf2tsv -n NA $output_rare > $output_rare_tab
echo -e "rare variants output to $output_rare \n"

#output only rare variants that are "high" or "moderate" impact or an effect of:
#conserved_intergenic_variant
#conserved_intron_variant
#miRNA
#5_prime_UTR_premature_start_codon_gain_variant
#regulatory_region_variant
echo -e "filtering for impactful variants\n"
java -Xmx4g -jar ~/bin/snpEff-4.2/SnpSift.jar \
filter "( (ANN[ANY].IMPACT has 'HIGH')"\
" | (ANN[ANY].IMPACT has 'MODERATE')"\
" | (ANN[ANY].EFFECT has 'conserved_intergenic_variant')"\
" | (ANN[ANY].EFFECT has 'conserved_intron_variant')"\
" | (ANN[ANY].EFFECT has 'miRNA')"\
" | (ANN[ANY].EFFECT has '5_prime_UTR_premature_start_codon_gain_variant')"\
" | (ANN[ANY].EFFECT has 'regulatory_region_variant') )"\
 $output_rare > $output_imp
 ~/bin/vcflib/bin/vcf2tsv -n NA $output_imp > $output_imp_tab
echo -e "impactful variants output to $output_imp \n"
