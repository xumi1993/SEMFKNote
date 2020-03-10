#!/bin/bash

nstep=`grep ^NSTEP DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`
dstep=`grep ^NTSTEP_BETWEEN_FRAMES DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`
awk -v N="$nstep" -v D="$dstep" 'BEGIN { for (i = D; i <= N; i+=D) print "sh create_one_snapshot.sh "i }' | sh 