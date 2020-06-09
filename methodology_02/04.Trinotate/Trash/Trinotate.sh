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
inPath="../01.Trinity/" 
outPath=$(basename $0 .sh)
dbPath="~/programi/Trinotate/current/admin"

# Generate paths
mkdir -p $outPath

# Patts
patt="fasta"

# Fasta file
faFile=$(find $inPath -name "Trinity.$patt")

# Tans map file
trans_map=$(find $inPath -name "Trinity*gene_trans_map")

# Cluster params
J="Trinotate"
N=1
n="32"

# Transdecoder
if [[ ! -e $(basename $faFile).transdecoder.pep ]]; then 

   echo "TransDecoder.LongOrfs"

   # Transdecoder LongOrfs
   cmd="TransDecoder.LongOrfs -t $faFile" 
   echo "Running:$cmd" 
   eval "date && $cmd"
   
   # Transdecoder Predict
   echo "TransDecoder.Predict" 
   cmdTransDecoderPredict="TransDecoder.Predict --cpu $n -t $faFile" 
   echo "Running: $cmdTransDecoderPredict" 
   eval "date && $cmdTransDecoderPredict" 
 
else
   
   echo -e "Already done Transdecoder!\n"

fi

# Blastx
if [[ ! -e $outPath/blastx.outfmt6 ]]; then
 
   echo "Blastx transcripts" 
 
   cmdBlastx="blastx -query $faFile -db $dbPath/uniprot_sprot.pep -num_threads $n -max_target_seqs 1 -outfmt 6 > $outPath/blastx.outfmt6" 
   echo "Running: $cmdBlastx" 
   eval "date && $cmdBlastx" 

else

   echo -e "Already done Blastx\n"

fi

# Blastp
if [[ ! -e $outPath/blastp.outfmt6 ]]; then
 
   echo "Blast Transdecoder-predicted proteins" 
 
   cmdBlastp="blastp -query $(basename $faFile).transdecoder.pep -db $dbPath/uniprot_sprot.pep -num_threads $n -max_target_seqs 1 -outfmt 6 > $outPath/blastp.outfmt6" 
   echo "Running: $cmdBlastp" 
   eval "date && $cmdBlastp" 

else

   echo -e "Already done Blastp!\n"

fi

# Hmmer
if [[ ! -e $outPath/TrinotatePFAM.out ]]; then
 
   echo "hmmerscan" 
 
   cmdHmmer="hmmscan --cpu $n --domtblout $outPath/TrinotatePFAM.out $dbPath/Pfam-A.hmm $(basename $faFile).transdecoder.pep > $outPath/pfam.log" 
   echo "Running: $cmdHmmer" 
   eval "date && $cmdHmmer"

else 

   echo -e "Already done Hmmer!\n"

fi

      # RNAmmer
      #echo "RNAmmerTranscriptome" #RnammerTranscriptome.pl --transcriptome $inPath/$faFile --path_to_rnammer ~/bin/rnammer



# Load transcripts and coding regions intro Trinotate sqlite database
echo "Load info into Trinotate database"
cmd="Trinotate $dbPath/Trinotate.sqlite init \
--gene_trans_map $trans_map --transcript_fasta $faFile \
--transdecoder_pep $(basename $faFile).transdecoder.pep"
echo "Running: $cmd"
eval "date && $cmd"

# Load protein hits
echo "Load protein hits"
cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_swissprot_blastp $outPath/blastp.outfmt6"
echo "Running: $cmd"
eval "date && $cmd"

# Load transcript hits
echo "Load transcripts hits"
cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_swissprot_blastx $outPath/blastx.outfmt6"
echo "Running: $cmd"
eval "date && $cmd"

# Load Pfam domain entries
echo "Load Pfam domain entries"
cmd="Trinotate $dbPath/Trinotate.sqlite LOAD_pfam $outPath/TrinotatePFAM.out"
echo "Running: $cmd"
eval "date && $cmd"

# Output Annotation Report
echo "Output Annotation Report"
cmd="Trinotate $dbPath/Trinotate.sqlite report > $outPath/Trinotate_annotation_report.tab"
echo "Running: $cmd"
eval "date && $cmd"




