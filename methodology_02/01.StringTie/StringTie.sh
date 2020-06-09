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
inPath="../../00.Lyc_Genome/04.hisat2/"
outPath=$(basename $0 .sh)

# Makes paths
mkdir -p $outPath

# Patts
inPatt=".bam"

# Annotation file
annotFile="../Genome/grs.gff"

# Cluster params
J="StringTie"
N=1
n=32
qos="ipicyt"

# Input Files
inFiles=$(find $inPath -name "*$inPatt")

for inFile in $inFiles ; do

   echo $inFile

   # Get base
   base=`basename $inFile | sed "s/$inPatt//"`

   # Set filenames
   outPathBase="$outPath/${base}"
   logFile="$outPath/${base}.log"
  
   # Check if logfile exists
   if [[ -f $logFile ]]; then
      echo "$logFile already exists, skip processing!"
      continue
   fi  

   # Feature counts command base
   cmd0="stringtie $inFile -v -p $n -G $annotFile -A ${outPathBase}.tab -o ${outPathBase}.gtf"

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

