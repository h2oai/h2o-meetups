library(data.table)
library(RSocrata)

# some OSX work-around 
if (Sys.info()["sysname"] == "Darwin")
  Sys.setenv (TZ="America/Chicago")

# function to compare columns and types
compareDataframes <- function(df1, df2) {
  if(class(df1) != "data.frame") df1 = as.data.frame(df1)
  if(class(df2) != "data.frame") df2 = as.data.frame(df2)
  
  if (dim(df1)[[2]] != dim(df2)[[2]])
    return("Different number of columns")
  
  if (!identical(names(df1), names(df2)))
    return("Different column names")
  
  df1types = unlist(sapply(df1, class))
  df2types = unlist(sapply(df2, class))
  if (!identical(df1types, df2types)) {
    result = data.frame(df1.name=names(df1types), df1.type=df1types, 
                        df2.name=names(df2types), df2.type=df2types,
                        stringsAsFactors = FALSE)
    result = with(result, result[df1.type != df2.type,])
    return(paste("Different data types:", paste(capture.output(result), collapse="\n")))
  }
}

compareColumns <- function(df1, df2) {
  commonNames <- names(df1)[names(df1) %in% names(df2)]
  
  data.frame(Column = commonNames,
             df1 = sapply(df1[,commonNames], class),
             df2 = sapply(df2[,commonNames], class)) 
}

# Read Dallas Animal Shelters Data 2015 - 2018
data15.source = read.socrata(url = "https://www.dallasopendata.com/resource/8pn8-24ku.csv")
data16.source = read.socrata(url = "https://www.dallasopendata.com/resource/4qfv-27du.csv")
data17.source = read.socrata(url = "https://www.dallasopendata.com/resource/8849-mzxh.csv")
data18.source = read.socrata(url = "https://www.dallasopendata.com/resource/4jgt-nenk.csv")

# Create data tables for speed
dt15 = data.table(data15.source)
dt16 = data.table(data16.source)
dt17 = data.table(data17.source)
dt18 = data.table(data18.source)

# Minimal changes to make all years compatible
dt15n16 = rbindlist(list(dt15,dt16))
dt15n16[, c("intake_time","outcome_time") := 
          list(strftime(intake_time, format="%H:%M:%S"), 
               strftime(outcome_time, format="%H:%M:%S"))]

names(dt17)[21] = 'month'

alldata = rbindlist(list(dt15n16,dt17,dt18), use.names=TRUE, fill=TRUE)

alldogs = alldata[!is.na(outcome_date) & 
                    (intake_total == 1 | is.na(intake_total)) &
                    animal_type == 'DOG' &
                    !outcome_type %in% c("DEAD ON ARRIVAL","FOUND REPORT","LOST REPORT")]

alldogs[, c("activity_number","activity_sequence","tag_type",
            "animal_type","additional_information") := NULL]
alldogs[, c("intake_time", "outcome_time","intake_ts","outcome_ts","month",
            "lost","intake_is_contagious","intake_treatable") := list(
  substring(intake_time, 1, 8),
  substring(outcome_time, 1, 8),
  as.POSIXct(substring(intake_time, 1, 8), format="%T"),
  as.POSIXct(substring(outcome_time, 1, 8), format="%T"),
  substring(month, 1, 3),
  ifelse(outcome_type %in% c("DIED","EUTHANIZED","MISSING"), 1, 0),
  ifelse(is.na(stringr::str_match(intake_condition, ' CONTAGIOUS$')[,1]), 'NO','YES'),
  ifelse(is.na(stringr::str_match(intake_condition, '^TREATABLE ')[,1]), 'UNTREATABLE',
         ifelse(is.na(stringr::str_match(intake_condition, 'MANAGEABLE')[,1]),
                'REHABILITABLE', 'MANAGEABLE'))
)]

# extract date and time elements and drop intermediate columns with time
alldogs[, c("intake_month", "intake_month_day", "intake_week_day", "intake_week_of_month", "intake_hour",
            "intake_month_fac", "intake_month_day_fac", "intake_week_day_fac", "intake_week_of_month_fac",
            "intake_month_x", "intake_month_y", "intake_month_day_x", "intake_month_day_y", 
            "intake_week_day_x", "intake_week_day_y", "intake_week_of_month_x", "intake_week_of_month_y", 
            "intake_hour_x", "intake_hour_y", 
            "intake_ts","outcome_ts"
            ) := list(
            month(intake_date), mday(intake_date), wday(intake_date), trunc((mday(intake_date)-1)/7) + 1,
            hour(intake_ts),
            
            # factor
            factor(month(intake_date), labels=c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), 
                   ordered = TRUE),
            factor(formatC(mday(intake_date), width = 2, format = "d", flag = "0"), ordered = TRUE),
            factor(wday(intake_date), labels = c('Sun','Mon','Tue','Wed','Thu','Fri','Sat'), ordered = TRUE),
            factor(trunc((mday(intake_date)-1)/7) + 1, labels = c("w1","w2","w3","w4","w5"), ordered = TRUE),
            
            # polar
            cos((2*pi/12)*(month(intake_date)-1)),
            sin((2*pi/12)*(month(intake_date)-1)),
            
            cos((2*pi/31)*(mday(intake_date)-1)),
            sin((2*pi/31)*(mday(intake_date)-1)),
            
            cos((2*pi/7)*(wday(intake_date)-1)),
            sin((2*pi/7)*(wday(intake_date)-1)),
            
            cos((2*pi/5)*(trunc((mday(intake_date)-1)/7)+1-1)),
            sin((2*pi/5)*(trunc((mday(intake_date)-1)/7)+1-1)),
            
            cos((2*pi/12)*(hour(intake_ts)-1)),
            sin((2*pi/12)*(hour(intake_ts)-1)),
            
            # remove
            NULL, NULL
            )]

