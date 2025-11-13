#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\eclsk11\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}04_create_v04_eclsk11_valAdd.log", replace 

/*********************************************
PROGRAM NAME: 04_create_v04_eclsk11_valAdd.do
PURPOSE: Generate school value-added estimates
**********************************************/

/*********
INPUT DATA
**********/
use "${data_directory}v03_eclsk11_ccd.dta"

/********************
CORRECT MISSING DATES
*********************/
quietly levelsof s1_id, local(school_ids)
quietly foreach id of local school_ids {
    egen count = count(1) if s1_id == "`id'" & x1asmtdd !=., by(x1asmtmm x1asmtdd x1asmtyy)
	gen neg_count = -count
	sort neg_count
	
	gen most_freq_date_month = x1asmtmm if _n == 1
	gen most_freq_date_day = x1asmtdd if _n == 1
	gen most_freq_date_year = x1asmtyy if _n == 1

	replace most_freq_date_month = x1asmtmm[_n-1] if missing(most_freq_date_month)
	replace most_freq_date_day = x1asmtdd[_n-1] if missing(most_freq_date_day)
	replace most_freq_date_year = x1asmtyy[_n-1] if missing(most_freq_date_year)
	
	replace x1asmtmm = most_freq_date_month if s1_id == "`id'" & x1asmtmm == .
	replace x1asmtdd = most_freq_date_day if s1_id == "`id'" & x1asmtdd == .
	replace x1asmtyy = most_freq_date_year if s1_id == "`id'" & x1asmtyy == .
	
	drop count neg_count most_freq_date_month most_freq_date_day most_freq_date_year
}

quietly levelsof s2_id, local(school_ids)
quietly foreach id of local school_ids {
    egen count = count(1) if s2_id == "`id'" & x2asmtdd !=., by(x2asmtmm x2asmtdd x2asmtyy)
	gen neg_count = -count
	sort neg_count 
	
	gen most_freq_date_month = x2asmtmm if _n == 1
	gen most_freq_date_day = x2asmtdd if _n == 1
	gen most_freq_date_year = x2asmtyy if _n == 1
	
	replace most_freq_date_month = x2asmtmm[_n-1] if missing(most_freq_date_month)
	replace most_freq_date_day = x2asmtdd[_n-1] if missing(most_freq_date_day)
	replace most_freq_date_year = x2asmtyy[_n-1] if missing(most_freq_date_year)
	
	replace x2asmtmm = most_freq_date_month if s2_id == "`id'" & x2asmtmm == .
	replace x2asmtdd = most_freq_date_day if s2_id == "`id'" & x2asmtdd == .
	replace x2asmtyy = most_freq_date_year if s2_id == "`id'" & x2asmtyy == .
	
	drop count neg_count most_freq_date_month most_freq_date_day most_freq_date_year
	quietly
}

quietly levelsof s3_id, local(school_ids)
quietly foreach id of local school_ids {
    egen count = count(1) if s3_id == "`id'" & x3asmtdd !=., by(x3asmtmm x3asmtdd x3asmtyy)
	gen neg_count = -count
	sort neg_count 
	
	gen most_freq_date_month = x3asmtmm if _n == 1
	gen most_freq_date_day = x3asmtdd if _n == 1
	gen most_freq_date_year = x3asmtyy if _n == 1
	
	replace most_freq_date_month = x3asmtmm[_n-1] if missing(most_freq_date_month)
	replace most_freq_date_day = x3asmtdd[_n-1] if missing(most_freq_date_day)
	replace most_freq_date_year = x3asmtyy[_n-1] if missing(most_freq_date_year)
	
	replace x3asmtmm = most_freq_date_month if s3_id == "`id'" & x3asmtmm == .
	replace x3asmtdd = most_freq_date_day if s3_id == "`id'" & x3asmtdd == .
	replace x3asmtyy = most_freq_date_year if s3_id == "`id'" & x3asmtyy == .
	
	drop count neg_count most_freq_date_month most_freq_date_day most_freq_date_year
	quietly
}

