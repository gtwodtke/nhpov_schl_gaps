#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}03_create_v03_eclsk11_ccd.log", replace 

/*************************************************************
PROGRAM NAME: 03_create_v03_eclsk11_ccd.do
AUTHOR: KW/GW
PURPOSE: Merge ECLS-K with selected variables from CCD and PSS
**************************************************************/

/*set local macro for variable labeling convention*/
tokenize `""Kindergarten Fall" "Kindergarten Spring" "1st grade Fall" "1st grade Spring" "2nd grade Fall" "2nd grade Spring" "3rd grade" "4th grade" "5th grade""' 

/************************
CLEAN NON-FISCAL CCD DATA
*************************/
use "${data_directory}ccd\school_level\ccd_s_1011.dta" 
rename *, lower 
keep ncessch kg member 
replace kg = . if kg == -2 | kg == -9 | kg == -1 
replace member = . if member == -2 | member == -9 | member == -1 
rename kg ccd_schl_kenr1 
rename member ccd_schl_enr1 
rename ncessch f1ccdsid 
label variable ccd_schl_kenr1 "CCD Total number of school Kindergarten students, Fall 2010"
label variable ccd_schl_enr1 "CCD Total number of school students, Fall 2010" 
sort f1ccdsid 
save "${data_directory}ccd\school_level\ccd_s_1.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1011.dta"
rename *, lower
keep ncessch kg member 
replace kg = . if kg == -2 | kg == -9 | kg == -1
replace member = . if member == -2 | member == -9 | member == -1
rename kg ccd_schl_kenr2
rename member ccd_schl_enr2
rename ncessch f2ccdsid
label variable ccd_schl_kenr2 "CCD Total number of school Kindergarten students, Spring 2011"
label variable ccd_schl_enr2 "CCD Total number of school students, Spring 2011"
sort f2ccdsid
save "${data_directory}ccd\school_level\ccd_s_2.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1112.dta"
rename *, lower
keep ncessch g01 member 
replace g01 = . if g01 == -2 | g01 == -9 | g01 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g01 ccd_schl_1enr3
rename member ccd_schl_enr3
rename ncessch f3ccdsid
label variable ccd_schl_1enr3 "CCD Total number of school 1st grade students, Fall 2011"
label variable ccd_schl_enr3 "CCD Total number of school students, Fall 2011"
sort f3ccdsid
save "${data_directory}ccd\school_level\ccd_s_3.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1112.dta"
rename *, lower
keep ncessch g01 member 
replace g01 = . if g01 == -2 | g01 == -9 | g01 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g01 ccd_schl_1enr4
rename member ccd_schl_enr4
rename ncessch f4ccdsid
label variable ccd_schl_1enr4 "CCD Total number of school 1st grade students, Spring 2012"
label variable ccd_schl_enr4 "CCD Total number of school students, Spring 2012"
sort f4ccdsid
save "${data_directory}ccd\school_level\ccd_s_4.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1213.dta"
rename *, lower
keep ncessch g02 member 
replace g02 = . if g02 == -2 | g02 == -9 | g02 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g02 ccd_schl_2enr5
rename member ccd_schl_enr5
rename ncessch f5ccdsid
label variable ccd_schl_2enr5 "CCD Total number of school 2nd grade students, Fall 2012"
label variable ccd_schl_enr5 "CCD Total number of school students, Fall 2012"
sort f5ccdsid
save "${data_directory}ccd\school_level\ccd_s_5.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1213.dta"
rename *, lower
keep ncessch g02 member 
replace g02 = . if g02 == -2 | g02 == -9 | g02 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g02 ccd_schl_2enr6
rename member ccd_schl_enr6
rename ncessch f6ccdsid
label variable ccd_schl_2enr6 "CCD Total number of school 2nd grade students, Spring 2013"
label variable ccd_schl_enr6 "CCD Total number of school students, Spring 2013"
sort f6ccdsid
save "${data_directory}ccd\school_level\ccd_s_6.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1314.dta"
rename *, lower
keep ncessch g03 member 
replace g03 = . if g03 == -2 | g03 == -9 | g03 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g03 ccd_schl_3enr7
rename member ccd_schl_enr7
rename ncessch f7ccdsid
label variable ccd_schl_3enr7 "CCD Total number of school 3nd grade students, Spring 2014"
label variable ccd_schl_enr7 "CCD Total number of school students, Spring 2014"
sort f7ccdsid
save "${data_directory}ccd\school_level\ccd_s_7.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1415.dta"
rename *, lower
keep ncessch g04 member 
replace g04 = . if g04 == -2 | g04 == -9 | g04 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g04 ccd_schl_4enr8
rename member ccd_schl_enr8
rename ncessch f8ccdsid
label variable ccd_schl_4enr8 "CCD Total number of school 4th grade students, Spring 2015"
label variable ccd_schl_enr8 "CCD Total number of school students, Spring 2015"
sort f8ccdsid
save "${data_directory}ccd\school_level\ccd_s_8.dta", replace
clear

use "${data_directory}ccd\school_level\ccd_s_1516.dta"
rename *, lower
keep ncessch g05 member 
replace g05 = . if g05 == -2 | g05 == -9 | g05 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g05 ccd_schl_5enr9
rename member ccd_schl_enr9
rename ncessch f9ccdsid
label variable ccd_schl_5enr9 "CCD Total number of school 5th grade students, Spring 2016"
label variable ccd_schl_enr9 "CCD Total number of school students, Spring 2016"
sort f9ccdsid
save "${data_directory}ccd\school_level\ccd_s_9.dta", replace
clear

/************************
CLEAN NON-FISCAL PSS DATA
*************************/
use "${data_directory}pss\pss0910.dta"
keep ppin P160 P305
rename ppin fschpin
rename P160 pss_schl_kenr1
rename P305 pss_schl_enr1
label variable pss_schl_kenr1 "PSS Total number of school 1st grade students, Fall 2010"
label variable pss_schl_enr1 "PSS Total number of school students, Fall 2010"
save "${data_directory}pss\pss_s_1.dta", replace
clear

use "${data_directory}pss\pss0910.dta"
keep ppin P160 P305
rename ppin fschpin
rename P160 pss_schl_kenr2
rename P305 pss_schl_enr2
label variable pss_schl_kenr2 "PSS Total number of school 1st grade students, Spring 2011"
label variable pss_schl_enr2 "PSS Total number of school students, Spring 2011"
save "${data_directory}pss\pss_s_2.dta", replace
clear

use "${data_directory}pss\pss1112.dta"
keep ppin p190 p305 p160 
rename ppin fschpin
rename p190 pss_schl_1enr3
rename p305 pss_schl_enr3
rename p160 pss_schl_kenr3
label variable pss_schl_1enr3 "PSS Total number of school 1st grade students, Fall 2011"
label variable pss_schl_enr3 "PSS Total number of school students, Fall 2011"
label variable pss_schl_kenr3 "PSS Total number of school K students, Fall 2011"
save "${data_directory}pss\pss_s_3.dta", replace
clear

use "${data_directory}pss\pss1112.dta"
keep ppin p190 p305 p200
rename ppin fschpin
rename p190 pss_schl_1enr4
rename p305 pss_schl_enr4
rename p200 pss_schl_2enr4
label variable pss_schl_1enr4 "PSS Total number of school 1st grade students, Spring 2012"
label variable pss_schl_enr4 "PSS Total number of school students, Spring 2012"
label variable pss_schl_2enr4 "PSS Total number of school 2rd grade students, Spring 2012"
save "${data_directory}pss\pss_s_4.dta", replace
clear

use "${data_directory}pss\pss1314.dta"
rename *, lower
keep ppin p210 p305 p200 p220
rename ppin fschpin
rename p210 pss_schl_3enr7
rename p305 pss_schl_enr7
rename p200 pss_schl_2enr7
rename p220 pss_schl_4enr7
label variable pss_schl_3enr7 "PSS Total number of school 3rd grade students, Spring 2014"
label variable pss_schl_enr7 "PSS Total number of school students, Spring 2014"
label variable pss_schl_2enr7 "PSS Total number of 2nd grade students, Spring 2014"
label variable pss_schl_4enr7 "PSS Total number of 2nd grade students, Spring 2014"
save "${data_directory}pss\pss_s_7.dta", replace
clear

use "${data_directory}pss\pss1516.dta"
keep ppin p230 p305 p220
rename ppin fschpin
rename p230 pss_schl_5enr9
rename p305 pss_schl_enr9
rename p220 pss_schl_4enr9
label variable pss_schl_5enr9 "PSS Total number of school 5th grade students, Spring 2016"
label variable pss_schl_enr9 "PSS Total number of school students, Spring 2016"
label variable pss_schl_4enr9 "PSS Total number of 4th grade students, Spring 2016"
save "${data_directory}pss\pss_s_9.dta", replace
clear

/*******************
INTERPOLATE PSS DATA
********************/
use "${data_directory}pss\pss_s_1.dta"
merge 1:1 fschpin using "${data_directory}pss\pss_s_2.dta"
drop _merge 
merge 1:1 fschpin using "${data_directory}pss\pss_s_3.dta"
drop _merge
merge 1:1 fschpin using "${data_directory}pss\pss_s_4.dta"
drop _merge
merge 1:1 fschpin using "${data_directory}pss\pss_s_7.dta"
drop _merge
merge 1:1 fschpin using "${data_directory}pss\pss_s_9.dta"
drop _merge
save "${data_directory}pss\pss_s_m.dta", replace

replace pss_schl_kenr1 = (pss_schl_kenr1+pss_schl_kenr3)/2
replace pss_schl_enr1 = (pss_schl_enr1+pss_schl_enr3)/2
keep fschpin pss_schl_kenr1 pss_schl_enr1
sort fschpin
save "${data_directory}pss\pss_s_1.dta", replace
clear

use "${data_directory}pss\pss_s_m.dta"
replace pss_schl_kenr2 = (pss_schl_kenr2+pss_schl_kenr3)/2
replace pss_schl_enr2 = (pss_schl_enr2+pss_schl_enr3)/2
keep fschpin pss_schl_kenr2 pss_schl_enr2
sort fschpin
save "${data_directory}pss\pss_s_2.dta", replace
clear

use "${data_directory}pss\pss_s_m.dta"
gen pss_schl_2enr5 = . 
replace pss_schl_2enr5 = (pss_schl_2enr4+pss_schl_2enr7)/2
gen pss_schl_enr5 = . 
replace pss_schl_enr5 = (pss_schl_enr4+pss_schl_enr7)/2
keep fschpin pss_schl_2enr5 pss_schl_enr5 
label variable pss_schl_2enr5 "PSS Total number of school 2nd grade students, Fall 2012"
label variable pss_schl_enr5 "PSS Total number of school students, Fall 2012"
sort fschpin
save "${data_directory}pss\pss_s_5.dta", replace
clear

use "${data_directory}pss\pss_s_m.dta"
gen pss_schl_2enr6 = . 
replace pss_schl_2enr6 = (pss_schl_2enr4+pss_schl_2enr7)/2
gen pss_schl_enr6 = . 
replace pss_schl_enr6 = (pss_schl_enr4+pss_schl_enr7)/2
label variable pss_schl_2enr6 "PSS Total number of school 2nd grade students, Spring 2013"
label variable pss_schl_enr6 "PSS Total number of school students, Spring 2013"
keep fschpin pss_schl_2enr6 pss_schl_enr6 
sort fschpin
save "${data_directory}pss\pss_s_6.dta", replace
clear

use "${data_directory}pss\pss_s_m.dta"
gen pss_schl_4enr8 = .
replace pss_schl_4enr8 = (pss_schl_4enr7+pss_schl_4enr9)/2
gen pss_schl_enr8 = .
replace pss_schl_enr8 = (pss_schl_enr7+pss_schl_enr9)/2
label variable pss_schl_4enr8 "PSS Total number of school 4th grade students, Spring 2015"
label variable pss_schl_enr8 "PSS Total number of school students, Spring 2015"
keep fschpin pss_schl_4enr8 pss_schl_enr8 
sort fschpin
save "${data_directory}pss\pss_s_8.dta", replace
clear

use "${data_directory}pss\pss_s_1.dta"
rename fschpin f1schpin
sort f1schpin
save "${data_directory}pss\pss_s_1.dta", replace
clear

use "${data_directory}pss\pss_s_2.dta"
rename fschpin f2schpin
sort f2schpin
save "${data_directory}pss\pss_s_2.dta", replace
clear

use "${data_directory}pss\pss_s_3.dta"
rename fschpin f3schpin
drop pss_schl_kenr3
sort f3schpin
save "${data_directory}pss\pss_s_3.dta", replace
clear

use "${data_directory}pss\pss_s_4.dta"
rename fschpin f4schpin
drop pss_schl_2enr4
sort f4schpin
save "${data_directory}pss\pss_s_4.dta", replace
clear

use "${data_directory}pss\pss_s_5.dta"
rename fschpin f5schpin
sort f5schpin
save "${data_directory}pss\pss_s_5.dta", replace
clear

use "${data_directory}pss\pss_s_6.dta"
rename fschpin f6schpin
sort f6schpin
save "${data_directory}pss\pss_s_6.dta", replace
clear

use "${data_directory}pss\pss_s_7.dta"
rename fschpin f7schpin
drop pss_schl_2enr7 pss_schl_4enr7
sort f7schpin
save "${data_directory}pss\pss_s_7.dta", replace
clear

use "${data_directory}pss\pss_s_8.dta"
rename fschpin f8schpin
sort f8schpin
save "${data_directory}pss\pss_s_8.dta", replace
clear

use "${data_directory}pss\pss_s_9.dta"
rename fschpin f9schpin
drop pss_schl_4enr9
sort f9schpin
save "${data_directory}pss\pss_s_9.dta", replace
clear

/**************************************
CLEAN NON-FISCAL DISTRICT DATA FROM CCD
***************************************/
use "${data_directory}ccd\district_level\ccd_d_1011.dta"
rename *, lower
destring leaid, replace 
keep leaid kg member
replace kg = . if kg == -2 | kg == -9 | kg == -1
replace member = . if member == -2 | member == -9 | member == -1
rename kg ccd_dstr_kenr1
rename member ccd_dstr_enr1
rename leaid f1ccdlea
label variable ccd_dstr_kenr1 "CCD Total number of district Kindergarten students, Fall 2010"
label variable ccd_dstr_enr1 "CCD Total number of district students, Fall 2010"
sort f1ccdlea
save "${data_directory}ccd\district_level\ccd_d_1.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1011.dta"
rename *, lower
destring leaid, replace 
keep leaid kg member
replace kg = . if kg == -2 | kg == -9 | kg == -1
replace member = . if member == -2 | member == -9 | member == -1
rename kg ccd_dstr_kenr2
rename member ccd_dstr_enr2
rename leaid f2ccdlea
label variable ccd_dstr_kenr2 "CCD Total number of district Kindergarten students, Spring 2011"
label variable ccd_dstr_enr2 "CCD Total number of district students, Spring 2011"
sort f2ccdlea
save "${data_directory}ccd\district_level\ccd_d_2.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1112.dta"
rename *, lower
destring leaid, replace 
keep leaid g01 member
replace g01 = . if g01 == -2 | g01 == -9 | g01 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g01 ccd_dstr_1enr3
rename member ccd_dstr_enr3
rename leaid f3ccdlea
label variable ccd_dstr_1enr3 "CCD Total number of district 1st grade students, Fall 2011"
label variable ccd_dstr_enr3 "CCD Total number of district students, Fall 2011"
sort f3ccdlea
save "${data_directory}ccd\district_level\ccd_d_3.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1112.dta"
rename *, lower
destring leaid, replace 
keep leaid g01 member
replace g01 = . if g01 == -2 | g01 == -9 | g01 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g01 ccd_dstr_1enr4
rename member ccd_dstr_enr4
rename leaid f4ccdlea
label variable ccd_dstr_1enr4 "CCD Total number of district 1st grade students, Spring 2012"
label variable ccd_dstr_enr4 "CCD Total number of district students, Spring 2012"
sort f4ccdlea
save "${data_directory}ccd\district_level\ccd_d_4.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1213.dta"
rename *, lower
destring leaid, replace 
keep leaid g02 member
replace g02 = . if g02 == -2 | g02 == -9 | g02 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g02 ccd_dstr_2enr5
rename member ccd_dstr_enr5
rename leaid f5ccdlea
label variable ccd_dstr_2enr5 "CCD Total number of district 2nd grade students, Fall 2012"
label variable ccd_dstr_enr5 "CCD Total number of district students, Fall 2012"
sort f5ccdlea
save "${data_directory}ccd\district_level\ccd_d_5.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1213.dta"
rename *, lower
destring leaid, replace 
keep leaid g02 member
replace g02 = . if g02 == -2 | g02 == -9 | g02 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g02 ccd_dstr_2enr6
rename member ccd_dstr_enr6
rename leaid f6ccdlea
label variable ccd_dstr_2enr6 "CCD Total number of district 2nd grade students, Spring 2013"
label variable ccd_dstr_enr6 "CCD Total number of district students, Spring 2013"
sort f6ccdlea
save "${data_directory}ccd\district_level\ccd_d_6.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1314.dta"
rename *, lower
destring leaid, replace 
keep leaid g03 member
replace g03 = . if g03 == -2 | g03 == -9 | g03 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g03 ccd_dstr_3enr7
rename member ccd_dstr_enr7
rename leaid f7ccdlea
label variable ccd_dstr_3enr7 "CCD Total number of district 2nd grade students, Spring 2014"
label variable ccd_dstr_enr7 "CCD Total number of district students, Spring 2014"
sort f7ccdlea
save "${data_directory}ccd\district_level\ccd_d_7.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1415.dta"
rename *, lower
destring leaid, replace 
keep leaid g04 member
replace g04 = . if g04 == -2 | g04 == -9 | g04 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g04 ccd_dstr_4enr8
rename member ccd_dstr_enr8
rename leaid f8ccdlea
label variable ccd_dstr_4enr8 "CCD Total number of district 2nd grade students, Spring 2015"
label variable ccd_dstr_enr8 "CCD Total number of district students, Spring 2015"
sort f8ccdlea
save "${data_directory}ccd\district_level\ccd_d_8.dta", replace
clear

use "${data_directory}ccd\district_level\ccd_d_1516.dta"
rename *, lower
destring leaid, replace 
keep leaid g05 member
replace g05 = . if g05 == -2 | g05 == -9 | g05 == -1
replace member = . if member == -2 | member == -9 | member == -1
rename g05 ccd_dstr_5enr9
rename member ccd_dstr_enr9
rename leaid f9ccdlea
label variable ccd_dstr_5enr9 "CCD Total number of district 2nd grade students, Spring 2016"
label variable ccd_dstr_enr9 "CCD Total number of district students, Spring 2016"
sort f9ccdlea
save "${data_directory}ccd\district_level\ccd_d_9.dta", replace
clear

/****************************************
CLEAN FISCAL DISTRICT-LEVEL DATA FROM CCD
*****************************************/
use "${data_directory}ccd\district_level\fisc_ccd_d_1011.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp1
rename leaid f1ccdlea
label variable ccd_dstr_exp1 "CCD Total district expenditures, Fall 2010"
sort f1ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_1.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1011.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp2
rename leaid f2ccdlea
label variable ccd_dstr_exp2 "CCD Total district expenditures, Spring 2011"
sort f2ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_2.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1112.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp3
rename leaid f3ccdlea
label variable ccd_dstr_exp3 "CCD Total district expenditures, Fall 2011"
sort f3ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_3.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1112.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp4
rename leaid f4ccdlea
label variable ccd_dstr_exp4 "CCD Total district expenditures, Spring 2012"
sort f4ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_4.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1213.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp5
rename leaid f5ccdlea
label variable ccd_dstr_exp5 "CCD Total district expenditures, Fall 2012"
sort f5ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_5.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1213.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp6
rename leaid f6ccdlea
label variable ccd_dstr_exp6 "CCD Total district expenditures, Spring 2013"
sort f6ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_6.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1314.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp7
rename leaid f7ccdlea
label variable ccd_dstr_exp7 "CCD Total district expenditures, Spring 2014"
sort f7ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_7.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1415.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp8
rename leaid f8ccdlea
label variable ccd_dstr_exp8 "CCD Total district expenditures, Spring 2015"
sort f8ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_8.dta", replace
clear

use "${data_directory}ccd\district_level\fisc_ccd_d_1516.dta"
rename *, lower
destring leaid, replace 
keep leaid totalexp 
replace totalexp = . if totalexp < 0 
rename totalexp ccd_dstr_exp9
rename leaid f9ccdlea
label variable ccd_dstr_exp9 "CCD Total district expenditures, Spring 2016"
sort f9ccdlea
save "${data_directory}ccd\district_level\f_ccd_d_9.dta", replace
clear

/*************************************
CREATE DISTRCIT EXPENDITURES PER PUPIL    
**************************************/
use "${data_directory}ccd\district_level\f_ccd_d_1.dta"
merge 1:1 f1ccdlea using "${data_directory}ccd\district_level\ccd_d_1.dta"
drop _merge
drop ccd_dstr_kenr1 
gen ccd_dstr_exppp1 = . 
replace ccd_dstr_exppp1 = ccd_dstr_exp1/ccd_dstr_enr1 
replace ccd_dstr_exppp1 = round(ccd_dstr_exppp1, 0.01)
label variable ccd_dstr_exppp1 "CCD Total district expenditures per pupil, Fall 2010"
drop ccd_dstr_exp1 ccd_dstr_enr1 
sort f1ccdlea
save "${data_directory}ccd\district_level\ccd_d_1.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_2.dta"
merge 1:1 f2ccdlea using "${data_directory}ccd\district_level\ccd_d_2.dta"
drop _merge
drop ccd_dstr_kenr2 
gen ccd_dstr_exppp2 = . 
replace ccd_dstr_exppp2 = ccd_dstr_exp2/ccd_dstr_enr2 
replace ccd_dstr_exppp2 = round(ccd_dstr_exppp2, 0.01)
label variable ccd_dstr_exppp2 "CCD Total district expenditures per pupil, Spring 2011"
drop ccd_dstr_exp2 ccd_dstr_enr2 
sort f2ccdlea
save "${data_directory}ccd\district_level\ccd_d_2.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_3.dta"
merge 1:1 f3ccdlea using "${data_directory}ccd\district_level\ccd_d_3.dta"
drop _merge
drop ccd_dstr_1enr3 
gen ccd_dstr_exppp3 = . 
replace ccd_dstr_exppp3 = ccd_dstr_exp3/ccd_dstr_enr3 
replace ccd_dstr_exppp3 = round(ccd_dstr_exppp3, 0.01)
label variable ccd_dstr_exppp3 "CCD Total district expenditures per pupil, Fall 2011"
drop ccd_dstr_exp3 ccd_dstr_enr3 
sort f3ccdlea
save "${data_directory}ccd\district_level\ccd_d_3.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_4.dta"
merge 1:1 f4ccdlea using "${data_directory}ccd\district_level\ccd_d_4.dta"
drop _merge
drop ccd_dstr_1enr4 

replace ccd_dstr_exp4 = . if ccd_dstr_exp4 == 0 
replace ccd_dstr_enr4 = . if ccd_dstr_enr4 == 0 

gen ccd_dstr_exppp4 = . 
replace ccd_dstr_exppp4 = ccd_dstr_exp4/ccd_dstr_enr4 
replace ccd_dstr_exppp4 = round(ccd_dstr_exppp4, 0.01)
label variable ccd_dstr_exppp4 "CCD Total district expenditures per pupil, Spring 2012"

sum ccd_dstr_exppp4, det
_pctile ccd_dstr_exppp4, p(98)
ret li
replace ccd_dstr_exppp4 = . if ccd_dstr_exppp4 > `r(r1)' & ccd_dstr_exppp4 < .

