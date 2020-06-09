J="cd-hit"
N=1
n=32
qos="ipicyt"

base="Trinity_all"

cmd0="cd-hit-est -o ${base}_cd-hit -c 0.8 -i ${base}.fasta -T $n -M 1000"

logFile="${base}_cd-hit.log"

#eval "date && cmd "
cmd="echo -e '#!/bin/bash \n $cmd0' | sbatch -J $J -N $N -n $n --qos=$qos -o $logFile && touch $logFile"

echo "Running: $cmd"
eval "date && $cmd"
