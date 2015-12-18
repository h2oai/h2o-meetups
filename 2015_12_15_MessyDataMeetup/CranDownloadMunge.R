
cd ~/cran-mirror
R
require(data.table)

DT = fread("2015-02-28.csv")
DT
DT = DT[,-c("r_version","r_arch","r_os"),with=FALSE]
DT
DT[,.N,by=package]
DT[,.N,by=package][order(N)]
DT[,.N,by=package][order(-N)]
DT[,.N,by=package][head(order(-N),20)]

DT[,.N,by=ip_id]
DT[,.N,by=ip_id][order(-N)]
DT[ip_id==884]
DT[ip_id==884, .N, by=package][order(-N)]
DT[package=="dplyr", .N, by=ip_id][order(-N)]
DT[package=="dplyr" & ip_id==28]
DT[package=="data.table" & ip_id==28]

ans1 = DT[,.N,by=package][head(order(-N),110)][,rank:=.I]
ans1[package %in% c("data.table","dplyr")]

ans2 = DT[,.N,by=.(ip_id,package)][,.N,by=package][head(order(-N),110)][,rank:=.I]
ans2[package %in% c("data.table","dplyr")]
merge(ans1,ans2,by="package",all=TRUE)
merge(ans1,ans2,by="package",all=TRUE)[order(-abs(rank.x-rank.y))]

for (m in sprintf("2015-%02d",1:11)) {
  DT = rbindlist(lapply(dir(patt=m), fread))
  ans2 = DT[,.N,by=.(date,ip_id,package)][,.N,by=package][order(-N)][,rank:=.I]
  cat(m,"\n")
  print(ans2[package %in% c("data.table","dplyr")])
}


