#################################################
#################################################
##                                             ##
## PROGRAM NAME: 35_create_figure_G2           ##
##                                             ##
## PURPOSE: create figure of estimates for     ##
##          post-intv gaps in math scores      ##
##          after marginal equalization of     ##
##          schl characteristics               ##
##                                             ##
#################################################
#################################################

##### LOAD LIBRARIES #####
rm(list=ls())

list.of.packages <- c(
  "haven",
  "foreign",
  "rsample",
  "splines",
  "survey",
  "ranger",
  "xgboost",
  "rlang",
  "glmnet",
  "kernlab",
  "nnet",
  "caret",
  "KernSmooth",
  "mgcv",
  "tidyverse",
  "SuperLearner",
  "estimatr",
  "janitor",
  "foreach",
  "doParallel",
  "doRNG")

for(package.i in list.of.packages) {
  suppressPackageStartupMessages(library(package.i, character.only = TRUE))
}

source("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\zmisc.R")

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
nsim <- 100
nperm <- 5

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
  "drace_2",
  "drace_3",
  "drace_4",
  "drace_5",
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

##### ADD/RECODE VARIABLES ######
eclsk.mi$mththeta7 <- (eclsk.mi$mththeta7-mean(eclsk.mi$mththeta7))/sqrt(var(eclsk.mi$mththeta7))

for (v in 1:length(vars.schl.all)) {
  eclsk.mi[, vars.schl.all[v]] <- as.numeric(eclsk.mi[, vars.schl.all[v]])
  eclsk.mi[, vars.schl.all[v]]<-(eclsk.mi[, vars.schl.all[v]]-mean(eclsk.mi[, vars.schl.all[v]]))/sqrt(var(eclsk.mi[, vars.schl.all[v]]))
}

for (v in 1:length(vars.base)) {
  eclsk.mi[, vars.base[v]] <- as.numeric(eclsk.mi[, vars.base[v]])
}

eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

eclsk.mi$weight<-1

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

##### DEFINE CENSORING FUNCTION #####
censor <- function(x, low=0.01, high=0.99) {
  min <- quantile(x, low)
  max <- quantile(x, high)
  
  x[x<min] <- min
  x[x>max] <- max
  
  x
}

##### PARALLELIZATION #####
my.cluster <- parallel::makeCluster(ncores, type="PSOCK")
doParallel::registerDoParallel(cl=my.cluster)
foreach::getDoParRegistered()
registerDoRNG(60637)

clusterEvalQ(cl=my.cluster, {
  library(SuperLearner)
  library(dplyr)
  library(janitor)
  library(survey)
  library(rsample)
  library(tidyverse)
  library(rlang)
  library(caret)
})

clusterExport(cl=my.cluster,
  list(
    "eclsk.mi",
    "kfolds",
    "nsim",
    "nperm",
    "censor",
    "cntrl.sl.bin",
    "cntrl.sl.cnt",
    "customRF_1",
    "customGBTree_1"),
  envir=environment()
)