ttt = data.frame(train_name = h2o.names(das.train.hex), 
           train_type = unlist(h2o.getTypes(das.train.hex)),
           test_name = h2o.names(das.test.hex),
           test_type = unlist(h2o.getTypes(das.test.hex)))
View(ttt[ttt$train_type != ttt$test_type,])

# Save file for training (FY 2015-2017) 
fwrite(alldogs[!year %in% "FY2018"], file = "~/Projects/Playground/data/dallas_animal_services_train.csv")
# Save file for testing (FY 2018)
fwrite(alldogs[year %in% "FY2018"], file = "~/Projects/Playground/data/dallas_animal_services_test.csv")

## Excluded in DAI
# animal_id
# year

## Outcome leaking features:
# due_out
# hold_request
# impound_number

# intake_total

# kennel_number
# kennel_status
# reason
# receipt_number
# service_request_number
# source_id
# staff_id

# outcome_XXXX

## Join with Animal Records
# Read Dallas Animal Medical Records 2018 (not used)
data18.recs.source = read.socrata(url = "https://www.dallasopendata.com/resource/5dkq-vasv.csv")
data17.recs.source = read.socrata(url = "https://www.dallasopendata.com/resource/tab8-7f9r.csv")

compareColumns(data18.recs.source, data17.recs.source)

data17n18.recs.source = rbindlist(list(data18.recs.source,data17.recs.source))
# after analysis this shows little value add from medical records

## Join with Dallas Weather
# Source: https://www.ncdc.noaa.gov/cdo-web/datasets#GHCND
dallas_weather_source = fread("data/1313560-Dallas-weather-2014-2018.csv")

weather = dallas_weather_source[, .(intake_date = as.POSIXct(DATE),
                          precip = as.numeric(PRCP),
                          windspeed = as.numeric(AWND),
                          temp_avg = as.numeric(TAVG),
                          temp_min = as.numeric(TMIN),
                          temp_max = as.numeric(TMAX),
                          temp_range = as.numeric(TMAX) - as.numeric(TMIN),
                          is_fog = ifelse(WT01 != "" | WT02 != "", 'Y', 'N'),
                          is_thunder = ifelse(WT03 != "", 'Y', 'N'))]

alldogs_weather = weather[alldogs, on="intake_date"]

# Save file for training (FY 2015-2017) 
fwrite(alldogs_weather[!year %in% "FY2018"], file = "~/Projects/Playground/data/dallas_animal_services_weather_train.csv")
# Save file for testing (FY 2018)
fwrite(alldogs_weather[year %in% "FY2018"], file = "~/Projects/Playground/data/dallas_animal_services_weather_test.csv")


# Modeling with h2o
library(h2o)

h2o.init()

das.train.hex = h2o.importFile(normalizePath("~/Projects/Playground/data/dallas_animal_services_train.csv"), 
                               destination_frame = "das_train", col.names = names(alldogs),
                               col.types = )
types = unlist(h2o.getTypes(das.train.hex))
das.test.hex = h2o.importFile(normalizePath("~/Projects/Playground/data/dallas_animal_services_test.csv"),
                              destination_frame = "das_test", col.names = names(alldogs),
                              col.types = types)

# make lost a factor
das.train.hex[,'lost'] = as.factor(das.train.hex[,'lost']) 
das.test.hex[,'lost'] = as.factor(das.test.hex[,'lost']) 
das.gbm = h2o.gbm(y="lost", x=c("animal_breed","animal_origin","census_tract","chip_status","council_district",
                                "intake_condition","intake_date","intake_subtype","intake_time","intake_type",
                                "month","reason","staff_id"), training_frame = das.train.hex)
h2o.auc(das.gbm)
h2o.scoreHistory(das.gbm)
plot(das.gbm)
h2o.varimp(das.gbm)
das.leafs = h2o.predict_leaf_node_assignment(das.gbm, das.test.hex)



h2o.download_mojo(model=das.gbm, path=normalizePath("~/Projects/Playground/mojo"), get_genmodel_jar = TRUE)
