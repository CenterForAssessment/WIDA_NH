#################################################################################
###
### Data preparation script for WIDA NH data, 2017 & 2018
###
#################################################################################

### Load Packages

require(SGP)
require(data.table)


### Utility function

strtail <- function (s, n = 1) {
    if (n < 0)
        substring(s, 1 - n)
    else substring(s, nchar(s) - n + 1)
}

strhead <- function (s, n) {
    if (n < 0)
        substr(s, 1, nchar(s) + n)
    else substr(s, 1, n)
}


### Load Data

WIDA_NH_Data_LONG_2017 <- fread("Data/Base_Files/ESOLDatafor2017.dat", colClasses=rep("character", 5))
WIDA_NH_Data_LONG_2018 <- fread("Data/Base_Files/ESOLDatafor2018.dat", colClasses=rep("character", 5))
WIDA_NH_Data_LONG <- rbindlist(list(WIDA_NH_Data_LONG_2017, WIDA_NH_Data_LONG_2018))


### Clean Up Data

WIDA_NH_Data_LONG <- WIDA_NH_Data_LONG[!ID=="NULL"]
setnames(WIDA_NH_Data_LONG, c("YEAR", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_NH_Data_LONG[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_NH_Data_LONG[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_NH_Data_LONG[,ACHIEVEMENT_LEVEL_ORIGINAL:=strhead(paste0(ACHIEVEMENT_LEVEL_ORIGINAL, ".0"), 3)]
WIDA_NH_Data_LONG[,ACHIEVEMENT_LEVEL := ACHIEVEMENT_LEVEL_ORIGINAL]
WIDA_NH_Data_LONG[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_NH_Data_LONG[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_NH_Data_LONG[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_NH_Data_LONG[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_NH_Data_LONG[,VALID_CASE := "VALID_CASE"]
WIDA_NH_Data_LONG[,CONTENT_AREA := "READING"]




### Check for duplicates

setkey(WIDA_NH_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_NH_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_NH_Data_LONG[which(duplicated(WIDA_NH_Data_LONG, by=key(WIDA_NH_Data_LONG)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_NH_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)


### Reorder

setcolorder(WIDA_NH_Data_LONG, c(7,8,1,2,3,4,6,5))


### Save data

save(WIDA_NH_Data_LONG, file="Data/WIDA_NH_Data_LONG.Rdata")
