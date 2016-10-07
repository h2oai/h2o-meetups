# ------------------------------------------------------------------------------
# Step 6: Tuning Models via Early Stopping & Grid Search
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Loading and preparing data (same as previous steps)
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a local CSV file
secom <- h2o.importFile(path = "./data/secom.csv", destination_frame = "secom")

# Convert Classification to factor
secom$Classification <- as.factor(secom$Classification)

# Define Targets and Features
target <- "Classification"
features <- setdiff(colnames(secom), c("ID", "Classification"))

# Split
secom_splits <- h2o.splitFrame(data = secom, ratios = 0.6, seed = 1234)
secom_train <- secom_splits[[1]]  # 882 : 62 ... 7% of 1
secom_test  <- secom_splits[[2]]  # 581 : 42 ... 7% of 1


# ------------------------------------------------------------------------------
# Train H2O models with early stopping and grid search
# ------------------------------------------------------------------------------

# Define parameters for grid search
param_gbm <- list(
  max_depth = c(5, 6, 7),
  sample_rate = c(0.8, 0.9, 1)
)

# GBM with early stopping, cross validation and grid search
grid_gbm <- h2o.grid(

  # Core parameters for model training
  x = features,
  y = target,
  training_frame = secom_train,
  ntrees = 200,

  # Parameters for grid search
  grid_id = "my_gbm_grid",
  hyper_params = param_gbm,
  algorithm = "gbm",

  # Parameters for early stopping & cross validation
  nfolds = 5,
  stopping_metric = "logloss",
  score_tree_interval = 3,
  stopping_rounds = 20

)


# ------------------------------------------------------------------------------
# Extract the model and evaluate model performance on unseen data
# ------------------------------------------------------------------------------

# Sort models by metric "logloss"
grid_sort <- h2o.getGrid("my_gbm_grid", sort_by = "logloss", decreasing = FALSE)
print(grid_sort)

# Extract the best model
model_ids <- grid_sort@model_ids
best_gbm <- h2o.getModel(model_ids[[1]])

# Evaluate
h2o.performance(best_gbm, newdata = secom_test)




# ------------------------------------------------------------------------------
# Train H2O models with early stopping and RANDOM grid search
# ------------------------------------------------------------------------------

# Define parameters for grid search
param_gbm <- list(
  max_depth = c(4, 5, 6, 7, 8), sample_rate = c(0.6, 0.7, 0.8, 0.9, 1)
)

# Define criteria for random grid search
search_criteria <- list(
  strategy = "RandomDiscrete",
  max_models = 5,
  seed = 1234,
  max_runtime_secs = 600
)

# GBM with early stopping, cross validation and RANDOM grid search
ran_grid_gbm <- h2o.grid(

  # Core parameters for model training
  x = features, y = target,
  training_frame = secom_train,
  ntrees = 200,

  # Parameters for grid search
  grid_id = "random_gbm_grid",
  hyper_params = param_gbm,
  search_criteria = search_criteria, # <- added this for Random Grid Search
  algorithm = "gbm",

  # Parameters for early stopping & cross validation
  nfolds = 5,
  stopping_metric = "logloss",
  score_tree_interval = 3,
  stopping_rounds = 20

)

# Sort models by metric "logloss"
ran_grid_sort <- h2o.getGrid("random_gbm_grid",
                             sort_by = "logloss", decreasing = FALSE)
print(ran_grid_sort)
