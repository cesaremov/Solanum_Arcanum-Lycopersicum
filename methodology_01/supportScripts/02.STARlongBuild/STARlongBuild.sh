#!/bin/bash

# Paths
inPath="../../Genome/"
outPath=$(basename $0 .sh)

# Generate Paths
mkdir -p $outPath

# Patts
#base="testPairs"
inPatt="fasta"

# Genome path
genomePath="$inPath"
genomeFile="$inPath/S_lycopersicum_chromosomes.3.00.fa"

# Run STARlong
echo "Running STARlong"
cmd="STARlong --runMode genomeGenerate --genomeDir $genomePath --genomeFastaFiles $genomeFile"
echo "running: $cmd"
eval "date && $cmd"




