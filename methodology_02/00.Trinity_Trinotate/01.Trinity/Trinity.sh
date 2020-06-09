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
inPath="../00.concat/"
outPath=$(basename $0 .sh)

# Generate Paths
#mkdir -p $outPath

# Patts
inPatt="fastq.gz"
unmPatt="[12]"

# Cluster params
J="Trinity"
#p="all" #"fat_compute"
mem="380G"
p="fat_compute"
N=1
n=32
#time="48:00:00"
qos="long"

# Trinity params
mcl=500

# Get mates
mates=$(find $inPath -name *$inPatt | sed -r "s/${unmPatt}.${inPatt}$//" | uniq)

# Run Tronity per mates
for mate in $mates; do

   echo -e "\nTrinity"
   echo $mate

   # Generate outPath
   outPathMate="${outPath}_$(dirname $mate | sed -r 's/^.+\///g')"
   mkdir -p $outPathMate

   if [[ ! -e $outPathMate/Trinity.fasta ]]; then
      
      # Base command Trinity
      cmd0="Trinity --no_salmon --seqType fq --max_memory $mem --CPU $(echo $N*$n | bc) \
           --min_contig_length $mcl --left ${mate}1.${inPatt} --right ${mate}2.${inPatt} \
           --output $outPathMate"
      
      if [[ $mode == "local" ]]; then
   
         echo "Local mode"   
         cmd=$cmd0

      elif [[ $mode == "cluster"  ]]; then

         echo "Cluster mode"
         cmd="echo -e '#!/bin/bash \n module load anaconda/3.6; $cmd0' | sbatch -J $J -p $p -N $N -n $n --qos=$qos -o ${outPathMate}.log --export='ALL' && touch ${outPathMate}.log"

      fi

      # Run
      echo "Running: $cmd"
      eval "date && $cmd"

   else

      echo "$outPathMate/Trinity.fasta already exists!"
      continue

   fi

done
