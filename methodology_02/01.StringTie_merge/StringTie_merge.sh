#!/bin/bash

# Paths
inPath="../01.StringTie/"
outPath=$(basename $0 .sh)

# Generate paths
mkdir -p $outPath

# Patts
patt=".gtf"

# Reference annotation
annot="../Genome/grs.gtf"

# Get gtfs
gtfs=$(find $inPath -name "*$patt" | tr '\n' ' ')

# Set command
cmd="stringtie --merge $gtfs -G $annot -o $outPath/all.gtf"
echo "Running: $cmd"
eval "date && $cmd"
