import pybedtools
import glob

input_regions = pybedtools.BedTool('/media/sf_BigShare/SCID/Illumina/vcfs/run1/for_filter/170302_vcfeval/inputs/170213_SCID_Exons_w_20bp_Padding.sorted.bed')

for callable_bed in glob.iglob('/media/sf_BigShare/SCID/Illumina/SCID1/BaseCalls/Alignment/callable_regions/*'):
    callable_regions = pybedtools.BedTool(callable_bed)
    filter_regions = callable_regions.filter(lambda x: x.name == "CALLABLE")
    tx_out_file=callable_bed+".targets.exons.bed"
    filter_regions.intersect(input_regions, nonamecheck=True).saveas(tx_out_file)