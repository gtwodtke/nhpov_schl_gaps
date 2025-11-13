################################################
################################################
##                                            ##
## PROGRAM NAME: 09_create_figure_1           ##
##                                            ##
## PURPOSE: create dot-whisker plot for       ##
##          observed gaps in school           ##
##          composition                       ##
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

##### STANDARDIZE SCHOOL VARS ######
for (v in 1:length(vars.schl.com)) {
  eclsk.mi[,vars.schl.com[v]]<-(as.numeric(eclsk.mi[,vars.schl.com[v]])) 
  eclsk.mi[,vars.schl.com[v]]<-(eclsk.mi[,vars.schl.com[v]]-mean(eclsk.mi[,vars.schl.com[v]]))/sqrt(var(eclsk.mi[,vars.schl.com[v]]))
}

##### CODE HIGH-POVERTY NHOODS #####
eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, 1, 0)

##### ESTIMATE OBSERVED DIFFERENCES #####
miest<-mivar<-matrix(data=NA, nrow=length(vars.schl.com), ncol=nmi)

for (i in 1:nmi) {
  
  ## LOAD MI DATA
  eclsk<-eclsk.mi[which(eclsk.mi$minum==i),]
  print(c("nmi=", i))

  ## ESTIMATE OBSERVED GAPS
  for (v in 1:length(vars.schl.com)) {
    diff.est <- lm_robust(get(vars.schl.com[v])~hipovnh, cluster=schlid, se_type="stata", data=eclsk)
    miest[v,i]<-diff.est$coefficients["hipovnh"]
    mivar[v,i]<-diff.est$std.error["hipovnh"]^2
  }
}  

##### COMBINE MI ESTIMATES #####
est.comb<-matrix(data=NA,nrow=length(vars.schl.com),ncol=4)

for (i in 1:length(vars.schl.com)) { 
  est.comb[i,1]<-round(mean(miest[i,]), digits=3)
  est.comb[i,2]<-round(sqrt(mean(mivar[i,]) + var(miest[i,])*(1+(1/nmi))), digits=3)
  est.comb[i,3]<-round(est.comb[i,1]-1.96*est.comb[i,2], digits=3)
  est.comb[i,4]<-round(est.comb[i,1]+1.96*est.comb[i,2], digits=3)
}

##### PRINT RESULTS #####
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\09_create_figure_1_log.txt")

label.schl.com<-c(
  "% Black",
  "% ELL",
  "% Free lunch",
  "% Gifted",
  "% Hispanic",
  "% Spec ed",
  "% White",
  "Prcpl male",
  "Prcpl white",
  "Tchr male",
  "Tchr white")

output<-as.data.frame(cbind(label.schl.com, est.comb))
colnames(output)<-c('term', 'est', 'se', 'llci', 'ulci')
output$est<-as.numeric(output$est)
output$se<-as.numeric(output$se)
output$llci<-as.numeric(output$llci)
output$ulci<-as.numeric(output$ulci)
output<-output[order(output$est, decreasing=T),]

print(output)

##### CREATE DOT-WHISKER PLOT #####
#load("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig1Output.RData")

plot.com <- output %>%
  mutate(term=fct_reorder(term, est)) %>%
  ggplot(aes(x=term, y=est)) +
  geom_errorbar(aes(ymin=llci, ymax=ulci), width=0, color="gray55") +
  geom_point(size=1.025) +
  coord_flip() +
  theme_bw() +
  ggtitle("High- versus Low-poverty Neighborhoods") +
  scale_y_continuous(
    name="Standardized Mean Difference",
    limits=c(-1.07, 1.07),
    breaks=round(seq(-1.0, 1.0, 0.20), 2)) +
  scale_x_discrete(name=" ") +
  theme(plot.title=element_text(size=10, face="bold"),
        legend.position="none",
        panel.grid.major=element_blank(), 
        panel.grid.minor=element_blank(),
        panel.background=element_blank(), 
        axis.line=element_line(colour="black")) +
  geom_hline(yintercept=0, colour="black", linetype=2)

ggsave("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_1.jpeg", height=4, width=4.5, dpi=600)

print(startTime)
print(Sys.time())

sink()

save(output, file="C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\_TEMP\\fig1Output.RData")