sum ccd_dstr_exppp4, det
_pctile ccd_dstr_exppp4, p(2)
ret li
replace ccd_dstr_exppp4 = . if ccd_dstr_exppp4 < `r(r1)'

drop ccd_dstr_exp4 ccd_dstr_enr4
sort  f4ccdlea
save "${data_directory}ccd\district_level\ccd_d_4.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_5.dta"
merge 1:1 f5ccdlea using "${data_directory}ccd\district_level\ccd_d_5.dta"
drop _merge
drop ccd_dstr_2enr5 
gen ccd_dstr_exppp5 = . 
replace ccd_dstr_exppp5 = ccd_dstr_exp5/ccd_dstr_enr5 
replace ccd_dstr_exppp5 = round(ccd_dstr_exppp5, 0.01)
label variable ccd_dstr_exppp5 "CCD Total district expenditures per pupil, Fall 2012"
drop ccd_dstr_exp5 ccd_dstr_enr5 
sort f5ccdlea
save "${data_directory}ccd\district_level\ccd_d_5.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_6.dta"
merge 1:1 f6ccdlea using "${data_directory}ccd\district_level\ccd_d_6.dta"
drop _merge
drop ccd_dstr_2enr6 
gen ccd_dstr_exppp6 = . 
replace ccd_dstr_exppp6 = ccd_dstr_exp6/ccd_dstr_enr6 
replace ccd_dstr_exppp6 = round(ccd_dstr_exppp6, 0.01)
label variable ccd_dstr_exppp6 "CCD Total district expenditures per pupil, Spring 2013"
drop ccd_dstr_exp6 ccd_dstr_enr6 
sort f6ccdlea
save "${data_directory}ccd\district_level\ccd_d_6.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_7.dta"
merge 1:1 f7ccdlea using "${data_directory}ccd\district_level\ccd_d_7.dta"
drop _merge
drop ccd_dstr_3enr7 
gen ccd_dstr_exppp7 = . 
replace ccd_dstr_exppp7 = ccd_dstr_exp7/ccd_dstr_enr7 
replace ccd_dstr_exppp7 = round(ccd_dstr_exppp7, 0.01)
label variable ccd_dstr_exppp7 "CCD Total district expenditures per pupil, Spring 2014"
drop ccd_dstr_exp7 ccd_dstr_enr7 
sort f7ccdlea
save "${data_directory}ccd\district_level\ccd_d_7.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_8.dta"
merge 1:1 f8ccdlea using "${data_directory}ccd\district_level\ccd_d_8.dta"
drop _merge
drop ccd_dstr_4enr8 
gen ccd_dstr_exppp8 = . 
replace ccd_dstr_exppp8 = ccd_dstr_exp8/ccd_dstr_enr8 
replace ccd_dstr_exppp8 = round(ccd_dstr_exppp8, 0.01)
label variable ccd_dstr_exppp8 "CCD Total district expenditures per pupil, Spring 2015"
drop ccd_dstr_exp8 ccd_dstr_enr8 
sort f8ccdlea
save "${data_directory}ccd\district_level\ccd_d_8.dta", replace
clear

use "${data_directory}ccd\district_level\f_ccd_d_9.dta"
merge 1:1 f9ccdlea using "${data_directory}ccd\district_level\ccd_d_9.dta"
drop _merge
drop ccd_dstr_5enr9 
gen ccd_dstr_exppp9 = . 
replace ccd_dstr_exppp9 = ccd_dstr_exp9/ccd_dstr_enr9 
replace ccd_dstr_exppp9 = round(ccd_dstr_exppp9, 0.01)
label variable ccd_dstr_exppp9 "CCD Total district expenditures per pupil, Spring 2016"
drop ccd_dstr_exp9 ccd_dstr_enr9 
sort f9ccdlea
save "${data_directory}ccd\district_level\ccd_d_9.dta", replace
clear

erase "${data_directory}ccd\district_level\f_ccd_d_1.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_2.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_3.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_4.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_5.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_6.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_7.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_8.dta"
erase "${data_directory}ccd\district_level\f_ccd_d_9.dta"

/***************************
MERGE CCD AND PSS WITH ECLSK
****************************/
use "${data_directory}eclsk11\v02_eclsk11_clean.dta"
local nums 1 2 3 4 5 6 7 8 9 
foreach i of local nums {
	destring f`i'ccdlea, replace
}

