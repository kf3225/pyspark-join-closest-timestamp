#!/bin/bash
source ~/.profile
jupyter lab --port 8888 --ip=0.0.0.0 --allow-root --NotebookApp.notebook_dir=$JUPYTERLAB_NOTEBOOK_DIR
