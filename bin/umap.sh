#!/bin/bash

bamfile=$1
remap=$2

ulimit -H -c unlimited
ulimit -H unlimited
ulimit -c unlimited

java -XX:ParallelGCThreads=16  -Xmx100G -Djava.io.tmpdir=`pwd`/tmp -jar ~/modules/BWAMem/picard.jar RevertSam \
     MAX_RECORDS_IN_RAM=50000000 \
     I=${bamfile} \
     O=${remap}.bam \
     SANITIZE=true \
     MAX_DISCARD_FRACTION=0.005 \
     ATTRIBUTE_TO_CLEAR=XT \
     ATTRIBUTE_TO_CLEAR=XN \
     ATTRIBUTE_TO_CLEAR=AS \
     ATTRIBUTE_TO_CLEAR=OC \
     ATTRIBUTE_TO_CLEAR=OP \
     SORT_ORDER=queryname \
     RESTORE_ORIGINAL_QUALITIES=true \
     REMOVE_DUPLICATE_INFORMATION=true \
     REMOVE_ALIGNMENT_INFORMATION=true #default
