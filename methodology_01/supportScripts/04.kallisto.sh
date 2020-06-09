#/bin/bash

# Paths
inPath="Raw"
outPath="kallisto"

mkdir -p $outPath

# Patts
inPatt=".fastq.gz"

# Kallisto index
transcriptome="Transcriptome/Mus_musculus"

fqFiles="`ls $inPath/*$inPatt`"
for fqFile in $fqFiles; do

   echo $fqFile

   base=`basename $fqFile $inPatt`
   echo $base

   # Quantification
   echo "Quantifying"
   cmdKallisto="kallisto quant --single -i $transcriptome -o $outPath/$base -b 100 -l 50 -s 1 -t 6 $fqFile"
   echo "running: $cmdKallisto"
   eval $cmdKallisto

done




