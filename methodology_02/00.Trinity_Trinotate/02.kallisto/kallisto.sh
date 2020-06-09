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
inPath="../00.concat/"
outPath=$(basename $0 .sh)
trinityPath="../01.Trinity/"

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

# Trinity file
echo "Define Trinity assembly"
trinityFasta=$(find $trinityPath -name 'Trinity.fasta')

# Set index
index="$outPath/trinity"

# Get mates
echo "Get pairs"
mates=$(find $inPath -name *$inPatt | sed -E 's/.[12].+gz$//' | uniq)
echo $mates

# Run kallisto per mates
echo "Running kallisto"
for mate in $mates; do

   echo $mate

   # Build index if not
   if [[ ! -e $index ]]; then
      echo -e "Building kallisto index\n"
      cmdBuild="kallisto index -i $index $trinityFasta"
   else 
      echo -e "kallisto index already exists!!!\n"
      cmdBuild="ls $index"
   fi
      
   # Kallisto base
   echo "Set kallisto base command"
   cmdQuant="kallisto quant -i $index -b 1000 -t $(echo $N*$n | bc) --pseudobam -o $outPath ${mate}_1.$inPatt ${mate}_2.$inPatt"
   cmd0="$cmdBuild && $cmdQuant"      

   if [[ $mode == "local" ]]; then
      cmd=$cmd0
   elif [[ $mode = "cluster" ]]; then
      cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -p $p -N $N -n $n -o $outPath/$(basename $mate).log && touch $outPath/$(basename $mate).log"
   fi

   # Eval commands
   echo "Running: $cmd"
   eval "date && $cmd"
done
