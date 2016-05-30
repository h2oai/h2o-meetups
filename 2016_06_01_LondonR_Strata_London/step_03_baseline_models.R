# Kaggle Shelter Animal Outcomes
# Data Prep

# ------------------------------------------------------------------------------
# Libraries
# ------------------------------------------------------------------------------

suppressPackageStartupMessages(library(randomForest))
suppressPackageStartupMessages(library(xgboost))
suppressPackageStartupMessages(library(foreach))
suppressPackageStartupMessages(library(doParallel))

# ------------------------------------------------------------------------------
# Previous step(s)
# ------------------------------------------------------------------------------

source("step_01_data_prep.R")
source("step_02_data_split.R")

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
# Train and evaluate baseline Random Forest and xgboost models
# ------------------------------------------------------------------------------

# Define features and no. of rounds
fea_ftr <- colnames(x_ftr_test)[-1]
fea_num <- colnames(x_num_test)[-1]

# Other parameters
max_round <- 50      # run the evaluation exercises for multiple times
n_tree_rf <- 100     # simple test only - can be fine-tuned for better performance
n_round_xgb <- 100   # simple test only - can be fine-tuned for better performance

# Add OutcomeTypeNum for xgboost
y_train$OutcomeTypeNum <- as.numeric(y_train$OutcomeType) - 1

# Custom function for training and evaluating random forest and xgboost
eval_rf_xgb <- function(n_tree_rf, n_round_xgb, n_seed) {

  # Set seed
  set.seed(n_seed)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Train RF model
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Train RF model_rf
  model_rf <- randomForest(x = x_ftr_train[which(x_ftr_train$fold != 5), fea_ftr],
                           y = y_train[which(y_train$fold != 5), ]$OutcomeType,
                           ntree = n_tree_rf)

  # Predict (validation set)
  yhat_valid_rf <- predict(model_rf, x_ftr_train[which(x_ftr_train$fold == 5), fea_ftr], type = "prob")

  # Evaluate performance on validation set and store results
  tmp_mll <- mlogloss(y_train[which(y_train$fold == 5), 3:7], yhat_valid_rf)

  # Output
  output <- data.frame(seed = n_seed, mlogloss_rf = tmp_mll)

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # xgboost
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Create DMatrix for xgboost
  xgb_train <- xgb.DMatrix(data = data.matrix(x_num_train[which(x_num_train$fold != 5), fea_num]),
                           label = y_train[which(y_train$fold != 5), ]$OutcomeTypeNum, missing = NA)

  xgb_valid <- xgb.DMatrix(data = data.matrix(x_num_train[which(x_num_train$fold == 5), fea_num]),
                           label = y_train[which(y_train$fold == 5), ]$OutcomeTypeNum, missing = NA)

  # Set up param
  param <- list(  objective           = "multi:softprob",
                  booster             = "gbtree",
                  eval_metric         = "mlogloss",
                  eta                 = 0.05,
                  max_depth           = 8,
                  subsample           = 0.5,
                  colsample_bytree    = 0.5,
                  num_class           = 5,
                  nthread             = 1 # use single thread within the function
  )

  # Train xgboost model
  model_xgb <- xgb.train(params = param,
                         data = xgb_train,
                         nrounds = n_round_xgb,
                         verbose = 0)

  # Evaluate performance on validation set and store results
  yy_valid_xgb <- data.frame(matrix(predict(model_xgb, xgb_valid), ncol = 5, byrow = T))
  colnames(yy_valid_xgb) <- colnames(y_train)[c(3:7)]
  output$mlogloss_xgb <- mlogloss(y_train[which(y_train$fold == 5), 3:7], yy_valid_xgb)


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Simple Averaging
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Add both model outputs
  yy_valid_avg <- yhat_valid_rf + yy_valid_xgb

  # Normalise per row
  norm_yy <- function(x) return(x/sum(x))
  yy_valid_avg_norm <- t(apply(yy_valid_avg, 1, norm_yy))

  # Evaluate performance on validation set and store results
  output$mlogloss_avg <- mlogloss(y_train[which(y_train$fold == 5), 3:7], yy_valid_avg_norm)


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return output
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return(output)

}

# Register parallel backend
cl <- makePSOCKcluster(detectCores())
registerDoParallel(cl)

# Train and evaluate baseline Random Forest (50 trees) in parallel mode
d_eval <- foreach(n_seed = 1:max_round, .combine = rbind,
                  .multicombine = TRUE, .inorder = FALSE,
                  .packages = c("randomForest", "MLmetrics", "xgboost")) %dopar%
  eval_rf_xgb(n_tree_rf, n_round_xgb, n_seed)

# Stop backend
stopCluster(cl)

# Save results
save(d_eval, file = "step_03_results.rda")

# Print
print(d_eval)

