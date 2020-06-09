#!/bin/bash

# Paths
inPath="../../../00.Lyc_Genome/04.hisat2"
outPath=$(basename $0 .sh)

# Generate Paths
mkdir -p $outPath

# Patts
inPatt="mate"

# Get pairs1
pairs1=$(find $inPath -name "*$inPatt\.1")
pairs2=$(find $inPath -name "*$inPatt\.2")

# Concat pair 1
echo "Concat pairs 1"
zcat $pairs1 | gzip -1 -c - > $outPath/pairs_1.fastq.gz

# Concat pair 2
echo "Concat pairs 2"
zcat $pairs2 | gzip -1 -c - > $outPath/pairs_2.fastq.gz


