awk '{idx=$1 OFS $2 OFS $3}{a[idx]=(idx in a)?a[idx]","$NF:$NF}END{for(i in a) print i,a[i]}' myFile
