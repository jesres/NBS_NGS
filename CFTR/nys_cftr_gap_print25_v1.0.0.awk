
BEGIN {
 OFS = "\t";
}
{
 if($8 ~ /NO_COVERAGE/ || $8 ~ /UNDER10/ || $8 ~ /UNDER25/)
 {
  min=$3
  max=$2
  if($6>max)max=$6;
  if($7<min)min=$7;
  size=min-max;
  print sample,$1,max,min,size,$4,$8;
 }
}

