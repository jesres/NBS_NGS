BEGIN { 
        FS="\t"
        OFS="\t" 
} 
{
sum=0; n=0; min=-1; max=0
for(i=3;i<=NF;i++)
     {
	  sum+=$i;
	  ++n;
	  if(min==-1) {min=$i}
	  if($i<min) {min=$i}
	  if($i>max) {max=$i}
	 }
	 avg=sum/n
	 if(avg<20)
	 {print $0, avg, min, max}
}
