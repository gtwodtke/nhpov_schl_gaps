################################################
################################################
##                                            ##
## PROGRAM NAME: 24_create_figure_E1          ##
##                                            ##
## PURPOSE: create bar chart with results     ##
##          of descriptive decomposition      ##
##          using 4th grade test scores       ##
##                                            ##
################################################
################################################

##### LOAD LIBRARIES #####
rm(list=ls())

list.of.packages <- c(
	"haven",
	"foreign",
	"Hmisc",
	"dplyr",
	"tidyr",
	"tidyverse",
	"ggplot2",
	"SuperLearner",
	"ranger",
	"nnet",
	"caret",
	"xgboost",
	"e1071",
	"sys",
	"foreach",
	"doParallel",
	"doRNG",
  "gridExtra",
	"estimatr")

for(package.i in list.of.packages) {
	suppressPackageStartupMessages(library(package.i, character.only = TRUE))
	}

startTime <- Sys.time()
set.seed(60637)

##### LOAD ECLS-K #####
eclsk.mi <- read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi <- as.data.frame(eclsk.mi[which(eclsk.mi$minum!=0),])
eclsk.mi <- eclsk.mi[order(eclsk.mi$childid, eclsk.mi$minum),]

##### SET SCRIPT PARAMETERS #####
nmi <- 5
kfolds <- 5
RFtrees <- 200 
GBtrees <- 100
ncores <- min(nmi, parallel::detectCores()-2)

##### DEFINE VARIABLE SETS #####
vars.meta <- c(
  "childid",
  "parentid",
  "schlid",
  "strat",
  "psu",
  "sampwt")

vars.schl.com<-c(
  "sblk4",
  "stotell4",
  "sfrlnch4",
  "sgif4",
  "shspnc4",
  "sspced4",
  "swht4",
  "pgender4",
  "prace4",
  "tgender4",
  "trace4")

vars.schl.res<-c(
  "strg_pp_4",
  "ccd_dstr_exppp4",
  "start_pp_4",
  "stesl_pp_4",
  "stgft_pp_4",
  "stgym_pp_4",
  "stcmp_pp_4",
  "stlib_pp_4",
  "stnrs_pp_4",
  "stpar_pp_4",
  "pyrspr4",
  "pyrstch4",
  "stfpsy_pp_4",
  "stsp_pp_4",
  "tyrsch4",
  "sttrn4",
  "tyrstch4",
  "ped4",
  "sartok4",
  "saudok4",
  "scafeok4",
  "sclssok4",
  "scompok4",
  "sgymok4",
  "slibok4",
  "smultok4",
  "smusok4",
  "splayok4",
  "sfnddc4",
  "shighgrd4",
  "slowgrd4",
  "sstffdec4",
  "sstfffrz4",
  "sstffinc4",
  "strnsl4",
  "stype4",
  "syrrnd4",
  "tcrt4",
  "tnexm4",
  "ted4")

