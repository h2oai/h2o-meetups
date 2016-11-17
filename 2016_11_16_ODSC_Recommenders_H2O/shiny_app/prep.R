library('data.table')
library('tsne')
library('plotly')
library('plyr')
library('shiny')

# Set Working Directory to shiny_app folder
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load Data for input selectors
data <- fread("Data/FormattedData.csv", stringsAsFactors = F, header = T)
data$userId <- as.factor(data$userId)
data$movieId <- as.factor(data$movieId)

movie_data <- unique(data[, c("movieId", "title", "genres"), with = FALSE])

# Load Predictions
predictions <- fread("Data/Predictions.csv", stringsAsFactors = F, header = T)

# Load Test Predictions
test <- fread("Data/TestPredictions.csv", stringsAsFactors = F, header = T)

# Load Movie Latent Factors
tsne_factors <- fread("Data/MovieLatentFactors.csv", stringsAsFactors = F, header = T)
tsne_factors$color <- "other"

runApp()