import pybedtools
import glob

input_regions = pybedtools.BedTool('/media/sf_BigShare/SCID/Ion/Design/WG_IAD68323_5.20170321.designed-no-header.bed')

for callable_bed in glob.iglob('/media/sf_BigShare/SCID/Ion/Val-Run1/analysis/vcfeval/callable-regions/*.callable.bed'):
    callable_regions = pybedtools.BedTool(callable_bed)
    filter_regions = callable_regions.filter(lambda x: x.name == "CALLABLE")
    tx_out_file=callable_bed+".targets.bed"
    filter_regions.intersect(input_regions, nonamecheck=True).saveas(tx_out_file)