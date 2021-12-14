#compress and index sample vcf files
vcf_dir=
echo $vcf_dir
for vcf in $vcf_dir/*.vcf
do
	
	bgzip -i -c $vcf > ${vcf}.gz
	tabix -f -p vcf ${vcf}.gz
	
done
