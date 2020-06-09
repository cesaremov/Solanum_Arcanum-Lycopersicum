#!/bin/bash

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
echo "Set paths"
inPath="../01.Trinity"
outPath=$(basename $0 .sh)

# Generate paths
echo "Generating paths"
mkdir -p $outPath

# Patts
echo "Set patts"
patt=".fasta"

# Cluster parameters
echo "Set cluster parameters"
J="kcombine"
N=1
n=1
t="10:00:00"

# Get assemblies
echo "Get Trinity assemblies"
fastas=$(find $inPath -name "Trinity$patt" | paste -sd ' ' - ) 

# Set logFile
logFile="$outPath/kcombine.log"

# kCombine base params
kcBase="kcombine 25 500 500"

if [[ -f $logFile  ]]; then
   echo "$logFile already exists, skip processing!"
   break
else

   # Set command kCombine
   cmdKC="$kcBase $fastas > $outPath/Trinity.fasta"

   if [[ $mode == "local" ]]; then
      echo "Local mode"
      cmd=$cmdKC
      echo "running: $cmd"
      eval "date && $cmd"
   else
      echo "Cluster mode"
      cmd0="#!/bin/bash; 
            cd \$SLURM_SUBMIT_DIR; ls > test.txt; $cmdKC" 
      cmd="echo '$cmd0' | sbatch -J $J -N $N -n $n"
      echo "running: $cmd"
      eval "date &&  $cmd"
   fi
fi

