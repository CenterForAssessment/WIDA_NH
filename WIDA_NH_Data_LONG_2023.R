#################################################################################
###
### Data preparation script for WIDA NH data, 2023
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
WIDA_NH_Data_LONG_2023 <- fread("Data/Base_Files/ESOLDatafor2023.csv", colClasses=rep("character", 5))


### Clean Up Data
setnames(WIDA_NH_Data_LONG_2023, c("YEAR", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_NH_Data_LONG_2023[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_NH_Data_LONG_2023[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_NH_Data_LONG_2023[,ACHIEVEMENT_LEVEL := ACHIEVEMENT_LEVEL_ORIGINAL]
WIDA_NH_Data_LONG_2023[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_NH_Data_LONG_2023[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_NH_Data_LONG_2023[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_NH_Data_LONG_2023[,VALID_CASE := "VALID_CASE"]
WIDA_NH_Data_LONG_2023[,CONTENT_AREA := "READING"]

### Check for duplicates
setkey(WIDA_NH_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_NH_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_NH_Data_LONG_2023[which(duplicated(WIDA_NH_Data_LONG_2023, by=key(WIDA_NH_Data_LONG_2023)))-1, VALID_CASE := "INVALID_CASE"]

### Reorder
setcolorder(WIDA_NH_Data_LONG_2023, c(7,8,1,2,3,4,5,6))


### Save data
save(WIDA_NH_Data_LONG_2023, file="Data/WIDA_NH_Data_LONG_2023.Rdata")
