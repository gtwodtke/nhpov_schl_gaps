################################################
################################################
##                                            ##
## PROGRAM NAME: 17_create_figure_8           ##
## AUTHOR: GW                                 ##
## DESCRIPTION:                               ##
##                                            ##
##  create plot of std diffs against          ##
##  marginal effects                          ##
##                                            ##
################################################
################################################

rm(list=ls())

list.of.packages <- c(
  "foreach",
  "doParallel",
  "doRNG",
  "sys",
  "haven",
  "foreign",
  "dplyr",
  "tidyr",
  "tidyverse",
  "ggplot2",
  "ranger",
  "caret",
  "xgboost",
  "e1071",
  "SuperLearner",
  "dotwhisker",
  "gridExtra",
  "ggrepel",
  "Hmisc")

for(package.i in list.of.packages) {
  suppressPackageStartupMessages(library(package.i, character.only = TRUE))
}

startTime<-Sys.time()
set.seed(60637)

##### LOAD ECLS-K #####
eclsk.mi <- read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi <- as.data.frame(eclsk.mi[which(eclsk.mi$minum!=0),])
eclsk.mi <- eclsk.mi[order(eclsk.mi$childid, eclsk.mi$minum),]

##### SET SCRIPT PARAMETERS #####
nmi <- 5
RFtrees <- 200
GBtrees <- 100

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

vars.schl.num <- c(
  "sblk4",
  "stotell4",
  "sfrlnch4",
  "sgif4",
  "shspnc4",
  "sspced4",
  "swht4",
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
  "tyrstch4",
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
  "tachmth4",
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
  "srptcrd4",
  "rdvaladd",
  "mtvaladd")

