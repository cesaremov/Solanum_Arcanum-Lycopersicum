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
inPath="Raw_rename"
outPath="01.fastqc"
logPath="$outPath"

# Make paths
echo "Making paths"
mkdir -p $outPath
#mkdir -p $logPath

# Patts
echo "Set Patt"
inExt=".fastq.gz"

# Cluster params
echo "Set cluster params"
nodes=1
ppn=1
mem="20G"

# FastQC parameters
echo "Set FastQC params"
params="-o $outPath --extract -f fastq -t 4"   #--contaminants contaminant_list.txt"

# Files to process
echo "Get files to process"
inFiles=`find $inPath -name "*$inExt"`

for inFile in $inFiles; do
  
   echo $inFile

   # logFile for each inFile
   logFileBase=`basename $inFile | sed  "s/$inExt/.log/"`
   logFile="$logPath/$logFileBase"
   echo $logFile
   
   # Check if logFile exists
   if [[ -f $logFile ]]; then
      echo "$logFile already exists, skip processing!"
      continue
   fi

   # FastQC
   echo "FastQC"
   cmd0="fastqc $params $inFile"
   if [[ $mode == "local" ]]; then
      cmd=$cmd0 
   elif [[ $mode == "cluster" ]]; then
      cmd="echo 'cd \$PBS_O_WORKDIR; module load FastQC/0.11.2; $cmd0' | qsub -V -N FastQC -l nodes=1:ppn=1,mem=$mem,vmem=$mem -o $logFile -j oe && touch $logFile"
   fi
   echo "running: $cmd"
   eval "date; $cmd"

done


