################################################
################################################
##                                            ##
## PROGRAM NAME: 13_create_figure_5           ##
## AUTHOR: GW                                 ##
##                                            ##
## PURPOSE: create density plot for school    ##
##          effectiveness (value-added)       ##
##                                            ##
################################################
################################################

##### LOAD LIBRARIES #####
rm(list=ls())

list.of.packages <- c(
  "tidyverse",
  "haven",
  "foreign",
  "dplyr",
  "tidyr",
  "ggplot2",
  "gridExtra",
  "Hmisc")

for(package.i in list.of.packages) {
  suppressPackageStartupMessages(library(package.i, character.only = TRUE))
}

startTime<-Sys.time()
set.seed(60637)

##### LOAD ECLS-K #####
eclsk.mi<-read.dta("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\data\\eclsk11\\v08_eclsk11_mi_final.dta")
eclsk.mi<-as.data.frame(eclsk.mi[which(eclsk.mi$minum!=0),])

##### RECODE VARIABLES #####
eclsk.mi$hipovnh<-ifelse(eclsk.mi$nhpovrt1>=0.20, ">=20% Poverty", "<20% Poverty")
eclsk.mi$rdvaladd<-(eclsk.mi$rdvaladd-mean(eclsk.mi$rdvaladd))/sqrt(var(eclsk.mi$rdvaladd))
eclsk.mi$mtvaladd<-(eclsk.mi$mtvaladd-mean(eclsk.mi$mtvaladd))/sqrt(var(eclsk.mi$mtvaladd))

##### COMPUTE GROUP MEANS #####
readMeanGt20<-mean(eclsk.mi[eclsk.mi$hipovnh==">=20% Poverty", "rdvaladd"])
readMeanLt20<-mean(eclsk.mi[eclsk.mi$hipovnh=="<20% Poverty", "rdvaladd"])
mathMeanGt20<-mean(eclsk.mi[eclsk.mi$hipovnh==">=20% Poverty", "mtvaladd"])
mathMeanLt20<-mean(eclsk.mi[eclsk.mi$hipovnh=="<20% Poverty", "mtvaladd"])

##### CREATE DENSITY PLOTS #####
plot.rd <- ggplot(eclsk.mi, aes(x=rdvaladd, fill=hipovnh, linetype=hipovnh)) +
	geom_density(alpha=0.4, adjust=2.25, size=0.6) +
	geom_vline(aes(xintercept=readMeanGt20), color="black", linetype="dashed", size=0.6) +
	geom_vline(aes(xintercept=readMeanLt20), color="black", linetype="solid", size=0.6) +
	labs(
		title="School Effectiveness by Neighborhood Poverty",
		x="Reading Value Added (SDs)",
		y="Density",
		fill="Neighborhood Poverty",
		linetype="Neighborhood Poverty") +
	theme_bw() +
	theme(
		plot.title=element_text(size=10, face="bold"),
		axis.line=element_line(colour="black"),
		panel.grid.minor=element_blank(),
		legend.position="none") +
	scale_fill_manual(values=c("grey80", "grey30")) +
	scale_linetype_manual(values=c("solid", "dashed")) +
  	scale_x_continuous(
	    limits=c(-4, 4),
	    breaks=seq(-4, 4, 1)) +
  	scale_y_continuous(
	    limits=c(0, 0.525),
	    breaks=round(seq(0.0, 0.5, 0.1), 1)) 

plot.mt <- ggplot(eclsk.mi, aes(x=mtvaladd, fill=hipovnh, linetype=hipovnh)) +
	geom_density(alpha=0.4, adjust=2.25, size=0.6) +
	geom_vline(aes(xintercept=mathMeanGt20), color="black", linetype="dashed", size=0.6) +
	geom_vline(aes(xintercept=mathMeanLt20), color="black", linetype="solid", size=0.6) +
	labs(
		title=" ",
		x="Math Value Added (SDs)",
		y="Density",
		fill="Neighborhood Poverty",
		linetype="Neighborhood Poverty") +
	theme_bw() +
	theme(
		plot.title=element_text(size=10, face="bold"),
		axis.line=element_line(colour="black"),
		panel.grid.minor=element_blank(),
		legend.position=c(0.97, 0.97),
		legend.justification=c("right", "top"),
		legend.box.just="right",
		legend.margin=margin(6, 6, 6, 6),
		legend.background=element_rect(color="black", size=0.6, linetype="solid"),
		legend.text=element_text(size=7),
		legend.title=element_text(size=9)) +
	scale_fill_manual(values=c("grey80", "grey30")) +
	scale_linetype_manual(values=c("solid", "dashed")) +
  	scale_x_continuous(
	    limits=c(-4, 4),
	    breaks=seq(-4, 4, 1)) +
  	scale_y_continuous(
	    limits=c(0, 0.525),
	    breaks=round(seq(0.0, 0.5, 0.1), 1)) 

jpeg("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\figures\\figure_5.jpeg", 
     height=5, 
     width=9,
     units='in',
     res=600)

grid.arrange(plot.rd, plot.mt, ncol=2)

dev.off()

### PRINT RESULTS ###
sink("C:\\Users\\Geoffrey Wodtke\\Desktop\\projects\\nhood_schl_gaps\\programs\\_LOGS\\13_create_figure_5_log.txt")

print(c(readMeanGt20, readMeanLt20, mathMeanGt20, mathMeanLt20))

print(startTime)
print(Sys.time())

sink()
