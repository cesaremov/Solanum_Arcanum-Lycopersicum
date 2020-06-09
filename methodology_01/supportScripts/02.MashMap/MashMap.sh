#!/bin/bash

# Paths
inPath="../01.Trinity/Trinity"
outPath=$(basename $0 .sh)

# Generate Paths
mkdir -p $outPath

# Patts
#base="testPairs"
inPatt="fasta"

# Genome path
genomeFile="../../Genome/S_lycopersicum_chromosomes.3.00.fa"

# Run STARlong
echo "Running STARlong"
cmd="mashmap -r $genomeFile -q $inPath/Trinity.$inPatt --perc_identity 80 --segLength 500"
echo "running: $cmd"
eval "date && $cmd"