/*merge CCD district-level data*/ 
replace f1ccdlea = . if f1ccdlea == -1
sort f1ccdlea childid
merge m:1 f1ccdlea using "${data_directory}ccd\district_level\ccd_d_1.dta"
drop if _merge == 2
drop _merge

replace f2ccdlea = . if f2ccdlea == -1
sort f2ccdlea childid
merge m:1 f2ccdlea using "${data_directory}ccd\district_level\ccd_d_2.dta"
drop if _merge == 2
drop _merge

replace f3ccdlea = . if f3ccdlea == -1
sort f3ccdlea childid
merge m:1 f3ccdlea using "${data_directory}ccd\district_level\ccd_d_3.dta"
drop if _merge == 2
drop _merge 

replace f4ccdlea = . if f4ccdlea == -1
sort f4ccdlea childid
merge m:1 f4ccdlea using "${data_directory}ccd\district_level\ccd_d_4.dta"
drop if _merge == 2 
drop _merge 

replace f5ccdlea = . if f5ccdlea == -1
sort f5ccdlea childid
merge m:1 f5ccdlea using "${data_directory}ccd\district_level\ccd_d_5.dta"
drop if _merge == 2 
drop _merge 

replace f6ccdlea = . if f6ccdlea == -1
sort f6ccdlea childid
merge m:1 f6ccdlea using "${data_directory}ccd\district_level\ccd_d_6.dta"
drop if _merge == 2 
drop _merge 

