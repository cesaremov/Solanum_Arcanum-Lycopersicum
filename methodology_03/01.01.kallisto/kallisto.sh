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
inPath="../Raw_rename/"
idxPath="../00.Trinity_Trinotate/01.Trinity/"
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
n=32

# Set index
index=$(find $idxPath -name 'Trinity_all')

# Get mates
echo "Get pairs"
mates=$(find $inPath -name *$inPatt | sed -E "s/_[12].$inPatt$//" | sort | uniq)

# Run kallisto per mates
echo "Running kallisto"
for mate in $mates; do

   echo $mate

   # Set base and logFile
   base="$outPath/$(basename $mate)" 
   logFile="${base}.log"

   # Check if logFile already exists
   if [[ -e $logFile ]]; then
      echo "$logFile already exists! continue..."
      continue
   fi
      

   # Kallisto base
   echo "Set kallisto base command"
   cmd0="kallisto quant -i $index -b 1000 -t $(echo $N*$n | bc) -o $base ${mate}_1.$inPatt ${mate}_2.$inPatt"

   if [[ $mode == "local" ]]; then
      cmd=$cmd0
   elif [[ $mode = "cluster" ]]; then
      cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -p $p -N $N -n $n -o $logFile && touch $logFile"
   fi

   # Eval commands
   echo "Running: $cmd"
   eval "date && $cmd"
done
