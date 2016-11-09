## H2O R Demo - MNIST

# Load H2O's R package
library(h2o)


# Start and connect to a local H2O cluster
h2o.init(nthreads = -1)


# Import CSV files
d_train <- h2o.importFile("MNIST_Kaggle_train.csv")
d_test <- h2o.importFile("MNIST_Kaggle_test.csv")


# Convert "label" column to categorial values
d_train$label <- as.factor(d_train$label)


# Split training data into train/valid
d_split <- h2o.splitFrame(d_train, ratios = 0.8, seed = 1234)


# Define features and target
features <- setdiff(colnames(d_train), "label")
target <- "label"


# Train a deep learning model with 80% data
model <- h2o.deeplearning(x = features, 
                          y = target,
                          training_frame = d_split[[1]], # 80% split
                          standardize = TRUE,
                          activation = "RectifierWithDropout",
                          hidden = c(50, 50),
                          epochs = 10)
print(model)


# Evaluate performance with 20% data
h2o.performance(model, d_split[[2]])


# Make predictions using model
yhat_test <- h2o.predict(model, d_test)
print(head(yhat_test))

