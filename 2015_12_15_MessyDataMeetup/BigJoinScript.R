
# java -jar ./build/h2o.jar -name MyCloud &

R
require(h2o)
h2o.init()
# or ...
# java -jar ./build/h2o.jar -name MyCloud &
# h2o.init(ip="mr-0xd6", port=55666)

N = 1e7

X = h2o.createFrame(rows=N,cols=5,integer_range=N,categorical_fraction = 0,integer_fraction=1,binary_fraction=0,missing_fraction = 0)
X
X$C1 = abs(X$C1)
colnames(X) = paste0("X.",colnames(X))
colnames(X)[1] = "KEY"
X
Y = h2o.createFrame(rows=N,cols=5,integer_range=N,categorical_fraction = 0,integer_fraction=1,binary_fraction=0,missing_fraction = 0)
Y$C1 = abs(Y$C1)
colnames(Y) = paste0("Y.",colnames(Y))
colnames(Y)[1] = "KEY"
Y

ans1 = h2o.merge(X, Y, method="radix")
system.time(print(dim(ans1)))
ans1
tail(ans1)

# END


ans1 = as.data.frame(ans1)
Xdf = as.data.frame(X)
Ydf = as.data.frame(Y)
system.time(ans2 <- merge(Xdf, Ydf))
dim(ans2)

ans1 = ans1[order(ans1$KEY,ans1$X.C2, ans1$X.C3, ans1$Y.C2, ans1$Y.C3),]
ans2 = ans2[order(ans2$KEY,ans2$X.C2, ans2$X.C3, ans2$Y.C2, ans2$Y.C3),]
mapply(all.equal, ans1, ans2)


# Speed test against data.table and base::merge
require(data.table)
N = 1E9L
DT1 = data.table(KEY=sample(N,replace=TRUE), C2=sample(N,replace=TRUE), C3=sample(N,replace=TRUE), C4=sample(N,replace=TRUE), C5=sample(N,replace=TRUE))
DT2 = data.table(KEY=sample(N,replace=TRUE), C2=sample(N,replace=TRUE), C3=sample(N,replace=TRUE), C4=sample(N,replace=TRUE), C5=sample(N,replace=TRUE))
system.time(ansDT <- DT1[DT2,on="KEY",nomatch=0][order(KEY)])
ansDT





X = as.h2o(data.frame(a=1:3, b=4:6))
Y = as.h2o(data.frame(a=1:3, c=7:9))
X
Y
h2o.merge(X,Y, method="radix")
Y = as.h2o(data.frame(a=2:4, c=10:12))
Y
h2o.merge(X,Y, method="radix")
h2o.merge(X,Y, all.x=TRUE, method="radix")
X = as.h2o(data.frame(a=1L, b=99L))
X
h2o.merge(X,Y, method="radix")
h2o.merge(X,Y, method="radix", all.x=TRUE)
X = as.h2o(data.frame(a=1:3, b=4:6))
Y = as.h2o(data.frame(a=c(1L,1L,1L,3L,3L), foo=7:11))
h2o.merge(X,Y, method="radix")
h2o.merge(X,Y, method="radix", all.x=TRUE)

set.seed(1)
N = 1e7
Xdf = data.frame(a=sample(1:1e9,N,replace=TRUE), leftVal1 = rnorm(N))
Ydf = data.frame(a=sample(1:1e9,N,replace=TRUE), rightVal1 = rnorm(N))



X = as.h2o(Xdf)
Y = as.h2o(Ydf)
head(X)
head(Y)

# because base R isn't stable within a right group, need to sort to compare.
# In this example, it's just rows 677 and 688 that are in unstable order in the base::merge result
ans1 = ans1[order(ans1$a, ans1$leftVal1, ans1$rightVal1),]
ans2 = ans2[order(ans2$a, ans2$leftVal1, ans2$rightVal1),]
mapply(all.equal, ans1, ans2)

ans3 = h2o.merge(X, Y)
system.time(head(ans3))  # hash method currently fails

require(data.table)
Xdt = as.data.table(Xdf)
Ydt = as.data.table(Ydf)
system.time(ans4 <- merge(Xdt,Ydt,by="a"))
ans4 = ans4[order(a, leftVal1, rightVal1)]
mapply(all.equal, ans2, ans4)





df.hex <- h2o.createFrame(integer_fraction = 1, 
                         categorical_fraction = 0, 
                         binary_fraction = 0,
                         rows=1000, cols=1000)


# b=sample(1:5, N, replace=TRUE)

setwd("~/devtestdata/")
library(data.table)
library(bit64)
l <- fread("step1_subset.csv")

r <- fread("test.csv")
# or ...
r <- fread("fullsize.csv")

setnames(l, "someID","CAL_DT")

r[l,on=c("HHLD_ID","CAL_DT"),which=TRUE]-1
r[l,on=c("HHLD_ID"),which=TRUE]-1
r[l[1],on=c("HHLD_ID"),which=TRUE]-1

r[l,on=c("HHLD_ID")][order(HHLD_ID)]

r[l,on=c("HHLD_ID","CAL_DT")]
# debugging in intellij and looking at _rightOrder[0][74192] through to _rightOrder[0][74201]
r[c(12093017,10579446,13586276,2360614,6375518,7,3700692,14603196,5705466,12594717)+1]


