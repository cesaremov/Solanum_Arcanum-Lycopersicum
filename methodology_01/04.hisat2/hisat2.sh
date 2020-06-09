#/bin/bash

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
inPath="../Raw_rename"
outPath="$(basename $0 .sh)"
#unalnPath= "${outPath}_unaln"

# Make paths
mkdir -p $outPath
#mkdir -p $unalnPath

# Patts
patt=".fastq.gz"

# Genome index
idx="../Genome/genome"

# Cluster params
J="hisat2"
N=1
n=32
qos="ipicyt"
#t=2:00:00

# Fastq files
fqBases=`find $inPath/ -name "*$patt" | sed -E "s/\_[12]$patt//" | sort | uniq`
echo $fqBases
for fqBase in $fqBases ; do

   echo $fqBase

   # Set logFile name
   base=`basename $fqBase` 
   logFile="$outPath/$base.log"
  
   # Check if logfile exists
   if [[ -f $logFile ]]; then
      echo "$logFile already exists, skip processing!"
      continue
   fi  

   # Hisat2
   outBase="$outPath/$base"
   cmdHisat2="mkdir $outBase\_un; hisat2 --threads $n --non-deterministic -x $idx -1 $fqBase\_1$patt -2 $fqBase\_2$patt --un-gz $outBase\_un --un-conc-gz $outBase\_un --summary-file $logFile.tab --new-summary | \
   samtools view -Sb - > $outPath/$base.bam"

   # Sort
   cmdSort="samtools sort --threads $n $outPath/$base.bam -o $outPath/$base.bam"

   # Index
   cmdIndex="samtools index -b $outPath/$base.bam"

   # Base command Hisat2, sort and index
   cmd0="$cmdHisat2 && $cmdSort && $cmdIndex"
 
   if [[ $mode == "local" ]]; then
      echo "Local mode"
      
      cmd=$cmd0
 
   elif [[ $mode == "cluster" ]]; then
      
      echo "Cluster mode"

      cmd="echo -e '#!/bin/bash \n $cmd0' |sbatch -J $J -N $N -n $n --qos=$qos -o $logFile && touch $logFile"

   fi
   
   # Run
   echo "Running: $cmd"
   eval "date; $cmd"

done

