#!/bin/bash
#BSUB -q mpi
#BSUB -J sem_Xu
#BSUB -n 264
#BSUB -o out.log
#BSUB -e err.log

echo "running example: `date`"
currentdir=`pwd`

# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

# cleans output files
mkdir -p OUTPUT_FILES
rm -rf OUTPUT_FILES/*

semhome=$HOME/software/specfem3d

# links executables
mkdir -p bin
cd bin/
rm -f *
ln -s $semhome/bin/xmeshfem3D
ln -s $semhome/bin/xgenerate_databases
ln -s $semhome/bin/xspecfem3D
ln -s $semhome/bin/xcombine_vol_data_vtk
cd ../

# stores setup
cp DATA/Par_file OUTPUT_FILES/
cp DATA/CMTSOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/

# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

# runs in-house mesher
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running mesher..."
  echo
  ./bin/xmeshfem3D
else
  # This is a MPI simulation
  echo
  echo "  running mesher on $NPROC processors..."
  echo
  mpirun -np $NPROC ./bin/xmeshfem3D
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs database generation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running database generation..."
  echo
  ./bin/xgenerate_databases
else
  # This is a MPI simulation
  echo
  echo "  running database generation on $NPROC processors..."
  echo
  mpirun -np $NPROC ./bin/xgenerate_databases
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs simulation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running solver..."
  echo
  ./bin/xspecfem3D
else
  # This is a MPI simulation
  echo
  echo "  running solver on $NPROC processors..."
  echo
  mpirun -np $NPROC ./bin/xspecfem3D
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi


# vtk-files of movie snapshots
#./create_one_snapshot.sh 500

#./create_one_snapshot.sh 1000
#./create_one_snapshot.sh 1500
#./create_one_snapshot.sh 2000

if [[ $? -ne 0 ]]; then exit 1; fi

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
python ../semcmd/plot_seis.py ./
echo `date`