quietly levelsof s4_id, local(school_ids)
quietly foreach id of local school_ids {
    egen count = count(1) if s4_id == "`id'" & x4asmtdd !=., by(x4asmtmm x4asmtdd x4asmtyy)
	gen neg_count = -count
	sort neg_count 
	
	gen most_freq_date_month = x4asmtmm if _n == 1
	gen most_freq_date_day = x4asmtdd if _n == 1
	gen most_freq_date_year = x4asmtyy if _n == 1
	
	replace most_freq_date_month = x4asmtmm[_n-1] if missing(most_freq_date_month)
	replace most_freq_date_day = x4asmtdd[_n-1] if missing(most_freq_date_day)
	replace most_freq_date_year = x4asmtyy[_n-1] if missing(most_freq_date_year)
	
	replace x4asmtmm = most_freq_date_month if s4_id == "`id'" & x4asmtmm == .
	replace x4asmtdd = most_freq_date_day if s4_id == "`id'" & x4asmtdd == .
	replace x4asmtyy = most_freq_date_year if s4_id == "`id'" & x4asmtyy == .
	
	drop count neg_count most_freq_date_month most_freq_date_day most_freq_date_year
	quietly
}

/************************************************
COMBINE SEPARATE DATE VARIABLES INTO DATE OBJECTS   
*************************************************/
gen assessdate2 = mdy(x2asmtmm, x2asmtdd, x2asmtyy)
gen assessdate4 = mdy(x4asmtmm, x4asmtdd, x4asmtyy)

format assessdate2 %td
format assessdate4 %td

label variable assessdate2 "Child assessment date, Spring Kindergarten"
label variable assessdate4 "Child assessment date, Spring 1st grade"

/********************************************
DEFINE ANALYTIC SAMPLE FOR VALUE-ADDED MODELS
*********************************************/
/*drop students missing school IDs for K-1st grade*/ 
drop if s2_id == "" | s4_id == ""

/*drop students who transferred schools*/ 
drop if s2_id != s4_id 

/*********************************
CALCULATE TIME BETWEEN ASSESSMENTS
**********************************/
gen k1_exp_w4 = (assessdate4 - assessdate2)/30
label variable k1_exp_w4 "# of months between spring of kindergarten and spring of 1st grade assessments"

/**************************
ESTIMATE SCHOOL VALUE-ADDED
***************************/
mixed mththeta4 mththeta2 mththeta1 rdtheta2 rdtheta1 i.gender i.race i.par1ed2 k1_exp_w4 || s4_id: , cov(id) mle
predict mtvaladd, reffects

mixed rdtheta4 rdtheta2 rdtheta1 mththeta2 mththeta1 i.gender i.race i.par1ed2 k1_exp_w4 || s4_id: , cov(id) mle
predict rdvaladd, reffects

label var mtvaladd "School value-added, 1st gr math"
label var rdvaladd "School value-added, 1st gr reading"
	  
sum mtvaladd rdvaladd, detail

_pctile mtvaladd, p(99.5)
ret li
replace mtvaladd = `r(r1)' if mtvaladd > `r(r1)' & mtvaladd != .

_pctile mtvaladd, p(0.5)
ret li
replace mtvaladd = `r(r1)' if mtvaladd < `r(r1)' & mtvaladd != .

_pctile rdvaladd, p(99.5)
ret li
replace rdvaladd = `r(r1)' if rdvaladd > `r(r1)' & rdvaladd != .

_pctile rdvaladd, p(0.5)
ret li
replace rdvaladd = `r(r1)' if rdvaladd < `r(r1)' & rdvaladd != .

/************************************************
MERGE VALUE-ADDED ESTIMATES BACK INTO FULL ECLS-K
*************************************************/
keep childid mtvaladd rdvaladd 

save "${data_directory}valAdd_temp.dta", replace

use "${data_directory}v03_eclsk11_ccd.dta", clear

merge 1:1 childid using "${data_directory}valAdd_temp.dta"

drop _merge 

erase "${data_directory}valAdd_temp.dta"

/********
SAVE DATA
*********/
save "${data_directory}v04_eclsk11_valAdd.dta", replace 

clear

log close
