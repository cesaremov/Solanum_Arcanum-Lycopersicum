#!/bin/bash

# Paths
inPath="../01.Trinity/Trinity"
outPath=$(basename $0 .sh)

# Generate paths
mkdir $outPath

# Trinity file
trinityFile="$inPath/Trinity.fasta"

# Minimum length
m=500

# Pullseq
echo "Filtering short transcripts"
cmd="pullseq -m $m -i $trinityFile > $outPath/Trinity.fasta"
echo "Running: $cmd"
eval "date && $cmd"
