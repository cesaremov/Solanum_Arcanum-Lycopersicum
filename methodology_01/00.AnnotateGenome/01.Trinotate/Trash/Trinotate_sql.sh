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
inPath="../07.GetSeqs/" 
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
J="Trinotate"
N=1
n="32"

# Transdecoder
if [[ ! -e $(basename $0 _sql.sh)_pep/TrinotatePFAM.out ]]; then 

   echo "Hmmer has not finished. Pease wait!"

else
   echo "Load info into Trinotate database"
   cmd="Trinotate $dbPath/Trinotate.sqlite init \
   --gene_trans_map $trans_map --transcript_fasta $faFile \
   --transdecoder_pep $(basename $faFile).transdecoder.pep"
   echo "Running: $cmd"
   eval "date && $cmd"

   # Load protein hits
   echo "Load protein hits"
   cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_swissprot_blastp $(basename $outPath _sql)_pep/blastp.outfmt6"
   echo "Running: $cmd"
   eval "date && $cmd"

   # Load transcript hits
   echo "Load transcripts hits"
   cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_swissprot_blastx $(basename $outPath _sql)_fa/blastx.outfmt6"
   echo "Running: $cmd"
   eval "date && $cmd"

   # Load Pfam domain entries
   echo "Load Pfam domain entries"
   cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_pfam $(basename $outPath _sql)_pep/TrinotatePFAM.out"
   echo "Running: $cmd"
   eval "date && $cmd"

   # Output Annotation Report
   echo "Output Annotation Report"
   cmd="Trinotate $dbPath/Trinotate.sqlite report > $outPath/Trinotate_annotation_report.tab"
   echo "Running: $cmd"
   eval "date && $cmd"

fi


