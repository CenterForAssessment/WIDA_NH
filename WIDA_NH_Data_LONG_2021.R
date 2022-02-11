#################################################################################
###
### Data preparation script for WIDA NH data, 2021
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
WIDA_NH_Data_LONG_2021 <- fread("Data/Base_Files/ESOLDatafor2021.dat", colClasses=rep("character", 5))
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY <- fread("Data/Base_Files/ESOL_Scores_with_US_entered_sped.csv")


### Clean Up Data
setnames(WIDA_NH_Data_LONG_2021, c("YEAR", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_NH_Data_LONG_2021[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_NH_Data_LONG_2021[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_NH_Data_LONG_2021[,ACHIEVEMENT_LEVEL := ACHIEVEMENT_LEVEL_ORIGINAL]
WIDA_NH_Data_LONG_2021[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_NH_Data_LONG_2021[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_NH_Data_LONG_2021[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_NH_Data_LONG_2021[,VALID_CASE := "VALID_CASE"]
WIDA_NH_Data_LONG_2021[,CONTENT_AREA := "READING"]

### Check for duplicates
setkey(WIDA_NH_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_NH_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_NH_Data_LONG_2021[which(duplicated(WIDA_NH_Data_LONG_2021, by=key(WIDA_NH_Data_LONG_2021)))-1, VALID_CASE := "INVALID_CASE"]


### Clean up and merge in years in us
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY <- WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[,c("yearid", "StudentID", "yrusentered", "spedany"), with=FALSE]
setnames(WIDA_NH_Data_LONG_2021_SUPPLEMENTARY, c("YEAR", "ID", "YEAR_ENTERED_US", "SPECIAL_EDUCATION_STATUS"))
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[,YEAR:=as.character(YEAR)]
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[,ID:=as.character(ID)]
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[YEAR_ENTERED_US=="NULL", YEAR_ENTERED_US:=NA]
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[,SPECIAL_EDUCATION_STATUS:=as.character(SPECIAL_EDUCATION_STATUS)]
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[SPECIAL_EDUCATION_STATUS==0, SPECIAL_EDUCATION_STATUS:="Special Education Status: No"]
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[SPECIAL_EDUCATION_STATUS==1, SPECIAL_EDUCATION_STATUS:="Special Education Status: Yes"]
setkey(WIDA_NH_Data_LONG_2021_SUPPLEMENTARY, YEAR, ID)
WIDA_NH_Data_LONG_2021_SUPPLEMENTARY <- WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[!duplicated(WIDA_NH_Data_LONG_2021_SUPPLEMENTARY, by=key(WIDA_NH_Data_LONG_2021_SUPPLEMENTARY))]
setkey(WIDA_NH_Data_LONG_2021, YEAR, ID)
WIDA_NH_Data_LONG_2021 <- WIDA_NH_Data_LONG_2021_SUPPLEMENTARY[WIDA_NH_Data_LONG_2021]
setkey(WIDA_NH_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)


### Reorder
setcolorder(WIDA_NH_Data_LONG_2021, c(9,10,1,2,5,6,7,8,3,4))


### Save data

save(WIDA_NH_Data_LONG_2021, file="Data/WIDA_NH_Data_LONG_2021.Rdata")
