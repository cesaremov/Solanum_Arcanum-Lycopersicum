#!/bin/bash

# Paths
lustrePath="/LUSTRE/usuario/"
fullPwd=${PWD/\/home/$lustrePath/}
genomePath="Genome"

# Genome file
genomeFile="$genomePath/S_lycopersicum_chromosomes.3.00.fa"

# Logfile
logFile="$fullPwd/$genomePath/hisat2-build.log"
#echo $logFile

# Base name
base="$genomePath/Slycopersicum"

# Cluster parameters
nodes=1
ppn=1
mem="20G"
name="hisat2-build"
walltime="24:00:00"

#
echo "cd \$PBS_O_WORKDIR; module load hisat2; hisat2-build -p $ppn $genomeFile $base && hisat2-inspect -s $base" | qsub -V -N $name -l nodes=$nodes:ppn=$ppn,mem=$mem,vmem=$mem,walltime=$walltime -o $logFile -j oe && touch $logFile

