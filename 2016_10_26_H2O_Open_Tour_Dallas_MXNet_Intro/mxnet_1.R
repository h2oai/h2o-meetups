require(mxnet)
require(vtreat)
require(ranger)
require(caret)

mx.metric.mlogloss <- mx.metric.custom("mlogloss", function(label, pred){
  require(Metrics)
  return(logLoss(label, pred))
})


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

varNames <- setdiff(names(dTestTreated),yName) #get variables name for mx.mlp
mx.set.seed(1234) # set random seed, MXNet has its own!!!

model <- mx.mlp(data.matrix(dTrainTreated[,varNames]), # data
                dTrainTreated[,"target"], # target variable
                hidden_node=c(128,128,128,128), # number of hidden nodes per layer
                activation = "relu", # activation function, 
                                     # can be a vector as well, 
                                     # like c("relu","tanh", "tanh")
                out_node=1, # output node, 1 in our case (binary classification)
                out_activation="logistic", # can be "rmse" for regression 
                                           # or "softmax" for multiclassification
                optimizer = "adam", # "sgd" by default, 
                                    # can be "rmsprop", "adagrad", "adadelta"
                num.round=20, # number of epochs
                array.batch.size=256, # batch size
                learning.rate=0.01, # learning rate
                device = mx.gpu(1), # uses mx.cpu() by default
                eval.metric=mx.metric.mlogloss, # LogLoss as evaluation metric
                verbose = T, array.layout = "rowmajor")

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
