# Initialise H2O Cluster
library(h2o)
h2o.init(nthreads = -1)

# Use Satellite data from "mlbench"
library(mlbench)
data("Satellite")
hex_sat <- as.h2o(Satellite)

# Build a GLRM and compress data into a 10-column matrix
glrm_sat <- h2o.glrm(training_frame = hex_sat[, -37], # exclude response
                     k = 2, seed = 1234,
                     transform = "STANDARDIZE",
                     regularization_x = "Quadratic",
                     regularization_y = "L1",
                     max_iterations = 100)

# Extract X from GLRM
X <- as.data.frame(h2o.getFrame(glrm_sat@model$representation_name))

# Create data frame for data visualisation
d_sat <- data.frame(X, as.data.frame(hex_sat[, 37]))
colnames(d_sat) <- c("Arch1", "Arch2", "Label")
d_sat$Label <- as.factor(d_sat$Label)

# Visualise
library(ggplot2)
library(ggthemes)
ggplot(d_sat, aes(Arch1, Arch2, colour = Label)) +
  geom_point() + theme_hc() + scale_colour_hc()
  ggtitle("Clusters in Satellite Dataset")