replace f7ccdlea = . if f7ccdlea == -1
sort f7ccdlea childid
merge m:1 f7ccdlea using "${data_directory}ccd\district_level\ccd_d_7.dta"
drop if _merge == 2 
drop _merge 

replace f8ccdlea = . if f8ccdlea == -1
sort f8ccdlea childid
merge m:1 f8ccdlea using "${data_directory}ccd\district_level\ccd_d_8.dta"
drop if _merge == 2 
drop _merge 

replace f9ccdlea = . if f9ccdlea == -1
sort f9ccdlea childid
merge m:1 f9ccdlea using "${data_directory}ccd\district_level\ccd_d_9.dta"
drop if _merge == 2 
drop _merge 

/*merge CCD school-level data*/ 
replace f1ccdsid = "" if f1ccdsid == "-1"
sort f1ccdsid childid
merge m:1 f1ccdsid using "${data_directory}ccd\school_level\ccd_s_1.dta"
drop if _merge == 2 
drop _merge 

replace f2ccdsid = "" if f2ccdsid == "-1"
sort f2ccdsid childid
merge m:1 f2ccdsid using "${data_directory}ccd\school_level\ccd_s_2.dta"
drop if _merge == 2 
drop _merge

replace f3ccdsid = "" if f3ccdsid == "-1"
sort f3ccdsid childid
merge m:1 f3ccdsid using "${data_directory}ccd\school_level\ccd_s_3.dta"
drop if _merge == 2 
drop _merge 

