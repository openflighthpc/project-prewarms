flight start
flight set always on

flight env create conda@jupyter
flight env activate conda@jupyter

conda install -y jupyter matplotlib 
conda install -y folium -c conda-forge

mkdir interactive-jupyter-demo
cd interactive-jupyter-demo

curl -L https://jupyterbook.org/en/stable/_downloads/12e9fb0f1c062494259ce630607cfc87/notebooks.ipynb > notebooks.ipynb

