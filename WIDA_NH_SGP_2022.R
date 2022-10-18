##########################################################################################
###
### Script for calculating SGPs for 2021-2022 WIDA/ACCESS New Hampshire
###
##########################################################################################

### Load SGP package
require(SGP)
require(data.table)

### Load Data
load("Data/WIDA_NH_SGP.Rdata")
load("Data/WIDA_NH_Data_LONG_2022.Rdata")
load("Data/Base_Files/WIDA_NH_ID_GRADE_REASSIGN.Rdata")

### Merge old and new data using updateSGP 
WIDA_NH_SGP <- updateSGP(WIDA_NH_SGP, WIDA_NH_Data_LONG_2022, steps="prepareSGP")

### Update GRADE to accomodate repeaters in analyses
setkey(WIDA_NH_SGP@Data, VALID_CASE, CONTENT_AREA, YEAR, ID)
setkey(WIDA_NH_ID_GRADE_REASSIGN, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_NH_SGP@Data[,GRADE_ORIGINAL:=GRADE]
WIDA_NH_SGP@Data[WIDA_NH_ID_GRADE_REASSIGN[,c("VALID_CASE", "CONTENT_AREA", "YEAR", "ID"), with=FALSE], GRADE:=WIDA_NH_ID_GRADE_REASSIGN$GRADE_NEW]

###   Add single-cohort baseline matrices to SGPstateData
SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA", "2022", "WIDA_NH")

### Run updateSGP
WIDA_NH_SGP <- abcSGP(
		WIDA_NH_SGP,
		years="2022",
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "visualizeSGP", "outputSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=TRUE,
		sgp.projections.lagged=TRUE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline=TRUE,
		sgp.projections.lagged.baseline=TRUE,
		get.cohort.data.info=TRUE,
		sgp.target.scale.scores=TRUE,
		plot.types=c("growthAchievementPlot", "studentGrowthPlot"),
		sgPlot.demo.report=TRUE,
		parallel.config=list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, GA_PLOTS=1, SG_PLOTS=1)))


### Save results
#save(WIDA_NH_SGP, file="Data/WIDA_NH_SGP.Rdata")
