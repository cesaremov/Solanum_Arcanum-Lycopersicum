#!/bin/bash

# Paths
inPathTrinity="../01.Trinity/"
inPathConcat="../00.concat/concat/"
outPath=$(basename $0 .sh)

# Generate paths
mkdir -p $outPath

# Set Trinity assemby
trinityFasta=$(find $inPathTrinity -name 'Trinity.fasta')

# TransRate examining contigs
#transrate --assembly $trinityFasta

# Cluster params
J="transrate"
N=1
n=32
t="48:00:00"

# TransRate using read evidence
cmd0="transrate --assembly $trinityFasta --threads=$n" #--left $inPathConcat/pairs_1.fastq.gz \
    # --right $inPathConcat/pairs_2.fastq.gz  --output=$outPath"

# LogFile
logFile="$outPath/transrate.log"

# Mode
#cmd=$cmd0
cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -N $N -n $n -t $t -o $logFile && touch $logFile"

# Eval
echo "Running: $cmd"
eval "date && $cmd"


