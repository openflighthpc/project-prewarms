flight start
flight set always on

flight env create spack
flight env activate spack
spack install bowtie

mkdir life-sciences-ecoli-demo
cd life-sciences-ecoli-demo

wget -O ecoli.fa https://raw.githubusercontent.com/BenLangmead/bowtie/master/reads/e_coli_1000.fa
cat << EOF > ecoli.sh
#!/bin/bash -l
#SBATCH -N 1
flight env activate spack
spack load bowtie
bowtie-build ecoli.fa e_coli
EOF
