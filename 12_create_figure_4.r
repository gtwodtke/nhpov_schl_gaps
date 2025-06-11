################################################
################################################
##                                            ##
## PROGRAM NAME: 12_create_figure_4           ##
## AUTHOR: KW/GW                              ##
##                                            ##
## PURPOSE: create dot-whisker plot for       ##
##          observed gaps in school           ##
##          climate                           ##
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
set.seed(60637)

##### LOAD ECLS-K #####
eclsk.mi<-read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi<-as.data.frame(eclsk.mi[which(eclsk.mi$minum!=0),])

##### SET SCRIPT PARAMETERS #####
nmi<-5

##### DEFINE VARIABLE SETS #####
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

##### STANDARDIZE SCHOOL VARS ######
for (v in 1:length(vars.schl.cli)) {
  eclsk.mi[,vars.schl.cli[v]]<-(as.numeric(eclsk.mi[,vars.schl.cli[v]])) 
  eclsk.mi[,vars.schl.cli[v]]<-(eclsk.mi[,vars.schl.cli[v]]-mean(eclsk.mi[,vars.schl.cli[v]]))/sqrt(var(eclsk.mi[,vars.schl.cli[v]]))
}

##### CODE HIGH-POVERTY NHOODS #####
eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

##### ESTIMATE OBSERVED DIFFERENCES #####
miest<-mivar<-matrix(data=NA, nrow=length(vars.schl.cli), ncol=nmi)

for (i in 1:nmi) {
  
  ## LOAD MI DATA
  eclsk<-eclsk.mi[which(eclsk.mi$minum==i),]
  print(c("nmi=", i))
  
  ## ESTIMATE OBSERVED GAPS
  for (v in 1:length(vars.schl.cli)) {
    diff.est <- lm_robust(get(vars.schl.cli[v])~hipovnh, cluster=schlid, se_type="stata", data=eclsk)
    miest[v,i]<-diff.est$coefficients["hipovnh"]
    mivar[v,i]<-diff.est$std.error["hipovnh"]^2
  }
}  

##### COMBINE MI ESTIMATES #####
est.comb<-matrix(data=NA,nrow=length(vars.schl.cli),ncol=4)

for (i in 1:length(vars.schl.cli)) { 
  est.comb[i,1]<-round(mean(miest[i,]), digits=3)
  est.comb[i,2]<-round(sqrt(mean(mivar[i,]) + var(miest[i,])*(1+(1/nmi))), digits=3)
  est.comb[i,3]<-round(est.comb[i,1]-1.96*est.comb[i,2], digits=3)
  est.comb[i,4]<-round(est.comb[i,1]+1.96*est.comb[i,2], digits=3)
}

### PRINT RESULTS ###
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\12_create_figure_4_log.txt")

label.schl.cli <- c(
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
  "Freq report cards")

output<-as.data.frame(cbind(label.schl.cli, est.comb))
colnames(output)<-c('term', 'est', 'se', 'llci', 'ulci')
output$est<-as.numeric(output$est)
output$se<-as.numeric(output$se)
output$llci<-as.numeric(output$llci)
output$ulci<-as.numeric(output$ulci)
output<-output[order(output$est, decreasing=T),]

print(output)

##### CREATE DOT-WHISKER PLOT #####
#load("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig4Output.RData")

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

jpeg("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_4.jpeg", 
     height=4, 
     width=9,
     units='in',
     res=600)

grid.arrange(plot.q2, plot.q1, ncol=2)

dev.off()

print(startTime)
print(Sys.time())

sink()

save(output,file="C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig4Output.RData")

