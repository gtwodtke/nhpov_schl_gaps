################################################
################################################
##                                            ##
## PROGRAM NAME: 11_create_figure_3           ##
## AUTHOR: KW/GW                              ##
##                                            ##
## PURPOSE: create dot-whisker plot for       ##
##          observed gaps in school           ##
##          instructional practices           ##
##                                            ##
################################################
################################################

##### LOAD LIBRARIES #####
rm(list=ls())

list.of.packages <- c(
  "tidyverse",
  "sys",
  "haven",
  "foreign",
  "dplyr",
  "tidyr",
  "ggplot2",
  "gridExtra",
  "metR",
  "dotwhisker",
  "Hmisc",
  "estimatr")

for(package.i in list.of.packages) {
  suppressPackageStartupMessages(library(package.i, character.only = TRUE))
}

startTime<-Sys.time()
set.seed(60657)

##### LOAD ECLS-K #####
eclsk.mi<-read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi<-as.data.frame(eclsk.mi[which(eclsk.mi$minum!=0),])

##### SET SCRIPT PARAMETERS #####
nmi<-5 

##### DEFINE VARIABLE SETS #####
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

##### STANDARDIZE SCHOOL VARS ######
for (v in 1:length(vars.schl.ins)) {
  eclsk.mi[,vars.schl.ins[v]]<-(as.numeric(eclsk.mi[,vars.schl.ins[v]])) 
  eclsk.mi[,vars.schl.ins[v]]<-(eclsk.mi[,vars.schl.ins[v]]-mean(eclsk.mi[,vars.schl.ins[v]]))/sqrt(var(eclsk.mi[,vars.schl.ins[v]]))
}

##### CODE HIGH-POVERTY NHOODS #####
eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

##### ESTIMATE OBSERVED DIFFERENCES #####
miest<-mivar<-matrix(data=NA, nrow=length(vars.schl.ins), ncol=nmi)

for (i in 1:nmi) {
  
  ## LOAD MI DATA
  eclsk<-eclsk.mi[which(eclsk.mi$minum==i),]
  print(c("nmi=", i))
  
  ## ESTIMATE OBSERVED GAPS
  for (v in 1:length(vars.schl.ins)) {
    diff.est <- lm_robust(get(vars.schl.ins[v])~hipovnh, cluster=schlid, se_type="stata", data=eclsk)
    miest[v,i]<-diff.est$coefficients["hipovnh"]
    mivar[v,i]<-diff.est$std.error["hipovnh"]^2
  }
}  

##### COMBINE MI ESTIMATES #####
est.comb<-matrix(data=NA,nrow=length(vars.schl.ins),ncol=4)

for (i in 1:length(vars.schl.ins)) { 
  est.comb[i,1]<-round(mean(miest[i,]), digits=3)
  est.comb[i,2]<-round(sqrt(mean(mivar[i,]) + var(miest[i,])*(1+(1/nmi))), digits=3)
  est.comb[i,3]<-round(est.comb[i,1]-1.96*est.comb[i,2], digits=3)
  est.comb[i,4]<-round(est.comb[i,1]+1.96*est.comb[i,2], digits=3)
}

### PRINT RESULTS ###
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\11_create_figure_3_log.txt")

label.schl.ins <- c(
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
  "Mth grp days/wk")

output<-as.data.frame(cbind(label.schl.ins, est.comb))
colnames(output)<-c('term', 'est', 'se', 'llci', 'ulci')
output$est<-as.numeric(output$est)
output$se<-as.numeric(output$se)
output$llci<-as.numeric(output$llci)
output$ulci<-as.numeric(output$ulci)
output<-output[order(output$est, decreasing=T),]

print(output)

##### CREATE DOT-WHISKER PLOT #####
#load("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig3Output.RData")

output.q2<-output[output$est>=quantile(output$est,prob=0.50),]
output.q1<-output[output$est<quantile(output$est,prob=0.50),]

plot.q2 <- output.q2 %>%
  mutate(term=fct_reorder(term, est)) %>%
  ggplot(aes(x=term, y=est)) +
  geom_errorbar(aes(ymin=llci, ymax=ulci), width=0, color="gray55") +
  geom_point(size=1.025) +
  coord_flip() +
  theme_bw() +
  ggtitle("High- versus Low-poverty Neighborhoods") +
  scale_y_continuous(
    name="Standardized Mean Difference",
    limits=c(-1.05, 1.05),
    breaks=round(seq(-1.00,1.00,0.20), 2)) +
  scale_x_discrete(name=" ") +
  theme(plot.title=element_text(size=10, face="bold"),
        legend.position="none",
        panel.grid.major=element_blank(), 
        panel.grid.minor=element_blank(),
        panel.background=element_blank(), 
        axis.line=element_line(colour="black")) +
  geom_hline(yintercept=0, colour="black", linetype=2)

plot.q1 <- output.q1 %>%
  mutate(term=fct_reorder(term, est)) %>%
  ggplot(aes(x=term, y=est)) +
  geom_errorbar(aes(ymin=llci, ymax=ulci), width=0, color="gray55") +
  geom_point(size=1.025) +
  coord_flip() +
  theme_bw() +
  ggtitle(" ") +
  scale_y_continuous(
    name="Standardized Mean Difference",
    limits=c(-1.025, 1.025),
    breaks=round(seq(-1.00, 1.00, 0.20), 2)) +
  scale_x_discrete(name=" ") +
  theme(plot.title=element_text(size=10, face="bold"),
        legend.position="none",
        panel.grid.major=element_blank(), 
        panel.grid.minor=element_blank(),
        panel.background=element_blank(), 
        axis.line=element_line(colour="black")) +
  geom_hline(yintercept=0, colour="black", linetype=2)

jpeg("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_3.jpeg", 
     height=9, 
     width=9,
     units='in',
     res=600)

grid.arrange(plot.q2,plot.q1,ncol=2)

dev.off()

print(startTime)
print(Sys.time())

sink()

save(output, file="C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig3Output.RData")

