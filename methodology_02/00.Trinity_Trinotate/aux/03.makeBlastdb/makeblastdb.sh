#!/bin/bash

# Paths
inPath="../../Genome/"

# Genome
genomeFile="$inPath/S_lycopersicum_chromosomes.3.00.fa"

makeblastdb -in $genomeFile  -dbtype nucl
