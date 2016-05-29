# Kaggle Shelter Animal Outcomes
# Data Prep

# ------------------------------------------------------------------------------
# Libraries
# ------------------------------------------------------------------------------

suppressPackageStartupMessages(library(caret))

# ------------------------------------------------------------------------------
# Previous step(s)
# ------------------------------------------------------------------------------

source("step_01_data_prep.R")

# ------------------------------------------------------------------------------
# Split training data into training and validation (80:20)
# ------------------------------------------------------------------------------

## Create 6-fold (1:5 = training, 6 = validation)
set.seed(1234)
max_fold <- 6
fold <- createFolds(y = y_train$OutcomeType, k = max_fold)

## Add a new df to store fold info
d_fold <- data.frame(ID = x_ftr_train$ID, fold = 0, stringsAsFactors = FALSE)

for (n_fold in 1:max_fold)
  d_fold[as.integer(unlist(fold[n_fold])), ]$fold <- n_fold

## Merge with x_ftr_train, x_num_train and y_train
x_ftr_train <- merge(x_ftr_train, d_fold)
x_num_train <- merge(x_num_train, d_fold)
y_train <- merge(y_train, d_fold)
