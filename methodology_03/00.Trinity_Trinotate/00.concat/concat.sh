#!/bin/bash

# Paths
inPath="../../Raw_rename/"
outPath=$(basename $0 .sh)

# Generate Paths
mkdir -p $outPath

# Patts
inPatt="fastq.gz"

# Get pairs1
pairs1=$(find $inPath -name "*_1.$inPatt" | tr '\n' ' ')
pairs2=$(find $inPath -name "*_2.$inPatt" | tr '\n' ' ')

# Concat pair 1
echo "Concat pairs 1"
echo -e "#!/bin/bash \n zcat $pairs1 | gzip -1 -c - > $outPath/pairs_1.fastq.gz" | sbatch

# Concat pair 2
echo "Concat pairs 2"
echo -e "#!/bin/bash \n zcat $pairs2 | gzip -1 -c - > $outPath/pairs_2.fastq.gz" | sbatch


