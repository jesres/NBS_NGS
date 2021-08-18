
BEGIN {
 OFS = "\t";
 print "Sample_Region\tChr\tStart\tEnd"
}
{
 if($10 <20)
 {
  n = split(FILENAME, a, "/");
  basename=a[n];
  o = split(basename, b, "_1712*");
  basename_clean=b[1];
  print basename_clean"_"$4,$7,$8,$9;
 }
}

