#!/bin/bash


# MultiQC if available
#if which multiqc > /dev/null; then
 #  echo "MultiQC procedding"
 #  multiqc $outPath -o $outPath/multiqc
#fi

# Paths
inPath="../01.fastqc"
outPath=$(basename $0 .sh)

# Generate path
mkdir -p $outPath

# 
cmd="multiqc $inPath -o $outPath/multiqc"

#
eval "date && $cmd"

#
#echo -e "#!/bin/bash \n $cmd" | sbatch

