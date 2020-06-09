#/bin/bash

usage(){
   echo "Usage: $0 -m/--mode [local/cluster]"
   echo "	-m/--mode [local/cluster]	mode to process"
   echo "	-h/--help 			print this usage message"
   exit 1
}

# Check number of arguments
if [[ $1 == "" ]] || [[ $# -ne 2 ]]; then
   usage
fi

# Define arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -m | --mode )		mode=$2
				shift;;
        -h | --help )           usage
                                exit;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Paths
inPath="../04.hisat2/"
outPath=$(basename $0 .sh)

# Makes paths
mkdir -p $outPath

# Patts
inPatt=".bam"

# Annotation types
#annotFile="../Genome/genes.gtf"
annotTypes="exon CDS intron intergenic" 

# featureCounts parameters
gene_id="gene_id"
feature_type="exon"

# Cluster params
J="featureCounts"
N=1
n=32
qos="ipicyt"

# Input Files
inFiles=$(find $inPath -name "*$inPatt")

for inFile in $inFiles ; do

   echo $inFile

   # Get base
   base=`basename $inFile | sed "s/$inPatt//"`

   for annotType in $annotTypes; do

      # Set filenames
      outFile="$outPath/${base}_$annotType.tab"
      logFile="$outPath/${base}_$annotType.log"
  
      # Check if logfile exists
      if [[ -f $logFile && -f $outFile.summary ]]; then
         echo "$logFile already exists, skip processing!"
         continue
      fi  

      # Feature counts
      cmdFeatCounts="featureCounts -p -T $n -J -M --fraction --largestOverlap --fracOverlap 0.75 \\
                     -t $feature_type -g $gene_id -a $annotType.gtf -o $outFile $inFile"

      # featureCounts command
      cmd0="$cmdFeatCounts"
      if [[ $mode == "local" ]]; then
     
         echo "Local mode"
         cmd=$cmd0

      elif [[ $mode == "cluster" ]]; then
      
         echo "Cluster mode"
         cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -N $N -n $n --qos=$qos -o $logFile && touch $logFile"
  
      fi
   
      # Run
      echo "Running: $cmd"
      eval "date && $cmd"

   done
done

