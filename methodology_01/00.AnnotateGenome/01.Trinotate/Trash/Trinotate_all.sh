#!/bin/bash

usage(){
   echo "Usage: $0 -m/--mode [local/cluster]"
   echo " -m/--mode [local/cluster]     mode to process"
   echo " -h/--help                               print this usage message"
   exit 1
}

# Check number of arguments
if [[ $1 == "" ]] || [[ $# -ne 2 ]]; then
   usage
fi

# Define arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -m | --mode )                   mode=$2
                                        shift;;
        -h | --help )           usage
                                exit;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Paths
inPath="../07.GetSeqs/GetSeqs/" 
outPath=$(basename $0 .sh)
dbPath="~/programi/Trinotate/current/admin"

# Generate paths
mkdir -p $outPath

# Patts
patt="fa"

# Fasta file
faFile=$(find $inPath -name "mrna_Seqs.$patt")

# Tans map file
trans_map=$(find $inPath -name "gene_trans_map")

# Cluster params
J=$(basename $0 .sh)
N=1
n="32"




