#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}05_create_v05_eclsk11_ncdb.log", replace 

/******************************************************
PROGRAM NAME: 05_create_eclsk11_ncdb.do
AUTHOR: KW/GW
PURPOSE: Merge ECLS-K with selected variables from NCDB
*******************************************************/

/**************
INPUT NCDB DATA
***************/
import delimited "${data_directory}ncdb\ncdb_raw.csv", encoding(ISO-8859-1) 

keep ///
	geo2010 ///
	trctpop1 ///
	educ81a educ111a educ121a educ151a educa1a educ161a educpp1a ///
	ffh1ad ffh1an ///
	povrat1ad povrat1an /// 
	unempt1an unempt1ad ///
	shrwht1n shrblk1n shrhsp1n

format geo2010 %12.0f

/*******************
CREATE NEW VARIABLES
********************/
/*educational composition*/
gen nhlesshs1=(educ81a+educ111a)/educpp1a 
gen nhhsgrad1=(educ121a)/educpp1a 
gen nhsomcol1=(educ151a+educa1a)/educpp1a 
gen nhcolgrd1=(educ161a)/educpp1a 
foreach v in nhlesshs1 nhhsgrad1 nhsomcol1 nhcolgrd1 { 
	replace `v'=. if inrange(`v',1,999) 
	} 

label var nhlesshs1 "Tract proportion with less than HS"
label var nhhsgrad1 "Tract proportion with HS diploma"
label var nhsomcol1 "Tract proportion with some college"
label var nhcolgrd1 "Tract proportion with BA degree"

sum nh*

/*proportion of female-headed families*/
gen nhfemhd1=ffh1an/ffh1ad 
replace nhfemhd1=. if inrange(nhfemhd1,1,999) 
label var nhfemhd1 "Tract proportion female-headed households"
sum nhfemhd1, detail

/*poverty rate*/ 
gen nhpovrt1=povrat1an/povrat1ad 
label var nhpovrt1 "Tract poverty rate"
sum nhpovrt1, detail

/*unemployment rate*/
gen nhunemprt1=unempt1an/unempt1ad
label var nhunemprt1 "Tract unemployment rate"
sum nhunemprt1, detail 

/*racial composition*/
gen nhshrwht1=shrwht1n/trctpop1 
replace nhshrwht1=. if inrange(nhshrwht1,1,999) 
label var nhshrwht1 "Tract proportion white"
sum nhshrwht1, detail

gen nhshrblk1=shrblk1n/trctpop1 
replace nhshrblk1=. if inrange(nhshrblk1,1,999) 
label var nhshrblk1 "Tract proportion black"
sum nhshrblk1, detail

gen nhshrhsp1=shrhsp1n/trctpop1 
replace nhshrhsp1=. if inrange(nhshrhsp1,1,999) 
label var nhshrhsp1 "Tract proportion hispanic"
sum nhshrhsp1, detail 

keep geo2010 nhlesshs1 nhhsgrad1 nhsomcol1 nhcolgrd1 nhfemhd1 nhpovrt1 nhunemprt1 nhshrwht1 nhshrblk1 nhshrhsp1

save "${data_directory}ncdb/ncdb_temp.dta", replace  

/***************
MERGE WITH ECLSK
****************/
use "${data_directory}eclsk11\v04_eclsk11_valAdd.dta", clear
destring p1centrc, gen(geo2010)

merge m:1 geo2010 using "${data_directory}ncdb/ncdb_temp.dta"
drop if _merge == 2
drop _merge 

erase "${data_directory}ncdb/ncdb_temp.dta"

local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
rename f`i'centrc hcensus`i'
rename p`i'centrc scensus`i'
}

local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
destring hcensus`i', replace
destring scensus`i', replace
}

save "${data_directory}\eclsk11\v05_eclsk11_ncdb.dta", replace

clear

log close
