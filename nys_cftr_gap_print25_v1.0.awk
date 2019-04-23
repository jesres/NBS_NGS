
BEGIN {
 OFS = "\t";
 print "Chr\tGap_Start\tGap_Stop\tGap_Size\tRegion_Name\tCov_Bin"
}
{
 if($8 ~ /NO_COVERAGE/ || $8 ~ /UNDER10/ || $8 ~ /UNDER25/)
 {
  min=$3
  max=$2
  if($6>max)max=$6;
  if($7<min)min=$7;
  size=min-max;
  print $1,max,min,size,$4,$8;
 }
}

