from __future__ import print_function
import sys, os
sys.path.insert(1, os.path.join("..","..",".."))
import h2o
from h2o.estimators.deepwater import H2ODeepWaterEstimator

# Start and connect to H2O local cluster
h2o.init()

# Import CSV
frame = h2o.import_file("bigdata/laptop/deepwater/imagenet/cat_dog_mouse.csv")
print(frame.head(5))

# Define LeNet model
model = H2ODeepWaterEstimator(epochs=300, rate=1e-3, network='lenet', score_interval=0, train_samples_per_iteration=1000)

# Train LeNet model on GPU
model.train(x=[0],y=1, training_frame=frame)
model.show()
