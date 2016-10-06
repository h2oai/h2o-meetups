library('RTextTools')
library('caret')

set.seed(101) 

# Load Data From CSV
Sample_data <- read.csv("/Users/Surekha/Downloads/tweets.csv")

#Shuffle data, current dataset has Hillary Tweets followed by Trump tweets
Sample_data <- Sample_data[sample(nrow(Sample_data)),]

# Create Document Term Matrix
text_matrix <- create_matrix(Sample_data$text, language="english", removeNumbers=TRUE,
                             stemWords=TRUE, removeSparseTerms=.998)

# Create container with training and test data in 80/20 ratio
container <- create_container(text_matrix, Sample_data$handle, trainSize=1:5000,
                              testSize=5001:6444, virgin=FALSE)

# Train model using Maximum Entropy Model
model <- train_model(container, "MAXENT")

# Predict the results for test data
result <- classify_model(container, model)

# Confusion Matrix and Statistics
confusionMatrix(as.matrix(result$MAXENTROPY_LABEL), Sample_data$handle[5001:6444])

# Output Values:

#                 Reference
#Prediction        HillaryClinton realDonaldTrump
#HillaryClinton             588             109
#realDonaldTrump            102             645

#                 Accuracy : 0.8539          
#                   95% CI : (0.8346, 0.8717)