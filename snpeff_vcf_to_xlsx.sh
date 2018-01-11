#!/bin/bash
#set -x

input=$1
output=$2


if [ $# -ne 2 ];then
    printf "Usage: $0 input_file output_file\n" 
    exit 1
fi

cat $input \
| /home/rsicko/bin/snpEff-4.2/scripts/vcfEffOnePerLine.pl \
| java -jar /home/rsicko/bin/snpEff-4.2/SnpSift.jar extractFields -s "," -e "." - \
CHROM POS ID REF ALT QUAL FILTER "GEN[*].VF" QD DP CLNSIG CLNDSDBID "ANN[*].IMPACT" \
"ANN[*].EFFECT" "ANN[*].GENE" "ANN[*].GENEID" "ANN[*].FEATUREID" "ANN[*].RANK" "ANN[*].HGVS_C" "ANN[*].HGVS_P" "GEN[*].GT" \
"dbNSFP_1000Gp3_AFR_AF" "dbNSFP_1000Gp3_AMR_AF" "dbNSFP_1000Gp3_EAS_AF" \
"dbNSFP_1000Gp3_SAS_AF" "dbNSFP_1000Gp3_EUR_AF" "dbNSFP_TWINSUK_AF" \
"dbNSFP_ESP6500_AA_AF" "dbNSFP_ESP6500_EA_AF" \
"dbNSFP_ExAC_AFR_AF" "dbNSFP_ExAC_AMR_AF" "dbNSFP_ExAC_EAS_AF" \
"dbNSFP_ExAC_FIN_AF" "dbNSFP_ExAC_NFE_AF" "dbNSFP_ExAC_NFE_AF" "dbNSFP_ExAC_SAS_AF" \
"LOF[*].GENE" "LOF[*].GENEID" "LOF[*].NUMTR" "LOF[*].PERC" \
"NMD[*].GENE" "NMD[*].GENEID" "NMD[*].NUMTR" "NMD[*].PERC" \
"dbNSFP_MetaSVM_pred" "dbNSFP_MetaLR_pred" "dbNSFP_FATHMM_pred" "dbNSFP_fathmm_MKL_coding_pred" \
"dbNSFP_LRT_pred" "dbNSFP_PROVEAN_pred" "dbNSFP_MutationTaster_pred" "dbNSFP_MutationAssessor_pred" \
"dbNSFP_SIFT_pred" "dbNSFP_Polyphen2_HVAR_pred" "dbNSFP_Polyphen2_HDIV_pred" "dbNSFP_FATHMM_pred" \
"dbNSFP_DANN_score" "dbNSFP_DANN_rankscore" "dbNSFP_CADD_raw" \
"dbNSFP_CADD_phred" "dbNSFP_Eigen_phred" \
> $output 

echo -e "variants output to $output \n"
