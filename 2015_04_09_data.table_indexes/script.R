
# Script to accompany slides and video here :
# http://www.meetup.com/Silicon-Valley-Big-Data-Science/events/221575298/

require(data.table)

x = runif(10e6, min=0, max=100)
system.time(o1 <- base::order(x))
system.time(o2 <- data.table:::forderv(x))
identical(o1,o2)

ans = sapply( 2^(0:5),  function(n) {
  cat("Timing",n,"million numbers\n")
  x = runif(n*1e6, min=0, max=100)
  c( n,
     system.time(o1 <- base::order(x))["elapsed"],
     system.time(o2 <- data.table:::forderv(x))["elapsed"] )
})

matplot(x=ans[1,], y=t(ans[-1,])/60,
        ylab="Minutes",
        xlab="How many random numbers (millions)",
        type='l', lty=1, col=c("red","blue"), lwd=3)
legend("topleft", legend=c("R's order()","data.table's order()"),
      fill=c("red","blue"))

require(dplyr)
ids = as.vector(outer(outer(LETTERS,LETTERS,paste0),LETTERS,paste0))
head(ids)
length(ids)
26^3
N = 10e6
DF = data.frame(id=sample(ids, N, replace=TRUE),
                val=sample(5, N, TRUE),
                stringsAsFactors=FALSE)
head(DF,3)
system.time(subset(DF, id=="ABC"))
system.time(subset(DF, id=="ABC"))
system.time(DF %>% filter(id=="ABC"))
system.time(DF %>% filter(id=="ABC"))
DT = as.data.table(DF)
system.time(DT[id=="ABC",])
system.time(DT[id=="ABC",])
system.time(DT[id %in% sample(ids,1000)])

N = 100e6
DT = data.table(id=sample(ids, N, TRUE),
                val=sample(5, N, TRUE))
system.time(subset(DT, id=="ABC"))
system.time(subset(DT, id=="ABC"))
system.time(DT$id == "ABC")
system.time(DT$id == "ABC")
system.time(DT[id=="ABC",])
system.time(DT[id=="ABC",])
system.time(DT %>% filter(id=="ABC"))
system.time(DT %>% filter(id=="ABC"))
key2(DT)
set2key(DT,NULL)
system.time(DT %>% filter(id=="ABC"))
system.time(DT %>% filter(id=="ABC"))

options(datatable.verbose=TRUE)
set2key(DT,NULL)
system.time(DT %>% filter(id=="ABC"))
system.time(DT %>% filter(id=="ABC"))
options(datatable.verbose=FALSE)