replace f4ccdsid = "" if f4ccdsid == "-1"
sort f4ccdsid childid
merge m:1 f4ccdsid using "${data_directory}ccd\school_level\ccd_s_4.dta"
drop if _merge == 2 
drop _merge 

replace f5ccdsid = "" if f5ccdsid == "-1"
sort f5ccdsid childid
merge m:1 f5ccdsid using "${data_directory}ccd\school_level\ccd_s_5.dta"
drop if _merge == 2 
drop _merge 

replace f6ccdsid = "" if f6ccdsid == "-1"
sort f6ccdsid childid
merge m:1 f6ccdsid using "${data_directory}ccd\school_level\ccd_s_6.dta"
drop if _merge == 2 
drop _merge 

replace f7ccdsid = "" if f7ccdsid == "-1"
sort f7ccdsid childid
merge m:1 f7ccdsid using "${data_directory}ccd\school_level\ccd_s_7.dta"
drop if _merge == 2 
drop _merge 

replace f8ccdsid = "" if f8ccdsid == "-1"
sort f8ccdsid childid
merge m:1 f8ccdsid using "${data_directory}ccd\school_level\ccd_s_8.dta"
drop if _merge == 2 
drop _merge 

replace f9ccdsid = "" if f9ccdsid == "-1"
sort f9ccdsid childid
merge m:m f9ccdsid using "${data_directory}ccd\school_level\ccd_s_9.dta"
drop if _merge == 2 
drop _merge 

