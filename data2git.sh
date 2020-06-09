#!/bin/bash

meths="01 02 03"
for meth in $meths; do

   #meth0=$(echo "${meth}-1" | bc )

   echo "Cleanning"
   rm -rf methodology_${meth}/*

   echo "Syncronizing"
   rsync -av --max-size=10K --progress --delete-after ../${meth}.methodology_Lyc_Arc/* methodology_${meth}/
 
   echo "Final cleanning"
   rm -rf methdology_${meth}/[SsT]*

done

