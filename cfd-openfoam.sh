flight start
flight set always on

flight env create gridware@cfd
flight env activate gridware@cfd

gridware install --yes apps/openfoam/4.1

mkdir cfd-cavity-demo
cd cfd-cavity-demo

cat << 'EOF' > cavity.sh
#!/bin/bash
#SBATCH -N 1

# Activate environment and load OpenFOAM module
flight env activate gridware
module load apps/openfoam

# Create job directory from example job
cp -r $FOAM_TUTORIALS/incompressible/icoFoam/cavity/cavity $HOME/.
cd $HOME/cavity

# Calculate fluid pressure with OpenFOAM tools
blockMesh
checkMesh
icoFoam
EOF