/*merge PSS school-level data*/ 
replace f1schpin = "" if f1schpin == "-1"
sort f1schpin childid
merge m:1 f1schpin using "${data_directory}pss\pss_s_1.dta"
drop if _merge == 2
drop _merge

replace f2schpin = "" if f2schpin == "-1"
sort f2schpin childid
merge m:1 f2schpin using "${data_directory}pss\pss_s_2.dta"
drop if _merge == 2
drop _merge

replace f3schpin = "" if f3schpin == "-1"
sort f3schpin childid
merge m:1 f3schpin using "${data_directory}pss\pss_s_3.dta"
drop if _merge == 2
drop _merge

replace f4schpin = "" if f4schpin == "-1"
sort f4schpin childid
merge m:1 f4schpin using "${data_directory}pss\pss_s_4.dta"
drop if _merge == 2
drop _merge

replace f5schpin = "" if f5schpin == "-1"
sort f5schpin childid
merge m:1 f5schpin using "${data_directory}pss\pss_s_5.dta"
drop if _merge == 2
drop _merge

replace f6schpin = "" if f6schpin == "-1"
sort f6schpin childid
merge m:1 f6schpin using "${data_directory}pss\pss_s_6.dta"
drop if _merge == 2
drop _merge

replace f7schpin = "" if f7schpin == "-1"
sort f7schpin childid
merge m:1 f7schpin using "${data_directory}pss\pss_s_7.dta"
drop if _merge == 2
drop _merge

replace f8schpin = "" if f8schpin == "-1"
sort f8schpin childid
merge m:1 f8schpin using "${data_directory}pss\pss_s_8.dta"
drop if _merge == 2
drop _merge

replace f9schpin = "" if f9schpin == "-1"
sort f9schpin childid
merge m:1 f9schpin using "${data_directory}pss\pss_s_9.dta"
drop if _merge == 2
drop _merge

