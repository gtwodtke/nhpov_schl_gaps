#################################################
#################################################
##                                             ##
## PROGRAM NAME: 40_create_table_H5            ##
##                                             ##
## PURPOSE: create table of estimates for the  ##
##          disparity eliminated among         ##
##          black students                     ##
##                                             ##
#################################################
#################################################

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

vars.base <- c(
  "rdtheta1",
  "mththeta1",
  "gender",
  #"drace_2",
  #"drace_3",
  #"drace_4",
  #"drace_5",
  "brthwt",
  "marbrth",
  "age1",
  "lang1",
  "hhtot1",
  "par1age1",
  "par2age1",
  "dpar1emp1_2",
  "dpar1emp1_3",
  "dpar2emp1_2",
  "dpar2emp1_3",
  "dx1locale_2",
  "dx1locale_3",
  "dx1locale_4",
  "dx1locale_5",
  "dx1region_2",
  "dx1region_3",
  "dx1region_4",
  "faminc2",
  "pared2",
  "parocc1",
  "wichh1",
  "fstmp1",
  "tanf1",
  "married1",
  "hhprnt1",
  "pprctnm1",
  "preadbk1",
  "p1exp1",
  "extrn1",
  "intrn1",
  "mtvt1",
  "cooper1",
  "attn1",
  "hlthscale1")

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
eclsk.mi$rdtheta7 <- (eclsk.mi$rdtheta7-mean(eclsk.mi$rdtheta7))/sqrt(var(eclsk.mi$rdtheta7))
eclsk.mi$mththeta7 <- (eclsk.mi$mththeta7-mean(eclsk.mi$mththeta7))/sqrt(var(eclsk.mi$mththeta7))

for (v in 1:length(vars.schl.all)) {
  eclsk.mi[, vars.schl.all[v]] <- as.numeric(eclsk.mi[, vars.schl.all[v]])
  eclsk.mi[, vars.schl.all[v]]<-(eclsk.mi[, vars.schl.all[v]]-mean(eclsk.mi[, vars.schl.all[v]]))/sqrt(var(eclsk.mi[, vars.schl.all[v]]))
}

eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

