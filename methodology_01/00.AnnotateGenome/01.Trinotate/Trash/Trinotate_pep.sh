#!/bin/bash

usage(){
   echo "Usage: $0 -m/--mode [local/cluster]"
   echo " -m/--mode [local/cluster]     mode to process"
   echo " -h/--help                               print this usage message"
   exit 1
}

# Check number of arguments
if [[ $1 == "" ]] || [[ $# -ne 2 ]]; then
   usage
fi

# Define arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -m | --mode )                   mode=$2
                                        shift;;
        -h | --help )           usage
                                exit;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Paths
inPath="../07.GetSeqs/GetSeqs/" 
outPath=$(basename $0 .sh)
dbPath="~/programi/Trinotate/current/admin"

# Generate paths
mkdir -p $outPath

# Patts
patt="fa"

# Fasta file
faFile=$(find $inPath -name "mrna_Seqs.$patt")

# Tans map file
trans_map=$(find $inPath -name "gene_trans_map")

# Cluster params
J=$(basename $0 .sh)
N=1
n="32"

if [[ -e $(basename $faFile).transdecoder.pep ]]; then

   # Blastp
   cmdBp="blastp -query $(basename $faFile).transdecoder.pep -db $dbPath/uniprot_sprot.pep -num_threads $n -max_target_seqs 1 -outfmt 6 > $outPath/blastp.outfmt6" 

   # Hmmer
   cmdH="hmmscan --cpu $n --domtblout $outPath/TrinotatePFAM.out $dbPath/Pfam-A.hmm $(basename $faFile).transdecoder.pep > $outPath/pfam.log" 

else 

   echo -e "\nWaiting Trinotate_fa.sh results!\n"
   exit 1

fi

# RNAmmer
#echo "RNAmmerTranscriptome" #RnammerTranscriptome.pl --transcriptome $inPath/$faFile --path_to_rnammer ~/bin/rnammer


# Command to eval
cmd0="$cmdBp && $cmdH"

# LogFile
logFile="Trinotate_pep.log"

# Choose mode to run
if [[ $mode == "local" ]]; then
   
   echo "Local mode"
   cmd="$cmd0" # 2> $logFile"
 
elif [[ $mode == "cluster" ]]; then
 
   echo "Cluster mode"
   cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -N $N -n $n -o $logFile && touch $logFile"

fi

# Eval
echo "Running: $cmd" 
eval "date && $cmd"