erase "${data_directory}ccd\district_level\ccd_d_1.dta"
erase "${data_directory}ccd\district_level\ccd_d_2.dta"
erase "${data_directory}ccd\district_level\ccd_d_3.dta"
erase "${data_directory}ccd\district_level\ccd_d_4.dta"
erase "${data_directory}ccd\district_level\ccd_d_5.dta"
erase "${data_directory}ccd\district_level\ccd_d_6.dta"
erase "${data_directory}ccd\district_level\ccd_d_7.dta"
erase "${data_directory}ccd\district_level\ccd_d_8.dta"
erase "${data_directory}ccd\district_level\ccd_d_9.dta"

erase "${data_directory}ccd\school_level\ccd_s_1.dta"
erase "${data_directory}ccd\school_level\ccd_s_2.dta"
erase "${data_directory}ccd\school_level\ccd_s_3.dta"
erase "${data_directory}ccd\school_level\ccd_s_4.dta"
erase "${data_directory}ccd\school_level\ccd_s_5.dta"
erase "${data_directory}ccd\school_level\ccd_s_6.dta"
erase "${data_directory}ccd\school_level\ccd_s_7.dta"
erase "${data_directory}ccd\school_level\ccd_s_8.dta"
erase "${data_directory}ccd\school_level\ccd_s_9.dta"

erase "${data_directory}pss\pss_s_1.dta"
erase "${data_directory}pss\pss_s_2.dta"
erase "${data_directory}pss\pss_s_3.dta"
erase "${data_directory}pss\pss_s_4.dta"
erase "${data_directory}pss\pss_s_5.dta"
erase "${data_directory}pss\pss_s_6.dta"
erase "${data_directory}pss\pss_s_7.dta"
erase "${data_directory}pss\pss_s_8.dta"
erase "${data_directory}pss\pss_s_9.dta"
erase "${data_directory}pss\pss_s_m.dta"

/***************************************
COMBINE PSS AND CCD ENROLLMENT VARIABLES  
****************************************/
rename ccd_schl_enr1 schl_enr1 
rename ccd_schl_enr2 schl_enr2 
rename ccd_schl_enr3 schl_enr3 
rename ccd_schl_enr4 schl_enr4 
rename ccd_schl_enr5 schl_enr5 
rename ccd_schl_enr6 schl_enr6 
rename ccd_schl_enr7 schl_enr7 
rename ccd_schl_enr8 schl_enr8 
rename ccd_schl_enr9 schl_enr9

replace schl_enr3 = pss_schl_enr3 if schl_enr3 == .
replace schl_enr4 = pss_schl_enr4 if schl_enr4 == .
replace schl_enr7 = pss_schl_enr7 if schl_enr7 == .
replace schl_enr9 = pss_schl_enr9 if schl_enr9 == .

label variable schl_enr1 "Total number of school students, Kindergarten Fall"
label variable schl_enr2 "Total number of school students, Kindergarten Spring"
label variable schl_enr3 "Total number of school students, 1st grade Fall"
label variable schl_enr4 "Total number of school students, 1st grade Spring"
label variable schl_enr5 "Total number of school students, 2nd grade Fall"
label variable schl_enr6 "Total number of school students, 2nd grade Spring"
label variable schl_enr7 "Total number of school students, 3rd grade"
label variable schl_enr8 "Total number of school students, 4th grade"
label variable schl_enr9 "Total number of school students, 5th grade"

replace schl_enr4 = . if stotenrl4 == 1 & schl_enr4 == 1408
replace schl_enr4 = . if stotenrl4 == 3 & schl_enr4 == 1120
replace schl_enr4 = . if stotenrl4 == 4 & schl_enr4 == 1005
replace schl_enr4 = . if stotenrl4 == 3 & schl_enr4 == 917
replace schl_enr4 = . if schl_enr4 == 0

rename ccd_schl_kenr1 schl_kenr1 
rename ccd_schl_kenr2 schl_kenr2 
rename ccd_schl_1enr3 schl_1enr3 
rename ccd_schl_1enr4 schl_1enr4 
rename ccd_schl_2enr5 schl_2enr5 
rename ccd_schl_2enr6 schl_2enr6 
rename ccd_schl_3enr7 schl_3enr7 
rename ccd_schl_4enr8 schl_4enr8 
rename ccd_schl_5enr9 schl_5enr9

replace schl_1enr3 = pss_schl_1enr3 if schl_1enr3 == .
replace schl_1enr4 = pss_schl_1enr4 if schl_1enr4 == .
replace schl_enr7 = pss_schl_3enr7 if schl_3enr7 == .
replace schl_enr9 = pss_schl_5enr9 if schl_5enr9 == .

label variable schl_kenr1 "Total number of Kindergarten school students, Kindergarten Fall"
label variable schl_kenr2 "Total number of Kindergarten school students, Kindergarten Spring"
label variable schl_1enr3 "Total number of 1st grade school students, 1st grade Fall"
label variable schl_1enr4 "Total number of 1st grade school students, 1st grade Spring"
label variable schl_2enr5 "Total number of 2nd grade school students, 2nd grade Fall"
label variable schl_2enr6 "Total number of 2nd grade school students, 2nd grade Spring"
label variable schl_3enr7 "Total number of 3rd grade chool students, 3rd grade"
label variable schl_4enr8 "Total number of 4th grade school students, 4th grade"
label variable schl_5enr9 "Total number of 5th grade school students, 5th grade"

drop pss*

/**************************
CREATE TEACHER-PUPIL RATIOS
***************************/
/*full-time regular classroom teachers*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	gen strg_pp_`i' = (strgl`i'/schl_enr`i')*100
	label variable strg_pp_`i' "Teachers-per-100-students - regular classroom teachers, ``i''"
}

sum strg_pp_4, det
replace strg_pp_4 = . if strg_pp_4 < r(p1) | strg_pp_4 > r(p99)

/*full-time elective teachers*/
rename selctv2 sartstf2
local nums 2 4 6 7 8 9 
foreach i of local nums {
	gen start_pp_`i' = (sartstf`i'/schl_enr`i')*100
	label variable start_pp_`i' "Teachers-per-100-students - elective teachers, ``i''"
}

sum start_pp_4, det
replace start_pp_4 = . if start_pp_4 > r(p99) & start_pp_4 < .

drop sarts* 

/*full-time gym/health teachers*/
local nums 4 6 7 8 9 
foreach i of local nums {
	gen stgym_pp_`i' = (sgymstf`i'/schl_enr`i')*100
	label variable stgym_pp_`i' "Teachers-per-100-students - gym/health teachers, ``i''"
}

