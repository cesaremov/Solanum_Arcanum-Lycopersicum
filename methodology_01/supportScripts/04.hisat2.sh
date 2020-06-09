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
inPath="Raw_rename"
outPath="04.hisat2"

mkdir -p $outPath

# Patts
patt=".fastq.gz"

# Genome index
idx="Genome/Slycopersicum"

# Cluster params
nodes=1
ppn=10
mem="20G"

# Fastq files
fqBases=`find $inPath -name "*$patt" | sed -E "s/\_[12]$patt//"`

for fqBase in $fqBases ; do

   echo $fqBase

   # Set logFile name
   logBase=`basename $fqBase` 
   logFile="$outPath/$logBase.log"
   
   # Check if logfile exists
   if [[ -f $logFile ]]; then
      echo "$logFile already exists, skip processing!"
      continue
   fi  

   # Hisat2
   cmdHisat2="hisat2 --threads $ppn --non-deterministic -x $idx -1 $fqBase\_1$patt -2 $fqBase\_2$patt | \
   samtools view -Sb - > $outPath/$base.bam"

   # Sort
   cmdSort="samtools sort --threads $ppn $outPath/$base.bam -o $outPath/$base.bam"

   # Index
   cmdIndex="samtools index -b $outPath/$base.bam"



   echo "running: $cmdHisat2"
   eval $cmdHisat2 2> $outPath/$base.log

      # Sorting
      echo "Sorting"
      cmdSort="samtools sort --threads $ppn $outPath/$base.bam -o $outPath/$base.bam"
      echo "running: $cmdSort"
      eval $cmdSort

      # Indexing bam   
      echo "Indexing"
      cmdIndex="samtools index -b $outPath/$base.bam"
      echo "running: $cmdIndex"
      eval $cmdIndex

   else
      continue
   fi
done


