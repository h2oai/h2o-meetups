##################
## FUNCTIONS
#################
# Function from Owen's Amazon competition (https://github.com/owenzhang/Kaggle-AmazonChallenge2013/blob/master/__final_utils.R)
#2 way count
my.f2cnt<-function(th2, vn1, vn2, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1,with=FALSE], f2=th2[,vn2,with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "filter")
  sum1<-sqldf("select f1, f2, count(*) as cnt from df where filter=1 group by 1,2")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

my.f3cnt <- function(th2, vn1, vn2, vn3, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "filter")
  sum1<-sqldf("select f1, f2, f3, count(*) as cnt from df where filter=1 group by 1, 2, 3")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2 and a.f3=b.f3")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

my.f4cnt <- function(th2, vn1, vn2, vn3, vn4, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], f4=th2[, vn4, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "f4", "filter")
  sum1<-sqldf("select f1, f2, f3, f4, count(*) as cnt from df where filter=1 group by 1, 2, 3, 4")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2 and a.f3=b.f3 and a.f4=b.f4")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

my.f5cnt <- function(th2, vn1, vn2, vn3, vn4, vn5, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], f4=th2[, vn4, with=FALSE], f5=th2[, vn5, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "f4", "f5", "filter")
  sum1<-sqldf("select f1, f2, f3, f4, f5, count(*) as cnt from df where filter=1 group by 1, 2, 3, 4, 5")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2 and a.f3=b.f3 and a.f4=b.f4 and a.f5=b.f5")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

my.f6cnt <- function(th2, vn1, vn2, vn3, vn4, vn5, vn6, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], f4=th2[, vn4, with=FALSE], f5=th2[, vn5, with=FALSE], f6=th2[, vn6, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "f4", "f5", "f6", "filter")
  sum1<-sqldf("select f1, f2, f3, f4, f5, f6, count(*) as cnt from df where filter=1 group by 1, 2, 3, 4, 5, 6")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2 and a.f3=b.f3 and a.f4=b.f4 and a.f5=b.f5 and a.f6=b.f6")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

my.f7cnt <- function(th2, vn1, vn2, vn3, vn4, vn5, vn6, vn7, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], f4=th2[, vn4, with=FALSE], f5=th2[, vn5, with=FALSE], f6=th2[, vn6, with=FALSE], f7=th2[, vn7, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "f4", "f5", "f6", "f7","filter")
  sum1<-sqldf("select f1, f2, f3, f4, f5, f6, f7, count(*) as cnt from df where filter=1 group by 1, 2, 3, 4, 5, 6")
  tmp<-sqldf("select b.cnt from df a left join sum1 b on a.f1=b.f1 and a.f2=b.f2 and a.f3=b.f3 and a.f4=b.f4 and a.f5=b.f5 and a.f6=b.f6 and a.f7=b.f7")
  tmp$cnt[is.na(tmp$cnt)]<-0
  return(tmp$cnt)
}

int3WayBool <- function(th2, vn1, vn2, vn3, filter=TRUE) {
  df<-data.frame(f1=th2[,vn1, with=FALSE], f2=th2[,vn2, with=FALSE], f3=th2[, vn3, with=FALSE], filter=filter)
  colnames(df) <- c("f1", "f2", "f3", "filter")
  tmp <- ifelse(df$f1>0 & df$f2>0 & df$f3>0, apply(df[,c("f1","f2","f3")], MARGIN = 1, sum, na.rm=TRUE), 0)
  return(tmp)
}

