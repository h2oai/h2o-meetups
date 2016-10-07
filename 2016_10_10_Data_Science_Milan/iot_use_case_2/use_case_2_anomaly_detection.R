# ------------------------------------------------------------------------------
# Using Deep Learning for Anomaly Detection
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a local CSV file
mtcar <- read.csv("./data/auto_design.csv")
mtcar$gear <- as.factor(mtcar$gear)
mtcar$carb <- as.factor(mtcar$carb)
mtcar$cyl <- as.factor(mtcar$cyl)
mtcar$vs  <- as.factor(mtcar$vs)
mtcar$am  <- as.factor(mtcar$am)
mtcar$ID  <- 1:nrow(mtcar)

# Print it out
print(mtcar)

# Convert R data frame into H2O data frame
h2o_mtcar  <- as.h2o(mtcar)


# ------------------------------------------------------------------------------
# Training an unsupervised deep neural network with autoencoder
# ------------------------------------------------------------------------------

# Use a bigger DNN
model <- h2o.deeplearning(x = 1:10,
                          training_frame = h2o_mtcar,
                          autoencoder = TRUE,
                          activation = "RectifierWithDropout",
                          hidden = c(50, 50, 50),
                          epochs = 100)

# Calculate reconstruction errors (MSE)
errors <- h2o.anomaly(model, h2o_mtcar, per_feature = FALSE)
print(errors)
errors <- as.data.frame(errors)

# Plot
plot(sort(errors$Reconstruction.MSE), main = "Reconstruction Error")

# Outliers (define 0.09 as the cut-off point)
row_outliers <- which(errors > 0.09) # based on plot above
mtcar[row_outliers,]