##### SELECT SUBSAMPLE #####
eclsk.mi <- eclsk.mi[which(eclsk.mi$drace_2==1),]

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
                "vars.base",
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
  
  ### ESTIMATE DISPARITY ELIMATED ###
  muhat0.rd <- mean(eclsk[which(eclsk$hipovnh==0), "rdtheta7"])
  muhat1.rd <- mean(eclsk[which(eclsk$hipovnh==1), "rdtheta7"])
  muhat0.mt <- mean(eclsk[which(eclsk$hipovnh==0), "mththeta7"])
  muhat1.mt <- mean(eclsk[which(eclsk$hipovnh==1), "mththeta7"])
  
  partitions <- eclsk %>% 
    distinct(schlid) %>%
    mutate(k = sample(1:kfolds, n(), replace=TRUE))
  
  eclsk <- eclsk %>%
    left_join(partitions, by="schlid")
  
  eclsk.x1 <- eclsk %>% mutate(hipovnh=1)
  eclsk.x0 <- eclsk %>% mutate(hipovnh=0)
  
  eifEst <- eclsk[, c(vars.meta, "k", "hipovnh", "rdtheta7", "mththeta7")]
  
  eifEst$phat.x1 <- eifEst$phat.x1.base <- eifEst$phat.x1.base.com <- eifEst$phat.x1.base.res <- eifEst$phat.x1.base.ins <- eifEst$phat.x1.base.cli <- eifEst$phat.x1.base.efx <- NA
  
  eifEst$yhat.x1.base.rd.com <- eifEst$yhat.x1.base.rd.res <- eifEst$yhat.x1.base.rd.ins <- eifEst$yhat.x1.base.rd.cli <- eifEst$yhat.x1.base.rd.efx <- NA
  eifEst$yhat.x1.base.mt.com <- eifEst$yhat.x1.base.mt.res <- eifEst$yhat.x1.base.mt.ins <- eifEst$yhat.x1.base.mt.cli <- eifEst$yhat.x1.base.mt.efx <- NA
  
  eifEst$yhat.x1.x0.base.rd.com <- eifEst$yhat.x1.x0.base.rd.res <- eifEst$yhat.x1.x0.base.rd.ins <- eifEst$yhat.x1.x0.base.rd.cli <- eifEst$yhat.x1.x0.base.rd.efx <- NA
  eifEst$yhat.x1.x0.base.mt.com <- eifEst$yhat.x1.x0.base.mt.res <- eifEst$yhat.x1.x0.base.mt.ins <- eifEst$yhat.x1.x0.base.mt.cli <- eifEst$yhat.x1.x0.base.mt.efx <- NA
  
  eifEst$yhat.x1.x0.base.x1.rd.com <- eifEst$yhat.x1.x0.base.x1.rd.res <- eifEst$yhat.x1.x0.base.x1.rd.ins <- eifEst$yhat.x1.x0.base.x1.rd.cli <- eifEst$yhat.x1.x0.base.x1.rd.efx <- NA
  eifEst$yhat.x1.x0.base.x1.mt.com <- eifEst$yhat.x1.x0.base.x1.mt.res <- eifEst$yhat.x1.x0.base.x1.mt.ins <- eifEst$yhat.x1.x0.base.x1.mt.cli <- eifEst$yhat.x1.x0.base.x1.mt.efx <- NA
  
  # INITIATE K-FOLD CROSS-FITTING #
  for (j in 1:kfolds) {

    nhpov.mod.base <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), vars.base],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.base.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.base, vars.schl.com)],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.base.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.base, vars.schl.com, vars.schl.res)],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.base.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.base.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    nhpov.mod.base.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "hipovnh"],
      X=eclsk[which(eclsk$k!=j), c(vars.base, vars.schl.all)],
      family = binomial(),
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.bin)
    
    eifEst[which(eifEst$k==j), "phat.x1"] <- mean(eclsk[which(eclsk$k!=j), "hipovnh"])
    eifEst[which(eifEst$k==j), "phat.x1.base"] <- predict(nhpov.mod.base, newdata = eclsk[which(eclsk$k==j), vars.base])$pred
    eifEst[which(eifEst$k==j), "phat.x1.base.com"] <- predict(nhpov.mod.base.com, newdata = eclsk[which(eclsk$k==j), c(vars.base, vars.schl.com)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.base.res"] <- predict(nhpov.mod.base.res, newdata = eclsk[which(eclsk$k==j), c(vars.base, vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.base.ins"] <- predict(nhpov.mod.base.ins, newdata = eclsk[which(eclsk$k==j), c(vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.base.cli"] <- predict(nhpov.mod.base.cli, newdata = eclsk[which(eclsk$k==j), c(vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "phat.x1.base.efx"] <- predict(nhpov.mod.base.efx, newdata = eclsk[which(eclsk$k==j), c(vars.base, vars.schl.all)])$pred
  
    read.mod.base.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.base.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.base.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.base.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    read.mod.base.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "rdtheta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.all)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.base.com <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.base.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.base.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.base.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    math.mod.base.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "mththeta7"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base, vars.schl.all)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    eifEst[which(eifEst$k==j), "yhat.x1.base.rd.com"] <- predict(read.mod.base.com, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.rd.res"] <- predict(read.mod.base.res, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.rd.ins"] <- predict(read.mod.base.ins, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.rd.cli"] <- predict(read.mod.base.cli, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.rd.efx"] <- predict(read.mod.base.efx, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.all)])$pred
    
    eifEst[which(eifEst$k==j), "yhat.x1.base.mt.com"] <- predict(math.mod.base.com, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.mt.res"] <- predict(math.mod.base.res, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.mt.ins"] <- predict(math.mod.base.ins, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.mt.cli"] <- predict(math.mod.base.cli, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.base.mt.efx"] <- predict(math.mod.base.efx, newdata = eclsk.x1[which(eclsk.x1$k==j), c("hipovnh", vars.base, vars.schl.all)])$pred
    
    eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.com"] <- predict(read.mod.base.com, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.res"] <- predict(read.mod.base.res, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.ins"] <- predict(read.mod.base.ins, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.cli"] <- predict(read.mod.base.cli, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.efx"] <- predict(read.mod.base.efx, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.all)])$pred
    
    eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.com"] <- predict(math.mod.base.com, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.res"] <- predict(math.mod.base.res, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.ins"] <- predict(math.mod.base.ins, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.cli"] <- predict(math.mod.base.cli, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.com, vars.schl.res, vars.schl.ins, vars.schl.cli)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.efx"] <- predict(math.mod.base.efx, newdata = eclsk.x1[which(eclsk.x1$k!=j), c("hipovnh", vars.base, vars.schl.all)])$pred
    
    e.read.mod.base.com<- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.com"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.read.mod.base.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.res"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.read.mod.base.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.ins"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.read.mod.base.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.cli"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)

    e.read.mod.base.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.rd.efx"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.math.mod.base.com<- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.com"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.math.mod.base.res <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.res"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.math.mod.base.ins <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.ins"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.math.mod.base.cli <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.cli"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    e.math.mod.base.efx <- SuperLearner(
      Y=eclsk[which(eclsk$k!=j), "yhat.x1.base.mt.efx"],
      X=eclsk[which(eclsk$k!=j), c("hipovnh", vars.base)],
      SL.library=c("SL.glmnet", "customRF_1", "customGBTree_1"),
      cvControl=cntrl.sl.cnt)
    
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.rd.com"] <- predict(e.read.mod.base.com, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.rd.res"] <- predict(e.read.mod.base.res, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.rd.ins"] <- predict(e.read.mod.base.ins, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.rd.cli"] <- predict(e.read.mod.base.cli, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.rd.efx"] <- predict(e.read.mod.base.efx, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.mt.com"] <- predict(e.math.mod.base.com, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.mt.res"] <- predict(e.math.mod.base.res, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.mt.ins"] <- predict(e.math.mod.base.ins, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.mt.cli"] <- predict(e.math.mod.base.cli, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.mt.efx"] <- predict(e.math.mod.base.efx, newdata = eclsk.x0[which(eclsk.x0$k==j), c("hipovnh", vars.base)])$pred
    
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.rd.com"] <- predict(e.read.mod.base.com, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.rd.res"] <- predict(e.read.mod.base.res, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.rd.ins"] <- predict(e.read.mod.base.ins, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.rd.cli"] <- predict(e.read.mod.base.cli, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.rd.efx"] <- predict(e.read.mod.base.efx, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.mt.com"] <- predict(e.math.mod.base.com, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.mt.res"] <- predict(e.math.mod.base.res, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.mt.ins"] <- predict(e.math.mod.base.ins, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.mt.cli"] <- predict(e.math.mod.base.cli, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred
    eclsk[which(eclsk$k!=j), "yhat.x1.x0.base.mt.efx"] <- predict(e.math.mod.base.efx, newdata = eclsk.x0[which(eclsk.x0$k!=j), c("hipovnh", vars.base)])$pred

    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.rd.com"] <- mean(eclsk$yhat.x1.x0.base.rd.com[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.rd.res"] <- mean(eclsk$yhat.x1.x0.base.rd.res[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.rd.ins"] <- mean(eclsk$yhat.x1.x0.base.rd.ins[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.rd.cli"] <- mean(eclsk$yhat.x1.x0.base.rd.cli[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.rd.efx"] <- mean(eclsk$yhat.x1.x0.base.rd.efx[which(eclsk$k!=j & eclsk$hipovnh==1)])
    
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.mt.com"] <- mean(eclsk$yhat.x1.x0.base.mt.com[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.mt.res"] <- mean(eclsk$yhat.x1.x0.base.mt.res[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.mt.ins"] <- mean(eclsk$yhat.x1.x0.base.mt.ins[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.mt.cli"] <- mean(eclsk$yhat.x1.x0.base.mt.cli[which(eclsk$k!=j & eclsk$hipovnh==1)])
    eifEst[which(eifEst$k==j), "yhat.x1.x0.base.x1.mt.efx"] <- mean(eclsk$yhat.x1.x0.base.mt.efx[which(eclsk$k!=j & eclsk$hipovnh==1)])    
  }

  # COMPUTE WEIGHTS #
  eifEst$wt1.com[eifEst$hipovnh==1] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==1]) * (eifEst$phat.x1.base[eifEst$hipovnh==1]/(1-eifEst$phat.x1.base[eifEst$hipovnh==1])) * ((1-eifEst$phat.x1.base.com[eifEst$hipovnh==1])/eifEst$phat.x1.base.com[eifEst$hipovnh==1]))
  eifEst$wt1.res[eifEst$hipovnh==1] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==1]) * (eifEst$phat.x1.base[eifEst$hipovnh==1]/(1-eifEst$phat.x1.base[eifEst$hipovnh==1])) * ((1-eifEst$phat.x1.base.res[eifEst$hipovnh==1])/eifEst$phat.x1.base.res[eifEst$hipovnh==1]))
  eifEst$wt1.ins[eifEst$hipovnh==1] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==1]) * (eifEst$phat.x1.base[eifEst$hipovnh==1]/(1-eifEst$phat.x1.base[eifEst$hipovnh==1])) * ((1-eifEst$phat.x1.base.ins[eifEst$hipovnh==1])/eifEst$phat.x1.base.ins[eifEst$hipovnh==1]))
  eifEst$wt1.cli[eifEst$hipovnh==1] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==1]) * (eifEst$phat.x1.base[eifEst$hipovnh==1]/(1-eifEst$phat.x1.base[eifEst$hipovnh==1])) * ((1-eifEst$phat.x1.base.cli[eifEst$hipovnh==1])/eifEst$phat.x1.base.cli[eifEst$hipovnh==1]))
  eifEst$wt1.efx[eifEst$hipovnh==1] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==1]) * (eifEst$phat.x1.base[eifEst$hipovnh==1]/(1-eifEst$phat.x1.base[eifEst$hipovnh==1])) * ((1-eifEst$phat.x1.base.efx[eifEst$hipovnh==1])/eifEst$phat.x1.base.efx[eifEst$hipovnh==1]))
  eifEst$wt1.com[eifEst$hipovnh==0] <- eifEst$wt1.res[eifEst$hipovnh==0] <- eifEst$wt1.ins[eifEst$hipovnh==0] <- eifEst$wt1.cli[eifEst$hipovnh==0] <- eifEst$wt1.efx[eifEst$hipovnh==0] <- 0
  
  eifEst$wt2[eifEst$hipovnh==0] <- censor((1/eifEst$phat.x1[eifEst$hipovnh==0]) * (eifEst$phat.x1.base[eifEst$hipovnh==0]/(1-eifEst$phat.x1.base[eifEst$hipovnh==0])))
  eifEst$wt2[eifEst$hipovnh==1] <- 0
  
  # COMPUTE SUMMAND OF EIF ESTIMATOR #
  eifEst$summand.rd.com <- (eifEst$hipovnh * eifEst$wt1.com * (eifEst$rdtheta7 - eifEst$yhat.x1.base.rd.com)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.rd.com - eifEst$yhat.x1.x0.base.rd.com)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.rd.com - eifEst$yhat.x1.x0.base.x1.rd.com)
    + eifEst$yhat.x1.x0.base.x1.rd.com)

  eifEst$summand.rd.res <- (eifEst$hipovnh * eifEst$wt1.res * (eifEst$rdtheta7 - eifEst$yhat.x1.base.rd.res)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.rd.res - eifEst$yhat.x1.x0.base.rd.res)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.rd.res - eifEst$yhat.x1.x0.base.x1.rd.res)
    + eifEst$yhat.x1.x0.base.x1.rd.res)
  
  eifEst$summand.rd.ins <- (eifEst$hipovnh * eifEst$wt1.ins * (eifEst$rdtheta7 - eifEst$yhat.x1.base.rd.ins)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.rd.ins - eifEst$yhat.x1.x0.base.rd.ins)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.rd.ins - eifEst$yhat.x1.x0.base.x1.rd.ins)
    + eifEst$yhat.x1.x0.base.x1.rd.ins)
  
  eifEst$summand.rd.cli <- (eifEst$hipovnh * eifEst$wt1.cli * (eifEst$rdtheta7 - eifEst$yhat.x1.base.rd.cli)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.rd.cli - eifEst$yhat.x1.x0.base.rd.cli)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.rd.cli - eifEst$yhat.x1.x0.base.x1.rd.cli)
    + eifEst$yhat.x1.x0.base.x1.rd.cli)
  
  eifEst$summand.rd.efx <- (eifEst$hipovnh * eifEst$wt1.efx * (eifEst$rdtheta7 - eifEst$yhat.x1.base.rd.efx)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.rd.efx - eifEst$yhat.x1.x0.base.rd.efx)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.rd.efx - eifEst$yhat.x1.x0.base.x1.rd.efx)
    + eifEst$yhat.x1.x0.base.x1.rd.efx)
  
  eifEst$summand.mt.com <- (eifEst$hipovnh * eifEst$wt1.com * (eifEst$mththeta7 - eifEst$yhat.x1.base.mt.com)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.mt.com - eifEst$yhat.x1.x0.base.mt.com)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.mt.com - eifEst$yhat.x1.x0.base.x1.mt.com)
    + eifEst$yhat.x1.x0.base.x1.mt.com)
  
  eifEst$summand.mt.res <- (eifEst$hipovnh * eifEst$wt1.res * (eifEst$mththeta7 - eifEst$yhat.x1.base.mt.res)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.mt.res - eifEst$yhat.x1.x0.base.mt.res)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.mt.res - eifEst$yhat.x1.x0.base.x1.mt.res)
    + eifEst$yhat.x1.x0.base.x1.mt.res)
  
  eifEst$summand.mt.ins <- (eifEst$hipovnh * eifEst$wt1.ins * (eifEst$mththeta7 - eifEst$yhat.x1.base.mt.ins)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.mt.ins - eifEst$yhat.x1.x0.base.mt.ins)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.mt.ins - eifEst$yhat.x1.x0.base.x1.mt.ins)
    + eifEst$yhat.x1.x0.base.x1.mt.ins)
  
  eifEst$summand.mt.cli <- (eifEst$hipovnh * eifEst$wt1.cli * (eifEst$mththeta7 - eifEst$yhat.x1.base.mt.cli)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.mt.cli - eifEst$yhat.x1.x0.base.mt.cli)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.mt.cli - eifEst$yhat.x1.x0.base.x1.mt.cli)
    + eifEst$yhat.x1.x0.base.x1.mt.cli)
  
  eifEst$summand.mt.efx <- (eifEst$hipovnh * eifEst$wt1.efx * (eifEst$mththeta7 - eifEst$yhat.x1.base.mt.efx)
    + (1-eifEst$hipovnh) * eifEst$wt2 * (eifEst$yhat.x1.base.mt.efx - eifEst$yhat.x1.x0.base.mt.efx)
    + (eifEst$hipovnh / eifEst$phat.x1) * (eifEst$yhat.x1.x0.base.mt.efx - eifEst$yhat.x1.x0.base.x1.mt.efx)
    + eifEst$yhat.x1.x0.base.x1.mt.efx)  
  
  # POINT ESTIMATES #
  delta.obs.rd <- muhat1.rd - muhat0.rd
  lambda.com.rd <- muhat1.rd - mean(eifEst$summand.rd.com)
  lambda.res.rd <- muhat1.rd - mean(eifEst$summand.rd.res)
  lambda.ins.rd <- muhat1.rd - mean(eifEst$summand.rd.ins)
  lambda.cli.rd <- muhat1.rd - mean(eifEst$summand.rd.cli)
  lambda.efx.rd <- muhat1.rd - mean(eifEst$summand.rd.efx)

  delta.obs.mt <- muhat1.mt - muhat0.mt
  lambda.com.mt <- muhat1.mt - mean(eifEst$summand.mt.com)
  lambda.res.mt <- muhat1.mt - mean(eifEst$summand.mt.res)
  lambda.ins.mt <- muhat1.mt - mean(eifEst$summand.mt.ins)
  lambda.cli.mt <- muhat1.mt - mean(eifEst$summand.mt.cli)
  lambda.efx.mt <- muhat1.mt - mean(eifEst$summand.mt.efx)

  # VARIANCE #
  var.obs.rd <- lm_robust(rdtheta7~hipovnh, cluster=schlid, se_type="stata", data=eclsk)$std.error["hipovnh"]^2  
  var.com.rd <- lm_robust((rdtheta7 - summand.rd.com)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.res.rd <- lm_robust((rdtheta7 - summand.rd.res)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.ins.rd <- lm_robust((rdtheta7 - summand.rd.ins)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.cli.rd <- lm_robust((rdtheta7 - summand.rd.cli)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.efx.rd <- lm_robust((rdtheta7 - summand.rd.efx)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  
  var.obs.mt <- lm_robust(mththeta7~hipovnh, cluster=schlid, se_type="stata", data=eclsk)$std.error["hipovnh"]^2  
  var.com.mt <- lm_robust((mththeta7 - summand.mt.com)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.res.mt <- lm_robust((mththeta7 - summand.mt.res)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.ins.mt <- lm_robust((mththeta7 - summand.mt.ins)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.cli.mt <- lm_robust((mththeta7 - summand.mt.cli)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  var.efx.mt <- lm_robust((mththeta7 - summand.mt.efx)~1, cluster=schlid, se_type="stata", data=eifEst)$std.error^2
  
  return(
    list(
      delta.obs.rd, lambda.com.rd, lambda.res.rd, lambda.ins.rd, lambda.cli.rd, lambda.efx.rd,
      delta.obs.mt, lambda.com.mt, lambda.res.mt, lambda.ins.mt, lambda.cli.mt, lambda.efx.mt,
      var.obs.rd, var.com.rd, var.res.rd, var.ins.rd, var.cli.rd, var.efx.rd,
      var.obs.mt, var.com.mt, var.res.mt, var.ins.mt, var.cli.mt, var.efx.mt
    )
  )
}

stopCluster(my.cluster)
rm(my.cluster)

mi.results <- matrix(unlist(mi.results), ncol=24, byrow=TRUE)
miest.rd <- mi.results[, 1:6]
miest.mt <- mi.results[, 7:12]
mivar.rd <- mi.results[, 13:18] 
mivar.mt <- mi.results[, 19:24]

##### COMBINE MI ESTIMATES #####
est.rd.comb <- est.mt.comb <- matrix(data=NA, nrow=ncol(miest.rd), ncol=5)

for (i in 1:nrow(est.rd.comb)) {
  
  est.rd.comb[i,1]<-round(mean(miest.rd[,i]), digits=3)
  est.rd.comb[i,2]<-round(sqrt(mean(mivar.rd[,i]) + var(miest.rd[,i])*(1+(1/nmi))), digits=3)
  est.rd.comb[i,3]<-round(est.rd.comb[i,1]-1.96*est.rd.comb[i,2], digits=3)
  est.rd.comb[i,4]<-round(est.rd.comb[i,1]+1.96*est.rd.comb[i,2], digits=3)
  est.rd.comb[i,5]<-round(est.rd.comb[i,1]/est.rd.comb[1,1], digits=2)
  
  est.mt.comb[i,1]<-round(mean(miest.mt[,i]), digits=3)
  est.mt.comb[i,2]<-round(sqrt(mean(mivar.mt[,i]) + var(miest.mt[,i])*(1+(1/nmi))), digits=3)
  est.mt.comb[i,3]<-round(est.mt.comb[i,1]-1.96*est.mt.comb[i,2], digits=3)
  est.mt.comb[i,4]<-round(est.mt.comb[i,1]+1.96*est.mt.comb[i,2], digits=3)
  est.mt.comb[i,5]<-round(est.mt.comb[i,1]/est.mt.comb[1,1], digits=2)
}

rlabel<-c(
  "Observed Gap",
  "Elim. by Com",
  "Elim. by Res",
  "Elim. by Ins",
  "Elim. by Cli",
  "Elim. by Efx")

output.rd <- data.frame(est.rd.comb, row.names=rlabel)
output.mt <- data.frame(est.mt.comb, row.names=rlabel)

colnames(output.rd) <- colnames(output.mt) <- c('estimate', 'SE', 'll.pct.95ci', 'ul.pct.95ci', "prop.elim")

##### PRINT RESULTS #####
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\40_create_table_H5_log.txt")

cat("===========================================\n")
cat("BLACK STUDENTS\n")
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