cat2WayAvg <- function(data, var1, var2, y, pred0, filter, k, f, lambda=NULL, r_k){
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","y","pred0","filt")
  sum1 <- sqldf("SELECT v1, v2, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 WHERE filt=1 GROUP BY v1, v2")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub1 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 ")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)]<-0
  tmp1$cnt1 <- tmp1$cnt
  tmp1$cnt1[filter] <- tmp1$cnt[filter] - 1
  tmp1$sumy1 <- tmp1$sumy
  tmp1$sumy1[filter] <- tmp1$sumy[filter] - tmp1$y[filter]
  tmp1$avgp <- with(tmp1, sumy1/cnt1)
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt1 - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgp + tmp1$beta*tmp1$pred0
  tmp1$avgp[is.na(tmp1$avgp)] <- tmp1$pred0[is.na(tmp1$avgp)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  tmp1$adj_avg[filter]<-tmp1$adj_avg[filter]*(1+(runif(sum(filter))-0.5)*r_k)
  return(tmp1$adj_avg)
}

cat2WayAvgCV <- function(data, var1, var2, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

cat3WayAvg <- function(data, var1, var2, var3, y, pred0, filter, k, f, lambda=NULL, r_k){
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","y","pred0","filt")
  sum1 <- sqldf("SELECT v1, v2, v3, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 WHERE filt=1 GROUP BY v1, v2, v3")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub1 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)]<-0
  tmp1$cnt1 <- tmp1$cnt
  tmp1$cnt1[filter] <- tmp1$cnt[filter] - 1
  tmp1$sumy1 <- tmp1$sumy
  tmp1$sumy1[filter] <- tmp1$sumy[filter] - tmp1$y[filter]
  tmp1$avgp <- with(tmp1, sumy1/cnt1)
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt1 - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgp + tmp1$beta*tmp1$pred0
  tmp1$avgp[is.na(tmp1$avgp)] <- tmp1$pred0[is.na(tmp1$avgp)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  tmp1$adj_avg[filter]<-tmp1$adj_avg[filter]*(1+(runif(sum(filter))-0.5)*r_k)
  return(tmp1$adj_avg)
}

cat3WayAvgCV <- function(data, var1, var2, var3, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

cat4WayAvgCV <- function(data, var1, var2, var3, var4, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "v4", "y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, v4, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","v4", "y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, v4, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

cat5WayAvgCV <- function(data, var1, var2, var3, var4, var5, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "v4", "v5", "y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","v4", "v5", "y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

cat6WayAvgCV <- function(data, var1, var2, var3, var4, var5, var6, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "v4", "v5", "v6", "y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","v4", "v5", "v6", "y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}


cat7WayAvgCV <- function(data, var1, var2, var3, var4, var5, var6, var7, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], v7=data[,var7,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "v4", "v5", "v6", "v7", "y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, v7, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6, v7")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.v7, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6 AND a.v7=b.v7")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], v7=data[,var7,with=FALSE],y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","v4", "v5", "v6", "v7","y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, v7, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6, v7")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.v7, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6 AND a.v7=b.v7")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

cat9WayAvgCV <- function(data, var1, var2, var3, var4, var5, var6, var7, var8, var9, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], v7=data[,var7,with=FALSE], v8=data[,var8,with=FALSE], v9=data[,var9,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c("v1","v2","v3", "v4", "v5", "v6", "v7", "v8","v9","y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, v7, v8, v9, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6, v7, v8, v9")
      tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.v7, b.v8, b.v9, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6 AND a.v7=b.v7 AND a.v8=b.v8 AND a.v9=b.v9")
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], v3=data[,var3,with=FALSE], v4=data[,var4,with=FALSE], v5=data[,var5,with=FALSE], v6=data[,var6,with=FALSE], v7=data[,var7,with=FALSE], v8=data[,var8,with=FALSE], v9=data[,var9,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c("v1","v2","v3","v4", "v5", "v6", "v7","v8","v9","y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sqldf("SELECT v1, v2, v3, v4, v5, v6, v7, v8, v9, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 GROUP BY v1, v2, v3, v4, v5, v6, v7, v8, v9")
  tmp1 <- sqldf("SELECT b.v1, b.v2, b.v3, b.v4, b.v5, b.v6, b.v7, b.v8, b.v9, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub2 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 AND a.v3=b.v3 AND a.v4=b.v4 AND a.v5=b.v5 AND a.v6=b.v6 AND a.v7=b.v7 AND a.v8=b.v8 AND a.v9=b.v9")
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}


# sub1 <- data.frame(v1=data[,var1, with=FALSE], v2=data[,var2,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
# colnames(sub1) <- c("v1","v2","y","pred0","filt")
# sum1 <- sqldf("SELECT v1, v2, SUM(y) as sumy, AVG(y) as avgY, sum(1) as cnt FROM sub1 WHERE filt=1 GROUP BY v1, v2")
# tmp1 <- sqldf("SELECT b.v1, b.v2, b.y, b.pred0, a.sumy, a.avgY, a.cnt FROM sub1 b LEFT JOIN sum1 a ON a.v1=b.v1 AND a.v2=b.v2 ")
# tmp1$cnt[is.na(tmp1$cnt)] <- 0
# tmp1$sumy[is.na(tmp1$sumy)]<-0
# tmp1$cnt1 <- tmp1$cnt
# tmp1$cnt1[filter] <- tmp1$cnt[filter] - 1
# tmp1$sumy1 <- tmp1$sumy
# tmp1$sumy1[filter] <- tmp1$sumy[filter] - tmp1$y[filter]
# tmp1$avgp <- with(tmp1, sumy1/cnt1)
# if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt1 - k)/f))
# tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgp + tmp1$beta*tmp1$pred0
# tmp1$avgp[is.na(tmp1$avgp)] <- tmp1$pred0[is.na(tmp1$avgp)]
# tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
# tmp1$adj_avg[filter]<-tmp1$adj_avg[filter]*(1+(runif(sum(filter))-0.5)*r_k)
# return(tmp1$adj_avg)

catNWayAvg <- function(data, varList, y, pred0, filter, k, f, lambda=NULL, r_k){
  n <- length(varList)
  varNames <- paste0("v",seq(n))
  sub1 <- data.table(v1=data[,varList,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c(varNames,"y","pred0","filt")
  # sub2 <- sub1[sub1$filt==F,]
  sub2 <- sub1[sub1$filt==T,]
  sum1 <- sub2[,list(sumy=sum(y), avgY=mean(y), cnt=length(y)), by=varNames]
  tmp1 <- merge(sub1, sum1, by = varNames, all.x=TRUE, sort=FALSE)
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)]<-0
  tmp1$cnt1 <- tmp1$cnt
  tmp1[filt==T, cnt1:=cnt-1] 
  tmp1$sumy1 <- tmp1$sumy
  tmp1$sumy1[filter] <- tmp1$sumy[filter] - tmp1$y[filter]
  tmp1$avgp <- with(tmp1, sumy1/cnt1)
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt1 - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgp + tmp1$beta*tmp1$pred0
  tmp1$avgp[is.na(tmp1$avgp)] <- tmp1$pred0[is.na(tmp1$avgp)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  tmp1$adj_avg[filter]<-tmp1$adj_avg[filter]*(1+(runif(sum(filter))-0.5)*r_k)
  return(tmp1$adj_avg)
}



catNWayAvgCV <- function(data, varList, y, pred0, filter, k, f, g=1, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  n <- length(varList)
  varNames <- paste0("v",seq(n))
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.table(v1=data[,varList,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c(varNames,"y","pred0")
      sub2 <- sub1[cv[[i]],]
      sub1 <- sub1[-cv[[i]],]
      sum1 <- sub1[,list(sumy=sum(y), avgY=mean(y), cnt=length(y)), by=varNames]
      tmp1 <- merge(sub2, sum1, by = varNames, all.x=TRUE, sort=FALSE)
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(g+exp((tmp1$cnt - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
      tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.table(v1=data[,varList,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c(varNames,"y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sub1[,list(sumy=sum(y), avgY=mean(y), cnt=length(y)), by=varNames]
  tmp1 <- merge(sub2, sum1, by = varNames, all.x=TRUE, sort=FALSE)
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(g+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}


catNWayAvgCV_inFold <- function(data, varList, y, pred0, filter, k, f, lambda=NULL, r_k, cv=NULL){
  # It is probably best to sort your dataset first by filter and then by ID (or index)
  n <- length(varList)
  varNames <- paste0("v",seq(n))
  ind <- unlist(cv, use.names=FALSE)
  oof <- NULL
  if (length(cv) > 0){
    for (i in 1:length(cv)){
      sub1 <- data.table(v1=data[,varList,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
      sub1 <- sub1[sub1$filt==TRUE,]
      sub1$filt <- NULL
      colnames(sub1) <- c(varNames,"y","pred0")
      sub2 <- sub1[cv[[i]],]
      # sub1 <- sub1[-cv[[i]],]
      sum1 <- sub2[,list(sumy=sum(y), avgY=mean(y), cnt=length(y)), by=varNames]
      tmp1 <- merge(sub2, sum1, by = varNames, all.x=TRUE, sort=FALSE)
      tmp1$cnt[is.na(tmp1$cnt)] <- 0
      tmp1$sumy[is.na(tmp1$sumy)] <- 0
      tmp1$cnt1 <- tmp1$cnt - 1
      tmp1$sumy1 <- tmp1$sumy - tmp1$y
      tmp1$avgp <- with(tmp1, sumy1/cnt1)
      if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt1 - k)/f))
      tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgp + tmp1$beta*tmp1$pred0
      # tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
      tmp1$avgp[is.na(tmp1$avgp)] <- tmp1$pred0[is.na(tmp1$avgp)]
      tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
      tmp1$adj_avg <- tmp1$adj_avg*(1+(runif(nrow(sub2))-0.5)*r_k)
      oof <- c(oof, tmp1$adj_avg)
    }
  }
  oofInd <- data.frame(ind, oof)
  oofInd <- oofInd[order(oofInd$ind),]
  sub1 <- data.table(v1=data[,varList,with=FALSE], y=data[,y,with=FALSE], pred0=data[,pred0,with=FALSE], filt=filter)
  colnames(sub1) <- c(varNames,"y","pred0","filt")
  sub2 <- sub1[sub1$filt==F,]
  sub1 <- sub1[sub1$filt==T,]
  sum1 <- sub1[,list(sumy=sum(y), avgY=mean(y), cnt=length(y)), by=varNames]
  tmp1 <- merge(sub2, sum1, by = varNames, all.x=TRUE, sort=FALSE)
  tmp1$cnt[is.na(tmp1$cnt)] <- 0
  tmp1$sumy[is.na(tmp1$sumy)] <- 0
  if(!is.null(lambda)) tmp1$beta <- lambda else tmp1$beta <- 1/(1+exp((tmp1$cnt - k)/f))
  tmp1$adj_avg <- (1-tmp1$beta)*tmp1$avgY + tmp1$beta*tmp1$pred0
  tmp1$avgY[is.na(tmp1$avgY)] <- tmp1$pred0[is.na(tmp1$avgY)]
  tmp1$adj_avg[is.na(tmp1$adj_avg)] <- tmp1$pred0[is.na(tmp1$adj_avg)]
  # Combine train and test into one vector
  return(c(oofInd$oof, tmp1$adj_avg))
}

#################
## Golden Features
## Got these functions from teammate Tian Zhou during Homesite
################
gold_features <- function(df,number){
  list_out<-list()
  for(i in 1:number){
    list_out[[length(list_out)+1]]<-list(df[i,1],df[i,2])
  }
  list_out
}

gold_featuresUnCor <- function(df,number){
  list_out<-list()
  end <- nrow(df)
  start <- end-number
  for(i in start:end){
    list_out[[length(list_out)+1]]<-list(df[i,1],df[i,2])
  }
  list_out
}

#################
## Combining 2 output in a parallel loop. http://stackoverflow.com/questions/19791609/saving-multiple-outputs-of-foreach-dopar-loop
################
comb <- function(x, ...) {
  lapply(seq_along(x),
         function(i) c(x[[i]], lapply(list(...), function(y) y[[i]])))
}

##########################
## PARALLELIZED CORRELATION MATRIX
## bigcorPar code from -- https://gist.github.com/bobthecat/5024079
##########################
bigcorPar <- function(x, nblocks = 10, verbose = TRUE, ncore="all", ...){
  library(ff)
  require(doParallel)
  if(ncore=="all"){
    ncore = parallel:::detectCores()
    registerDoParallel(cores = ncore)
  } else{
    registerDoParallel(cores = ncore)
  }
  
  NCOL <- ncol(x)
  
  ## test if ncol(x) %% nblocks gives remainder 0
  if (NCOL %% nblocks != 0){stop("Choose different 'nblocks' so that ncol(x) %% nblocks = 0!")}
  
  ## preallocate square matrix of dimension
  ## ncol(x) in 'ff' single format
  corMAT <- ff(vmode = "single", dim = c(NCOL, NCOL), dimnames=list(colnames(x),colnames(x)))
  # corMAT <- data.frame(matrix(0, ncol=NCOL, nrow=NCOL))
  
  ## split column numbers into 'nblocks' groups
  SPLIT <- split(1:NCOL, rep(1:nblocks, each = NCOL/nblocks))
  
  ## create all unique combinations of blocks
  COMBS <- expand.grid(1:length(SPLIT), 1:length(SPLIT))
  COMBS <- t(apply(COMBS, 1, sort))
  COMBS <- unique(COMBS)
  
  ## iterate through each block combination, calculate correlation matrix
  ## between blocks and store them in the preallocated matrix on both
  ## symmetric sides of the diagonal
  foreach(i = 1:nrow(COMBS)) %dopar% {
    COMB <- COMBS[i, ]
    G1 <- SPLIT[[COMB[1]]]
    G2 <- SPLIT[[COMB[2]]]
    if (verbose) cat("Block", COMB[1], "with Block", COMB[2], "\n")
    flush.console()
    COR <- cor(x[, G1], x[, G2])
    corMAT[G1, G2] <- COR
    corMAT[G2, G1] <- t(COR)
    COR <- NULL
  }
  
  gc()
  return(corMAT)
}