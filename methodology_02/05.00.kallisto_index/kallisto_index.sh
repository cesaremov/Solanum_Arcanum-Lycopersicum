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
echo "Set paths"
inPath="../Raw_rename"
trxPath="../03.01.Concat_Transcriptomes/Concat_Transcriptomes/"
outPath=$(basename $0 .sh)

# Generate Paths
echo "Generating Paths"
mkdir -p $outPath

# Patts
echo "Patts"
inPatt="fastq.gz"

# Cluster parameters
echo "Set cluster parameters"
J="kallisto"
p="computes_standard"
N=1
n=1

# Transcriptome file
echo "Define Transcriptome"
trxFasta=$(find $trxPath -name 'Trinity_all.fasta')

# Set index
index="${trxFasta/.fasta/}"

# Run kallisto index
echo "Running index"

# Build index if not
if [[ ! -e $index ]]; then
   echo -e "Building kallisto index\n"
   cmd0="kallisto index -i $index $trxFasta"
else 
   echo -e "kallisto index already exists!!!\n"
   cmd0="ls $index"
   exit
fi


if [[ $mode == "local" ]]; then
   cmd=$cmd0
elif [[ $mode = "cluster" ]]; then
   cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -p $p -N $N -n $n -o $outPath/kallisto_index.log && touch $outPath/kallisto_index.log"
fi

# Eval commands
echo "Running: $cmd"
eval "date && $cmd"



