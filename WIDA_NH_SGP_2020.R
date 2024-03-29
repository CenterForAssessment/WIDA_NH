##########################################################################################
###
### Script for calculating SGPs for 2019-2020 WIDA/ACCESS New Hampshire
###
##########################################################################################

### Load SGP package

require(SGP)


### Load Data

load("Data/WIDA_NH_SGP.Rdata")
load("Data/WIDA_NH_Data_LONG_2020.Rdata")

### Add in baseline matrices

SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA", "2020", "WIDA_NH")


### Run updateSGP

WIDA_NH_SGP <- updateSGP(
		WIDA_NH_SGP,
		WIDA_NH_Data_LONG_2020,
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

save(WIDA_NH_SGP, file="Data/WIDA_NH_SGP.Rdata")
