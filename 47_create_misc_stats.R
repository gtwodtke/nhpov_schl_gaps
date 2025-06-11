#################################################
#################################################
##                                             ##
## PROGRAM NAME: 47_create_misc_stats          ##
##                                             ##
## PURPOSE: create misc stats                  ##
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
  "tidyr")

for(package.i in list.of.packages) {
  suppressPackageStartupMessages(library(package.i, character.only = TRUE))
}

startTime <- Sys.time()
set.seed(60637)

##### LOAD ECLS-K #####
eclsk.mi <- read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi <- eclsk.mi[order(eclsk.mi$childid, eclsk.mi$minum),]

sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\47_create_misc_stats.txt")

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

vars.all <- c(
  vars.base,
  vars.schl.all,
  "rdtheta7",
  "mththeta7")

##### VECTOR LENGTHS ######
print(c("composition = ", length(vars.schl.com)))
print(c("resources = ", length(vars.schl.res)))
print(c("instructional practices = ", length(vars.schl.ins)))
print(c("climate = ", length(vars.schl.cli)))
print(c("effectiveness = ", length(vars.schl.efx)))
print(c("all schl vars = ", length(vars.schl.all)))
print(c("baseline covars = ", length(vars.base)))

##### TOTAL PROPORTION OF MISSING INFORMATION #####
eclsk.raw <- eclsk.mi[which(eclsk.mi$minum==0),]
prop.miss.info <- sum(is.na(eclsk.raw[vars.all]))/(length(vars.all)*nrow(eclsk.raw))
print(c("proportion of missing information =", round(prop.miss.info, digits=3)))

##### PROPORTION OF MISSING INFORMATION FOR EACH VARIABLE #####
for (v in 1:length(vars.all)) {
  prop.miss.info.v <- sum(is.na(eclsk.raw[vars.all[v]]))/nrow(eclsk.raw)
  print(c("proportion of missing information for", vars.all[v], "=", round(prop.miss.info.v, digits=3)))
}
 
sink()

