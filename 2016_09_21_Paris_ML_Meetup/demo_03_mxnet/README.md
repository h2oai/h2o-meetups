# H2O + mxnet Demo for Paris ML meetup

<br><hr>

## Introduction

Original reference: `https://github.com/h2oai/h2o-3/tree/deepwater/h2o-py/tests/testdir_algos/deepwater`

<br><hr>

## Prerequisite

- Install Ubuntu 16.04 LTS
- Install the latest NVIDIA Display driver
- Install CUDA 8 (latest available) 
- Install CUDNN 5

<br><hr>

## Files from H2O

- Obtain GPU-enabled h2o.jar (preview: https://slack-files.com/T0329MHH6-F2C9B5KGF-6472650a90) - not strictly necessary, as h2o.jar is also in the python module below, but done here for simplicity (manual launch below)
- Obtain Deep Water edition of H2O's python module (preview: https://slack-files.com/T0329MHH6-F2C9LUFHN-2ebff8798e), install with sudo pip install h2o*.whl
- Optional (only for custom networks) - Obtain mxnet python egg (preview: https://slack-files.com/T0329MHH6-F2C7LQWMR-6b78dfab1a), install with sudo easy_install <egg-file>
- Set environment variables: `export CUDA_PATH=/usr/local/cuda` and `export LD_LIBRARY_PATH=$CUDA_PATH/lib64:$LD_LIBRARY_PATH`
- Download dataset (`https://h2o-public-test-data.s3.amazonaws.com/bigdata/laptop/deepwater/imagenet/cat_dog_mouse.tgz`, unpack contents into directory `./bigdata/laptop/deepwater/imagenet/`, relative to where h2o was launched)

<br><hr>

## Step-by-step

- In terminal: Run `java -jar h2o.jar` (the Deep Water edition)
- Make sure the dataset is in the same folder
- (Optional) In another terminal: Run `nvidia-smi -l 1` (this will monitor GPU usage)
- In another terminal: Run `python` and then enter the following commands
    - `from __future__ import print_function`
    - `import sys, os`
    - `sys.path.insert(1, os.path.join("..","..",".."))`
    - `import h2o`
    - `from h2o.estimators.deepwater import H2ODeepWaterEstimator`
    - `h2o.init()`
    - `frame = h2o.import_file("bigdata/laptop/deepwater/imagenet/cat_dog_mouse.csv")`
    - `model = H2ODeepWaterEstimator(epochs=100, rate=1e-3, network='lenet', score_interval=0, train_samples_per_iteration=1000)`
    - `model.train(x=[0],y=1, training_frame=frame)`
    - `model.show()`
- Now try to view the dataset/model in Flow (i.e. `localhost:54321`)

<br>






