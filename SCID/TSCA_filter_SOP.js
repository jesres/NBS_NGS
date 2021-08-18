// Derive new ROI FORMAT field for each sample
ensureFormatHeader('##FORMAT=<ID=ROI,Number=1,Type=String,' +
'Description="Field to track if the variant is in the ROI">');

function record() {
	//record.addFilter("FAIL");
	//record.addFilter(VcfUtils.FILTER_PASS)
	SAMPLES.forEach(function(sample) {
		//clear existing filter
		//RTG_VCF_RECORD.getFilters().clear();
	
		if(RTG_VCF_RECORD.getFilters().indexOf('OUTSIDE_ROI') > -1) {
		//variant outside of ROI, so lets set ROI field
			sample.ROI = "OUTSIDE_ROI";
		}
		else {
			sample.ROI = "IN_ROI";
		}
		//define failure filters
		if ((has(sample.VF) && sample.VF < 0.156)) {
			RTG_VCF_RECORD.addFilter("FAIL_VF_LOW");
		}
		else if ((has(sample.GQ) && sample.GQ < 3.01)) {
			RTG_VCF_RECORD.addFilter("FAIL_GQ_LOW");
		}
		else if ((has(sample.GQX) && sample.GQX < 6)) {
			RTG_VCF_RECORD.addFilter("FAIL_GQX_LOW");
		}
		else if ((has(INFO.QD) && INFO.QD < 2.87)) {
			RTG_VCF_RECORD.addFilter("FAIL_QD_LOW");
		}
		else if ((has(QUAL) && QUAL < 72.9)) {
			RTG_VCF_RECORD.addFilter("FAIL_QUAL_LOW");
		}
		else if ((has(INFO.DP) && INFO.DP < 3)) {
			RTG_VCF_RECORD.addFilter("FAIL_DP_LOW");
		}
		//need to add PASS to any record that doesn't fail our filters
		else {
			RTG_VCF_RECORD.addFilter("PASS_DEFAULT");
		}
	});
}
