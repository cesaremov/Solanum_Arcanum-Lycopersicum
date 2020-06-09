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
genomePath="../../Genome/S_lycopersicum_chromosomes.3.00.fa"

# Run STARlong
echo "Running STARlong"
cmd="STARlong --genomeDir $genomePath --readFilesIn $inPath/Trinity.$inPatt"
echo "running: $cmd"
eval "date && $cmd"