sum stgym_pp_4, det
replace stgym_pp_4 = . if stgym_pp_4 > r(p99) & stgym_pp_4 < .

drop sgymstf*

/*full-time special education teachers*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	gen stsp_pp_`i' = (spedstf`i'/schl_enr`i')*100
	label variable stsp_pp_`i' "Teachers-per-100-students - special education teachers, ``i''"
}

sum stsp_pp_4, det
_pctile stsp_pp_4, p(98)
ret li
replace stsp_pp_4 = . if stsp_pp_4 > `r(r1)' & stsp_pp_4 < 100000

drop spedstf*

/*full-time ESL teachers*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	gen stesl_pp_`i' = (seslstf`i'/schl_enr`i')*100
	label variable stesl_pp_`i' "Teachers-per-100-students - ESL/bilingual teachers, ``i''"
}

sum stesl_pp_4, det
_pctile stesl_pp_4, p(98)
ret li
replace stesl_pp_4 = . if stesl_pp_4 > `r(r1)' & stesl_pp_4 < .

drop seslstf*

/*full-time reading teachers/specialists*/
gen strd_pp_2 = schl_enr2/srdstf2
label variable strd_pp_2 "Teachers-per-100-students - reading teachers, Kindergarten Spring"
drop srdstf2 

/*full-time G/T teachers*/
local nums 2 4 6
foreach i of local nums {
	gen stgft_pp_`i' = (sgftstf`i'/schl_enr`i')*100
	label variable stgft_pp_`i' "Teachers-per-100-students - G/T teachers, ``i''"
}

sum stgft_pp_4, det
_pctile stgft_pp_4, p(98)
ret li
replace stgft_pp_4 = . if stgft_pp_4 > `r(r1)' & stgft_pp_4 < .

drop sgftstf*

/*full-time school nurses/health professionals*/
local nums 2 4 6
foreach i of local nums {
	gen stnrs_pp_`i' = (snrsstf`i'/schl_enr`i')*100
	label variable stnrs_pp_`i' "Teachers-per-100-students - school nurses, ``i''"
}

sum stnrs_pp_4, det 
replace stnrs_pp_4 = . if stnrs_pp_4 > r(p99) & stnrs_pp_4 < .

drop snrsstf*

/*full-time school psychologists/social workers*/
local nums 2 4 6
foreach i of local nums {
	gen stfpsy_pp_`i' = (spsyfstf`i'/schl_enr`i')*100
	label variable stfpsy_pp_`i' "Teachers-per-100-students - school psychologists, ``i''"
}

sum stfpsy_pp_4, det
replace stfpsy_pp_4 = . if stfpsy_pp_4 > r(p99) & stfpsy_pp_4 < .

drop spsyfstf*

/*part-time school psychologists/social workers*/
local nums 2 4 6
foreach i of local nums {
	gen stppsy_pp_`i' = (spsypstf`i'/schl_enr`i')*100
	label variable stppsy_pp_`i' "Teachers-per-100-students - school psychologists part-time, ``i''"
}

drop spsypstf*

/*full-time para professionals*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	gen stpar_pp_`i' = (sparastf`i'/schl_enr`i')*100
	label variable stpar_pp_`i' "Teachers-per-100-students - para professionals, ``i''"
}

sum stpar_pp_4, det
replace stpar_pp_4 = . if stpar_pp_4 > r(p99) & stpar_pp_4 < .

drop sparastf*

/*full-time librarians*/
local nums 2 4 6
foreach i of local nums {
	gen stlib_pp_`i' = (slibstf`i'/schl_enr`i')*100
	label variable stlib_pp_`i' "Teachers-per-100-students - librarians, ``i''"
}

sum stlib_pp_4, det
replace stlib_pp_4 = . if stlib_pp_4 > r(p99) & stlib_pp_4 < .

drop slibstf*

/*full-time computer teachers*/
local nums 4 6
foreach i of local nums {
	gen stcmp_pp_`i' = (scmpstf`i'/schl_enr`i')*100
	label variable stcmp_pp_`i' "Teachers-per-100-students - computer teachers, ``i''"
}

sum stcmp_pp_4, det
replace stcmp_pp_4 = . if stcmp_pp_4 > r(p99) & stcmp_pp_4 < .

drop scmpstf*

/*total teachers at school*/
local nums 2 4 6 9
foreach i of local nums {
	gen sttot_pp_`i' = (stnum`i'/schl_enr`i')*100
	label variable sttot_pp_`i' "Teachers-per-100-students - total, ``i''"
}

sum sttot_pp_4, det 
replace sttot_pp_4 = . if sttot_pp_4 < r(p1)
replace sttot_pp_4 = . if sttot_pp_4 > r(p99) & sttot_pp_4 < .

/*teacher turnover rate*/ 
label define turnlbl 0 "No turnover" 1 "At least some turnover"
local nums 2 4 6 9
foreach i of local nums {
	gen sttrn`i' = (slftt`i'/stnum`i')
	replace sttrn`i'=1 if sttrn`i'>0 & sttrn`i'<9999999
	label values sttrn`i' turnlbl
	label variable sttrn`i' "Nonzero teacher turnover rate, ``i''"
}
	
/********
SAVE DATA
*********/
save "${data_directory}eclsk11\v03_eclsk11_ccd.dta", replace

clear

log close