vars.schl.ins<-c(
  "tevlbhv4",
  "tevlcoop4",
  "tevldir4",
  "tevleff4",
  "tevlimp4",
  "tevlpart4",
  "tevlclss4",
  "tevlstd4",
  "tevlprj4",
  "tevlqz4",
  "tevlwrksh4",
  "tevlwrksa4",
  "thw4",
  "a4usebsl4",
  "a4uselev4",
  "a4usenew4",
  "a4usekit4",
  "a4usecmp4",
  "a4usetrd4",
  "a4useoth4",
  "a4useman4",
  "a4usebgbk4",
  "a4usedecb4",
  "a4useaubk4",
  "a4useanth4",
  "a4mainid4",
  "a4retell4",
  "a4deschar4",
  "a4senses4",
  "a4whotell4",
  "a4maintext4",
  "a4reassup4",
  "a4simdiff4",
  "a4ficnonf4",
  "a4cmpxinf4",
  "a4cmpxpro4",
  "a4segword4",
  "a4manpho4",
  "a4sndwrd4",
  "a4irregwd4",
  "a4paceint4",
  "a4rdaccr4",
  "a4useglos4",
  "a4senctxt4",
  "a4charplot4",
  "a4gencsp4",
  "a4predict4",
  "a4opinion4",
  "a4infpiec4",
  "a4narrtv4",
  "a4cnt20qty4",
  "a4relqty4",
  "a4slvadsb4",
  "a4slvadd34",
  "a4ctadsub4",
  "a4eqlsign4",
  "a4sidequa4",
  "a4slvuknm4",
  "a4cnt1204",
  "a4nmrl1204",
  "a4numqty4",
  "a4tenones4",
  "a4relsym4",
  "a4addto1004",
  "a4find104",
  "a4skipcnt4",
  "a4arr3obj4",
  "a4lng2by34",
  "a4lngmult4",
  "a4meatool4",
  "a4estlng4",
  "a4telltime4",
  "a4wrttime4",
  "a4slvcoin4",
  "a4drwgrph4",
  "a4ansgrph4",
  "a4attrshp4",
  "a4dimcomp4",
  "a4parteql4",
  "a4triquad4",
  "tord4",
  "tomth4",
  "ttrd4",
  "ttmth4",
  "ttsgrp4",
  "ttlgrp4",
  "ttindv4",
  "ttpeer4",
  "tevltst4",
  "tachrd4",
  "tachmth4")

vars.schl.cli <- c(
  "saenc4",
  "sapri4",
  "sprnpar4",
  "tbhvr4",
  "sdsrd4",
  "sspprt4",
  "sacns4",
  "sblly4",
  "scnfl4",
  "sthft4",
  "sptcnf4",
  "spsupp4",
  "tacpt4",
  "tlstd4",
  "tenjy4",
  "tmkdff4",
  "tideas4",
  "tppwrk4",
  "tstfrec4",
  "tmssn4",
  "tchstch4",
  "sattnd4",
  "ststinf4",
  "srptcrd4")

vars.schl.efx <- c(
  "rdvaladd",
  "mtvaladd")

vars.schl.all <- c(
  vars.schl.com, 
  vars.schl.res, 
  vars.schl.ins, 
  vars.schl.cli, 
  vars.schl.efx)

##### RECODE VARIABLES ######
eclsk.mi$rdtheta8 <- (eclsk.mi$rdtheta8-mean(eclsk.mi$rdtheta8))/sqrt(var(eclsk.mi$rdtheta8))
eclsk.mi$mththeta8 <- (eclsk.mi$mththeta8-mean(eclsk.mi$mththeta8))/sqrt(var(eclsk.mi$mththeta8))

for (v in 1:length(vars.schl.all)) {
  eclsk.mi[, vars.schl.all[v]] <- as.numeric(eclsk.mi[, vars.schl.all[v]])
  eclsk.mi[, vars.schl.all[v]]<-(eclsk.mi[, vars.schl.all[v]]-mean(eclsk.mi[, vars.schl.all[v]]))/sqrt(var(eclsk.mi[, vars.schl.all[v]]))
}

eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

##### DEFINE CENSORING FUNCTION #####
censor <- function(x, low=0.01, high=0.99) {
  min <- quantile(x, low)
  max <- quantile(x, high)
  
  x[x<min] <- min
  x[x>max] <- max

  x
}

##### SETUP SUPERLEARNER #####
cntrl.sl.cnt <- SuperLearner.CV.control(V=5L, shuffle=TRUE, validRows=NULL)
cntrl.sl.bin <- SuperLearner.CV.control(V=5L, stratifyCV=TRUE, shuffle=TRUE, validRows=NULL)

customRF <- create.Learner(
  "SL.ranger",
  name_prefix="customRF",
  params=list(
    num.trees=RFtrees,
    min.node.size=10
  )
)

customGBTree <- create.Learner(
  "SL.xgboost",
  name_prefix="customGBTree",
  params=list(
    nrounds=GBtrees,
    max_depth=3,
    eta=0.1,
    gamma=0.005,
    min_child_weight=10
  )
)

