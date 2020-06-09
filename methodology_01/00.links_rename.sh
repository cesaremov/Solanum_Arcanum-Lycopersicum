#!/bin/bash

# Paths
echo "Set paths"
inPath="Raw"
outPath="${inPath}_rename"

# Make paths
echo "Making paths"
mkdir -p $outPath

# Patts
echo "Set Patts"
inPatt=".fq.gz"
outPatt=".fastq.gz"

# Pdata filename
echo "Set pdata file"
pdata="pdata/pdata.tab"

# Get files
echo "Get files to process"
files=`ls $inPath/*$inPatt`

for file in $files; do 
 
   echo $file

   # Process file name
   a=`basename $file $inPatt`; 
   b=`grep $a $pdata | cut -f2`; 
   b=${b//./_}
   echo $inPath/$b;
   
   # Link
   echo "Linking"
   cmd="ln -sf ../$file $outPath/$b$outPatt"
   echo "running: $cmd"
   eval $cmd

done

