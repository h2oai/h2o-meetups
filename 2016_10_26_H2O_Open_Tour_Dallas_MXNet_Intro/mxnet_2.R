require(mxnet)
require(vtreat)
require(ranger)
require(caret)

mx.metric.mlogloss <- mx.metric.custom("mlogloss", function(label, pred){
  require(Metrics)
  return(logLoss(label, pred))
})
auc <- function (actual, predicted) 
{
  r <- rank(predicted)
  n_pos <- as.numeric(sum(actual == 1))
  n_neg <- as.numeric(length(actual) - n_pos)
  auc <- (sum(r[actual == 1]) - n_pos * (n_pos + 1)/2)/(n_pos * 
                                                          n_neg)
  auc
}

setwd("~/CC_default")
dataset <- read.csv("default of credit card clients.csv")
#convert to categical
dataset$SEX <- as.factor(dataset$SEX)
dataset$EDUCATION <- as.factor(dataset$EDUCATION)
dataset$MARRIAGE <- as.factor(dataset$MARRIAGE)
#rename target variable
names(dataset)[names(dataset) == 'default.payment.next.month'] <- 'target'
#remove ID from data
dataset[,"ID"] <-NULL

set.seed(3456)
testIndex <- createDataPartition(as.factor(dataset$target), times = 1, p = 0.2, list = F)
dTrain <- dataset[-testIndex,]
dTest <- dataset[testIndex,]

yName <- 'target' # define target variable
yTarget <- 1 # define level to be considered "success"
varNames <- setdiff(names(dTrain),yName) # get variable names for vtreat

set.seed(8765)
treatmentsC <- designTreatmentsC(dTrain,varNames,yName,yTarget, verbose=FALSE)
dTrainTreated <- prepare(treatmentsC,dTrain,pruneSig=c(),scale=TRUE)
dTestTreated <- prepare(treatmentsC,dTest,pruneSig=c(),scale=TRUE)

varNames <- setdiff(names(dTestTreated),yName)

data <- mx.symbol.Variable('data')
fc1  <- mx.symbol.FullyConnected(data = data, name = 'fc1', num_hidden = 128)
act1 <- mx.symbol.Activation(data = fc1, name = 'relu1', act_type = "relu")

fc2  <- mx.symbol.FullyConnected(data = act1, name = 'fc2', num_hidden = 128)
act2 <- mx.symbol.Activation(data = fc2, name = 'relu2', act_type = "relu")

fc3 <- mx.symbol.FullyConnected(data = act2, name = 'fc3', num_hidden = 128)
act3 <- mx.symbol.Activation(data = fc3, name = 'relu3', act_type = "relu")

fc4  <- mx.symbol.FullyConnected(data = act3, name = 'fc4', num_hidden = 128)
act4 <- mx.symbol.Activation(data = fc4, name = 'relu4', act_type = "relu")

fc5  <- mx.symbol.FullyConnected(data = act4, name = 'fc5', num_hidden = 1)
mlp  <- mx.symbol.LogisticRegressionOutput(data = fc5, name = 'logistic')


mx.set.seed(1234)
model <- mx.model.FeedForward.create(
  X                 = data.matrix(dTrainTreated[,varNames]),
  y                 = dTrainTreated[,"target"],
  optimizer         = "adam",
  ctx               = mx.gpu(1),
  symbol            = mlp,
  eval.metric       = mx.metric.mlogloss,
  num.round         = 20,
  learning.rate     = 0.01,
  array.batch.size  = 256
)
graph.viz(model$symbol$as.json())

preds = t(predict(model, data.matrix(dTestTreated[,varNames]), 
                  array.layout = "rowmajor"))
auc_nn <- auc(dTestTreated[,"target"], preds[,1])
logloss_nn <-logLoss(dTestTreated[,"target"], preds[,1])

set.seed(42)
rf <- ranger(as.factor(target) ~., data = dTrain, probability = T)
rf_preds <- predict(rf, dTest)$predictions
auc_rf <- auc(dTestTreated[,"target"], rf_preds[,2])
logloss_rf <- logLoss(dTestTreated[,"target"], rf_preds[,2])

print(paste("Logloss. MXNet ver 1.0:", logloss_nn, "Baseline (randomForest):", logloss_rf))
print(paste("AUC. MXNet ver 1.0:", auc_nn, "Baseline (randomForest):", auc_rf))
