#!/bin/bash

usage(){
   echo "Usage: $0 -m/--mode [local/cluster]"
   echo " -m/--mode [local/cluster]     mode to process"
   echo " -c/--clean [yes/no]"          clean previous Trinotate results?
   echo " -h/--help                     print this usage message"
   exit 1
}

clean(){
   del *transdecoder*
   del pipeliner*
   del swis*
   del chkpt*
   del transcriptSuperScaffold.*
   del temp*
   del sig*
   del *cf
   del TMH*
   del tmp*
   del pfam*
   del tmhmm*
   del TrinotatePFAM.out
   del trx.fa.*      
}

# Check number of arguments
if [[ $1 == "" ]] || [[ $# -ne 4 ]]; then
   usage
fi

# Define arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -m | --mode )           mode=$2
                                shift;;
        -c | --clean )          clean=$3
                                shift;;
        -h | --help )           usage
                                exit;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Clean if requested
if [[ $clean == "yes"  ]]; then
   clean
fi

# Paths
#inPath="../00.GetSeqs/GetSeqs/" 
outPath=$(basename $0 .sh)

# Generate paths
#mkdir -p $outPath

# Patts
#pattFa="fa"
#pattGTMap="gene_trans_map"

# Fasta file
#faFile=$(find $inPath -name "mrna_Seqs.$patt")

# Tans map file
#trans_map=$(find $inPath -name "gene_trans_map")


# Cluster parameters
J=$(basename $0 .sh)
N=1
n=32
#walltime=""
qos="ipicyt"

# Auto Trnotate parameters
Trinotate_sqlite="~/programi/Trinotate/current/admin/Trinotate.sqlite"
transcripts=trx.fa #$(find $inPath -name "mrna_Seqs.$pattFa")
gene_to_trans_map=gene_trans_map #$(find $inPath -name $pattGTMap)
conf="conf.txt"
CPU=$n

# Set base command
cmd0="autoTrinotate.pl --Trinotate_sqlite $Trinotate_sqlite \\
                 --transcripts $transcripts \\
                 --gene_to_trans_map $gene_to_trans_map \\
                 --conf $conf --CPU $CPU"

  # Choose mode to run
   if [[ $mode == "local" ]]; then
      
      echo "Local mode"
      cmd="$cmd0" # 2> $logFile"

   elif [[ $mode == "cluster" ]]; then
   
      echo "Cluster mode"
      logFile="$J.log"
      cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -N $N -n $n -o $logFile && touch $logFile"

   fi


echo "Runiing: $cmd"
eval "date & $cmd"


