## Deep Water Demo


# Using nightly build
library(h2o)


# Connect to H2O Deep Water Edition
h2o.init(strict_version_check = FALSE)


# Convert Iris dataset into H2O data frame
train <- as.h2o(iris)
print(head(train))

# Define features and target
features <- setdiff(colnames(train), "Species")
target <- "Species"


# Define parameters search range
hidden_opts <- list(c(20, 20), c(50, 50, 50), c(200,200), c(50,50,50,50,50))
activation_opts <- c("tanh", "rectifier")
learnrate_opts <- seq(1e-3, 1e-2, 1e-3)

hyper_params <- list(activation = activation_opts,
                     hidden = hidden_opts, 
                     learning_rate = learnrate_opts)


# Define search criteria
seed <- 1234
nfolds <- 5         ## k-fold Cross Validation
max_runtime_secs <- 30  ## limit overall time
max_models <- 1000      ## limit no. of models

search_criteria = list(strategy = "RandomDiscrete",
                       max_models = max_models, 
                       seed = seed, 
                       max_runtime_secs = max_runtime_secs,
                       stopping_rounds = 5,          
                       stopping_metric = "logloss",
                       stopping_tolerance = 1e-4)


# H2O Grid Search API
dw_grid <- h2o.grid(algorithm = "deepwater",
                    grid_id = "deepwater_grid",
                    x = features, 
                    y = target, 
                    training_frame = train,
                    epochs = 500,  ## long enough to allow early stopping 
                    nfolds = nfolds,
                    hyper_params = hyper_params,  
                    search_criteria = search_criteria)


# Print grid
dw_grid


# Get the best model based on logloss
best_model_id <- dw_grid@model_ids[[1]]
best_model <- h2o.getModel(best_model_id)

