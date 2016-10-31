create_feature_map <- function(fmap_filename, features){
  for (i in 1:length(features)){
    cat(paste(c(i-1,features[i],"q"), collapse = "\t"), file=fmap_filename, sep="\n",append=TRUE)
  }
}

# varnames <- colnames(ts1Trans[,4:ncol(ts1Trans),with=FALSE])
# create_feature_map("./xgb35_fmap.txt", varnames)
# 
# 
# 
# xgb.dump(model=xgb35full, fname="xgb_dump",fmap="./xgb35_fmap.txt", with.stats = TRUE)


create_feature_map("./xgb1_fmap.txt", varnames)
xgb.dump(model=xgb1, fname="xgb_dump", fmap="./xgb1_fmap.txt", with.stats = TRUE)