##### COMPUTE DML ESTIMATES: EQUALIZING COMPOSITION ######
mi.results.com <- foreach(m=1:nmi, .combine=cbind) %dopar% {
  
  ### DEFINE INPUTS ###
  df <- eclsk.mi[which(eclsk.mi$minum==m),]

  x <- expr(hipovnh)

  cc <- exprs(
    rdtheta1,
    mththeta1,
    gender,
    drace_2,
    drace_3,
    drace_4,
    drace_5,
    brthwt,
    marbrth,
    age1,
    lang1,
    hhtot1,
    par1age1,
    par2age1,
    dpar1emp1_2,
    dpar1emp1_3,
    dpar2emp1_2,
    dpar2emp1_3,
    dx1locale_2,
    dx1locale_3,
    dx1locale_4,
    dx1locale_5,
    dx1region_2,
    dx1region_3,
    dx1region_4,
    faminc2,
    pared2,
    parocc1,
    wichh1,
    fstmp1,
    tanf1,
    married1,
    hhprnt1,
    pprctnm1,
    preadbk1,
    p1exp1,
    extrn1,
    intrn1,
    mtvt1,
    cooper1,
    attn1,
    hlthscale1)

  s <- exprs(
    sblk4,
    stotell4,
    sfrlnch4,
    sgif4,
    shspnc4,
    sspced4,
    swht4,
    pgender4,
    prace4,
    tgender4,
    trace4)

  y <- expr(mththeta7)

  ### DEFINE FORMULAS ###
  x_c_form  <- as.formula(paste(x, " ~ ", paste(c(cc), collapse= "+")))
  x_cs_form <- as.formula(paste(x, " ~ ", paste(c(cc, s), collapse= "+")))
  y_xcs_form <- as.formula(paste(y, " ~ ", paste(c(x, cc, s), collapse= "+")))
  pm_cs_form <- as.formula(paste("permuted ~ ", paste(c(cc, s), collapse= "+")))

  ### DEFINE DESIGN MATRICES ###
  df_c <- model.matrix(x_c_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_cs <- model.matrix(x_cs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_xcs <- model.matrix(y_xcs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()

  ### CREATE K FOLDS FOR CROSS-FITTING ###
  schools <- unique(df$schlid)
  schl_fold <- createFolds(schools, kfolds)
  cf_fold <- lapply(schl_fold, function(school_idx) {which(df$schlid %in% schools[school_idx])})
  main_list <- vector(mode = "list", kfolds)

  ### INITIATE CROSS-FITTING ###
  for (k in 1:kfolds) {
  
    cat(" cross-fitting fold ", k, "\n")
  
    aux <- df[-cf_fold[[k]], ]
  
    aux_c <- model.matrix(x_c_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_cs <- model.matrix(x_cs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_xcs <- model.matrix(y_xcs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
  
    ## FIT OUTCOME MODEL ##
    y_xcs_sl <- SuperLearner(
      Y          = aux[[deparse(y)]],
      X          = aux_xcs,
      family     = gaussian(),
      obsWeights = aux$weight,
      SL.library = c("SL.lm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE),
      cvControl  = cntrl.sl.cnt
    )

    ## ESTIMATE E[Y|X, C, S] ##
    df$Ey_xcs <- predict(y_xcs_sl, newdata = df_xcs)$pred
  
    ## REGRESSION SIMULATION ##
    df_s_x0 <- df %>% filter(!!x == 0) %>% dplyr::select(!!!s, weight)
    df_xc <- df %>% dplyr::select(!!x, !!!cc)
  
    ri_mat <- matrix(NA, nrow(df), nsim) 

    for (i in 1:nsim) {
    
      if (i %% 10 == 0) cat(" Monte Carlo Sample ", i, "\n")
    
      indices <- sample(nrow(df_s_x0), nrow(df_xc), replace = TRUE, prob = df_s_x0$weight)
    
      df_xc_intvS <- bind_cols(df_xc, df_s_x0[indices, ]) %>% dplyr::select(-weight) %>% clean_names()
    
      ri_mat[, i] <- predict(y_xcs_sl, newdata = df_xc_intvS)$pred
    }
  
    df$ri_est <- rowMeans(ri_mat)

    ## FIT GROUP MODELS ##
    x_c_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_c,
      newX       = df_c,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
  
    x_cs_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_cs,
      newX       = df_cs,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
  
    ## ESTIMATE P(X=1|C) AND P(X=1|C, S)
    df$Ex_c <- x_c_sl$SL.predict
    df$Ex_cs <- x_cs_sl$SL.predict
  
    ## PERMUTATION WEIGHTING ##
    aux_c_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!cc)
    aux_s_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!s)
    aux_original_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0) %>% mutate(permuted = 0)
  
    pw_mat <- matrix(NA, nrow(df_cs), nperm)
  
    for (j in 1:nperm) {
    
      cat(" permutation ", j, "\n")
    
      indices <- sample(nrow(aux_s_x0), replace = FALSE) 
    
      aux_permuated_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0[indices, ]) %>% mutate(permuted = 1)
    
      aux_pw_df <- bind_rows(aux_original_cs_x0, aux_permuated_cs_x0)
    
      aux_pw_cs <- model.matrix(pm_cs_form, data = aux_pw_df)[, -1] %>% as_tibble()
    
      pw_sl <-  SuperLearner(
        Y          = aux_pw_df$permuted,
        X          = aux_pw_cs,
        newX       = df_cs,
        family     = binomial(),
        SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
        control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
        cvControl  = cntrl.sl.bin
      )
    
      pw_mat[, j] <- pw_sl$SL.predict/(1 - pw_sl$SL.predict)
    }

    df$wg_A <- rowMeans(pw_mat)
  
    main_list[[k]] <- df[cf_fold[[k]], ]
  }

  ## COLLATE ESTIMATES ##
  main_df <- reduce(main_list, bind_rows) %>% 
    mutate(
      wg_B = Ex_c/(1 - Ex_c) * (1 - Ex_cs)/Ex_cs,
      wg = ifelse(!!x == 1, censor(wg_A * wg_B), 1),
      rEIF = ifelse(!!x == 1, (wg * (!!y - Ey_xcs) + ri_est), !!y)
    )

  design_main <- svydesign(ids = ~ schlid, data = main_df, weights = ~ weight)

  y_x_form  <- as.formula(paste(y, " ~ ", x))
  dml_y_x_form <- as.formula(paste("rEIF ~ ", x))

  obs <- svyglm(y_x_form, design_main)
  intv_dml <- svyglm(dml_y_x_form, design = design_main)

  delta.obs <- obs$coefficients[[2]]
  delta.intv <- intv_dml$coefficients[[2]]

  var.obs <- obs$cov.unscaled[2,2]  
  var.intv <- intv_dml$cov.unscaled[2,2]

  return(
    list(
      delta.obs, delta.intv, 
      var.obs, var.intv
    )
  )
}

mi.results.com <- matrix(unlist(mi.results.com), ncol=4, byrow=TRUE)
miest.com <- mi.results.com[, 1:2]
mivar.com <- mi.results.com[, 3:4] 

## COMBINE MI ESTIMATES ##
est.comb.com <- matrix(data=NA, nrow=ncol(miest.com), ncol=4)

for (i in 1:nrow(est.comb.com)) {
  
  est.comb.com[i,1]<-round(mean(miest.com[,i]), digits=3)
  est.comb.com[i,2]<-round(sqrt(mean(mivar.com[,i]) + var(miest.com[,i])*(1+(1/nmi))), digits=3)
  est.comb.com[i,3]<-round(est.comb.com[i,1]-1.96*est.comb.com[i,2], digits=3)
  est.comb.com[i,4]<-round(est.comb.com[i,1]+1.96*est.comb.com[i,2], digits=3)
}

##### COMPUTE DML ESTIMATES: EQUALIZING THROUGH RESOURCES ######
mi.results.res <- foreach(m=1:nmi, .combine=cbind) %dopar% {
  
  ### DEFINE INPUTS ###
  df <- eclsk.mi[which(eclsk.mi$minum==m),]
  
  x <- expr(hipovnh)
  
  cc <- exprs(
    rdtheta1,
    mththeta1,
    gender,
    drace_2,
    drace_3,
    drace_4,
    drace_5,
    brthwt,
    marbrth,
    age1,
    lang1,
    hhtot1,
    par1age1,
    par2age1,
    dpar1emp1_2,
    dpar1emp1_3,
    dpar2emp1_2,
    dpar2emp1_3,
    dx1locale_2,
    dx1locale_3,
    dx1locale_4,
    dx1locale_5,
    dx1region_2,
    dx1region_3,
    dx1region_4,
    faminc2,
    pared2,
    parocc1,
    wichh1,
    fstmp1,
    tanf1,
    married1,
    hhprnt1,
    pprctnm1,
    preadbk1,
    p1exp1,
    extrn1,
    intrn1,
    mtvt1,
    cooper1,
    attn1,
    hlthscale1)
  
  s <- exprs(
    sblk4,
    stotell4,
    sfrlnch4,
    sgif4,
    shspnc4,
    sspced4,
    swht4,
    pgender4,
    prace4,
    tgender4,
    trace4,
    strg_pp_4,
    ccd_dstr_exppp4,
    start_pp_4,
    stesl_pp_4,
    stgft_pp_4,
    stgym_pp_4,
    stcmp_pp_4,
    stlib_pp_4,
    stnrs_pp_4,
    stpar_pp_4,
    pyrspr4,
    pyrstch4,
    stfpsy_pp_4,
    stsp_pp_4,
    tyrsch4,
    sttrn4,
    tyrstch4,
    ped4,
    sartok4,
    saudok4,
    scafeok4,
    sclssok4,
    scompok4,
    sgymok4,
    slibok4,
    smultok4,
    smusok4,
    splayok4,
    sfnddc4,
    shighgrd4,
    slowgrd4,
    sstffdec4,
    sstfffrz4,
    sstffinc4,
    strnsl4,
    stype4,
    syrrnd4,
    tcrt4,
    tnexm4,
    ted4)
  
  y <- expr(mththeta7)
  
  ### DEFINE FORMULAS ###
  x_c_form  <- as.formula(paste(x, " ~ ", paste(c(cc), collapse= "+")))
  x_cs_form <- as.formula(paste(x, " ~ ", paste(c(cc, s), collapse= "+")))
  y_xcs_form <- as.formula(paste(y, " ~ ", paste(c(x, cc, s), collapse= "+")))
  pm_cs_form <- as.formula(paste("permuted ~ ", paste(c(cc, s), collapse= "+")))
  
  ### DEFINE DESIGN MATRICES ###
  df_c <- model.matrix(x_c_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_cs <- model.matrix(x_cs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_xcs <- model.matrix(y_xcs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  
  ### CREATE K FOLDS FOR CROSS-FITTING ###
  schools <- unique(df$schlid)
  schl_fold <- createFolds(schools, kfolds)
  cf_fold <- lapply(schl_fold, function(school_idx) {which(df$schlid %in% schools[school_idx])})
  main_list <- vector(mode = "list", kfolds)
  
  ### INITIATE CROSS-FITTING ###
  for (k in 1:kfolds) {
    
    cat(" cross-fitting fold ", k, "\n")
    
    aux <- df[-cf_fold[[k]], ]
    
    aux_c <- model.matrix(x_c_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_cs <- model.matrix(x_cs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_xcs <- model.matrix(y_xcs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    
    ## FIT OUTCOME MODEL ##
    y_xcs_sl <- SuperLearner(
      Y          = aux[[deparse(y)]],
      X          = aux_xcs,
      family     = gaussian(),
      obsWeights = aux$weight,
      SL.library = c("SL.lm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE),
      cvControl  = cntrl.sl.cnt
    )
    
    ## ESTIMATE E[Y|X, C, S] ##
    df$Ey_xcs <- predict(y_xcs_sl, newdata = df_xcs)$pred
    
    ## REGRESSION SIMULATION ##
    df_s_x0 <- df %>% filter(!!x == 0) %>% dplyr::select(!!!s, weight)
    df_xc <- df %>% dplyr::select(!!x, !!!cc)
    
    ri_mat <- matrix(NA, nrow(df), nsim) 
    
    for (i in 1:nsim) {
      
      if (i %% 10 == 0) cat(" Monte Carlo Sample ", i, "\n")
      
      indices <- sample(nrow(df_s_x0), nrow(df_xc), replace = TRUE, prob = df_s_x0$weight)
      
      df_xc_intvS <- bind_cols(df_xc, df_s_x0[indices, ]) %>% dplyr::select(-weight) %>% clean_names()
      
      ri_mat[, i] <- predict(y_xcs_sl, newdata = df_xc_intvS)$pred
    }
    
    df$ri_est <- rowMeans(ri_mat)
    
    ## FIT GROUP MODELS ##
    x_c_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_c,
      newX       = df_c,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    x_cs_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_cs,
      newX       = df_cs,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    ## ESTIMATE P(X=1|C) AND P(X=1|C, S)
    df$Ex_c <- x_c_sl$SL.predict
    df$Ex_cs <- x_cs_sl$SL.predict
    
    ## PERMUTATION WEIGHTING ##
    aux_c_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!cc)
    aux_s_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!s)
    aux_original_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0) %>% mutate(permuted = 0)
    
    pw_mat <- matrix(NA, nrow(df_cs), nperm)
    
    for (j in 1:nperm) {
      
      cat(" permutation ", j, "\n")
      
      indices <- sample(nrow(aux_s_x0), replace = FALSE) 
      
      aux_permuated_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0[indices, ]) %>% mutate(permuted = 1)
      
      aux_pw_df <- bind_rows(aux_original_cs_x0, aux_permuated_cs_x0)
      
      aux_pw_cs <- model.matrix(pm_cs_form, data = aux_pw_df)[, -1] %>% as_tibble()
      
      pw_sl <-  SuperLearner(
        Y          = aux_pw_df$permuted,
        X          = aux_pw_cs,
        newX       = df_cs,
        family     = binomial(),
        SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
        control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
        cvControl  = cntrl.sl.bin
      )
      
      pw_mat[, j] <- pw_sl$SL.predict/(1 - pw_sl$SL.predict)
    }
    
    df$wg_A <- rowMeans(pw_mat)
    
    main_list[[k]] <- df[cf_fold[[k]], ]
  }
  
  ## COLLATE ESTIMATES ##
  main_df <- reduce(main_list, bind_rows) %>% 
    mutate(
      wg_B = Ex_c/(1 - Ex_c) * (1 - Ex_cs)/Ex_cs,
      wg = ifelse(!!x == 1, censor(wg_A * wg_B), 1),
      rEIF = ifelse(!!x == 1, (wg * (!!y - Ey_xcs) + ri_est), !!y)
    )
  
  design_main <- svydesign(ids = ~ schlid, data = main_df, weights = ~ weight)
  
  dml_y_x_form <- as.formula(paste("rEIF ~ ", x))
  
  intv_dml <- svyglm(dml_y_x_form, design = design_main)
  
  delta.intv <- intv_dml$coefficients[[2]]
  
  var.intv <- intv_dml$cov.unscaled[2,2]
  
  return(
    list(
      delta.intv, var.intv
    )
  )
}

mi.results.res <- matrix(unlist(mi.results.res), ncol=2, byrow=TRUE)
miest.res <- mi.results.res[, 1]
mivar.res <- mi.results.res[, 2] 

## COMBINE MI ESTIMATES ##
est.comb.res <- matrix(data=NA, nrow=1, ncol=4)

for (i in 1:nrow(est.comb.res)) {
  
  est.comb.res[1]<-round(mean(miest.res), digits=3)
  est.comb.res[2]<-round(sqrt(mean(mivar.res) + var(miest.res)*(1+(1/nmi))), digits=3)
  est.comb.res[3]<-round(est.comb.res[1]-1.96*est.comb.res[2], digits=3)
  est.comb.res[4]<-round(est.comb.res[1]+1.96*est.comb.res[2], digits=3)
}

##### COMPUTE DML ESTIMATES: EQUALIZING THROUGH INSTRUCTION ######
mi.results.ins <- foreach(m=1:nmi, .combine=cbind) %dopar% {
  
  ### DEFINE INPUTS ###
  df <- eclsk.mi[which(eclsk.mi$minum==m),]
  
  x <- expr(hipovnh)
  
  cc <- exprs(
    rdtheta1,
    mththeta1,
    gender,
    drace_2,
    drace_3,
    drace_4,
    drace_5,
    brthwt,
    marbrth,
    age1,
    lang1,
    hhtot1,
    par1age1,
    par2age1,
    dpar1emp1_2,
    dpar1emp1_3,
    dpar2emp1_2,
    dpar2emp1_3,
    dx1locale_2,
    dx1locale_3,
    dx1locale_4,
    dx1locale_5,
    dx1region_2,
    dx1region_3,
    dx1region_4,
    faminc2,
    pared2,
    parocc1,
    wichh1,
    fstmp1,
    tanf1,
    married1,
    hhprnt1,
    pprctnm1,
    preadbk1,
    p1exp1,
    extrn1,
    intrn1,
    mtvt1,
    cooper1,
    attn1,
    hlthscale1)
  
  s <- exprs(
    sblk4,
    stotell4,
    sfrlnch4,
    sgif4,
    shspnc4,
    sspced4,
    swht4,
    pgender4,
    prace4,
    tgender4,
    trace4,
    strg_pp_4,
    ccd_dstr_exppp4,
    start_pp_4,
    stesl_pp_4,
    stgft_pp_4,
    stgym_pp_4,
    stcmp_pp_4,
    stlib_pp_4,
    stnrs_pp_4,
    stpar_pp_4,
    pyrspr4,
    pyrstch4,
    stfpsy_pp_4,
    stsp_pp_4,
    tyrsch4,
    sttrn4,
    tyrstch4,
    ped4,
    sartok4,
    saudok4,
    scafeok4,
    sclssok4,
    scompok4,
    sgymok4,
    slibok4,
    smultok4,
    smusok4,
    splayok4,
    sfnddc4,
    shighgrd4,
    slowgrd4,
    sstffdec4,
    sstfffrz4,
    sstffinc4,
    strnsl4,
    stype4,
    syrrnd4,
    tcrt4,
    tnexm4,
    ted4,
    tevlbhv4,
    tevlcoop4,
    tevldir4,
    tevleff4,
    tevlimp4,
    tevlpart4,
    tevlclss4,
    tevlstd4,
    tevlprj4,
    tevlqz4,
    tevlwrksh4,
    tevlwrksa4,
    thw4,
    a4usebsl4,
    a4uselev4,
    a4usenew4,
    a4usekit4,
    a4usecmp4,
    a4usetrd4,
    a4useoth4,
    a4useman4,
    a4usebgbk4,
    a4usedecb4,
    a4useaubk4,
    a4useanth4,
    a4mainid4,
    a4retell4,
    a4deschar4,
    a4senses4,
    a4whotell4,
    a4maintext4,
    a4reassup4,
    a4simdiff4,
    a4ficnonf4,
    a4cmpxinf4,
    a4cmpxpro4,
    a4segword4,
    a4manpho4,
    a4sndwrd4,
    a4irregwd4,
    a4paceint4,
    a4rdaccr4,
    a4useglos4,
    a4senctxt4,
    a4charplot4,
    a4gencsp4,
    a4predict4,
    a4opinion4,
    a4infpiec4,
    a4narrtv4,
    a4cnt20qty4,
    a4relqty4,
    a4slvadsb4,
    a4slvadd34,
    a4ctadsub4,
    a4eqlsign4,
    a4sidequa4,
    a4slvuknm4,
    a4cnt1204,
    a4nmrl1204,
    a4numqty4,
    a4tenones4,
    a4relsym4,
    a4addto1004,
    a4find104,
    a4skipcnt4,
    a4arr3obj4,
    a4lng2by34,
    a4lngmult4,
    a4meatool4,
    a4estlng4,
    a4telltime4,
    a4wrttime4,
    a4slvcoin4,
    a4drwgrph4,
    a4ansgrph4,
    a4attrshp4,
    a4dimcomp4,
    a4parteql4,
    a4triquad4,
    tord4,
    tomth4,
    ttrd4,
    ttmth4,
    ttsgrp4,
    ttlgrp4,
    ttindv4,
    ttpeer4,
    tevltst4,
    tachrd4,
    tachmth4)
  
  y <- expr(mththeta7)
  
  ### DEFINE FORMULAS ###
  x_c_form  <- as.formula(paste(x, " ~ ", paste(c(cc), collapse= "+")))
  x_cs_form <- as.formula(paste(x, " ~ ", paste(c(cc, s), collapse= "+")))
  y_xcs_form <- as.formula(paste(y, " ~ ", paste(c(x, cc, s), collapse= "+")))
  pm_cs_form <- as.formula(paste("permuted ~ ", paste(c(cc, s), collapse= "+")))
  
  ### DEFINE DESIGN MATRICES ###
  df_c <- model.matrix(x_c_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_cs <- model.matrix(x_cs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_xcs <- model.matrix(y_xcs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  
  ### CREATE K FOLDS FOR CROSS-FITTING ###
  schools <- unique(df$schlid)
  schl_fold <- createFolds(schools, kfolds)
  cf_fold <- lapply(schl_fold, function(school_idx) {which(df$schlid %in% schools[school_idx])})
  main_list <- vector(mode = "list", kfolds)
  
  ### INITIATE CROSS-FITTING ###
  for (k in 1:kfolds) {
    
    cat(" cross-fitting fold ", k, "\n")
    
    aux <- df[-cf_fold[[k]], ]
    
    aux_c <- model.matrix(x_c_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_cs <- model.matrix(x_cs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_xcs <- model.matrix(y_xcs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    
    ## FIT OUTCOME MODEL ##
    y_xcs_sl <- SuperLearner(
      Y          = aux[[deparse(y)]],
      X          = aux_xcs,
      family     = gaussian(),
      obsWeights = aux$weight,
      SL.library = c("SL.lm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE),
      cvControl  = cntrl.sl.cnt
    )
    
    ## ESTIMATE E[Y|X, C, S] ##
    df$Ey_xcs <- predict(y_xcs_sl, newdata = df_xcs)$pred
    
    ## REGRESSION SIMULATION ##
    df_s_x0 <- df %>% filter(!!x == 0) %>% dplyr::select(!!!s, weight)
    df_xc <- df %>% dplyr::select(!!x, !!!cc)
    
    ri_mat <- matrix(NA, nrow(df), nsim) 
    
    for (i in 1:nsim) {
      
      if (i %% 10 == 0) cat(" Monte Carlo Sample ", i, "\n")
      
      indices <- sample(nrow(df_s_x0), nrow(df_xc), replace = TRUE, prob = df_s_x0$weight)
      
      df_xc_intvS <- bind_cols(df_xc, df_s_x0[indices, ]) %>% dplyr::select(-weight) %>% clean_names()
      
      ri_mat[, i] <- predict(y_xcs_sl, newdata = df_xc_intvS)$pred
    }
    
    df$ri_est <- rowMeans(ri_mat)
    
    ## FIT GROUP MODELS ##
    x_c_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_c,
      newX       = df_c,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    x_cs_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_cs,
      newX       = df_cs,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    ## ESTIMATE P(X=1|C) AND P(X=1|C, S)
    df$Ex_c <- x_c_sl$SL.predict
    df$Ex_cs <- x_cs_sl$SL.predict
    
    ## PERMUTATION WEIGHTING ##
    aux_c_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!cc)
    aux_s_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!s)
    aux_original_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0) %>% mutate(permuted = 0)
    
    pw_mat <- matrix(NA, nrow(df_cs), nperm)
    
    for (j in 1:nperm) {
      
      cat(" permutation ", j, "\n")
      
      indices <- sample(nrow(aux_s_x0), replace = FALSE) 
      
      aux_permuated_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0[indices, ]) %>% mutate(permuted = 1)
      
      aux_pw_df <- bind_rows(aux_original_cs_x0, aux_permuated_cs_x0)
      
      aux_pw_cs <- model.matrix(pm_cs_form, data = aux_pw_df)[, -1] %>% as_tibble()
      
      pw_sl <-  SuperLearner(
        Y          = aux_pw_df$permuted,
        X          = aux_pw_cs,
        newX       = df_cs,
        family     = binomial(),
        SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
        control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
        cvControl  = cntrl.sl.bin
      )
      
      pw_mat[, j] <- pw_sl$SL.predict/(1 - pw_sl$SL.predict)
    }
    
    df$wg_A <- rowMeans(pw_mat)
    
    main_list[[k]] <- df[cf_fold[[k]], ]
  }
  
  ## COLLATE ESTIMATES ##
  main_df <- reduce(main_list, bind_rows) %>% 
    mutate(
      wg_B = Ex_c/(1 - Ex_c) * (1 - Ex_cs)/Ex_cs,
      wg = ifelse(!!x == 1, censor(wg_A * wg_B), 1),
      rEIF = ifelse(!!x == 1, (wg * (!!y - Ey_xcs) + ri_est), !!y)
    )
  
  design_main <- svydesign(ids = ~ schlid, data = main_df, weights = ~ weight)
  
  dml_y_x_form <- as.formula(paste("rEIF ~ ", x))
  
  intv_dml <- svyglm(dml_y_x_form, design = design_main)
  
  delta.intv <- intv_dml$coefficients[[2]]
  
  var.intv <- intv_dml$cov.unscaled[2,2]
  
  return(
    list(
      delta.intv, var.intv
    )
  )
}

mi.results.ins <- matrix(unlist(mi.results.ins), ncol=2, byrow=TRUE)
miest.ins <- mi.results.ins[, 1]
mivar.ins <- mi.results.ins[, 2] 

## COMBINE MI ESTIMATES ##
est.comb.ins <- matrix(data=NA, nrow=1, ncol=4)

for (i in 1:nrow(est.comb.ins)) {
  
  est.comb.ins[1]<-round(mean(miest.ins), digits=3)
  est.comb.ins[2]<-round(sqrt(mean(mivar.ins) + var(miest.ins)*(1+(1/nmi))), digits=3)
  est.comb.ins[3]<-round(est.comb.ins[1]-1.96*est.comb.ins[2], digits=3)
  est.comb.ins[4]<-round(est.comb.ins[1]+1.96*est.comb.ins[2], digits=3)
}

##### COMPUTE DML ESTIMATES: EQUALIZING THROUGH CLIMATE ######
mi.results.cli <- foreach(m=1:nmi, .combine=cbind) %dopar% {
  
  ### DEFINE INPUTS ###
  df <- eclsk.mi[which(eclsk.mi$minum==m),]
  
  x <- expr(hipovnh)
  
  cc <- exprs(
    rdtheta1,
    mththeta1,
    gender,
    drace_2,
    drace_3,
    drace_4,
    drace_5,
    brthwt,
    marbrth,
    age1,
    lang1,
    hhtot1,
    par1age1,
    par2age1,
    dpar1emp1_2,
    dpar1emp1_3,
    dpar2emp1_2,
    dpar2emp1_3,
    dx1locale_2,
    dx1locale_3,
    dx1locale_4,
    dx1locale_5,
    dx1region_2,
    dx1region_3,
    dx1region_4,
    faminc2,
    pared2,
    parocc1,
    wichh1,
    fstmp1,
    tanf1,
    married1,
    hhprnt1,
    pprctnm1,
    preadbk1,
    p1exp1,
    extrn1,
    intrn1,
    mtvt1,
    cooper1,
    attn1,
    hlthscale1)
  
  s <- exprs(
    sblk4,
    stotell4,
    sfrlnch4,
    sgif4,
    shspnc4,
    sspced4,
    swht4,
    pgender4,
    prace4,
    tgender4,
    trace4,
    strg_pp_4,
    ccd_dstr_exppp4,
    start_pp_4,
    stesl_pp_4,
    stgft_pp_4,
    stgym_pp_4,
    stcmp_pp_4,
    stlib_pp_4,
    stnrs_pp_4,
    stpar_pp_4,
    pyrspr4,
    pyrstch4,
    stfpsy_pp_4,
    stsp_pp_4,
    tyrsch4,
    sttrn4,
    tyrstch4,
    ped4,
    sartok4,
    saudok4,
    scafeok4,
    sclssok4,
    scompok4,
    sgymok4,
    slibok4,
    smultok4,
    smusok4,
    splayok4,
    sfnddc4,
    shighgrd4,
    slowgrd4,
    sstffdec4,
    sstfffrz4,
    sstffinc4,
    strnsl4,
    stype4,
    syrrnd4,
    tcrt4,
    tnexm4,
    ted4,
    tevlbhv4,
    tevlcoop4,
    tevldir4,
    tevleff4,
    tevlimp4,
    tevlpart4,
    tevlclss4,
    tevlstd4,
    tevlprj4,
    tevlqz4,
    tevlwrksh4,
    tevlwrksa4,
    thw4,
    a4usebsl4,
    a4uselev4,
    a4usenew4,
    a4usekit4,
    a4usecmp4,
    a4usetrd4,
    a4useoth4,
    a4useman4,
    a4usebgbk4,
    a4usedecb4,
    a4useaubk4,
    a4useanth4,
    a4mainid4,
    a4retell4,
    a4deschar4,
    a4senses4,
    a4whotell4,
    a4maintext4,
    a4reassup4,
    a4simdiff4,
    a4ficnonf4,
    a4cmpxinf4,
    a4cmpxpro4,
    a4segword4,
    a4manpho4,
    a4sndwrd4,
    a4irregwd4,
    a4paceint4,
    a4rdaccr4,
    a4useglos4,
    a4senctxt4,
    a4charplot4,
    a4gencsp4,
    a4predict4,
    a4opinion4,
    a4infpiec4,
    a4narrtv4,
    a4cnt20qty4,
    a4relqty4,
    a4slvadsb4,
    a4slvadd34,
    a4ctadsub4,
    a4eqlsign4,
    a4sidequa4,
    a4slvuknm4,
    a4cnt1204,
    a4nmrl1204,
    a4numqty4,
    a4tenones4,
    a4relsym4,
    a4addto1004,
    a4find104,
    a4skipcnt4,
    a4arr3obj4,
    a4lng2by34,
    a4lngmult4,
    a4meatool4,
    a4estlng4,
    a4telltime4,
    a4wrttime4,
    a4slvcoin4,
    a4drwgrph4,
    a4ansgrph4,
    a4attrshp4,
    a4dimcomp4,
    a4parteql4,
    a4triquad4,
    tord4,
    tomth4,
    ttrd4,
    ttmth4,
    ttsgrp4,
    ttlgrp4,
    ttindv4,
    ttpeer4,
    tevltst4,
    tachrd4,
    tachmth4,
    saenc4,
    sapri4,
    sprnpar4,
    tbhvr4,
    sdsrd4,
    sspprt4,
    sacns4,
    sblly4,
    scnfl4,
    sthft4,
    sptcnf4,
    spsupp4,
    tacpt4,
    tlstd4,
    tenjy4,
    tmkdff4,
    tideas4,
    tppwrk4,
    tstfrec4,
    tmssn4,
    tchstch4,
    sattnd4,
    ststinf4,
    srptcrd4)
  
  y <- expr(mththeta7)
  
  ### DEFINE FORMULAS ###
  x_c_form  <- as.formula(paste(x, " ~ ", paste(c(cc), collapse= "+")))
  x_cs_form <- as.formula(paste(x, " ~ ", paste(c(cc, s), collapse= "+")))
  y_xcs_form <- as.formula(paste(y, " ~ ", paste(c(x, cc, s), collapse= "+")))
  pm_cs_form <- as.formula(paste("permuted ~ ", paste(c(cc, s), collapse= "+")))
  
  ### DEFINE DESIGN MATRICES ###
  df_c <- model.matrix(x_c_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_cs <- model.matrix(x_cs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_xcs <- model.matrix(y_xcs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  
  ### CREATE K FOLDS FOR CROSS-FITTING ###
  schools <- unique(df$schlid)
  schl_fold <- createFolds(schools, kfolds)
  cf_fold <- lapply(schl_fold, function(school_idx) {which(df$schlid %in% schools[school_idx])})
  main_list <- vector(mode = "list", kfolds)
  
  ### INITIATE CROSS-FITTING ###
  for (k in 1:kfolds) {
    
    cat(" cross-fitting fold ", k, "\n")
    
    aux <- df[-cf_fold[[k]], ]
    
    aux_c <- model.matrix(x_c_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_cs <- model.matrix(x_cs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_xcs <- model.matrix(y_xcs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    
    ## FIT OUTCOME MODEL ##
    y_xcs_sl <- SuperLearner(
      Y          = aux[[deparse(y)]],
      X          = aux_xcs,
      family     = gaussian(),
      obsWeights = aux$weight,
      SL.library = c("SL.lm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE),
      cvControl  = cntrl.sl.cnt
    )
    
    ## ESTIMATE E[Y|X, C, S] ##
    df$Ey_xcs <- predict(y_xcs_sl, newdata = df_xcs)$pred
    
    ## REGRESSION SIMULATION ##
    df_s_x0 <- df %>% filter(!!x == 0) %>% dplyr::select(!!!s, weight)
    df_xc <- df %>% dplyr::select(!!x, !!!cc)
    
    ri_mat <- matrix(NA, nrow(df), nsim) 
    
    for (i in 1:nsim) {
      
      if (i %% 10 == 0) cat(" Monte Carlo Sample ", i, "\n")
      
      indices <- sample(nrow(df_s_x0), nrow(df_xc), replace = TRUE, prob = df_s_x0$weight)
      
      df_xc_intvS <- bind_cols(df_xc, df_s_x0[indices, ]) %>% dplyr::select(-weight) %>% clean_names()
      
      ri_mat[, i] <- predict(y_xcs_sl, newdata = df_xc_intvS)$pred
    }
    
    df$ri_est <- rowMeans(ri_mat)
    
    ## FIT GROUP MODELS ##
    x_c_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_c,
      newX       = df_c,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    x_cs_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_cs,
      newX       = df_cs,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    ## ESTIMATE P(X=1|C) AND P(X=1|C, S)
    df$Ex_c <- x_c_sl$SL.predict
    df$Ex_cs <- x_cs_sl$SL.predict
    
    ## PERMUTATION WEIGHTING ##
    aux_c_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!cc)
    aux_s_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!s)
    aux_original_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0) %>% mutate(permuted = 0)
    
    pw_mat <- matrix(NA, nrow(df_cs), nperm)
    
    for (j in 1:nperm) {
      
      cat(" permutation ", j, "\n")
      
      indices <- sample(nrow(aux_s_x0), replace = FALSE) 
      
      aux_permuated_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0[indices, ]) %>% mutate(permuted = 1)
      
      aux_pw_df <- bind_rows(aux_original_cs_x0, aux_permuated_cs_x0)
      
      aux_pw_cs <- model.matrix(pm_cs_form, data = aux_pw_df)[, -1] %>% as_tibble()
      
      pw_sl <-  SuperLearner(
        Y          = aux_pw_df$permuted,
        X          = aux_pw_cs,
        newX       = df_cs,
        family     = binomial(),
        SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
        control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
        cvControl  = cntrl.sl.bin
      )
      
      pw_mat[, j] <- pw_sl$SL.predict/(1 - pw_sl$SL.predict)
    }
    
    df$wg_A <- rowMeans(pw_mat)
    
    main_list[[k]] <- df[cf_fold[[k]], ]
  }
  
  ## COLLATE ESTIMATES ##
  main_df <- reduce(main_list, bind_rows) %>% 
    mutate(
      wg_B = Ex_c/(1 - Ex_c) * (1 - Ex_cs)/Ex_cs,
      wg = ifelse(!!x == 1, censor(wg_A * wg_B), 1),
      rEIF = ifelse(!!x == 1, (wg * (!!y - Ey_xcs) + ri_est), !!y)
    )
  
  design_main <- svydesign(ids = ~ schlid, data = main_df, weights = ~ weight)
  
  dml_y_x_form <- as.formula(paste("rEIF ~ ", x))
  
  intv_dml <- svyglm(dml_y_x_form, design = design_main)
  
  delta.intv <- intv_dml$coefficients[[2]]
  
  var.intv <- intv_dml$cov.unscaled[2,2]
  
  return(
    list(
      delta.intv, var.intv
    )
  )
}

mi.results.cli <- matrix(unlist(mi.results.cli), ncol=2, byrow=TRUE)
miest.cli <- mi.results.cli[, 1]
mivar.cli <- mi.results.cli[, 2] 

## COMBINE MI ESTIMATES ##
est.comb.cli <- matrix(data=NA, nrow=1, ncol=4)

for (i in 1:nrow(est.comb.cli)) {
  
  est.comb.cli[1]<-round(mean(miest.cli), digits=3)
  est.comb.cli[2]<-round(sqrt(mean(mivar.cli) + var(miest.cli)*(1+(1/nmi))), digits=3)
  est.comb.cli[3]<-round(est.comb.cli[1]-1.96*est.comb.cli[2], digits=3)
  est.comb.cli[4]<-round(est.comb.cli[1]+1.96*est.comb.cli[2], digits=3)
}

##### COMPUTE DML ESTIMATES: EQUALIZING ALL SCHL CHARACTERISTICS ######
mi.results.efx <- foreach(m=1:nmi, .combine=cbind) %dopar% {
  
  ### DEFINE INPUTS ###
  df <- eclsk.mi[which(eclsk.mi$minum==m),]
  
  x <- expr(hipovnh)
  
  cc <- exprs(
    rdtheta1,
    mththeta1,
    gender,
    drace_2,
    drace_3,
    drace_4,
    drace_5,
    brthwt,
    marbrth,
    age1,
    lang1,
    hhtot1,
    par1age1,
    par2age1,
    dpar1emp1_2,
    dpar1emp1_3,
    dpar2emp1_2,
    dpar2emp1_3,
    dx1locale_2,
    dx1locale_3,
    dx1locale_4,
    dx1locale_5,
    dx1region_2,
    dx1region_3,
    dx1region_4,
    faminc2,
    pared2,
    parocc1,
    wichh1,
    fstmp1,
    tanf1,
    married1,
    hhprnt1,
    pprctnm1,
    preadbk1,
    p1exp1,
    extrn1,
    intrn1,
    mtvt1,
    cooper1,
    attn1,
    hlthscale1)
  
  s <- exprs(
    sblk4,
    stotell4,
    sfrlnch4,
    sgif4,
    shspnc4,
    sspced4,
    swht4,
    pgender4,
    prace4,
    tgender4,
    trace4,
    strg_pp_4,
    ccd_dstr_exppp4,
    start_pp_4,
    stesl_pp_4,
    stgft_pp_4,
    stgym_pp_4,
    stcmp_pp_4,
    stlib_pp_4,
    stnrs_pp_4,
    stpar_pp_4,
    pyrspr4,
    pyrstch4,
    stfpsy_pp_4,
    stsp_pp_4,
    tyrsch4,
    sttrn4,
    tyrstch4,
    ped4,
    sartok4,
    saudok4,
    scafeok4,
    sclssok4,
    scompok4,
    sgymok4,
    slibok4,
    smultok4,
    smusok4,
    splayok4,
    sfnddc4,
    shighgrd4,
    slowgrd4,
    sstffdec4,
    sstfffrz4,
    sstffinc4,
    strnsl4,
    stype4,
    syrrnd4,
    tcrt4,
    tnexm4,
    ted4,
    tevlbhv4,
    tevlcoop4,
    tevldir4,
    tevleff4,
    tevlimp4,
    tevlpart4,
    tevlclss4,
    tevlstd4,
    tevlprj4,
    tevlqz4,
    tevlwrksh4,
    tevlwrksa4,
    thw4,
    a4usebsl4,
    a4uselev4,
    a4usenew4,
    a4usekit4,
    a4usecmp4,
    a4usetrd4,
    a4useoth4,
    a4useman4,
    a4usebgbk4,
    a4usedecb4,
    a4useaubk4,
    a4useanth4,
    a4mainid4,
    a4retell4,
    a4deschar4,
    a4senses4,
    a4whotell4,
    a4maintext4,
    a4reassup4,
    a4simdiff4,
    a4ficnonf4,
    a4cmpxinf4,
    a4cmpxpro4,
    a4segword4,
    a4manpho4,
    a4sndwrd4,
    a4irregwd4,
    a4paceint4,
    a4rdaccr4,
    a4useglos4,
    a4senctxt4,
    a4charplot4,
    a4gencsp4,
    a4predict4,
    a4opinion4,
    a4infpiec4,
    a4narrtv4,
    a4cnt20qty4,
    a4relqty4,
    a4slvadsb4,
    a4slvadd34,
    a4ctadsub4,
    a4eqlsign4,
    a4sidequa4,
    a4slvuknm4,
    a4cnt1204,
    a4nmrl1204,
    a4numqty4,
    a4tenones4,
    a4relsym4,
    a4addto1004,
    a4find104,
    a4skipcnt4,
    a4arr3obj4,
    a4lng2by34,
    a4lngmult4,
    a4meatool4,
    a4estlng4,
    a4telltime4,
    a4wrttime4,
    a4slvcoin4,
    a4drwgrph4,
    a4ansgrph4,
    a4attrshp4,
    a4dimcomp4,
    a4parteql4,
    a4triquad4,
    tord4,
    tomth4,
    ttrd4,
    ttmth4,
    ttsgrp4,
    ttlgrp4,
    ttindv4,
    ttpeer4,
    tevltst4,
    tachrd4,
    tachmth4,
    saenc4,
    sapri4,
    sprnpar4,
    tbhvr4,
    sdsrd4,
    sspprt4,
    sacns4,
    sblly4,
    scnfl4,
    sthft4,
    sptcnf4,
    spsupp4,
    tacpt4,
    tlstd4,
    tenjy4,
    tmkdff4,
    tideas4,
    tppwrk4,
    tstfrec4,
    tmssn4,
    tchstch4,
    sattnd4,
    ststinf4,
    srptcrd4,
    rdvaladd,
    mtvaladd)
  
  y <- expr(mththeta7)
  
  ### DEFINE FORMULAS ###
  x_c_form  <- as.formula(paste(x, " ~ ", paste(c(cc), collapse= "+")))
  x_cs_form <- as.formula(paste(x, " ~ ", paste(c(cc, s), collapse= "+")))
  y_xcs_form <- as.formula(paste(y, " ~ ", paste(c(x, cc, s), collapse= "+")))
  pm_cs_form <- as.formula(paste("permuted ~ ", paste(c(cc, s), collapse= "+")))
  
  ### DEFINE DESIGN MATRICES ###
  df_c <- model.matrix(x_c_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_cs <- model.matrix(x_cs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  df_xcs <- model.matrix(y_xcs_form, data = df)[, -1] %>% as_tibble() %>% clean_names()
  
  ### CREATE K FOLDS FOR CROSS-FITTING ###
  schools <- unique(df$schlid)
  schl_fold <- createFolds(schools, kfolds)
  cf_fold <- lapply(schl_fold, function(school_idx) {which(df$schlid %in% schools[school_idx])})
  main_list <- vector(mode = "list", kfolds)
  
  ### INITIATE CROSS-FITTING ###
  for (k in 1:kfolds) {
    
    cat(" cross-fitting fold ", k, "\n")
    
    aux <- df[-cf_fold[[k]], ]
    
    aux_c <- model.matrix(x_c_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_cs <- model.matrix(x_cs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    aux_xcs <- model.matrix(y_xcs_form, data = aux)[, -1] %>% as_tibble() %>% clean_names()
    
    ## FIT OUTCOME MODEL ##
    y_xcs_sl <- SuperLearner(
      Y          = aux[[deparse(y)]],
      X          = aux_xcs,
      family     = gaussian(),
      obsWeights = aux$weight,
      SL.library = c("SL.lm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE),
      cvControl  = cntrl.sl.cnt
    )
    
    ## ESTIMATE E[Y|X, C, S] ##
    df$Ey_xcs <- predict(y_xcs_sl, newdata = df_xcs)$pred
    
    ## REGRESSION SIMULATION ##
    df_s_x0 <- df %>% filter(!!x == 0) %>% dplyr::select(!!!s, weight)
    df_xc <- df %>% dplyr::select(!!x, !!!cc)
    
    ri_mat <- matrix(NA, nrow(df), nsim) 
    
    for (i in 1:nsim) {
      
      if (i %% 10 == 0) cat(" Monte Carlo Sample ", i, "\n")
      
      indices <- sample(nrow(df_s_x0), nrow(df_xc), replace = TRUE, prob = df_s_x0$weight)
      
      df_xc_intvS <- bind_cols(df_xc, df_s_x0[indices, ]) %>% dplyr::select(-weight) %>% clean_names()
      
      ri_mat[, i] <- predict(y_xcs_sl, newdata = df_xc_intvS)$pred
    }
    
    df$ri_est <- rowMeans(ri_mat)
    
    ## FIT GROUP MODELS ##
    x_c_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_c,
      newX       = df_c,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    x_cs_sl <- SuperLearner(
      Y          = aux[[deparse(x)]],
      X          = aux_cs,
      newX       = df_cs,
      family     = binomial(),
      obsWeights = aux$weight,
      SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
      control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
      cvControl  = cntrl.sl.bin
    )
    
    ## ESTIMATE P(X=1|C) AND P(X=1|C, S)
    df$Ex_c <- x_c_sl$SL.predict
    df$Ex_cs <- x_cs_sl$SL.predict
    
    ## PERMUTATION WEIGHTING ##
    aux_c_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!cc)
    aux_s_x0 <- aux %>% filter(!!x == 0) %>% dplyr::select(!!!s)
    aux_original_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0) %>% mutate(permuted = 0)
    
    pw_mat <- matrix(NA, nrow(df_cs), nperm)
    
    for (j in 1:nperm) {
      
      cat(" permutation ", j, "\n")
      
      indices <- sample(nrow(aux_s_x0), replace = FALSE) 
      
      aux_permuated_cs_x0 <- bind_cols(aux_c_x0, aux_s_x0[indices, ]) %>% mutate(permuted = 1)
      
      aux_pw_df <- bind_rows(aux_original_cs_x0, aux_permuated_cs_x0)
      
      aux_pw_cs <- model.matrix(pm_cs_form, data = aux_pw_df)[, -1] %>% as_tibble()
      
      pw_sl <-  SuperLearner(
        Y          = aux_pw_df$permuted,
        X          = aux_pw_cs,
        newX       = df_cs,
        family     = binomial(),
        SL.library = c("SL.glm", "customRF_1", "customGBTree_1"),
        control    = list(saveFitLibrary = TRUE, trimLogit = 0.001),
        cvControl  = cntrl.sl.bin
      )
      
      pw_mat[, j] <- pw_sl$SL.predict/(1 - pw_sl$SL.predict)
    }
    
    df$wg_A <- rowMeans(pw_mat)
    
    main_list[[k]] <- df[cf_fold[[k]], ]
  }
  
  ## COLLATE ESTIMATES ##
  main_df <- reduce(main_list, bind_rows) %>% 
    mutate(
      wg_B = Ex_c/(1 - Ex_c) * (1 - Ex_cs)/Ex_cs,
      wg = ifelse(!!x == 1, censor(wg_A * wg_B), 1),
      rEIF = ifelse(!!x == 1, (wg * (!!y - Ey_xcs) + ri_est), !!y)
    )
  
  design_main <- svydesign(ids = ~ schlid, data = main_df, weights = ~ weight)
  
  dml_y_x_form <- as.formula(paste("rEIF ~ ", x))
  
  intv_dml <- svyglm(dml_y_x_form, design = design_main)
  
  delta.intv <- intv_dml$coefficients[[2]]
  
  var.intv <- intv_dml$cov.unscaled[2,2]
  
  return(
    list(
      delta.intv, var.intv
    )
  )
}

mi.results.efx <- matrix(unlist(mi.results.efx), ncol=2, byrow=TRUE)
miest.efx <- mi.results.efx[, 1]
mivar.efx <- mi.results.efx[, 2] 

## COMBINE MI ESTIMATES ##
est.comb.efx <- matrix(data=NA, nrow=1, ncol=4)

for (i in 1:nrow(est.comb.efx)) {
  
  est.comb.efx[1]<-round(mean(miest.efx), digits=3)
  est.comb.efx[2]<-round(sqrt(mean(mivar.efx) + var(miest.efx)*(1+(1/nmi))), digits=3)
  est.comb.efx[3]<-round(est.comb.efx[1]-1.96*est.comb.efx[2], digits=3)
  est.comb.efx[4]<-round(est.comb.efx[1]+1.96*est.comb.efx[2], digits=3)
}

stopCluster(my.cluster)
rm(my.cluster)

##### COLLATE ALL ESTIMATES #####
est.collated <- rbind(
  est.comb.com, 
  est.comb.res,
  est.comb.ins,
  est.comb.cli,
  est.comb.efx)

rlabel<-c(
  "Observed Disparity",
  "(1): Disp. after Eq. Composition",
  "(2): (1) + Eq. Resources",
  "(3): (2) + Eq. Instruction",
  "(4): (3) + Eq. Climate",
  "(5): (4) + Eq. Effectiveness")

output <- data.frame(est.collated, row.names=rlabel)
colnames(output) <- c('estimate', 'SE', 'll.pct.95ci', 'ul.pct.95ci')

##### PRINT RESULTS #####
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\35_create_figure_G2_log.txt")

cat("===========================================\n")
cat("SUPER LEARNER\n")
cat("===========================================\n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
cat("Reading Test Scores\n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
print(output)
cat(" \n")
cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
cat("===========================================\n")

print(startTime)
print(Sys.time())

sink()

##### PLOT RESULTS #####
output$label <- rownames(output)
output$label <- factor(output$label, levels=unique(output$label))

plot.rd <- 
  ggplot(output, aes(x=label, y=estimate, ymin=ll.pct.95ci, ymax=ul.pct.95ci)) +
  geom_hline(yintercept=0, linetype="dashed", color="grey30") +
  geom_col(fill="grey60") +
  geom_errorbar(width=0.2) +
  scale_y_continuous(limits=c(-0.6, 0.0), breaks=seq(-0.6, 0.0, 0.1), labels=function(x) format(round(x,2), nsmall=1, scientific=FALSE)) +
  labs(
    title="Math Scores",
    x=" ",
    y="Standard Deviations") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) 
  

ggsave("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_G2.jpeg", height=5, width=4.5, dpi=600)