vars.schl.cat <- c(
  "pgender4",
  "prace4",
  "tgender4",
  "trace4",
  "sttrn4",
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

##### DEFINE VARIABLE LABELS #####
labels.schl.num <- c(
  "% Black",
  "% ELL",
  "% Free lunch",
  "% Gifted",
  "% Hispanic",
  "% Spec ed",
  "% White",
  "Classrm tchrs/stdnt",
  "Expenditures/stdnt",
  "Elect tchrs/stdnt",
  "ESL tchrs/stdnt",
  "G&T tchrs/stdnt",
  "Gym tchrs/stdnt",
  "IT tchrs/stdnt",
  "Librarians/stdnt",
  "Nurses/stdnt",
  "Paraprofs/stdnt",
  "Prcpl tenure",
  "Prcpl yrs exp",
  "Psychs/stdnt",
  "Spec ed tchrs/stdnt",
  "Tchr tenure",
  "Tchr yrs exp",
  "Eval behavior",
  "Eval co-op",
  "Eval directions",
  "Eval effort",
  "Eval improvement",
  "Eval particip",
  "Eval relatively",
  "Eval standards",
  "Freq projects",
  "Freq quizzes",
  "Freq worksheets",
  "Freq wrk samples",
  "Homework/wk",
  "Rd basal series",
  "Rd leveled",
  "Rd news/mags",
  "Rd kits",
  "Rd computer",
  "Rd trade books",
  "Rd other",
  "Rd manipulatvs",
  "Rd big books",
  "Rd decodables",
  "Rd audiobooks",
  "Rd anthology",
  "Rd main id stry",
  "Rd retelling",
  "Rd characters",
  "Rd feelings",
  "Rd narrator",
  "Rd main id inf",
  "Rd evidence",
  "Rd sim/diff",
  "Rd fic/nonfic",
  "Rd info text",
  "Rd poetry",
  "Rd word seg",
  "Rd form words",
  "Rd blend snds",
  "Rd irreg spl",
  "Rd pace",
  "Rd accuracy",
  "Rd glossaries",
  "Rd sen context",
  "Rd char/plot",
  "Rd char Qs",
  "Rd predict",
  "Wrt opinion",
  "Wrt info",
  "Wrt narrative",
  "Mth count 20",
  "Mth rel quant",
  "Mth word probs.",
  "Mth add by 3s",
  "Mth add/sub",
  "Mth equal sign",
  "Mth equations",
  "Mth solve #",
  "Mth count 120",
  "Mth rd/wrt nums",
  "Mth # vs quant",
  "Mth 10s/1s plc",
  "Mth symbols",
  "Mth sum to 100",
  "Mth add/sub 10",
  "Mth skip count",
  "Mth length",
  "Mth comp lngth",
  "Mth msr lngth",
  "Mth msr tool",
  "Mth est lngth",
  "Mth tell time",
  "Mth write time",
  "Mth $ probs",
  "Mth draw graph",
  "Mth use graph",
  "Mth shp attrib",
  "Mth shp togthr",
  "Mth shp part",
  "Mth shp names",
  "Rd days/wk",
  "Mth days/wk",
  "Rd hrs/day",
  "Mth hrs/day",
  "Sml grp hrs/day",
  "Lrg grp hrs/day",
  "Ind act hrs/day",
  "Peers hrs/day",
  "Eval std tests",
  "Rd grp days/wk",
  "Mth grp days/wk",
  "Admin encouraging",
  "Admin sets priorities",
  "Freq admin-parent mtgs",
  "Class behaves",
  "Class disorder",
  "Community support",
  "Consensus exp",
  "Freq bullying",
  "Freq fights",
  "Freq theft",
  "Freq parent-tchr confs",
  "Parental support",
  "Tchr accepted",
  "Schl has low stds",
  "Tchr enjoys job",
  "Tchr makes diff",
  "Admin welcomes ideas",
  "Too much paperwork",
  "Faculty recognized",
  "Aligned on mission",
  "Tchr teach again",
  "Attendance",
  "Freq test info",
  "Freq report cards",
  "Rd-value add", 
  "Mth-value add")

labels.schl.cat <- c(
  "Prcpl male",
  "Prcpl white",
  "Tchr male",
  "Tchr white",
  "Tchr turnover",
  "Prcpl PhD/EdD",
  "Qlty art rm",
  "Qlty auditorium",
  "Qlty cafeteria",
  "Qlty classrms",
  "Qlty IT lab",
  "Qlty gym",
  "Qlty library",
  "Qlty multi-use rm",
  "Qlty music rm",
  "Qlty playground",
  "Schl funds decl",
  "6th highest grd",
  "K lowest grd",
  "Schl salary decl",
  "Schl salary frz",
  "Schl salary inc",
  "Schl translators",
  "Pub schl",
  "Year-round schl",
  "Tchr state cert",
  "Tchr passed board",
  "Tchr MA")

##### RECODE VARIABLES ######
eclsk.mi$rdtheta7 <- (eclsk.mi$rdtheta7-mean(eclsk.mi$rdtheta7))/sqrt(var(eclsk.mi$rdtheta7))
eclsk.mi$mththeta7 <- (eclsk.mi$mththeta7-mean(eclsk.mi$mththeta7))/sqrt(var(eclsk.mi$mththeta7))

for (v in 1:length(vars.schl.num)) {
  eclsk.mi[,vars.schl.num[v]]<-as.numeric(eclsk.mi[,vars.schl.num[v]])
  eclsk.mi[,vars.schl.num[v]]<-(eclsk.mi[,vars.schl.num[v]]-mean(eclsk.mi[,vars.schl.num[v]]))/sqrt(var(eclsk.mi[,vars.schl.num[v]]))
}

for (v in 1:length(vars.schl.cat)) {
  eclsk.mi[,vars.schl.cat[v]]<-as.numeric(eclsk.mi[,vars.schl.cat[v]])
}

eclsk.mi$hipovnh <- ifelse(eclsk.mi$nhpovrt1>=0.2, 1, 0)

##### SETUP SUPERLEARNER #####
cntrl.sl.cv <- SuperLearner.CV.control(V=5L, shuffle=TRUE, validRows=NULL)

customRF <- create.Learner(
  "SL.ranger",
  name_prefix="customRF",
  params=list(
    num.trees=RFtrees,
    min.node.size=10))

customGBTree <- create.Learner(
  "SL.xgboost",
  name_prefix="customGBTree",
  params=list(
    nrounds=GBtrees,
    max_depth=3,
    eta=0.1,
    gamma=0.005,
    min_child_weight=10))

##### STD MEAN DIFF IN SCHL VARS BTW POOR VS NONPOOR NHOOD #####
load("C:/Users/Geoffrey Wodtke/Desktop/projects/nhood_schl_gaps/data/_TEMP/fig1Output.RData")
est.schl.com <- output[, 1:2]

load("C:/Users/Geoffrey Wodtke/Desktop/projects/nhood_schl_gaps/data/_TEMP/fig2Output.RData")
est.schl.res <- output[, 1:2]

load("C:/Users/Geoffrey Wodtke/Desktop/projects/nhood_schl_gaps/data/_TEMP/fig3Output.RData")
est.schl.ins <- output[, 1:2]

load("C:/Users/Geoffrey Wodtke/Desktop/projects/nhood_schl_gaps/data/_TEMP/fig4Output.RData")
est.schl.cli <- output[, 1:2]

mRdValAdd <- lm(rdvaladd ~ hipovnh, data=eclsk.mi)
mMtValAdd <- lm(mtvaladd ~ hipovnh, data=eclsk.mi)
est.schl.efx <- data.frame(
  term = c("Rd-value add", "Mth-value add"),
  est = c(round(mRdValAdd$coefficients["hipovnh"], digits=3), round(mMtValAdd$coefficients["hipovnh"], digits=3))
  )

output.nh.schl <- rbind(est.schl.com, est.schl.res, est.schl.ins, est.schl.cli, est.schl.efx)
colnames(output.nh.schl) <- c("label", "effect.schl")

##### COMPUTE MI ESTIMATES #####
miest.rd.num <- miest.mt.num <- matrix(data=NA, nrow=length(vars.schl.num), ncol=nmi)
miest.rd.cat <- miest.mt.cat <- matrix(data=NA, nrow=length(vars.schl.cat), ncol=nmi)

for (i in 1:nmi) {
  
  ### LOAD MI DATA ###
  print(c("nmi=", i))
  eclsk <- eclsk.mi[which(eclsk.mi$minum==i),]
  
  ### TRAIN MODELS ###
  read.train<-eclsk[,"rdtheta7"]
  math.train<-eclsk[,"mththeta7"]
  xvar.train<-eclsk[,c(vars.base, vars.schl.num, vars.schl.cat)]

  read.mod <- SuperLearner(
    Y=read.train,
    X=xvar.train,
    SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
    cvControl=cntrl.sl.cv)
  
  math.mod <- SuperLearner(
    Y=math.train,
    X=xvar.train,
    SL.library=c("SL.lm", "customRF_1", "customGBTree_1"),
    cvControl=cntrl.sl.cv)

  for (v in 1:length(vars.schl.num)) {

    xvar.imp <- xvar.train

    yhat.rd <- predict(read.mod, xvar.imp)$pred
    yhat.mt <- predict(math.mod, xvar.imp)$pred
    
    xvar.imp[, vars.schl.num[v]] <- xvar.train[, vars.schl.num[v]] + 0.1
    
    yhatd.rd <- predict(read.mod, xvar.imp)$pred
    yhatd.mt <- predict(math.mod, xvar.imp)$pred
  
    miest.rd.num[v,i] <- mean(yhatd.rd - yhat.rd) / 0.1
    miest.mt.num[v,i] <- mean(yhatd.mt - yhat.mt) / 0.1
  }

  for (v in 1:length(vars.schl.cat)) {

    xvar.imp <- xvar.train

    xvar.imp[, vars.schl.cat[v]] <- 2
    
    yhat2.rd <- predict(read.mod, xvar.imp)$pred
    yhat2.mt <- predict(math.mod, xvar.imp)$pred

    xvar.imp[, vars.schl.cat[v]] <- 1

    yhat1.rd <- predict(read.mod, xvar.imp)$pred
    yhat1.mt <- predict(math.mod, xvar.imp)$pred

    miest.rd.cat[v,i] <- mean(yhat2.rd - yhat1.rd)
    miest.mt.cat[v,i] <- mean(yhat2.mt - yhat1.mt)
  }
}

##### COMBINE MI ESTIMATES #####
est.rd.num <- est.mt.num <- matrix(data=NA, nrow=length(vars.schl.num), ncol=2)
est.rd.cat <- est.mt.cat <- matrix(data=NA, nrow=length(vars.schl.cat), ncol=2)

for (i in 1:length(vars.schl.num)) {
  
  est.rd.num[i,1] <- est.mt.num[i,1] <- labels.schl.num[i]
  est.rd.num[i,2]<-round(mean(miest.rd.num[i,]), digits=5)
  est.mt.num[i,2]<-round(mean(miest.mt.num[i,]), digits=5)
}

for (i in 1:length(vars.schl.cat)) {
  
  est.rd.cat[i,1] <- est.mt.cat[i,1] <- labels.schl.cat[i]
  est.rd.cat[i,2]<-round(mean(miest.rd.cat[i,]),digits=5)
  est.mt.cat[i,2]<-round(mean(miest.mt.cat[i,]),digits=5)
}

output.schl.rd <- as.data.frame(rbind(est.rd.num, est.rd.cat))
output.schl.mt <- as.data.frame(rbind(est.mt.num, est.mt.cat))
colnames(output.schl.rd) <- c("label", "effect.rd")
colnames(output.schl.mt) <- c("label", "effect.mt")

##### PRINT RESULTS #####
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\17_create_figure_8_log.txt")

output <- output.nh.schl %>%
	full_join(output.schl.rd, by = "label") %>%
	full_join(output.schl.mt, by = "label")

print(output)

##### CREATE SCATTER PLOT #####
#load("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig8Output.RData")

output$effect.schl <- as.numeric(output$effect.schl)
output$effect.rd <- as.numeric(output$effect.rd)
output$effect.mt <- as.numeric(output$effect.mt)

plot.rd <- ggplot(output, aes(x=effect.schl, y=effect.rd, label=label)) +
  xlab("Std. Difference in School Var. between High- and Low-poverty Nh.") +
  ylab("Marginal Effect of School Var. on Achievement") +
  ggtitle("Reading Scores") +
  scale_y_continuous(breaks = seq(-0.1, 0.1, 0.02), limits = c(-0.1, 0.1)) +
  scale_x_continuous(breaks = seq(-1.0, 1.0, 0.2), limits = c(-1.0, 1.0)) +
  geom_point(color ="black", size=0.2)+
  theme_grey(base_size = 8.5) +
  geom_text_repel(size = 2.3, max.overlaps = 40)

plot.mt <- ggplot(output, aes(x=effect.schl, y=effect.mt, label=label))+
  xlab("Std. Difference in School Var. between High- and Low-poverty Nh.") +
  ylab("Marginal Effect of School Var. on Achievement") +
  ggtitle("Math Scores") +
  scale_y_continuous(breaks = seq(-0.1, 0.1, 0.02), limits = c(-0.1, 0.1)) +
  scale_x_continuous(breaks = seq(-1.0, 1.0, 0.2), limits = c(-1.0, 1.0)) +
  geom_point(color = "black", size = 0.2) +
  theme_grey(base_size = 8.5) +
  geom_text_repel(size = 2.3, max.overlaps = 40)

jpeg("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_8.jpeg",
     height=5,
     width=9,
     units='in',
     res=600)

grid.arrange(plot.rd, plot.mt, ncol=2)

dev.off()

print(startTime)
print(Sys.time())

sink()

save(output, file="C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig8Output.RData")

