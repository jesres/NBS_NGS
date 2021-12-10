
BEGIN {
 OFS = "\t";
}
{
 if($10 ~ /NO_COVERAGE/ || $10 ~ /UNDER10/ || $10 ~ /UNDER25/)
 {
  min=$3
  max=$2
  if($8>max)max=$8;
  if($9<min)min=$9;
  size=min-max;
  print sample,$1,max,min,size,$4,$10;
 }
}

