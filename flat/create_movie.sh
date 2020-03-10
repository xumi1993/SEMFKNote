#!/bin/bash
#
cmddir=../semcmd

# stepbegin=`grep ^NTSTEP_BETWEEN_FRAMES DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`
# stepend=`grep ^NSTEP DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`
sh create_vtk_group.sh
$cmddir/avs2xz.py
$cmddir/ps_movie.sh