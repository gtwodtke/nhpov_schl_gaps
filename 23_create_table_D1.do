#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\eclsk11\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}23_create_table_D1.log", replace 

/**********************************
PROGRAM NAME: 22_create_table_D1.do
PURPOSE: variable descriptives
***********************************/

/***INPUT DATA***/
use "${data_directory}v08_eclsk11_mi_final.dta"   
keep if minum != 0

/***RECODE VARIABLES***/
quietly sum rdtheta1
scalar mu = r(mean)
scalar sig = r(sd)
	
foreach v in rdtheta1 rdtheta7 rdtheta8 rdtheta9 {
	quietly replace `v' = (`v'  - mu)/sig
}

quietly sum mththeta1
scalar mu = r(mean)
scalar sig = r(sd)
	
foreach v in mththeta1 mththeta7 mththeta8 mththeta9 {
	quietly replace `v' = (`v'  - mu)/sig
}

quietly gen hipovnh = 0
quietly replace hipovnh = 1 if nhpovrt1>=0.2 		
quietly tab hipovnh, gen(hipovnh_)

quietly tab pared2, gen(pared2_)
quietly tab pprctnm1, gen(pprctnm1_)
quietly tab preadbk1, gen(preadbk1_)
quietly tab p1exp1, gen(p1exp1_)

foreach v in gender marbrth lang1 wichh1 fstmp1 tanf1 married1 hhprnt1 {
	quietly replace `v' = `v' - 1
}
	 
/***DEFINE VARIABLE SETS***/
global vars_base ///
	rdtheta7 rdtheta8 rdtheta9 ///
	mththeta7 mththeta8 mththeta9 ///
	hipovnh_* nhpovrt1 ///
	gender drace_* age1 brthwt marbrth ///
	lang1 hhtot1 par1age1 par2age1 dpar1emp1_* dpar2emp1_* ///
	pared2_* faminc2 parocc1 wichh1 fstmp1 tanf1 married1 hhprnt1 pprctnm1_* preadbk1_* p1exp1_* /// 
	dx1locale_* dx1region_* ///
	extrn1 intrn1 mtvt1 cooper1 attn1 hlthscale1 ///
	rdtheta1 mththeta1 

/***COVARIATE DESCRIPTIVES***/
tabstat $vars_base, stat(mean sd min max) columns(stat)

log close
