#!/bin/bash 


# This is a script for finding the <DEL> valued rows in the file and sorting the result with chr name and starts, it also finds the number of occurances of sizes of SVs. 

infile=$1
gz_file=$(basename $infile)
extracted_file=${gz_file::-3}

if [ "$#" -ne 1 ]; 
then
	echo "Illegal number of parameters"
	exit 2
elif [ ${infile: -2} != "gz" ]; 
then 
	echo "Incorrect Format"
	exit 2 
elif ! type "gunzip" > /dev/null;
then 
	echo "no gunzip"
fi

#To download the file
wget $infile

#To extract the file from the gz 
gunzip AJtrio_TARDIS.bilkentuniv.072319.vcf.gz

#To check if extraction is failed
if [ ! -f $extracted_file ];
then 
	echo "extraction is failed."
	exit 2
fi

# get the data for following conditions, sort the data and save it to SV_del.bed
awk '{split($8,col,";"); split(col[1], end, "=");split(col[3],rsp,"="); if($5 == "<DEL>" && rsp[2]>10 && (end[2] - $2)>1000) print $1 "\t" $2 "\t" end[2]}' $extracted_file | sort -k1,1 -k2,2n > SV_del.bed

# remove the file
rm -f $gz_file
rm -f $extracted_file

# To count the number of occurances of SV sizes.
awk '{c[($3-$2)]++} END{for (i in c) printf("%s\t%s\n",i,c[i])}' SV_del.bed > size_distribution.txt



