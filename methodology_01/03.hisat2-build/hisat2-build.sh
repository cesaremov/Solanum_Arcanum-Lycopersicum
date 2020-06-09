#!/bin/bash

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
genomePath="../Genome"

# Patts
patt=".fasta"

# Genome file
genomeFile="$genomePath/genome$patt"

# Cluster parameters
J="hisat2-build"
N=1
n=1

# Genome base
base=$(basename $genomeFile $patt)

# Base command
cmd0="hisat2-build $genomeFile $genomePath/$base && hisat2-inspect -s $genomePath/$base > $genomePath/$base.tab"

if [[ $mode == "local" ]]; then

   echo "Local mode"

   cmd=$cmd0

elif [[$mode == "cluster" ]]; then

   echo "Cluster mode"
      
   cmd="echo '#!/bin/bash; cd \$SLURM_SUBMIT_DIR; $cmd0' | sbatch -J $J -N $n -n $n"

fi

# Run
echo "Running: $cmd"
eval "date && $cmd"