##### PARALLELIZATION #####
my.cluster <- parallel::makeCluster(ncores, type="PSOCK")
doParallel::registerDoParallel(cl=my.cluster)
foreach::getDoParRegistered()
registerDoRNG(60637)

clusterEvalQ(cl=my.cluster, {
  library(SuperLearner)
  library(dplyr)
  library(estimatr)
  })

clusterExport(cl=my.cluster,
  list(
    "eclsk.mi",
    "vars.meta",
    "vars.schl.all",
    "vars.schl.efx",
    "vars.schl.cli",
    "vars.schl.ins",
    "vars.schl.res",
    "vars.schl.com",
    "kfolds",
    "censor",
    "cntrl.sl.bin",
    "cntrl.sl.cnt",
    "customRF_1",
    "customGBTree_1"),
  envir=environment()
)

##### COMPUTE MI ESTIMATES #####
mi.results <- foreach(i=1:nmi, .combine=cbind) %dopar% {

  ### LOAD MI DATA ###
  eclsk <- eclsk.mi[which(eclsk.mi$minum==i),]

  ### DECOMP OBSREVED GAP ###
  muhat0.rd <- mean(eclsk[which(eclsk$hipovnh==0), "rdtheta8"])
  muhat1.rd <- mean(eclsk[which(eclsk$hipovnh==1), "rdtheta8"])
  muhat0.mt <- mean(eclsk[which(eclsk$hipovnh==0), "mththeta8"])
  muhat1.mt <- mean(eclsk[which(eclsk$hipovnh==1), "mththeta8"])
  
  partitions <- eclsk %>% 
    distinct(schlid) %>%
    mutate(k = sample(1:kfolds, n(), replace=TRUE))
  
  eclsk <- eclsk %>%
    left_join(partitions, by="schlid")
  
  eclsk.x1 <- eclsk %>% mutate(hipovnh=1)
  
  eifEst <- eclsk[, c(vars.meta, "k", "hipovnh", "rdtheta8", "mththeta8")]
  eifEst$phat.x1 <- eifEst$phat.x1.com <- eifEst$phat.x1.res <- eifEst$phat.x1.ins <- eifEst$phat.x1.cli <- eifEst$phat.x1.efx <- NA
  eifEst$yhat.x1.rd.com <- eifEst$yhat.x1.rd.res <- eifEst$yhat.x1.rd.ins <- eifEst$yhat.x1.rd.cli <- eifEst$yhat.x1.rd.efx <- NA
  eifEst$yhat.x1.mt.com <- eifEst$yhat.x1.mt.res <- eifEst$yhat.x1.mt.ins <- eifEst$yhat.x1.mt.cli <- eifEst$yhat.x1.mt.efx <- NA
  eifEst$yhat.x1.x0.rd.com <- eifEst$yhat.x1.x0.rd.res <- eifEst$yhat.x1.x0.rd.ins <- eifEst$yhat.x1.x0.rd.cli <- eifEst$yhat.x1.x0.rd.efx <- NA
  eifEst$yhat.x1.x0.mt.com <- eifEst$yhat.x1.x0.mt.res <- eifEst$yhat.x1.x0.mt.ins <- eifEst$yhat.x1.x0.mt.cli <- eifEst$yhat.x1.x0.mt.efx <- NA
  
  # INITIATE K-FOLD CROSS-FITTING #
  for (j in 1:kfolds) {
    
    nhpov.mod.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), vars.schl.com],
      family = binomial(),
      SL.library=c("SL.glm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)

    nhpov.mod.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.schl.com, vars.schl.res)],
      family = binomial(),
      SL.library=c("SL.glm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.schl.com, vars.schl.res, vars.schl.ins)],
      family = binomial(),
      SL.library=c("SL.glm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)

    nhpov.mod.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      family = binomial(),
      SL.library=c("SL.glm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)

    nhpov.mod.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), vars.schl.all],
      family = binomial(),
      SL.library=c("SL.glm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    eifEst[which(eifEst$k==j), "phat.x1"] <- mean(eclsk[which(eclsk$k!=j), "hipovnh"])
    eifEst[which(eifEst$k==j), "phat.x1.com"] <- predict(nhpov.mod.com, newdata = eclsk[which(eclsk$k==j), vars.schl.com])$pred
    eifEst[which(eifEst$k==j), "phat.x1.res"] <- predict(nhpov.mod.res, newdata = eclsk[which(eclsk$k==j), c(vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.ins"] <- predict(nhpov.mod.ins, newdata = eclsk[which(eclsk$k==j), c(vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.cli"] <- predict(nhpov.mod.cli, newdata = eclsk[which(eclsk$k==j), c(vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.efx"] <- predict(nhpov.mod.efx, newdata = eclsk[which(eclsk$k==j), vars.schl.all])$pred

    read.mod.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)

    read.mod.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.all)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta8"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.schl.all)],
      SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    eifEst[which(eifEst$k==j), "yhat.x1.rd.com"] <- predict(read.mod.com, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.rd.res"] <- predict(read.mod.res, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.rd.ins"] <- predict(read.mod.ins, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.rd.cli"] <- predict(read.mod.cli, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.rd.efx"] <- predict(read.mod.efx, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.all)])$pred
    
    eifEst[which(eifEst$k==j), "yhat.x1.mt.com"] <- predict(math.mod.com, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.mt.res"] <- predict(math.mod.res, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.mt.ins"] <- predict(math.mod.ins, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.mt.cli"] <- predict(math.mod.cli, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.mt.efx"] <- predict(math.mod.efx, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.schl.all)])$pred
 
    eclsk[which(eclsk$k!=j), "yhat.x1.rd.com"] <- predict(read.mod.com, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.rd.res"] <- predict(read.mod.res, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.rd.ins"] <- predict(read.mod.ins, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.rd.cli"] <- predict(read.mod.cli, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.rd.efx"] <- predict(read.mod.efx, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.all)])$pred

    eclsk[which(eclsk$k!=j), "yhat.x1.mt.com"] <- predict(math.mod.com, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.mt.res"] <- predict(math.mod.res, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.mt.ins"] <- predict(math.mod.ins, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.mt.cli"] <- predict(math.mod.cli, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.mt.efx"] <- predict(math.mod.efx, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.schl.all)])$pred
    
    eifEst[which(eifEst$k==j), "yhat.x1.x0.rd.com"] <- mean(eclsk$yhat.x1.rd.com[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.rd.res"] <- mean(eclsk$yhat.x1.rd.res[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.rd.ins"] <- mean(eclsk$yhat.x1.rd.ins[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.rd.cli"] <- mean(eclsk$yhat.x1.rd.cli[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.rd.efx"] <- mean(eclsk$yhat.x1.rd.efx[which(eclsk$k!=j & eclsk$hipovnh==0)])
    
    eifEst[which(eifEst$k==j), "yhat.x1.x0.mt.com"] <- mean(eclsk$yhat.x1.mt.com[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.mt.res"] <- mean(eclsk$yhat.x1.mt.res[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.mt.ins"] <- mean(eclsk$yhat.x1.mt.ins[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.mt.cli"] <- mean(eclsk$yhat.x1.mt.cli[which(eclsk$k!=j & eclsk$hipovnh==0)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.mt.efx"] <- mean(eclsk$yhat.x1.mt.efx[which(eclsk$k!=j & eclsk$hipovnh==0)])
  }

  # COMPUTE WEIGHTS #
  eifEst$wt.com[eifEst$hipovnh==1] <- censor(((1/(1-eifEst$phat.x1[eifEst$hipovnh==1]))*(1-eifEst$phat.x1.com[eifEst$hipovnh==1])/eifEst$phat.x1.com[eifEst$hipovnh==1]))
  eifEst$wt.res[eifEst$hipovnh==1] <- censor(((1/(1-eifEst$phat.x1[eifEst$hipovnh==1]))*(1-eifEst$phat.x1.res[eifEst$hipovnh==1])/eifEst$phat.x1.res[eifEst$hipovnh==1]))
  eifEst$wt.ins[eifEst$hipovnh==1] <- censor(((1/(1-eifEst$phat.x1[eifEst$hipovnh==1]))*(1-eifEst$phat.x1.ins[eifEst$hipovnh==1])/eifEst$phat.x1.ins[eifEst$hipovnh==1]))
  eifEst$wt.cli[eifEst$hipovnh==1] <- censor(((1/(1-eifEst$phat.x1[eifEst$hipovnh==1]))*(1-eifEst$phat.x1.cli[eifEst$hipovnh==1])/eifEst$phat.x1.cli[eifEst$hipovnh==1]))
  eifEst$wt.efx[eifEst$hipovnh==1] <- censor(((1/(1-eifEst$phat.x1[eifEst$hipovnh==1]))*(1-eifEst$phat.x1.efx[eifEst$hipovnh==1])/eifEst$phat.x1.efx[eifEst$hipovnh==1]))
  eifEst$wt.com[eifEst$hipovnh==0] <- eifEst$wt.res[eifEst$hipovnh==0] <- eifEst$wt.ins[eifEst$hipovnh==0] <- eifEst$wt.cli[eifEst$hipovnh==0] <- eifEst$wt.efx[eifEst$hipovnh==0] <- 0
  
  # COMPUTE SUMMAND OF EIF ESTIMATOR #
  eifEst$summand.rd.com <- eifEst$hipovnh * eifEst$wt.com * (eifEst$rdtheta8 - eifEst$yhat.x1.rd.com) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.rd.com - eifEst$yhat.x1.x0.rd.com) 
    + eifEst$yhat.x1.x0.rd.com
  
  eifEst$summand.rd.res <- eifEst$hipovnh * eifEst$wt.res * (eifEst$rdtheta8 - eifEst$yhat.x1.rd.res) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.rd.res - eifEst$yhat.x1.x0.rd.res) 
    + eifEst$yhat.x1.x0.rd.res
  
  eifEst$summand.rd.ins <- eifEst$hipovnh * eifEst$wt.ins * (eifEst$rdtheta8 - eifEst$yhat.x1.rd.ins) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.rd.ins - eifEst$yhat.x1.x0.rd.ins) 
    + eifEst$yhat.x1.x0.rd.ins
  
  eifEst$summand.rd.cli <- eifEst$hipovnh * eifEst$wt.cli * (eifEst$rdtheta8 - eifEst$yhat.x1.rd.cli) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.rd.cli - eifEst$yhat.x1.x0.rd.cli) 
    + eifEst$yhat.x1.x0.rd.cli
  
  eifEst$summand.rd.efx <- eifEst$hipovnh * eifEst$wt.efx * (eifEst$rdtheta8 - eifEst$yhat.x1.rd.efx) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.rd.efx - eifEst$yhat.x1.x0.rd.efx) 
    + eifEst$yhat.x1.x0.rd.efx

  eifEst$summand.mt.com <- eifEst$hipovnh * eifEst$wt.com * (eifEst$mththeta8 - eifEst$yhat.x1.mt.com) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.mt.com - eifEst$yhat.x1.x0.mt.com) 
    + eifEst$yhat.x1.x0.mt.com
  
  eifEst$summand.mt.res <- eifEst$hipovnh * eifEst$wt.res * (eifEst$mththeta8 - eifEst$yhat.x1.mt.res) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.mt.res - eifEst$yhat.x1.x0.mt.res) 
    + eifEst$yhat.x1.x0.mt.res
  
  eifEst$summand.mt.ins <- eifEst$hipovnh * eifEst$wt.ins * (eifEst$mththeta8 - eifEst$yhat.x1.mt.ins) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.mt.ins - eifEst$yhat.x1.x0.mt.ins) 
    + eifEst$yhat.x1.x0.mt.ins
  
  eifEst$summand.mt.cli <- eifEst$hipovnh * eifEst$wt.cli * (eifEst$mththeta8 - eifEst$yhat.x1.mt.cli) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.mt.cli - eifEst$yhat.x1.x0.mt.cli) 
    + eifEst$yhat.x1.x0.mt.cli
  
  eifEst$summand.mt.efx <- eifEst$hipovnh * eifEst$wt.efx * (eifEst$mththeta8 - eifEst$yhat.x1.mt.efx) 
    + (1-eifEst$hipovnh)/(1-eifEst$phat.x1) * (eifEst$yhat.x1.mt.efx - eifEst$yhat.x1.x0.mt.efx) 
    + eifEst$yhat.x1.x0.mt.efx
  
  # ESTIMATE DECOMP TERMS #
  delta.obs.rd <- muhat1.rd - muhat0.rd
  delta.com.rd <- muhat1.rd - mean(eifEst$summand.rd.com)
  delta.res.rd <- mean(eifEst$summand.rd.com) - mean(eifEst$summand.rd.res)
  delta.ins.rd <- mean(eifEst$summand.rd.res) - mean(eifEst$summand.rd.ins)
  delta.cli.rd <- mean(eifEst$summand.rd.ins) - mean(eifEst$summand.rd.cli)
  delta.efx.rd <- mean(eifEst$summand.rd.cli) - mean(eifEst$summand.rd.efx)
  delta.unx.rd <- mean(eifEst$summand.rd.efx) - muhat0.rd
  
  delta.obs.mt <- muhat1.mt - muhat0.mt
  delta.com.mt <- muhat1.mt - mean(eifEst$summand.mt.com)
  delta.res.mt <- mean(eifEst$summand.mt.com) - mean(eifEst$summand.mt.res)
  delta.ins.mt <- mean(eifEst$summand.mt.res) - mean(eifEst$summand.mt.ins)
  delta.cli.mt <- mean(eifEst$summand.mt.ins) - mean(eifEst$summand.mt.cli)
  delta.efx.mt <- mean(eifEst$summand.mt.cli) - mean(eifEst$summand.mt.efx)
  delta.unx.mt <- mean(eifEst$summand.mt.efx) - muhat0.mt
  
  # COMPUTE VAR OF DECOMP ESTIMATES #
  var.obs.rd <- lm_robust(rdtheta8~hipovnh, cluster=schlid, se_type="stata", data=eclsk)$std.error["hipovnh"]^2  
  var.com.rd <- lm_robust((rdtheta8 - summand.rd.com)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.res.rd <- lm_robust((summand.rd.com - summand.rd.res)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.ins.rd <- lm_robust((summand.rd.res - summand.rd.ins)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.cli.rd <- lm_robust((summand.rd.ins - summand.rd.cli)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.efx.rd <- lm_robust((summand.rd.cli - summand.rd.efx)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.unx.rd <- lm_robust((summand.rd.efx - rdtheta8)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  
  var.obs.mt <- lm_robust(mththeta8~hipovnh, cluster=schlid, se_type="stata", data=eclsk)$std.error["hipovnh"]^2  
  var.com.mt <- lm_robust((mththeta8 - summand.mt.com)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.res.mt <- lm_robust((summand.mt.com - summand.mt.res)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.ins.mt <- lm_robust((summand.mt.res - summand.mt.ins)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.cli.mt <- lm_robust((summand.mt.ins - summand.mt.cli)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.efx.mt <- lm_robust((summand.mt.cli - summand.mt.efx)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.unx.mt <- lm_robust((summand.mt.efx - mththeta8)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  
  return(
    list(
      delta.obs.rd, delta.com.rd, delta.res.rd, delta.ins.rd, delta.cli.rd, delta.efx.rd, delta.unx.rd,
      delta.obs.mt, delta.com.mt, delta.res.mt, delta.ins.mt, delta.cli.mt, delta.efx.mt, delta.unx.mt,
      var.obs.rd, var.com.rd, var.res.rd, var.ins.rd, var.cli.rd, var.efx.rd, var.unx.rd,
      var.obs.mt, var.com.mt, var.res.mt, var.ins.mt, var.cli.mt, var.efx.mt, var.unx.mt
    )
  )
}

stopCluster(my.cluster)
rm(my.cluster)

mi.results <- matrix(unlist(mi.results), ncol=28, byrow=TRUE)
miest.rd <- mi.results[, 1:7]
miest.mt <- mi.results[, 8:14]
mivar.rd <- mi.results[, 15:21] 
mivar.mt <- mi.results[, 22:28]

##### COMBINE MI ESTIMATES #####
est.rd.comb <- est.mt.comb <- matrix(data=NA, nrow=ncol(miest.rd), ncol=4)

for (i in 1:nrow(est.rd.comb)) {

  est.rd.comb[i,1]<-round(mean(miest.rd[,i]), digits=3)
  est.rd.comb[i,2]<-round(sqrt(mean(mivar.rd[,i]) + var(miest.rd[,i])*(1+(1/nmi))), digits=3)
  est.rd.comb[i,3]<-round(est.rd.comb[i,1]-1.96*est.rd.comb[i,2], digits=3)
  est.rd.comb[i,4]<-round(est.rd.comb[i,1]+1.96*est.rd.comb[i,2], digits=3)
  
  est.mt.comb[i,1]<-round(mean(miest.mt[,i]), digits=3)
  est.mt.comb[i,2]<-round(sqrt(mean(mivar.mt[,i]) + var(miest.mt[,i])*(1+(1/nmi))), digits=3)
  est.mt.comb[i,3]<-round(est.mt.comb[i,1]-1.96*est.mt.comb[i,2], digits=3)
  est.mt.comb[i,4]<-round(est.mt.comb[i,1]+1.96*est.mt.comb[i,2], digits=3)
}

rlabel<-c(
  "Observed Disparity",
  "Expl. by Composition",
  "Expl. by Resources",
  "Expl. by Instruction",
  "Expl. by Climate",
  "Expl. by Effectiveness",
  "Unexplained")

output.rd <- data.frame(est.rd.comb, row.names=rlabel)
output.mt <- data.frame(est.mt.comb, row.names=rlabel)

colnames(output.rd) <- colnames(output.mt) <- c('estimate', 'SE', 'll.pct.95ci', 'ul.pct.95ci')

##### PRINT RESULTS #####
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\24_create_figure_E1_log.txt")

cat("===========================================\n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
cat("Reading Test Scores\n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
print(output.rd)
cat(" \n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
cat("Math Test Scores\n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
print(output.mt)
cat(" \n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
cat("===========================================\n")

print(startTime)
print(Sys.time())

sink()

##### PLOT RESULTS #####
output.rd$label <- rownames(output.rd)
output.rd$label <- factor(output.rd$label, levels=rev(unique(output.rd$label)))

plot.rd <- 
  ggplot(output.rd, aes(y=label, x=estimate, xmin=ll.pct.95ci, xmax=ul.pct.95ci)) +
    geom_vline(xintercept=0, linetype="dashed", color="grey30") +
    geom_col(fill="grey60") +
    geom_errorbarh(height=0.2) +
    scale_x_continuous(limits=c(-0.6, 0.1), breaks=seq(-0.6, 0.1, 0.1), labels=function(x) format(round(x,2), nsmall=1, scientific=FALSE)) +
    labs(
      title="4th Grade Reading Scores",
      x="Standard Deviations",
      y=" ") +
    theme_bw()

output.mt$label <- rownames(output.mt)
output.mt$label <- factor(output.mt$label, levels=rev(unique(output.mt$label)))

plot.mt <- 
  ggplot(output.mt, aes(y=label, x=estimate, xmin=ll.pct.95ci, xmax=ul.pct.95ci)) +
    geom_vline(xintercept=0, linetype="dashed", color="grey30") +
    geom_col(fill="grey60") +
    geom_errorbarh(height=0.2) +
    scale_x_continuous(limits=c(-0.6, 0.1), breaks=seq(-0.6, 0.1, 0.1), labels=function(x) format(round(x,2), nsmall=1, scientific=FALSE)) +
    labs(
      title="4th Grade Math Scores",
      x="Standard Deviations",
      y=" ") +
    theme_bw()

jpeg("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_E1.jpeg", 
     height=5, 
     width=9,
     units='in',
     res=600)

grid.arrange(plot.rd, plot.mt, ncol=2)

dev.off()
