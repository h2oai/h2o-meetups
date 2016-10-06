library('RTextTools')
library('caret')

set.seed(101) 

# Load Data From CSV
tweets <- read.csv("/Users/Surekha/Downloads/tweets.csv", stringsAsFactors = F)
# Inspect data
table(tweets$handle)
#Shuffle data, current dataset has Hillary Tweets followed by Trump tweets
tweets <- tweets[sample(nrow(tweets)),]

# Prepare data
input_data <- cbind(tweets$text, tweets$retweet_count, tweets$favorite_count)

# Create Document-Term Matrix
text_matrix <- create_matrix(input_data, language="english", removeNumbers=TRUE,
                             stemWords=TRUE, removeSparseTerms=.998)

# Create container with training and test data in 80/20 ratio
container <- create_container(text_matrix, tweets$handle, trainSize=1:5000,
                              testSize=5001:6444, virgin=FALSE)

# Train model using different models

#SVM <- train_model(container,"SVM")
#GLMNET <- train_model(container,"GLMNET")
#SLDA <- train_model(container,"SLDA")
#BOOSTING <- train_model(container,"BOOSTING")
#BAGGING <- train_model(container,"BAGGING")
#NNET <- train_model(container,"NNET")

MAXENT_model <- train_model(container,"MAXENT")
RF_model <- train_model(container,"RF")
TREE_model <- train_model(container,"TREE")

# Predict the results for test data
MAXENT_result <- classify_model(container, MAXENT_model)
RF_result <- classify_model(container, RF_model)
TREE_result <- classify_model(container, TREE_model)

# Confusion Matrix and Statistics
confusionMatrix(as.matrix(MAXENT_result[1]), tweets$handle[5001:6444])
confusionMatrix(as.matrix(RF_result[1]), tweets$handle[5001:6444])
confusionMatrix(as.matrix(TREE_result[1]), tweets$handle[5001:6444])

# MAXENT Output Values:

#                  Reference
#Prediction        HillaryClinton realDonaldTrump
#HillaryClinton             588             109
#realDonaldTrump            102             645

#                 Accuracy : 0.8539          
#                   95% CI : (0.8346, 0.8717)