#!/bin/bash

# Paths
inPath="../Raw_rename"
outPath="00.countLines"

# Make paths
mkdir -p $outPath

# Patterns
inPatt=".fastq.gz"
idPatt="^@E00515"

# Input files
inFiles="$inPath/*$inPatt"
#echo $inFiles

# Process
outFile="$outPath/results.txt"
echo -n > $outFile
for inFile in $inFiles; do

   echo "Processing $inFile"

   # Count ids
   nIds=$(gzip -dc $inFile |  grep -E -c "$idPatt")
   echo $nIds
   echo -e "$inFile\t$nIds" >> $outFile
   #echo "Running: $cmd"
   #eval "date; $cmd"
done

