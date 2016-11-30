# ------------------------------------------------------------------------------
# Build a simple classification model using iris dataset
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a R data frame
data(iris)
d_iris <- as.h2o(iris)

# Define Targets and Features
target <- "Species"
features <- setdiff(colnames(d_iris), c("Species"))

# ------------------------------------------------------------------------------
# Train a H2O Model
# ------------------------------------------------------------------------------

# Train three basic H2O models 
model_drf <- h2o.randomForest(x = features,
                              y = target,
                              model_id = "iris_random_forest",
                              training_frame = d_iris)

model_gbm <- h2o.gbm(x = features,
                     y = target,
                     model_id = "iris_gbm",
                     training_frame = d_iris)

model_dnn <- h2o.deeplearning(x = features,
                              y = target,
                              model_id = "iris_deep_learning",
                              training_frame = d_iris)




# ------------------------------------------------------------------------------
# Use Steam to deploy model (Optional)
# ------------------------------------------------------------------------------

# Live demo time
# See http://docs.h2o.ai/steam/latest-stable/index.html

# Basic Steps
# 1. In terminal, go to steam folder
# 2. [enter] java -jar var/master/assets/jetty-runner.jar var/master/assets/ROOT.war
# 3. In another terminal, go to the same steam folder
# 4. [enter] ./steam serve master --superuser-name=superuser --superuser-password=superuser
# 5. go to steam web interface (localhost:9000)
# 6. Create a project and continue to deploy a model

