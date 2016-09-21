# H2O + TensorFlow Demo for Paris ML meetup

<br><hr>

## Introduction

Original reference: `https://github.com/h2oai/sparkling-water/blob/master/py/examples/notebooks/TensorFlowDeepLearning.ipynb`

<br><hr>

## Prerequisite

- Install Sparkling Water 1.6.5+
- Install TensorFlow 0.8.0+ (CPU or GPU version)
- Install CUDA (for GPU version)

<br><hr>

## Files from H2O

- `https://github.com/h2oai/sparkling-water/blob/master/py/examples/notebooks/TensorFlowDeepLearning.ipynb`

<br><hr>

## Step-by-step

- Point SPARK_HOME to the existing installation of Spark and export variable MASTER.
    - `export SPARK_HOME="<your spark folder>"` (e.g. `export SPARK_HOME="/home/joe/demo_sw/spark-1.6.2-bin-hadoop2.6"`)
    - `echo $SPARK_HOME`

- To launch a local Spark cluster with 3 worker nodes with 2 cores and 1G memory per node.
    - `export MASTER="local-cluster[3,2,1024]"`

- To start a notebook with Sparkling Water / PySparkling
    - `IPYTHON_OPTS="notebook" <your sparkling water folder>` (e.g. `IPYTHON_OPTS="notebook" /home/joe/demo_sw/sparkling-water-1.6.6/bin/pysparkling`)

Then follow the steps as shown in the notebook.

<br>
