# Initialise H2O Cluster
library(h2o)
h2o.init(nthreads = -1)

# Use Satellite data from "mlbench"
library(mlbench)
library(data.table)
data("Satellite")

hex_sat <- as.h2o(Satellite)

# Build a GLRM and compress data into a 10-column matrix
glrm_sat <- h2o.glrm(training_frame = hex_sat[, -37], # exclude response
                     k = 6, seed = 1234,
                     transform = "STANDARDIZE",
                     regularization_x = "Quadratic",
                     regularization_y = "L1",
                     max_iterations = 100)

# Check convergence
plot(glrm_sat)

# Extract X
X <- as.data.frame(h2o.getFrame(glrm_sat@model$representation_name))

# Prepare dataset for machine learning
d_sat_glrm <- cbind(X, as.data.frame(hex_sat[, "classes"]))
hex_sat_glrm <- as.h2o(d_sat_glrm)

# Define features
features_full <- colnames(hex_sat)[-ncol(hex_sat)]
features_glrm <- colnames(hex_sat_glrm)[-ncol(hex_sat_glrm)]


# Train DRF with Full Dataset
time_start <- proc.time()
model_drf_full <- h2o.randomForest(training_frame = hex_sat,
                                   x = features_full,
                                   y = "classes",
                                   ntrees = 500,
                                   nfolds = 10)
time_end_full <- timetaken(time_start)
model_drf_full

# Train DRF with Compressed Dataset
time_start <- proc.time()
model_drf_glrm <- h2o.randomForest(training_frame = hex_sat_glrm,
                                   x = features_glrm,
                                   y = "classes",
                                   ntrees = 500,
                                   nfolds = 10)
time_end_glrm <- timetaken(time_start)
model_drf_glrm
