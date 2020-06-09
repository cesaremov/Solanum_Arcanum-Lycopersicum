#!/bin/bash

# Set paths
outPath=$(basename $0 .sh)

# Generate paths
mkdir -p $outPath

# Transcriptomes to concat
lycTrans="../03.00.GetSeqs/GetSeqs/mrna_Seqs.fa"  #"../Genome/ITAG3.2_cDNA.fasta" #"../01.GetSeqs/GetSeqs/trx_Seqs.fa"
trinityTrans="../00.Trinity_Trinotate/01.Trinity/Trinity_concat/Trinity.fasta"

# Out Transcriptome
outTrans="$outPath/Trinity_all.fasta"

# Concat Transcriptome
echo "Concat Transcriptomes"
cmd="cat $lycTrans $trinityTrans > $outTrans"
echo "Running: $cmd"
eval "date && $cmd"



# Concat gene_trans_map files
lycGTM="../03.00.GetSeqs/GetSeqs/gene_trans_map"
trinityGTM="../00.Trinity_Trinotate/01.Trinity/Trinity_concat/Trinity.fasta.gene_trans_map"

# Out GTM
outGTM="$outPath/gene_trans_map"

#Concat GTM
echo "Concat GTM"
cmd="cat $lycGTM $trinityGTM > $outGTM"
echo "Running: $cmd"
eval "date && $cmd"





