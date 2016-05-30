# Kaggle Shelter Animal Outcomes
# Simple (full) Grid Search

# ------------------------------------------------------------------------------
# Previous step(s)
# ------------------------------------------------------------------------------

source("step_01_data_prep.R")
source("step_02_data_split.R")

# ------------------------------------------------------------------------------
# Libraries
# ------------------------------------------------------------------------------

suppressPackageStartupMessages(library(h2o))
suppressPackageStartupMessages(library(h2oEnsemble))

# ------------------------------------------------------------------------------
# Custom Functions
# ------------------------------------------------------------------------------

# Multi-class Log Loss
# https://www.kaggle.com/c/predict-closed-questions-on-stack-overflow/forums/t/2421/multiclass-logloss-in-r/72939
mlogloss <- function(actual, predicted, eps=1e-15) {
  predicted[predicted < eps] <- eps;
  predicted[predicted > 1 - eps] <- 1 - eps;
  -1/nrow(actual)*(sum(actual*log(predicted)))
}

# ------------------------------------------------------------------------------
# Prepare data for H2O
# ------------------------------------------------------------------------------

# Start a new cluster
h2o.init(nthreads = -1)

# Define features
fea_ftr <- colnames(x_ftr_test)[-1]

# Combine x and y
d_train <- merge(x_ftr_train[which(x_ftr_train$fold != 5),],
                 y_train[which(y_train$fold != 5),])
d_valid <- merge(x_ftr_train[which(x_ftr_train$fold == 5),],
                 y_train[which(y_train$fold == 5),])
d_test <- x_ftr_test

# Convert to H2O DF
hex_train <- as.h2o(d_train)
hex_valid <- as.h2o(d_valid)
hex_test  <- as.h2o(d_test)

# Define features
features <- colnames(d_test)[-1]

# ------------------------------------------------------------------------------
# Grid Search for h2o.gbm()
# ------------------------------------------------------------------------------

# Define a list of hyper-parameters
h_param_gbm <- list(max_depth = seq(5, 20, 1))

# Grid Search
grid <- h2o.grid(

  ## hyper parameters
  hyper_params = h_param_gbm,

  ## full Cartesian hyper-parameter search
  search_criteria = list(strategy = "Cartesian"),

  ## which algorithm to run
  algorithm = "gbm",

  ## identifier for the grid, to later retrieve it
  grid_id = "gbm_grid",

  ## standard model parameters
  x = features,
  y = "OutcomeType",
  training_frame = hex_train,
  validation_frame = hex_valid,

  ## more trees is better if the learning rate is small enough
  ## here, use "more than enough" trees - we have early stopping
  ntrees = 10000,

  ## smaller learning rate is better
  ## since we have learning_rate_annealing, we can afford to start with a bigger learning rate
  learn_rate = 0.1,

  ## learning rate annealing: learning_rate shrinks by 1% after every tree
  ## (use 1.00 to disable, but then lower the learning_rate)
  learn_rate_annealing = 0.99,

  ## sample 80% of rows per tree
  sample_rate = 0.8,

  ## sample 80% of columns per split
  col_sample_rate = 0.8,

  ## fix a random number generator seed for reproducibility
  seed = 1234,

  ## early stopping once the validation logloss doesn't improve by at least 0.01% for 5 consecutive scoring events
  stopping_rounds = 5,
  stopping_tolerance = 1e-4,
  stopping_metric = "logloss",

  ## score every 10 trees to make early stopping reproducible (it depends on the scoring interval)
  score_tree_interval = 5
)

# Print the grid search results
print(grid)

# Get the best GBM model
best_model <- h2o.getModel(grid@model_ids[[1]])

