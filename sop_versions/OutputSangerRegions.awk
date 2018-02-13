
BEGIN {
 OFS = "\t";
 print "Sample\tChr\tStart\tEnd\tDepth\tSize_Coverage_Interval\tRegion_Name"
}
{
 if($10 <20)
 {
  n = split(FILENAME, a, "/");
  basename=a[n];
  o = split(basename, b, "_1712*");
  basename_clean=b[1];
  print basename_clean,$7,$8,$9,$10,$11,$4;
 }
}

