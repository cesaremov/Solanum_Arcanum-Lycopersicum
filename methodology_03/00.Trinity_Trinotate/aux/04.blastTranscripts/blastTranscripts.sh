#!/bin/bash

# Paths
inPath="../02.filterTranscripts/filterTranscripts"
outPath="$(basename $0 .sh)"
dbPath="../../Genome"

# Generate paths
mkdir -p $outPath

# Patts

# dbFile
dbFile="$dbPath/S_lycopersicum_chromosomes.3.00.fa"

# Trinity transcripts
trinityFile="$inPath/Trinity.fasta"

# Blast
echo "Running Blastn"
cmd="blastn -query $trinityFile -db $dbFile -out $outPath/blast.tab -outfmt 6"
echo "running $cmd"
eval "date; $cmd"
