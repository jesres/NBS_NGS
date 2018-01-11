#!/bin/bash
#set -x


for vcf in /media/sf_BigShare/SCID/Illumina/vcfs/run2/from_run1/*.vcf
do
	java -Xmx10G -jar ~/bin/snpEff-4.2/snpEff.jar GRCh37.75 $vcf | \
	java -Xmx10G -jar ~/bin/snpEff-4.2/SnpSift.jar annotate -id /media/sf_VMShare/snpEff/data/GRCh37.75/00-All_20160528_dbsnp147.vcf.gz \
	- | \
	java -Xmx10G -jar ~/bin/snpEff-4.2/SnpSift.jar annotate /media/sf_VMShare/snpEff/data/GRCh37.75/clinvar_20160705.vcf.gz \
	- | \
	java -Xmx10G -jar ~/bin/snpEff-4.2/SnpSift.jar dbnsfp -db /media/sf_VMShare/snpEff/data/GRCh37.75/dbNSFP3.2a_hg19_sorted_reheader.txt.gz \
	-f SIFT_score,SIFT_converted_rankscore,SIFT_pred,Uniprot_acc_Polyphen2,Uniprot_id_Polyphen2,Uniprot_aapos_Polyphen2,Polyphen2_HDIV_score,Polyphen2_HDIV_rankscore,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,LRT_Omega,MutationTaster_score,MutationTaster_converted_rankscore,MutationTaster_pred,MutationTaster_model,MutationTaster_AAE,MutationAssessor_UniprotID,MutationAssessor_variant,MutationAssessor_score,MutationAssessor_score_rankscore,MutationAssessor_pred,FATHMM_score,FATHMM_converted_rankscore,FATHMM_pred,PROVEAN_score,PROVEAN_converted_rankscore,PROVEAN_pred,Transcript_id_VEST3,Transcript_var_VEST3,VEST3_score,VEST3_rankscore,MetaSVM_score,MetaSVM_rankscore,MetaSVM_pred,MetaLR_score,MetaLR_rankscore,MetaLR_pred,Reliability_index,CADD_raw,CADD_raw_rankscore,CADD_phred,DANN_score,DANN_rankscore,fathmm-MKL_coding_score,fathmm-MKL_coding_rankscore,fathmm-MKL_coding_pred,fathmm-MKL_coding_group,Eigen-raw,Eigen-phred,Eigen-raw_rankscore,Eigen-PC-raw,Eigen-PC-raw_rankscore,GenoCanyon_score,GenoCanyon_score_rankscore,integrated_fitCons_score,integrated_fitCons_score_rankscore,integrated_confidence_value,H1-hESC_fitCons_score,H1-hESC_fitCons_score_rankscore,H1-hESC_confidence_value,GERP++_NR,GERP++_RS,GERP++_RS_rankscore,phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phyloP20way_mammalian,phyloP20way_mammalian_rankscore,phastCons100way_vertebrate,phastCons100way_vertebrate_rankscore,phastCons20way_mammalian,phastCons20way_mammalian_rankscore,SiPhy_29way_pi,SiPhy_29way_logOdds,SiPhy_29way_logOdds_rankscore,1000Gp3_AC,1000Gp3_AF,1000Gp3_AFR_AC,1000Gp3_AFR_AF,1000Gp3_EUR_AC,1000Gp3_EUR_AF,1000Gp3_AMR_AC,1000Gp3_AMR_AF,1000Gp3_EAS_AC,1000Gp3_EAS_AF,1000Gp3_SAS_AC,1000Gp3_SAS_AF,TWINSUK_AC,TWINSUK_AF,ESP6500_AA_AC,ESP6500_AA_AF,ESP6500_EA_AC,ESP6500_EA_AF,ExAC_Adj_AC,ExAC_Adj_AF,ExAC_AFR_AC,ExAC_AFR_AF,ExAC_AMR_AC,ExAC_AMR_AF,ExAC_EAS_AC,ExAC_EAS_AF,ExAC_FIN_AC,ExAC_FIN_AF,ExAC_NFE_AC,ExAC_NFE_AF,ExAC_SAS_AC,ExAC_SAS_AF,Interpro_domain,GTEx_V6_gene,GTEx_V6_tissue \
	- > ${vcf}.ann.dbsnp.clinvar.dbnsfp.vcf
done
