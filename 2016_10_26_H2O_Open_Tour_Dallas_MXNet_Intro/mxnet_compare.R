require(mxnet)
require(vtreat)
require(ranger)
require(caret)
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
set.seed(3456)
folds <- createMultiFolds(as.factor(dataset$target), k = 5, times = 5)
cv_results <- data.frame()
runnum = 0
for(fold in folds) {
  runnum = runnum+1
  #splitting dataset into train and validation
  trainIndex <- fold
  dTrain <- dataset[trainIndex,]
  dTest <- dataset[-trainIndex,]
  
  yName <- 'target' # define target variable
  yTarget <- 1 # define level to be considered "success"
  varNames <- setdiff(names(dTrain),yName) # get variable names for vtreat
  
  treatmentsC <- designTreatmentsC(dTrain,varNames,yName,yTarget, verbose=FALSE)
  dTrainTreated <- prepare(treatmentsC,dTrain,pruneSig=c(),scale=TRUE)
  dTestTreated <- prepare(treatmentsC,dTest,pruneSig=c(),scale=TRUE)

  varNames <- setdiff(names(dTestTreated),yName)
  data_len = length(varNames)
  data <- mx.symbol.Variable('data')
  dr0 = mx.symbol.Dropout(data = data, p = 0.1)
  fc1  <- mx.symbol.FullyConnected(data = dr0, name = 'fc1', num_hidden = 128)
  bn1 <- mx.symbol.BatchNorm(data = fc1, name = 'bn1')
  act1 <- mx.symbol.Activation(data = bn1, name = 'relu1', act_type = "relu")
  
  fc4 <- mx.symbol.FullyConnected(data = act1, name = 'fc4', num_hidden = 128)
  resid <- act1 + fc4
  bn4 <- mx.symbol.BatchNorm(data = resid, name = 'bn4')
  act4 <- mx.symbol.Activation(data = bn4, name = 'relu4', act_type = "relu")
  
  dr1 = mx.symbol.Dropout(data = act4, p = 0.5)
  fc6  <- mx.symbol.FullyConnected(data = dr1, name = 'fc6', num_hidden = 1)
  mlp  <- mx.symbol.LogisticRegressionOutput(data = fc6, name = 'logistic')
  
  mx.set.seed(1234)
  model <- mx.model.FeedForward.create(
    X                 = data.matrix(dTrainTreated[,varNames]),
    y                 = dTrainTreated[,"target"],
    initializer = mx.init.uniform(0.01),
    array.layout = "rowmajor",
    #eval.data          = val,
    optimizer = "adam",
    ctx                = mx.gpu(1),
    symbol             = mlp,
    eval.metric        = mx.metric.mlogloss,
    num.round          = 20,
    learning.rate      = 0.01,
    #momentum           = 0.9,
    #wd                 = 0.0001,
    array.batch.size   = 256,
    verbose = F
  )
  #graph.viz(model$symbol$as.json())
  
  preds = predict(model, data.matrix(dTestTreated[,varNames]), array.layout = "rowmajor")
  preds <- t(preds)
  auc_nn <- auc(dTestTreated[,"target"], preds[,1])
  logloss_nn <-logLoss(dTestTreated[,"target"], preds[,1])
  
  mx.set.seed(1234)
  model_mlp <- mx.mlp(data.matrix(dTrainTreated[,varNames]), dTrainTreated[,"target"], 
                  hidden_node=c(128,128,128,128), activation = "relu", out_node=1, 
                  out_activation="logistic",optimizer = "adam",#dropout = 0.5,
                  num.round=20, array.batch.size=256, learning.rate=0.01,#, momentum=0.9, 
                  device = mx.gpu(1),
                  eval.metric=mx.metric.mlogloss,
                  verbose = F, array.layout = "rowmajor")
  preds_mlp = predict(model_mlp, data.matrix(dTestTreated[,varNames]), array.layout = "rowmajor")
  preds_mlp <- t(preds_mlp)
  auc_mlp <- auc(dTestTreated[,"target"], preds_mlp[,1])
  logloss_mlp <-logLoss(dTestTreated[,"target"], preds_mlp[,1])
  
  set.seed(42)
  rf <- ranger(as.factor(target) ~., data = dTrain, probability = T)
  rf_preds <- predict(rf, dTest)$predictions
  auc_rf <- auc(dTestTreated[,"target"], rf_preds[,2])
  logloss_rf <- logLoss(dTestTreated[,"target"], rf_preds[,2])
  cv_results <- rbind(
    cv_results, 
    data.frame(model = "MXnet ver 1", logloss = logloss_mlp, auc = auc_mlp, run = runnum),
    data.frame(model = "MXnet ver 2", logloss = logloss_nn, auc = auc_nn, run = runnum),
    data.frame(model = "RandomForest", logloss = logloss_rf, auc = auc_rf, run = runnum))
}
require(ggplot2)
require(reshape2)
tmp <- melt(cv_results)
p <- ggplot(tmp[tmp[,"variable"]!="run",], aes(x=model, y=value, colour=model)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4)
p + facet_grid("variable~.", scales = "free", space = "free")
require(Rmisc)
aggregate(cbind(logloss, auc) ~ model, cv_results, function(x) CI(x, ci = .999999))
# model logloss.upper logloss.mean logloss.lower auc.upper  auc.mean auc.lower
# 1  MXnet ver 1     0.4397506    0.4369629     0.4341753 0.7778258 0.7749916 0.7721574
# 2  MXnet ver 2     0.4345878    0.4324396     0.4302913 0.7801308 0.7772532 0.7743755
# 3 RandomForest     0.4357005    0.4340097     0.4323188 0.7754171 0.7729250 0.7704328
