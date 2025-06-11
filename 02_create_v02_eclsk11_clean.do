#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\eclsk11\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}02_create_v02_eclsk11_clean.log", replace 

/*******************************************
PROGRAM NAME: 02_create_v02_eclsk11_clean.do
AUTHOR: KW/GW
PURPOSE: clean raw ECLS-K 2011 data
********************************************/

use "${data_directory}v01_eclsk11_raw.dta"

/*****************
MISSING DATA CODES 
******************/
/* 
item nonresponse:	-7 Refused, -8 Don't know, and -9 Not ascertained 
panel attrition:	. or " " 						
system missing: 	-1 not applicable/legit skip, -4 admin error, and -5 item not asked
*/

/*********************
SURVEY WAVE SUFFIX KEY 
**********************/
/* 
GRADE		 SUFFIX			SEASN		SCHL YR		
Kindergarten 	1			Fall     	2010-11  	  
Kindergarten 	2			Spring   	2010-11		
1st grade	 	3			Fall     	2011-12 
1st grade	 	4			Spring   	2011-12  	
2nd grade	 	5			Fall     	2012-13  	
2nd grade	 	6			Spring   	2012-13  	
3rd grade		7			Spring		2013-14		
4th grade		8			Spring		2014-15		
5th grade		9			Spring		2015-16		
*/

/*rename all variables to be lower case*/
rename *, lower

/*define common value labels*/ 
label define yes 0 "No" 1 "Yes"
label define likert 1 "Strongly disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
label define imp 1 "Not important" 2 "Somewhat important" 3 "Very important" 4 "Extremely important"

/*set local macro for variable labeling convention*/
tokenize `""Kindergarten Fall" "Kindergarten Spring" "1st grade Fall" "1st grade Spring" "2nd grade Fall" "2nd grade Spring" "3rd grade" "4th grade" "5th grade""' 

/*set missing values to missing*/ 
mvdecode *, mv(-7 = . \ -8 = . \ -9 = . \ -1 = . \ -4 = . \ -5 = .)

/**********
TEST SCORES
***********/
/*achievement test scores*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums { 
	label variable x`i'mthetk5 "Math test score theta, ``i''" 
	rename x`i'mthetk5 mththeta`i'
}

local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums { 
	label variable x`i'rthetk5 "Reading test score theta, ``i''"
	rename x`i'rthetk5 rdtheta`i'
}

local nums 2 3 4 5 6 7 8 9
foreach i of local nums { 
	label variable x`i'sthetk5 "Science test score theta, ``i''"
	rename x`i'sthetk5 sctheta`i'
}

/*****************
SCHOOL COMPOSITION
******************/
/*total school enrollment*/ 
rename x2kenrls x2enrls 
local nums 2 4 6 7 8 9 
foreach i of local nums { 
	label variable x`i'enrls "School total enrollment, ``i''"
	rename x`i'enrls stotenrl`i'
}

/*average daily attendance*/ 
replace s4ada = s4ada/100
sum s4ada, det
_pctile s4ada, p(2)
ret li
replace s4ada = . if s4ada < `r(r1)'
rename s4ada sattnd4
label variable sattnd4 "School - % of average daily attendance, 1st grade Spring" 

/*racial composition*/ 
local nums 2 4 6 7 8 9
foreach i of local nums { 
	replace s`i'hisppt = s`i'hisppt/100
	label variable s`i'hisppt "% students in school Hispanic/Latino, ``i''" 
	rename s`i'hisppt shspnc`i'
}

local nums 2 4 6 7 8 9
foreach i of local nums { 
	replace s`i'blacpt = s`i'blacpt/100
	label variable s`i'blacpt "% students in school Black/African American, ``i''"
	rename s`i'blacpt sblk`i'
}

local nums 2 4 6 7 8 9
foreach i of local nums { 
	replace s`i'whitpt = s`i'whitpt/100
	label variable s`i'whitpt "% students in school White, ``i''"
	rename s`i'whitpt swht`i'
}

/*% ELL*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace s`i'totell = s`i'totell/100
	label variable s`i'totell "% students in school ELL, ``i''"
	rename s`i'totell stotell`i'
}

replace stotell4 = . if stotell4 > 1

/*% in G/T program*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace s`i'gifpct = s`i'gifpct/100
	label variable s`i'gifpct "% students in G/T program, ``i''"
	rename s`i'gifpct sgif`i'
}

sum sgif4, det
_pctile sgif4, p(98)
ret li
replace sgif4 = . if sgif4 > `r(r1)' & sgif4 < .

/*% in special ed*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace s`i'spdpct = s`i'spdpct/100
	label variable s`i'spdpct "% students in special education, ``i''"
	rename s`i'spdpct sspced`i'
}

sum sspced4, det
replace sspced4 = . if sspced4 > r(p99) & sspced4 < .

/*% eligible for free or reduced price lunch*/ 
local nums 6 7 8 9 
foreach i of local nums {
	replace x`i'frmeal_i = . if x`i'frmeal_i > 100 & x`i'frmeal_i < 6000 
	replace x`i'frmeal_i = x`i'frmeal_i/100
	label variable x`i'frmeal_i "% students eligible free or reduced price lunch, ``i''"
	rename x`i'frmeal_i sfrlnch`i'
}

gen sfrlnch2 = x2flch2_i + x2rlch2_i
replace sfrlnch2 = . if sfrlnch2 > 100 & sfrlnch2 < .
replace sfrlnch2 = sfrlnch2/100
label variable sfrlnch2 "% students eligible free or reduced price lunch, Kindergarten Spring" 

gen sfrlnch4 = x4fmeal_i + x4rmeal_i
replace sfrlnch4 = . if sfrlnch4 > 100 & sfrlnch4 < .
replace sfrlnch4 = sfrlnch4/100
label variable sfrlnch4 "% students eligible free or reduced price lunch, 1st grade Spring" 

/**********************
TEACHER CHARACTERISTICS
***********************/
/*teacher highest level of education*/ 
label define ed 0 "Less than graduate degree" 1 "Graduate degree"
local nums 1 4 6 7 8 9
foreach i of local nums {
	replace a`i'hghstd = 0 if a`i'hghstd == 2 | a`i'hghstd == 3 | a`i'hghstd == 4 | a`i'hghstd == 5 
	replace a`i'hghstd = 1 if a`i'hghstd == 6 | a`i'hghstd == 7
	label values a`i'hghstd ed
	label variable a`i'hghstd "Teacher highest education, ``i''"
	rename a`i'hghstd ted`i'
}

/*teacher experience*/ 
local nums 1 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'yrstch "Teacher total years teaching, ``i''"
	rename a`i'yrstch tyrstch`i'
}

/*teacher tenure*/ 
local nums 1 4 6 
foreach i of local nums {
	label variable a`i'yrsch "Teacher years at this school, ``i''"
	rename a`i'yrsch tyrsch`i'
}

/*teacher board exam status*/ 
local nums 1 4 6 
foreach i of local nums {
	replace a`i'natexm = 0 if a`i'natexm == 1 | a`i'natexm == 3 | a`i'natexm == 4
	replace a`i'natexm = 1 if a`i'natexm == 2
	label values a`i'natexm yes
	label variable a`i'natexm "Teacher passed national board exam, ``i''"
	rename a`i'natexm tnexm`i'
}

/*teacher certification type*/ 
label define cert 0 "Not regular/state certified" 1 "Regular/state certification"
local nums 1 4 6 7 8 9 
foreach i of local nums {
	replace a`i'statct = 0 if a`i'statct == 2 | a`i'statct == 3 | a`i'statct == 4 | a`i'statct == 5
	label values a`i'statct cert
	label variable a`i'statct "Teacher certification type, ``i''"
	rename a`i'statct tcrt`i'
}

/*teacher gender*/ 
label define gender 0 "Female" 1 "Male" 
local nums 1 4 6 7 8 9
foreach i of local nums {
	replace a`i'tgend = 0 if a`i'tgend == 2
	label values a`i'tgend gender
	label variable a`i'tgend "Teacher gender, ``i''"
	rename a`i'tgend tgender`i'
}

/*teacher race/ethnicity*/ 
local nums 1 4 6 7 8 9
label define race2 0 "Another race" 1 "White"
foreach i of local nums {
	gen trace`i' = .
	replace trace`i' = 1 if a`i'white == 1
	replace trace`i' = 0 if a`i'black == 1 | a`i'hisp == 1  | a`i'asian == 1 | a`i'aminan == 1 | a`i'hawpi == 1
	label values trace`i' race2 
	label variable trace`i' "Teacher race/ethnicity, ``i''"
}

/************************
PRINCIPAL CHARACTERISTICS
*************************/
/*principal tenure*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable s`i'ryyemp "Principal years at school, ``i''"
	rename s`i'ryyemp pyrssch`i'
}

/*principal years teaching*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'ystch "Principal years teaching, ``i''"
	rename s`i'ystch pyrstch`i'
}

/*principal experience*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable s`i'totpri "Principal years as principal, ``i''"
	rename s`i'totpri pyrspr`i'
}

/*principal highest education level*/ 
label define pred 0 "No EdD/PhD" 1 "EdD/PhD"
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace s`i'edlvl = 0 if s`i'edlvl == 1 | s`i'edlvl == 2 | s`i'edlvl == 3 | s`i'edlvl == 4 | s`i'edlvl == 5
	replace s`i'edlvl = 1 if s`i'edlvl == 6 | s`i'edlvl == 7
	label values s`i'edlvl pred
	label variable s`i'edlvl "Principal highest education level, ``i''" 
	rename s`i'edlvl ped`i'
}

/*principal race/ethnicity*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	gen prace`i' = .
	replace prace`i' = 1 if s`i'white == 1
	replace prace`i' = 0 if s`i'black == 1 | s`i'hisp == 1 | s`i'asian == 1 | s`i'aminan == 1 | s`i'hawpi == 1
	label values prace`i' race2 
	label variable prace`i' "Principal race/ethnicity, ``i''" 
}

/*principal gender*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace s`i'gender = 0 if s`i'gender == 2
	label values s`i'gender gender
	label variable s`i'gender "Principal gender, ``i''" 
	rename s`i'gender pgender`i'
}

/**************
SCHOOL FINANCES
***************/
/*received Title 1 funds*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace s`i'tt1 = 0 if s`i'tt1 == 2 
	label values s`i'tt1 yes
	label variable s`i'tt1 "School received Title 1 funds, ``i''"
	rename s`i'tt1 ttlone`i'
}

/*funding levels decreased since last year*/ 
rename s2fundlv s2funddc
local nums 4 6 7 8 9 
foreach i of local nums {
	replace s`i'funddc = 0 if s`i'funddc == 1
	replace s`i'funddc = 1 if s`i'funddc == 2 | s`i'funddc == 3 | s`i'funddc == 4
	label values s`i'funddc yes
	label variable s`i'funddc "School funding decreased from last year, ``i''"
	rename s`i'funddc sfnddc`i'
}

/*staff salaries increased since last year*/ 
local nums 4 6 7 8 9
foreach i of local nums {
	replace s`i'csalin = 0 if s`i'csalin == 1
	replace s`i'csalin = 1 if s`i'csalin == 2 | s`i'csalin == 3 | s`i'csalin == 4
	label values s`i'csalin yes
	label variable s`i'csalin "School staff salaries increased, ``i''"
	rename s`i'csalin sstffinc`i'
}

/*staff salaries decreased since last year*/ 
local nums 4 6 7 8 9 
foreach i of local nums {
	replace s`i'csalde = 0 if s`i'csalde == 1
	replace s`i'csalde = 1 if s`i'csalde == 2 | s`i'csalde == 3 | s`i'csalde == 4
	label values s`i'csalde yes
	label variable s`i'csalde "School staff salaries decreased, ``i''"
	rename s`i'csalde sstffdec`i'
}

/*staff salaries frozen from last year*/ 
local nums 4 6 7 8 9 
foreach i of local nums {
	replace s`i'cslyfz = 0 if s`i'cslyfz == 2
	label values s`i'cslyfz yes
	label variable s`i'cslyfz "School staff salaries frozen, ``i''"
	rename s`i'cslyfz sstfffrz`i'
}

/**********
SCHOOL TYPE
***********/
/*year round school*/ 
rename x12yrrnd x2yrrnd
local nums 2 4 6 7 8 9
foreach i of local nums {
	label values x`i'yrrnd yes
	label variable x`i'yrrnd "School goes year round, ``i''"
	rename x`i'yrrnd syrrnd`i'
}

/*public or private*/ 
label define pub 0 "Private school" 1 "Public school"
local nums 1 2 3 4 5 6 7 8 9 
foreach i of local nums {
	replace x`i'pubpri = 0 if x`i'pubpri == 2
	label values x`i'pubpri pub
	label variable x`i'pubpri "School is a public school, ``i''"
	rename x`i'pubpri stype`i'
}

/*lowest grade at school*/ 
label define lowgrd 0 "Pre-Kindergarten" 1 "Kindergarten or higher" 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace x`i'lowgrd = . if x`i'lowgrd == 15
	replace x`i'lowgrd = 0 if x`i'lowgrd == 1
	replace x`i'lowgrd = 1 if x`i'lowgrd > 1 & x`i'lowgrd <= 14
	label variable x`i'lowgrd "School lowest grade level, ``i''"
	label values x`i'lowgrd lowgrd
	rename x`i'lowgrd slowgrd`i'
}

/*highest grade at school*/ 
label define highgrd 0 "<=5th grade" 1 ">5th grade" 
local nums 2 4 6 7 8 9
foreach i of local nums {
	replace x`i'higgrd = . if x`i'higgrd == 15
	replace x`i'higgrd = 0 if x`i'higgrd <= 7
	replace x`i'higgrd = 1 if x`i'higgrd > 7 & x`i'higgrd <=14
	label variable x`i'higgrd "School highest grade level, ``i''"
	label values x`i'higgrd highgrd
	rename x`i'higgrd shighgrd`i'
}

/****************
SCHOOL FACILITIES
*****************/
/*cafeteria meets school needs*/ 
replace s4cafeok = s2cafeok if s4cafeok == .
label define ok 0 "Not always adequate" 1 "Always adequate"
local nums 2 4 6 
foreach i of local nums {
	replace s`i'cafeok = 0 if s`i'cafeok == 1 | s`i'cafeok == 2 | s`i'cafeok == 3 | s`i'cafeok == 4
	replace s`i'cafeok = 1 if s`i'cafeok == 5
	label values s`i'cafeok ok
	label variable s`i'cafeok "School cafeteria meets needs, ``i''"
	rename s`i'cafeok scafeok`i'
}

/*computer lab meets school needs*/ 
replace s4compok = s2compok if s4compok == .
local nums 2 4 6 7
foreach i of local nums {
	replace s`i'compok = 0 if s`i'compok == 1 | s`i'compok == 2 | s`i'compok == 3 | s`i'compok == 4
	replace s`i'compok = 1 if s`i'compok == 5
	label values s`i'compok ok
	label variable s`i'compok "School computer lab meets needs, ``i''"
	rename s`i'compok scompok`i'
}

/*library meets school needs*/ 
replace s4lbryok = s2lbryok if s4lbryok == .
local nums 2 4 6 7
foreach i of local nums {
	replace s`i'lbryok = 0 if s`i'lbryok == 1 | s`i'lbryok == 2 | s`i'lbryok == 3 | s`i'lbryok == 4
	replace s`i'lbryok = 1 if s`i'lbryok == 5
	label values s`i'lbryok ok
	label variable s`i'lbryok "School library meets needs, ``i''"
	rename s`i'lbryok slibok`i'
}

/*art room meets school needs*/ 
replace s4artok = s2artok if s4artok == .
local nums 2 4 6 
foreach i of local nums {
	replace s`i'artok = 0 if s`i'artok == 1 | s`i'artok == 2 | s`i'artok == 3 | s`i'artok == 4
	replace s`i'artok = 1 if s`i'artok == 5
	label values s`i'artok ok
	label variable s`i'artok "School art room meets needs, ``i''"
	rename s`i'artok sartok`i'
}

/*gymnasium meets school needs*/ 
replace s4gymok = s2gymok if s4gymok == .
local nums 2 4 6 7
foreach i of local nums {
	replace s`i'gymok = 0 if s`i'gymok == 1 | s`i'gymok == 2 | s`i'gymok == 3 | s`i'gymok == 4
	replace s`i'gymok = 1 if s`i'gymok == 5
	label values s`i'gymok ok
	label variable s`i'gymok "School gymnasium meets needs, ``i''"
	rename s`i'gymok sgymok`i'
}

/*music room meets school needs*/
replace s4muscok = s2muscok if s4muscok == .
local nums 2 4 6 
foreach i of local nums {
	replace s`i'muscok = 0 if s`i'muscok == 1 | s`i'muscok == 2 | s`i'muscok == 3 | s`i'muscok == 4
	replace s`i'muscok = 1 if s`i'muscok == 5
	label values s`i'muscok ok
	label variable s`i'muscok "School music room meets needs, ``i''"
	rename s`i'muscok smusok`i'
}

/*playground meets school needs*/ 
replace s4playok = s2playok if s4playok == .
local nums 2 4 6 7
foreach i of local nums {
	replace s`i'playok = 0 if s`i'playok == 1 | s`i'playok == 2 | s`i'playok == 3 | s`i'playok == 4
	replace s`i'playok = 1 if s`i'playok == 5
	label values s`i'playok ok
	label variable s`i'playok "School playground meets needs, ``i''"
	rename s`i'playok splayok`i'
}

/*classrooms meet school needs*/ 
replace s4clssok = s2clssok if s4clssok == .
local nums 2 4 6 7
foreach i of local nums {
	replace s`i'clssok = 0 if s`i'clssok == 1 | s`i'clssok == 2 | s`i'clssok == 3 | s`i'clssok == 4
	replace s`i'clssok = 1 if s`i'clssok == 5
	label values s`i'clssok ok
	label variable s`i'clssok "School classrooms meet needs, ``i''"
	rename s`i'clssok sclssok`i'
}

/*auditorium meets school needs*/ 
replace s4audtok = s2audtok if s4audtok == .
local nums 2 4 6 
foreach i of local nums {
	replace s`i'audtok = 0 if s`i'audtok == 1 | s`i'audtok == 2 | s`i'audtok == 3 | s`i'audtok == 4
	replace s`i'audtok = 1 if s`i'audtok == 5
	label values s`i'audtok ok
	label variable s`i'audtok "School auditorium meets needs, ``i''"
	rename s`i'audtok saudok`i'
}

/*multi-use room meets school needs*/ 
replace s4multok = s2multok if s4multok == .
local nums 2 4 6 
foreach i of local nums {
	replace s`i'multok = 0 if s`i'multok == 1 | s`i'multok == 2 | s`i'multok == 3 | s`i'multok == 4
	replace s`i'multok = 1 if s`i'multok == 5
	label values s`i'multok ok
	label variable s`i'multok "School multi-use room meets needs, ``i''"
	rename s`i'multok smultok`i'
}

/**************
SCHOOL STAFFING
***************/
/*# regular classroom teachers - full-time*/ 
rename s2rtchfl s2rgtchf
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'rgtchf "School # of regular classroom teachers, ``i''"
	rename s`i'rgtchf strgl`i'
}

/*# elective teachers - full-time*/ 
rename s2msarfl selctv2
label variable selctv2 "School # of elective teachers, Kindergarten Spring"

/*# drama, music, art teachers - full-time*/ 
local nums 4 6 7 8 9
foreach i of local nums {
	label variable s`i'artstf "School # of drama/music/art teachers, ``i''"
	rename s`i'artstf sartstf`i'
}

/*# gym, health teachers - full-time*/ 
local nums 4 6 7 8 9
foreach i of local nums {
	label variable s`i'gymtf "School # of gym/health teachers, ``i''"
	rename s`i'gymtf sgymstf`i'
}

/*# special education teachers - full-time*/ 
rename s2spedfl s2spedf
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'spedf "School # of special education teachers, ``i''"
	rename s`i'spedf spedstf`i'
}

/*# ESL teachers - full-time*/ 
rename s2eslfl s2eslf
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'eslf "School # of ESL teachers, ``i''"
	rename s`i'eslf seslstf`i'
}

/*# reading teachers/specialists - full-time*/ 
rename s2readfl s2rdtcyn
local nums 2 7 8 9
foreach i of local nums {
	label variable s`i'rdtcyn "School # of reading teachers, ``i''"
	rename s`i'rdtcyn srdstf`i'
}

drop srdstf7 srdstf8 srdstf9 

/*# G/T teachers - full-time*/ 
rename s2giftfl s2giftf
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'giftf "School # of G/T teachers, ``i''"
	rename s`i'giftf sgftstf`i'
}

/*# school nurses/health professionals - full-time*/ 
rename s2nursfl s2nursf
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'nursf "School # of nurses, ``i''"
	rename s`i'nursf snrsstf`i'
}

/*# school psychologists/social workers - full-time*/ 
rename s2psycfl s2psycf
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'psycf "School # of full-time psychologists/social workers, ``i''"
	rename s`i'psycf spsyfstf`i'
}

/*# school psychologists/social workers - part-time*/ 
rename s2psycpt s2psycp
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'psycp "School # of part-time psychologists/social workers,``i''" 
	rename s`i'psycp spsypstf`i'
}

/*# para professionals - full-time*/ 
rename s2parafl s2paraf
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'paraf "School # of para professionals, ``i''"  
	rename s`i'paraf sparastf`i'
}

/*# librarians - full-time*/ 
rename s2librfl s2librf
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'librf "School # of full-time librarians, ``i''" 
	rename s`i'librf slibstf`i'
}

/*# computer teachers - full-time*/ 
local nums 4 6 
foreach i of local nums {
	label variable s`i'ctechf "School # of computer teachers, ``i''"
	rename s`i'ctechf scmpstf`i'
}

/*# new teachers this year*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'tebegn "School # of new teachers this year, ``i''"
	rename s`i'tebegn snewt`i'
}

/*# teachers left this year*/ 
local nums 2 4 6 7 8 9
foreach i of local nums {
	label variable s`i'teleft "School # of teachers left this year, ``i''"
	rename s`i'teleft slftt`i'
}

/*total number teachers*/ 
local nums 2 4 6 9
foreach i of local nums {
	label variable s`i'numtot "School # of total teachers, ``i''"
	rename s`i'numtot stnum`i'
}

/*school administrator sets priorities*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'setpri "Teacher feels school admin. sets priorities, ``i''" 
	rename a`i'setpri sapri`i'
	label values sapri`i' likert
}

/*school administrator encourages staff*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'encour "Teacher feels school admin. encourages staff, ``i''"
	rename a`i'encour saenc`i'
	label values saenc`i' likert
}

/*consensus on expectations*/ 
local nums 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'cnsnss "Teacher feels school consensus expectations, ``i''"
	rename a`i'cnsnss sacns`i'
	label values sacns`i' likert
}

/*hours per week administrator works with teachers*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'instru "Hours school admin. works with teachers, ``i''"
	rename s`i'instru sainst`i'
}

sum sainst4, det
replace sainst4 = . if sainst4 > r(p99) & sainst4 < .

/*professional development available for teachers*/ 
local nums 2 4 6 7  
foreach i of local nums {
	replace s`i't3prdv = 0 if s`i't3prdv == 2
	label values s`i't3prdv yes
	label variable s`i't3prdv "School offers professional development, ``i''"
	rename s`i't3prdv spd`i'
}

/*teacher enjoys job*/ 
local nums 1 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'enjoy "Teacher enjoys job, ``i''"
	rename a`i'enjoy tenjy`i'
	label values tenjy`i' likert
}

/*teacher feels they can make a difference*/ 
local nums 1 2 4 6 
foreach i of local nums {
	label variable a`i'mkdiff "Teacher feels can make difference, ``i''"
	rename a`i'mkdiff tmkdff`i'
	label values tmkdff`i' likert
}

/*teacher would choose teaching again*/ 
local nums 1 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'teach "Teacher would choose teaching again, ``i''"
	rename a`i'teach tchstch`i'
	label values tchstch`i' likert
}

/*teacher accepted at school*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable a`i'accptd "Teacher is accepted at school, ``i''" 
	rename a`i'accptd tacpt`i'
	label values tacpt`i' likert
}

/*staff learn new ideas*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable a`i'cntnlr "Staff learn new ideas, ``i''"
	rename a`i'cntnlr tideas`i'
	label values tideas`i' likert
}

/*teachers feel paper work interferes with teaching*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable a`i'paprwr "Teacher paper work interferes with teaching, ``i''" 
	rename a`i'paprwr tppwrk`i'
	label values tppwrk`i' likert
}

/*teachers feel there is cooperation among staff*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'copstf "Teacher feels cooperation among staff, ``i''"
	rename a`i'copstf tcoop`i'
}

/*teachers feel that staff is recognized*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable a`i'recjob "Teacher feels staff recognized, ``i''"
	rename a`i'recjob tstfrec`i'
	label values tstfrec`i' likert
}

/*teachers feel that academic standards at school was low*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'stndlo "Teacher thinks low academic standards, ``i''" 
	rename a`i'stndlo tlstd`i'
	label values tlstd`i' likert
}

/*teachers feel that faculty agree with the mission*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable a`i'missio "Faculty agree with school mission, ``i''"
	rename a`i'missio tmssn`i'
	label values tmssn`i' likert
}

/*teachers absenteeism is a problem*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable s`i'absent "Principal rates teacher absenteeism, ``i''"
	rename s`i'absent tabsnt`i'
}

/*************
SCHOOL CLIMATE
**************/
/*how often is theft a problem at school*/ 
label define bhv ///
	1 "Never happens" ///
	2 "Happens on occasion" ///
	3 "At least once a month" ///
	4 "At least once a week" ///
	5 "Daily" 
	
local nums 2 4 6 7 8 9 
foreach i of local nums {
	recode s`i'theft (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1)
	label variable s`i'theft "How often theft problem at school, ``i''"
	label values s`i'theft bhv
	rename s`i'theft sthft`i'
}

/*how often is physical conflict a problem at school*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	recode s`i'conflc (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1)
	label values s`i'conflc bhv
	label variable s`i'conflc "How often physical conflict problem at school, ``i''"
	rename s`i'conflc scnfl`i'
}

/*how often is bullying a problem*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	recode s`i'bully (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1)
	label values s`i'bully bhv
	label variable s`i'bully "How often bullying problem at school, ``i''"
	rename s`i'bully sblly`i'
}

/*how often is classroom disorder a problem*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	recode s`i'disord (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1)
	label values s`i'disord bhv
	label variable s`i'disord "How often classroom disorder problem at school, ``i''"
	rename s`i'disord sdsrd`i'
}

/*classroom behavior*/ 
rename a1dbehvr a1behvr
rename a2dbehvr a2behvr
rename g8behvr a8behvr
rename g9behvr a9behvr
label define beh 0 "Group misbehaves frequently" 1 "Group misbehaves occasionally" 2 "Group behaves well"
local nums 1 2 6 7 8 9
foreach i of local nums {
	replace a`i'behvr = 0 if a`i'behvr == 1 | a`i'behvr == 2
	replace a`i'behvr = 1 if a`i'behvr == 3
	replace a`i'behvr = 2 if a`i'behvr == 4 | a`i'behvr == 5
	label values a`i'behvr beh
	label variable a`i'behvr "Rating of classroom behavior, ``i''"
	rename a`i'behvr tclssbhv`i'
}

/**************************
SCHOOL-FAMILY COMMUNICATION
***************************/
/*parents support school staff*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable a`i'psupp "Parents support school staff, ``i''"
	label values a`i'psupp likert	
	rename a`i'psupp spsupp`i'
}

/*frequency of report cards*/ 
rename s2rprtcd s2rptcrd
label define freq 0 "At least 3 times per year" 1 "4-6 times per year" 2 "7 or more times per year"
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace s`i'rptcrd = 0 if s`i'rptcrd == 1 | s`i'rptcrd == 2 | s`i'rptcrd == 3
	replace s`i'rptcrd = 1 if s`i'rptcrd == 4
	replace s`i'rptcrd = 2 if s`i'rptcrd == 5
	label values s`i'rptcrd freq
	label variable s`i'rptcrd "Frequency school sends report cards, ``i''"
	rename s`i'rptcrd srptcrd`i'
}

/*frequency of information on tests sent home*/ 
label define ststinf 1 "Never" 2 "Once a year" 3 "2-3 times a year" 4 "4-6 times a year" 5 "7 or more times a year" 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label variable s`i'sttest "Frequency school sends test info, ``i''"
	rename s`i'sttest ststinf`i'
	label values ststinf`i' ststinf
}

/*frequency of parent-teacher conferences*/ 
label define sptcnf 0 "Once a year or less" 1 "2-3 times a year" 2 "4-6 times a year" 3 "7 or more times a year" 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace s`i'ptconf = 0 if s`i'ptconf == 1 | s`i'ptconf == 2
	replace s`i'ptconf = 1 if s`i'ptconf == 3 
	replace s`i'ptconf = 2 if s`i'ptconf == 4
	replace s`i'ptconf = 3 if s`i'ptconf == 5
	label variable s`i'ptconf "Frequency parent-teacher conferences, ``i''"
	label values s`i'ptconf sptcnf
	rename s`i'ptconf sptcnf`i'
}

/*translators for LM/LEP parents*/ 
replace s4transl = s2transl if s4transl == . 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace s`i'transl = 0 if s`i'transl == 2
	label values s`i'transl yes
	label variable s`i'transl "School has translators, ``i''"
	rename s`i'transl strnsl`i'
}

/*hours per week principal meets with parents*/ 
local nums 2 4 6 
foreach i of local nums {
	label variable s`i'talkpt "Hours per week principal meets parents, ``i''"
	rename s`i'talkpt sprnpar`i'
}

sum sprnpar4, det
replace sprnpar4 = . if sprnpar4 > r(p99) & sprnpar4 < .

/*school has community support*/ 
local nums 2 4 6 7
foreach i of local nums {
	label variable s`i'spprt "School has community support, ``i''"
	rename s`i'spprt sspprt`i'
	label values sspprt`i' likert
}

/****************************
SCHOOL CURRICULUM/INSTRUCTION
*****************************/
/*how often focus on reading & language arts*/ 
label define oft2 0 "Less than 3 days a week" 1 "3-4 days a week" 2 "5 days a week"
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftrdl = 0 if a`i'oftrdl == 1 | a`i'oftrdl == 2 | a`i'oftrdl == 3 | a`i'oftrdl == 4
	replace a`i'oftrdl = 1 if a`i'oftrdl == 5 | a`i'oftrdl == 6
	replace a`i'oftrdl = 2 if a`i'oftrdl == 7
	label values a`i'oftrdl oft2
	label variable a`i'oftrdl "How often teacher focuses reading, ``i''"
	rename a`i'oftrdl tord`i'
}

/*how often focus on math*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftmth = 0 if a`i'oftmth == 1 | a`i'oftmth == 2 | a`i'oftmth == 3 | a`i'oftmth == 4
	replace a`i'oftmth = 1 if a`i'oftmth == 5 | a`i'oftmth == 6
	replace a`i'oftmth = 2 if a`i'oftmth == 7
	label values a`i'oftmth oft2
	label variable a`i'oftmth "How often teacher focuses math, ``i''"
	rename a`i'oftmth tomth`i'
}

/*how often focus on social studies*/ 
local nums 4 
foreach i of local nums {
	replace a`i'oftsoc = 0 if a`i'oftsoc == 1 | a`i'oftsoc == 2 | a`i'oftsoc == 3 | a`i'oftsoc == 4
	replace a`i'oftsoc = 1 if a`i'oftsoc == 5 | a`i'oftsoc == 6
	replace a`i'oftsoc = 2 if a`i'oftsoc == 7
	label values a`i'oftsoc oft2
	label variable a`i'oftsoc "How often teacher focuses social studies, ``i''"
	rename a`i'oftsoc tosoc`i'
}

/*how often focus on science*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftsci = 0 if a`i'oftsci == 1 | a`i'oftsci == 2 | a`i'oftsci == 3 | a`i'oftsci == 4
	replace a`i'oftsci = 1 if a`i'oftsci == 5 | a`i'oftsci == 6
	replace a`i'oftsci = 2 if a`i'oftsci == 7
	label values a`i'oftsci oft2
	label variable a`i'oftsci "How often teacher focuses science, ``i''"
	rename a`i'oftsci tosci`i'
}

/*how often focus on music*/ 
label define oft3 0 "Less than 2 days a week" 1 "2 days a week" 2 "3 or more days a week"
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftmus = 0 if a`i'oftmus == 1 | a`i'oftmus == 2 | a`i'oftmus == 3 
	replace a`i'oftmus = 1 if a`i'oftmus == 4
	replace a`i'oftmus = 2 if a`i'oftmus == 5 | a`i'oftmus == 6 | a`i'oftmus == 7
	label values a`i'oftmus oft3
	label variable a`i'oftmus "How often teacher focuses music, ``i''"
	rename a`i'oftmus tomus`i'
}

/*how often focus on art*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftart = 0 if a`i'oftart == 1 | a`i'oftart == 2 | a`i'oftart == 3 
	replace a`i'oftart = 1 if a`i'oftart == 4
	replace a`i'oftart = 2 if a`i'oftart == 5 | a`i'oftart == 6 | a`i'oftart == 7
	label values a`i'oftart oft3
	label variable a`i'oftart "How often teacher focuses art, ``i''"
	rename a`i'oftart toart`i'
}

/*how often focus on physical education*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftpe = 0 if a`i'oftpe == 1 | a`i'oftpe == 2 | a`i'oftpe == 3 
	replace a`i'oftpe = 1 if a`i'oftpe == 4
	replace a`i'oftpe = 2 if a`i'oftpe == 5 | a`i'oftpe == 6 | a`i'oftpe == 7
	label values a`i'oftpe oft3
	label variable a`i'oftpe "How often teacher focuses gym, ``i''"
	rename a`i'oftpe togym`i'
}

/*how often focus on dance*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftdan = 0 if a`i'oftdan == 1 | a`i'oftdan == 2 | a`i'oftdan == 3 
	replace a`i'oftdan = 1 if a`i'oftdan == 4
	replace a`i'oftdan = 2 if a`i'oftdan == 5 | a`i'oftdan == 6 | a`i'oftdan == 7
	label values a`i'oftdan oft3
	label variable a`i'oftdan "How often teacher focuses dance, ``i''"
	rename a`i'oftdan todan`i'
}

/*how often focus on theater*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'ofthtr = 0 if a`i'ofthtr == 1 | a`i'ofthtr == 2 | a`i'ofthtr == 3 
	replace a`i'ofthtr = 1 if a`i'ofthtr == 4
	replace a`i'ofthtr = 2 if a`i'ofthtr == 5 | a`i'ofthtr == 6 | a`i'ofthtr == 7
	label values a`i'ofthtr oft3
	label variable a`i'ofthtr "How often teacher focuses theater, ``i''"
	rename a`i'ofthtr tothtr`i'
}

/*how often focus on foreign language*/ 
local nums 4 6 7 8 9 
foreach i of local nums {
	replace a`i'oftfln = 0 if a`i'oftfln == 1 | a`i'oftfln == 2 | a`i'oftfln == 3 
	replace a`i'oftfln = 1 if a`i'oftfln == 4
	replace a`i'oftfln = 2 if a`i'oftfln == 5 | a`i'oftfln == 6 | a`i'oftfln == 7
	label values a`i'oftfln oft3
	label variable a`i'oftfln "How often teacher focuses foreign language, ``i''"
	rename a`i'oftfln tofln`i'
}

/*time spent on reading & language arts*/ 
label define time ///
	1 "Less than 1 hour per day" ///
	2 "1 to less than 1.5 hours" ///
	3 "1.5 to less than 2 hours" ///
	4 "2 to less than 2.5 hours" ///
	5 "2.5 to less than 3 hours" ///
	6 "3 or more hours"
	
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txrdla = 1 if a`i'txrdla == 1 | a`i'txrdla == 2 | a`i'txrdla == 3
	replace a`i'txrdla = 2 if a`i'txrdla == 4
	replace a`i'txrdla = 3 if a`i'txrdla == 5
	replace a`i'txrdla = 4 if a`i'txrdla == 6
	replace a`i'txrdla = 5 if a`i'txrdla == 7
	replace a`i'txrdla = 6 if a`i'txrdla == 8
	label values a`i'txrdla time
	label variable a`i'txrdla "Teacher time spent on reading per day, ``i''"
	rename a`i'txrdla ttrd`i'
}

/*time spent on math*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txmth = 1 if a`i'txmth == 1 | a`i'txmth == 2 | a`i'txmth == 3
	replace a`i'txmth = 2 if a`i'txmth == 4
	replace a`i'txmth = 3 if a`i'txmth == 5
	replace a`i'txmth = 4 if a`i'txmth == 6
	replace a`i'txmth = 5 if a`i'txmth == 7
	replace a`i'txmth = 6 if a`i'txmth == 8
	label values a`i'txmth time
	label variable a`i'txmth "Teacher time spent on math per day, ``i''"
	rename a`i'txmth ttmth`i'
}

/*time spent on social studies*/ 
local nums 2 4 6 7 8 9 
label define time2 1 "Less than 1/2 hour a day" 2 "1/2 hour to less than 1 hour per day" ///
3 "1 to less than 1.5 hours" 4 "1.5 hours or more"
foreach i of local nums {
	replace a`i'txsoc = 1 if a`i'txsoc == 2
	replace a`i'txsoc = 2 if a`i'txsoc == 3
	replace a`i'txsoc = 3 if a`i'txsoc == 4
	replace a`i'txsoc = 4 if a`i'txsoc == 5 | a`i'txsoc == 6 | a`i'txsoc == 7 | a`i'txsoc == 8
	label values a`i'txsoc time2
	label variable a`i'txsoc "Teacher time spent on social studies per day, ``i''"
	rename a`i'txsoc ttsoc`i'
}

/*time spent on science*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txsci = 1 if a`i'txsci == 2
	replace a`i'txsci = 2 if a`i'txsci == 3
	replace a`i'txsci = 3 if a`i'txsci == 4
	replace a`i'txsci = 4 if a`i'txsci == 5 | a`i'txsci == 6 | a`i'txsci == 7 | a`i'txsci == 8
	label values a`i'txsci time2
	label variable a`i'txsci "Teacher time spent on science, ``i''"
	rename a`i'txsci ttsci`i'
}

/*time spent on music*/ 
label define time3 1 "Less than 1/2 hour a day" 2 "1/2 hour to less than 1 hour per day" 3 "1 hour or more"
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txmus = 1 if a`i'txmus == 2
	replace a`i'txmus = 2 if a`i'txmus == 3
	replace a`i'txmus = 3 if a`i'txmus == 4 | a`i'txmus == 5 | a`i'txmus == 6 | a`i'txmus == 7 | a`i'txmus == 8
	label values a`i'txmus time3
	label variable a`i'txmus "Teacher time spent on music, ``i''"
	rename a`i'txmus ttmus`i'
}

/*time spent on art*/
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txart = 1 if a`i'txart == 2
	replace a`i'txart = 2 if a`i'txart == 3
	replace a`i'txart = 3 if a`i'txart == 4 | a`i'txart == 5 | a`i'txart == 6 | a`i'txart == 7 | a`i'txart == 8
	label values a`i'txart time3
	label variable a`i'txart "Teacher time spent on art, ``i''"
	rename a`i'txart ttart`i'
}

/*time spent on physical education*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txpe = 1 if a`i'txpe == 2
	replace a`i'txpe = 2 if a`i'txpe == 3
	replace a`i'txpe = 3 if a`i'txpe == 4 | a`i'txpe == 5 | a`i'txpe == 6 | a`i'txpe == 7 | a`i'txpe == 8
	label values a`i'txpe time3
	label variable a`i'txpe "Teacher time spent on gym, ``i''"
	rename a`i'txpe ttgym`i'
}

/*time spent on dance*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txdan = 1 if a`i'txdan == 2
	replace a`i'txdan = 2 if a`i'txdan == 3
	replace a`i'txdan = 3 if a`i'txdan == 4 | a`i'txdan == 5 | a`i'txdan == 6 | a`i'txdan == 7 | a`i'txdan == 8
	label values a`i'txdan time3
	label variable a`i'txdan "Teacher time spent on dance, ``i''"
	rename a`i'txdan ttdan`i'
}

/*time spent on theater*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txthtr = 1 if a`i'txthtr == 2
	replace a`i'txthtr = 2 if a`i'txthtr == 3
	replace a`i'txthtr = 3 if inrange(a`i'txthtr,4,8)
	label values a`i'txthtr time3
	label variable a`i'txthtr "Teacher time spent on theater, ``i''"
	rename a`i'txthtr ttthtr`i'
}

/*time spent on foreign language*/ 
rename a2txfor a2txfln
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'txfln = 1 if a`i'txfln == 2
	replace a`i'txfln = 2 if a`i'txfln == 3
	replace a`i'txfln = 3 if a`i'txfln == 4 | a`i'txfln == 5 | a`i'txfln == 6 | a`i'txfln == 7 | a`i'txfln == 8
	label values a`i'txfln time3
	label variable a`i'txfln "Teacher time spent on foreign language, ``i''"
	rename a`i'txfln ttfln`i'
}

/*time spent on small group activities*/ 
label define time4 1 "Half hour or less" 2 "1 hour" 3 "2 hours" 4 "3 hours or more"
rename a2smlgrp a2wksgrp
rename g8wksgrp a8wksgrp
rename g9wksgrp a9wksgrp
local nums 2 4 6 8 9 
foreach i of local nums {
	replace a`i'wksgrp = 1 if a`i'wksgrp == 2
	replace a`i'wksgrp = 2 if a`i'wksgrp == 3
	replace a`i'wksgrp = 3 if a`i'wksgrp == 4
	replace a`i'wksgrp = 4 if a`i'wksgrp == 5 | a`i'wksgrp == 6
	label values a`i'wksgrp time4
	label variable a`i'wksgrp "Teacher time spent on small groups, ``i''"
	rename a`i'wksgrp ttsgrp`i'
}

/*time spent on large group activities*/ 
rename g8wklgrp a8wklgrp
rename g9wklgrp a9wklgrp
local nums 4 6 8 9 
foreach i of local nums {
	replace a`i'wklgrp = 1 if a`i'wklgrp == 2
	replace a`i'wklgrp = 2 if a`i'wklgrp == 3
	replace a`i'wklgrp = 3 if a`i'wklgrp == 4
	replace a`i'wklgrp = 4 if a`i'wklgrp == 5 | a`i'wklgrp == 6
	label values a`i'wklgrp time4
	label variable a`i'wklgrp "Teacher time spent on large groups, ``i''"
	rename a`i'wklgrp ttlgrp`i'
}

/*time spent on individual activities*/ 
rename a2indvdl a2wkindv
rename g8wkindv a8wkindv
rename g9wkindv a9wkindv
local nums 2 4 6 8 9 
foreach i of local nums {
	replace a`i'wkindv = 1 if a`i'wkindv == 2
	replace a`i'wkindv = 2 if a`i'wkindv == 3
	replace a`i'wkindv = 3 if a`i'wkindv == 4
	replace a`i'wkindv = 4 if a`i'wkindv == 5 | a`i'wkindv == 6
	label values a`i'wkindv time4
	label variable a`i'wkindv "Teacher time spent on individual activities, ``i''"
	rename a`i'wkindv ttindv`i'
}

/*time spent working independently*/
rename g8wkindp a8wkindp
rename g9wkindp a9wkindp
local nums 4 6 8 9 
foreach i of local nums {
	replace a`i'wkindp = 1 if a`i'wkindp == 2
	replace a`i'wkindp = 2 if a`i'wkindp == 3
	replace a`i'wkindp = 3 if a`i'wkindp == 4
	replace a`i'wkindp = 4 if a`i'wkindp == 5 | a`i'wkindp == 6
	label values a`i'wkindp time4
	label variable a`i'wkindp "Teacher time spent on independently working, ``i''"
	rename a`i'wkindp ttindp`i'
}

/*time spent working with peers*/ 
rename g8wkpeer a8wkpeer
rename g9wkpeer a9wkpeer
local nums 4 6 8 9 
foreach i of local nums {
	replace a`i'wkpeer = 1 if a`i'wkpeer == 2
	replace a`i'wkpeer = 2 if a`i'wkpeer == 3
	replace a`i'wkpeer = 3 if a`i'wkpeer == 4
	replace a`i'wkpeer = 4 if a`i'wkpeer == 5 | a`i'wkpeer == 6
	label values a`i'wkpeer time4
	label variable a`i'wkpeer "Teacher time spent working with peers, ``i''"
	rename a`i'wkpeer ttpeer`i'
}

/*teacher importance evaluating child relative to class*/ 
rename a2toclas a2toclss
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'toclss imp
	label variable a`i'toclss "Teacher importance evaluating child relative to class, ``i''"
	rename a`i'toclss tevlclss`i'
}

/*teacher importance evaluating child relative to standards*/ 
rename a2tostnd a2tostdr
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'tostdr imp
	label variable a`i'tostdr "Teacher importance evaluating child relative to standards, ``i''"
	rename a`i'tostdr tevlstd`i'
}

/*teacher importance evaluating child improvement*/ 
rename a2imprvm a2impprg
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'impprg imp
	label variable a`i'impprg "Teacher importance evaluating child on improvement, ``i''"
	rename a`i'impprg tevlimp`i'
}

/*teacher importance evaluating child effort*/ 
rename a2effo a2effrt
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'effrt imp
	label variable a`i'effrt "Teacher importance evaluating child on effort, ``i''"
	rename a`i'effrt tevleff`i'
}

/*teacher importance evaluating child class participation*/ 
rename a2claspa a2clspar
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'clspar imp
	label variable a`i'clspar "Teacher importance evaluating child on participation, ``i''" 
	rename a`i'clspar tevlpart`i'
}

/*teacher importance evaluating child class behavior*/ 
label define tevlbhv 0 "Not or somewhat important" 1 "Very important" 2 "Extremely important"
rename a2attnd a2clsbhv
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace a`i'clsbhv=0 if  a`i'clsbhv==1
	replace a`i'clsbhv=0 if  a`i'clsbhv==2
	replace a`i'clsbhv=1 if  a`i'clsbhv==3
	replace a`i'clsbhv=2 if  a`i'clsbhv==4
	label values a`i'clsbhv tevlbhv
	label variable a`i'clsbhv "Teacher importance evaluating child on behavior, ``i''" 
	rename a`i'clsbhv tevlbhv`i'
}

/*teacher importance evaluating child cooperation*/ 
rename a2coprtv a2cooprt
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'cooprt imp
	label variable a`i'cooprt "Teacher importance evaluating child on cooperation, ``i''" 
	rename a`i'cooprt tevlcoop`i'
}

/*teacher evaluates ability to take directions*/ 
rename a2fllwdr a2flldir
local nums 2 4 6 7 8 9 
foreach i of local nums {
	label values a`i'flldir imp
	label variable a`i'flldir "Teacher evaluates children on following directions, ``i''" 
	rename a`i'flldir tevldir`i'
}

/*teacher importance evaluating child ability by standardized tests*/ 
label define eval ///
	1 "Never" ///
	2 "1-2 times a year" ///
	3 "3-8 times a year" ///
	4 "1-2 times a month" ///
	5 "1-2 times a week" ///
	6 "3 or more times a week" 
rename a2stndrd a2stntst
local nums 2 4 6 
foreach i of local nums {
	label values a`i'stntst eval
	label variable a`i'stntst "Teacher evaluates child on standardized tests, ``i''" 
	rename a`i'stntst tevltst`i'
}

/*teacher evaluates ability by classroom tests*/ 
rename a2tchrmd a2tstqz
local nums 2 4 6 
foreach i of local nums {
	label values a`i'tstqz eval
	label variable a`i'tstqz "Teacher evaluates children on class tests, ``i''" 
	rename a`i'tstqz tevlqz`i'
}

/*teacher rating of classroom behavior*/ 
rename a4behvr tbhvr4
recode tbhvr4 (1=1) (2=1) (3=2) (4=3) (5=4)
label define tbhvr4 ///
	1 "Group misbehaves frequently" ///
	2 "Group misbehaves occasionally" ///
	3 "Group behaves well" ///
	4 "Group behaves exceptionally well"
label variable tbhvr4 "Teacher rating of classroom behavior, 1st grade Spring"
label values tbhvr4 tbhvr4

/*teacher gives individual or group projects*/ 
rename a2igrprj a2projct
local nums 2 4 6 
foreach i of local nums {
	label values a`i'projct eval
	label variable a`i'projct "Teacher assigns projects, ``i''" 
	rename a`i'projct tevlprj`i'
}

/*teacher gives worksheets*/ 
rename a2wrksht a2wrksts
local nums 2 4 6 
foreach i of local nums {
	label values a`i'wrksts eval
	label variable a`i'wrksts "Teacher assigns worksheets, ``i''" 
	rename a`i'wrksts tevlwrksh`i'
}

/*teacher gives work samples*/ 
rename a2wrksmp a2wrksam
local nums 2 4 6 
foreach i of local nums {
	label values a`i'wrksam eval
	label variable a`i'wrksam "Teacher provides work samples, ``i''"  
	rename a`i'wrksam tevlwrksa`i'
}

/*teacher assigns achievement groups - reading*/ 
label define time5 ///
	1 "Never" 2 "Less than 1 time per week" 3 "1 day a week" ///
	4 "2 days a week" 5 "3 days a week" 6 "4 days a week" 7 "5 days a week"
local nums 2 4 6 
foreach i of local nums {
	label values a`i'divrd time5
	label variable a`i'divrd "Teacher uses achievement groups - reading, ``i''"  
	rename a`i'divrd tachrd`i'
}

/*yeacher assigns achievement groups - math*/ 
local nums 2 4 6 
foreach i of local nums {
	label values a`i'divmth time5
	label variable a`i'divmth "Teacher uses achievement groups - reading, ``i''"  
	rename a`i'divmth tachmth`i'
}

/*teacher assigns daily homework*/ 
label define time6 0 "0 days" 1 "1 day" 2 "2 days" 3 "3 days" 4 "4 days" 5 "5 days" 
rename a1hmwrk a1dpwhmwk
rename g8dpwhmwk a8dpwhmwk
rename g9dpwhmwk a9dpwhmwk
local nums 1 4 6 7 8 9 
foreach i of local nums {
	label values a`i'dpwhmwk time6
	label variable a`i'dpwhmwk "Teacher assigns daily homework, ``i''"  
	rename a`i'dpwhmwk thw`i'
}

/*1st grade teacher taught X topic in class*/ 
label define days2 0 "Never or hardly ever" 1 "1-2 times per month" 2 "1-2 times per week" 3 "Almost every day"
foreach x of varlist a4usebsl-a4useanth {
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4
	label values `x' days2
	rename `x' `x'4
}

label define days1 0 "not taught" 1 "1-10 days" 2 "11-20 days" 3 "21-40 days" 4 "41-80 days" 5 "More than 80 days"
foreach x of varlist a4mainid-a4triquad {
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4
	replace `x' = 4 if `x' == 5
	replace `x' = 5 if `x' == 6
	label values `x' days1
	rename `x' `x'4
}

label define days 0 "not taught" 1 "1-5 days" 2 "6-10 days" 3 "11- 15 days" 4 "16-20 days" 5 "More than 20 days"
foreach x of varlist a4sensobs-a4grpchrt {
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4
	replace `x' = 4 if `x' == 5
	replace `x' = 5 if `x' == 6
	label values `x' days
	rename `x' `x'4
}

label define taught 0 "Not taught in teacher's class" 1 "Taught in teacher's class"
foreach x of varlist a4sttmtr-a4crevnt {
	replace `x' = 0 if `x' == 2 
	label values `x' taught
	rename `x' `x'4
}

/****************************
SAMPLE MEMBER CHARACTERISTICS
*****************************/
/*student gender*/ 
rename x_chsex_r gender
label variable gender "Child composite gender" 
replace gender = .i if gender == -9
replace gender = 0 if gender == 2 
label values gender gender

/*student race/ethnicity */ 
rename x_racethp_r race
label variable race "Child composite race/ethnicity" 
replace race = 3 if race == 3 | race == 4
replace race = 4 if race == 5
replace race = 5 if race == 6 | race == 7 | race == 8
label define race 1 "White, Non-Hispanic" 2 "Black, Non-Hispanic" 3 "Hispanic" 4 "Asian, Non-Hispanic" 5 "other" 
label values race race

/*birth weight*/ 
replace p1weigho = p1weigho/16
gen brthwt = p1weighp + p1weigho
drop p1weighp p1weigho 
label variable brthwt "Student birth weight"
	
/*home language*/ 
rename x12langst x1langst
label define lang 0 "Non-English language" 1 "English language"
local nums 1 4 6  
foreach i of local nums {
	replace x`i'langst = 0 if x`i'langst == 1
	replace x`i'langst = 1 if x`i'langst == 2 | x`i'langst == 3
	label variable x`i'langst "Home language English, ``i''"
	rename x`i'langst lang`i' 
	label values lang`i' lang
}

/*family receives WIC for each wave */ 
local nums 1 2 
foreach i of local nums {
	replace p`i'wicchd = 0 if p`i'wicchd == 2
	label variable p`i'wicchd "Family received WIC in past 6 months, ``i''"
	rename p`i'wicchd wichh`i'
	label values wichh`i' yes
}

/*family receives foodstamps*/ 
local nums 1 2 4 6 8 9 
foreach i of local nums { 
	replace p`i'fstamp = 0 if p`i'fstamp == 2
	label variable p`i'fstamp "Family received foodstamps in past 12 months, ``i''"
	rename p`i'fstamp fstmp`i'
	label values fstmp`i' yes
}

/*family receives TANF*/ 
local nums 1 2 4 6 8 9 
foreach i of local nums { 
	replace p`i'tanf = 0 if p`i'tanf == 2
	label variable p`i'tanf "Family received TANF ever, ``i''"
	rename p`i'tanf tanf`i'
	label values tanf`i' yes
}

/*student age*/ 
rename x1kage_r x1age
rename x2kage_r x2age
local nums 1 2 3 4 5 6 7 8 9 
foreach i of local nums { 
	label variable x`i'age "Child assessment age in months, ``i''"
	rename x`i'age age`i'
}

/*family income - deflated to 2010 dollars*/ 
local nums 2 4 6 7 8 9 
foreach i of local nums {
	replace x`i'inccat_i = 2500 if x`i'inccat_i == 1 
	replace x`i'inccat_i = 7500 if x`i'inccat_i == 2 
	replace x`i'inccat_i = 12500 if x`i'inccat_i == 3
	replace x`i'inccat_i = 17500 if x`i'inccat_i == 4
	replace x`i'inccat_i = 22500 if x`i'inccat_i == 5
	replace x`i'inccat_i = 27500 if x`i'inccat_i == 6
	replace x`i'inccat_i = 32500 if x`i'inccat_i == 7
	replace x`i'inccat_i = 37500 if x`i'inccat_i == 8
	replace x`i'inccat_i = 42500 if x`i'inccat_i == 9
	replace x`i'inccat_i = 47500 if x`i'inccat_i == 10
	replace x`i'inccat_i = 52500 if x`i'inccat_i == 11
	replace x`i'inccat_i = 57500 if x`i'inccat_i == 12
	replace x`i'inccat_i = 62500 if x`i'inccat_i == 13
	replace x`i'inccat_i = 67500 if x`i'inccat_i == 14
	replace x`i'inccat_i = 72500 if x`i'inccat_i == 15
	replace x`i'inccat_i = 77500 if x`i'inccat_i == 16
	replace x`i'inccat_i = 150000 if x`i'inccat_i == 17
	replace x`i'inccat_i = 260000 if x`i'inccat_i == 18
	label variable x`i'inccat_i "Family income in 2010 $s, ``i''"
	rename x`i'inccat_i faminc`i'
}

replace faminc2 = faminc2/(224.939/218.056)
replace faminc4 = faminc4/(229.594/218.056)
replace faminc6 = faminc6/(232.957/218.056)
replace faminc7 = faminc7/(236.736/218.056)
replace faminc8 = faminc8/(237.017/218.056)
replace faminc9 = faminc9/(240.007/218.056)

/*parental education*/ 
rename x12par1ed_i x2par1ed_i
label define pared ///
	0 "Less than high school diploma" ///
	1 "High school diploma or equivalent" ///
	2 "Vocational/technical degree or some college" ///
	3 "Bachelor's degree" ///
	4 "Graduate degree"
local nums 2 4 7 8 9
foreach i of local nums {
	replace x`i'par1ed_i = 0 if x`i'par1ed_i == 1 | x`i'par1ed_i == 2
	replace x`i'par1ed_i = 1 if x`i'par1ed_i == 3
	replace x`i'par1ed_i = 2 if x`i'par1ed_i == 4 | x`i'par1ed_i == 5
	replace x`i'par1ed_i = 3 if x`i'par1ed_i == 6 | x`i'par1ed_i == 7
	replace x`i'par1ed_i = 4 if x`i'par1ed_i == 8 | x`i'par1ed_i == 9
	label variable x`i'par1ed_i "Parent 1 highest education, ``i''"
	label values x`i'par1ed_i pared 
	rename x`i'par1ed_i par1ed`i'
}

rename x12par2ed_i x2par2ed_i
local nums 2 4 7 8 9
foreach i of local nums {
	replace x`i'par2ed_i = 0 if x`i'par2ed_i == 1 | x`i'par2ed_i == 2
	replace x`i'par2ed_i = 1 if x`i'par2ed_i == 3
	replace x`i'par2ed_i = 2 if x`i'par2ed_i == 4 | x`i'par2ed_i == 5
	replace x`i'par2ed_i = 3 if x`i'par2ed_i == 6 | x`i'par2ed_i == 7
	replace x`i'par2ed_i = 4 if x`i'par2ed_i == 8 | x`i'par2ed_i == 9
	label variable x`i'par2ed_i "Parent 2 highest education, ``i''"
	label values x`i'par2ed_i pared 
	rename x`i'par2ed_i par2ed`i'
}

local nums 2 4 7 8 9
foreach i of local nums {
	gen pared`i' = max(par1ed`i', par2ed`i')
	label values pared`i' pared
	label variable pared`i' "Parent highest education, ``i''"
}

/*parental occupational status*/
local nums 1 4 6 9
foreach i of local nums { 
	label variable x`i'par1scr_i "Parent 1 average occupational prestige, ``i''"
	rename x`i'par1scr_i par1occ`i'
}

local nums 1 4 6 9
foreach i of local nums { 
	label variable x`i'par2scr_i "Parent 2 average occupational prestige, ``i''"
	rename x`i'par2scr_i par2occ`i'
}

local nums 1 4 6 9
foreach i of local nums { 
	gen parocc`i' = max(par1occ`i', par2occ`i')
	label variable parocc`i' "Highest parent average occupational prestige, ``i''"
}

/*parental employment status*/ 
rename x1par1emp x1par1emp_i
label define emp 0 "Not in the labor force" 1 "Less than 35 hours per week" 2 "35 or more hours per week"
local nums 1 4 6 9 
foreach i of local nums { 
	replace x`i'par1emp_i = 0 if x`i'par1emp_i == 3 | x`i'par1emp_i == 4
	replace x`i'par1emp_i = 3 if x`i'par1emp_i == 2
	replace x`i'par1emp_i = 2 if x`i'par1emp_i == 1
	replace x`i'par1emp_i = 1 if x`i'par1emp_i == 3
	label values x`i'par1emp_i emp
	label variable x`i'par1emp_i "Parent 1 employment status, ``i''"
	rename x`i'par1emp_i par1emp`i'
}

rename x1par2emp x1par2emp_i
local nums 1 4 6 9 
foreach i of local nums { 
	replace x`i'par2emp_i = 0 if x`i'par2emp_i == 3 | x`i'par2emp_i == 4
	replace x`i'par2emp_i = 3 if x`i'par2emp_i == 2
	replace x`i'par2emp_i = 2 if x`i'par2emp_i == 1
	replace x`i'par2emp_i = 1 if x`i'par2emp_i == 3
	label values x`i'par2emp_i emp
	label variable x`i'par2emp_i "Parent 2 employment status, ``i''"
	rename x`i'par2emp_i par2emp`i'
}

/*household size*/ 
local nums 1 2 4 6 7 8 9
foreach i of local nums {
	label variable x`i'htotal "Total number of people in household, ``i''"
	rename x`i'htotal hhtot`i'
}

/*bio parents present*/
local nums 1 2 4 6 7 8 9 
foreach i of local nums{
	replace x`i'hparnt = 0 if x`i'hparnt == 2 | x`i'hparnt == 3 | x`i'hparnt == 4
	label values x`i'hparnt yes
	label variable x`i'hparnt "Two biological parents in household, ``i''"
	rename x`i'hparnt hhprnt`i'
}

/*sibship size*/
local nums 1 2 4 6 7 8 9
foreach i of local nums {
	replace x`i'numsib = 7 if x`i'numsib > 7 & x`i'numsib < 30
	label values x`i'numsib hh
	label variable x`i'numsib "Number of siblings in household, ``i''"
	rename x`i'numsib sibtot`i'
}

/*parental race/ethnicity*/ 
rename x1par1rac par1race
replace par1race = 3 if par1race == 4
replace par1race = 4 if par1race == 5
replace par1race = 5 if par1race == 6 | par1race == 7 | par1race == 8
label values par1race race
label variable par1race "Parent 1 race/ethnicity"

rename x1par2rac par2race
replace par2race = 3 if par2race == 4
replace par2race = 4 if par2race == 5
replace par2race = 5 if par2race == 6 | par2race == 7 | par2race == 8
label values par2race race
label variable par2race "Parent 2 race/ethnicity"

/*parent marital status*/ 
label define mar 0 "Not currently married" 1 "Currently married"
local nums 1 2 4 6 7 8 9
foreach i of local nums {
	replace p`i'curmar = 0 if p`i'curmar == 2 | p`i'curmar == 3 | p`i'curmar == 4 | p`i'curmar == 5
	replace p`i'curmar = 1 if p`i'curmar == 6
	label values p`i'curmar mar
	label variable p`i'curmar "Parent current marital status, ``i''"
	rename p`i'curmar married`i'
}

/*mother married at time of sample member's birth*/ 
rename x12momar marbrth
replace marbrth = 0 if marbrth == 2 
label values marbrth yes
label variable marbrth "Mother was married at time of birth"

/*parent age*/ 
rename x1par1age par1age1 
label variable par1age1 "Parent 1 age in years, Kindergarten Fall"

rename x1par2age par2age1 
label variable par2age1 "Parent 2 age in years, Kindergarten Fall"

/*parental involvement - reading*/ 
rename p3rdbktc p3readbk
rename p5rdbktc p5readbk
label define preadbk 1 "Not at all" 2 "Once or twice a week" 3 "3-6 times a week" 4 "Every day"
local nums 1 3 4 5 6
foreach i of local nums { 
	rename p`i'readbk preadbk`i'
	label values preadbk`i' preadbk
	label variable preadbk`i' "Parent reads books to child, ``i''"
}

/*parental involvement - math*/ 
rename p1numbrs p1practc
label define pprctnm 1 "Not at all" 2 "Once or twice a week" 3 "3 to 6 times a week" 4 "Everyday"
local nums 1 6 8 9 
foreach i of local nums { 
	rename p`i'practc pprctnm`i'
	label values pprctnm`i' pprctnm
	label variable pprctnm`i' "Parent practices numbers with child, ``i''"
}

/*parental expectations*/ 
label define exp ///
	0 "No postsecondary attendance" ///
	1 "Some postsecondary schooling" ///
	2 "Bachelor's degree" ///
	3 "Graduate degree"
local nums 1 7 9 
foreach i of local nums { 
	replace p`i'expect = 0 if p`i'expect == 1 | p`i'expect== 2
	replace p`i'expect = 1 if p`i'expect == 3 | p`i'expect == 4
	replace p`i'expect = 2 if p`i'expect == 5 
	replace p`i'expect = 3 if p`i'expect == 6 | p`i'expect == 7
	label values p`i'expect exp
	label variable p`i'expect "Parent 1 educational expectations, ``i''"
	rename p`i'expect p1exp`i'
}

/*teacher reported externalizing behaviors*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums { 
	label variable x`i'tchext "Teacher report child externalizing behaviors, ``i''"
	rename x`i'tchext extrn`i'
}

/*teacher reported internalizing behaviors*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	rename x`i'tchint intrn`i'
	label variable intrn`i' "Teacher report child internalizing behaviors, ``i''"
}

/*child motivation level*/ 
label def hilow 1 "1 Very Low" 2 "2 Low" 3 "3 Average" 4 "4 High" 5 "5 Very High"
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace c`i'motiva = . if c`i'motiva <= -1
	label var c`i'motiva "Observation - child motivated, ``i''"
	label values c`i'motiva hilow 
	rename c`i'motiva mtvt`i'
}

/*child cooperation level*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace c`i'cooper = . if c`i'cooper <= -1  
	label variable c`i'cooper "Observation - child cooperates, ``i''"
	label values c`i'cooper hilow 
	rename c`i'cooper cooper`i'
}

/*child attention level*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace c`i'attlvl = . if c`i'attlvl <= -1
	label variable c`i'attlvl "Observation - child attention level, ``i''"
	label values c`i'attlvl hilow 
	rename c`i'attlvl attn`i'
}

/*child health*/ 
label def health 1 "1 Excellent" 2 "2 Very Good" 3 "3 Good" 4 "4 Fair" 5 "5 Poor" 
local nums 1 2 4 6 7 8 9 
foreach i of local nums { 
	replace p`i'hscale = . if p`i'hscale <= -1
	label variable p`i'hscale "Parent report of child health scale, ``i''"
	label values p`i'hscale health
	rename p`i'hscale hlthscale`i'
}

/********
META-DATA
*********/
/*normalized sampling weights*/ 
sum w1c0
gen sampwt = w1c0/r(mean)
sum sampwt
drop w1c0
label variable sampwt "Normalized sampling weight" 

/*fall subsample participant*/ 
rename x3fallsmp fllsmp
label variable fllsmp "Selected for inclusion fall subsample, fall 1st grade" 
replace fllsmp = 0 if fllsmp == 3
replace fllsmp = 1 if fllsmp == 2

/*clean school ID strings*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums { 
	replace s`i'_id = "" if s`i'_id == "9100" | s`i'_id == "9997" | s`i'_id == "9995" | s`i'_id == "9993" | s`i'_id == "9998" | s`i'_id == "9994" | s`i'_id == "9999"
	label variable s`i'_id "School ID, ``i''"
}

/*kindergarten school ID*/  
gen schlid = s1_id 
replace schlid = s2_id if s1_id == ""
label variable schlid "Kindergarten school ID"

/*sampling stata and PSUs*/
sort psuid
gen temp_strat="" 
replace temp_strat = substr(psuid,1,4)
sort temp_strat
egen strat = group(temp_strat)
label variable strat "Sample stratum" 

sort psuid
egen psu = group(psuid)
label variable psu "Original PSU"

drop temp_strat psuid w1c0str w1c0psu

/******
GEODATA
*******/
/*region*/
label define x1region 1 "Northeast" 2 "Midwest" 3 "South" 4 "West" 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace x`i'region = .i if x`i'region == -7 | x`i'region == -8 | x`i'region == -9
	replace x`i'region = .p if x`i'region == .
	replace x`i'region = . if x`i'region == -1 | x`i'region == -4 | x`i'region == -5
	label values x`i'region x1region
}

/*locale*/ 
label define locale ///
	1 "Lrg city" /// 
	2 "Med city" ///
	3 "Sml city" ///
	4 "Suburb" ///
	5 "Rural" 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace x`i'locale = . if x`i'locale <= -1 
    replace x`i'locale = 1 if x`i'locale == 11
	replace x`i'locale = 2 if x`i'locale == 12
	replace x`i'locale = 3 if x`i'locale == 13
	replace x`i'locale = 4 if inrange(x`i'locale,21,23)
	replace x`i'locale = 5 if inrange(x`i'locale,31,43)
	label values x`i'locale locale
}

/*school census tracts*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace f`i'centr = "" if f`i'centr == "-7" | f`i'centr == "-8" | f`i'centr == "-9"
	replace f`i'centr = "" if f`i'centr == "-1" | f`i'centr == "-4" | f`i'centr == "-5"
}

/*home census tracts*/ 
local nums 1 2 3 4 5 6 7 8 9
foreach i of local nums {
	replace p`i'centr = "" if p`i'centr == "-7" | p`i'centr == "-8" | p`i'centr == "-9"
	replace p`i'centr = "" if p`i'centr == "-1" | p`i'centr == "-4" | p`i'centr == "-5"
}

/******************
DROP VARS NOT USING   
*******************/
drop ///
p2tincth p4tincth_i p6tincth_i p7tincth_i p8tincth_i p9tincth_i x1attnfs x2attnfs x4attnfs ///
x_hisp_r x_white_r x_black_r x_asian_r x_aminan_r x_hawpi_r x_multr_r p2tincth p4tincth_i ///
ifp4tincth p6tincth_i ifp6tincth p7tincth_i ifp7tincth p8tincth_i ifp8tincth p9tincth_i ifp9tincth ///
x1par1occ_i x4par1occ_i x6par1occ_i x9par1occ_i x1par2occ_i x4par2occ_i x6par2occ_i x9par2occ_i ///
x1less18 x2less18 x4less18_r x6less18 x7less18 x8less18 x9less18 ///
x1plss x2plss x3plss x4plss x1plart x2plart x3plart x4plart x9langst x4par1rac x6par1rac x7par1rac /// 
x8par1rac x9par1rac ifx12par1ed ifx1par1scr ifx4par1occ ifx4par1scr ifx6par1occ ifx6par1scr ///
ifx9par1occ ifx9par1scr x2par2rac x4par2rac x6par2rac x7par2rac x8par2rac x9par2rac ifx12par2ed ///
ifx1par2scr ifx4par2occ ifx4par2scr ifx6par2occ ifx6par2scr ifx9par2occ ifx9par2scr ifx2inccat ///
x2flch2_i x2rlch2_i x4fmeal_i x4rmeal_i x7frmealflg x8frmealflg x9frmealflg ifx2flch2 ifx2rlch2 ///
ifx4fmeal ifx4rmeal ifx6frmeal ifx7frmeal ifx8frmeal ifx9frmeal t2grade t3grade ///
p1sex_1 p1mom_1 p1dad_1 p1sex_2 p1mom_2 p1dad_2 p1numpla p2sex_1 p2mom_1 p2dad_1 p2sex_2 ///
p2mom_2 p2dad_2 p4sex_1 p4mom_1 p4dad_1 p4sex_2 p4mom_2 p4dad_2 p4numpla p6sex_1 p6mom_1 ///
p6dad_1 p6sex_2 p6mom_2 p6dad_2 p7sex_1 p7mom_1 p7dad_1 p7sex_2 p7mom_2 p7dad_2 p8sex_1 ///
p8mom_1 p8dad_1 p8sex_2 p8mom_2 p8dad_2 p9sex_1 p9mom_1 p9dad_1 p9sex_2 p9mom_2 p9dad_2 ///
a1smlgrp a1readar a1listnc a1wrtcnt a1mathar a1playar a1watrsa a1compar a1sciar a1dramar ///
a1artare a1timdis t1cmpsen t1reads t1write t1solve t1strat a2txtbk a2manipu a2audiov ///
a2video a2compeq a2softwa a2paper a2copier a2clsspc a2blndwd a4kdbehvr a4kwkindp ///
a4kwkindv a4kwkpeer a4kwksgrp a4kwklgrp a4kreadar a4klistnc a4kwrtcnt a4kmathar ///
a4kpuzblk a4kwtrsand a4kcompar a4ksciar a4kdramar a4kartare a4koftrdl a4koftmth ///
a4koftsci a4koftmus a4koftart a4koftpe a4koftdan a4kofthtr a4koftfln a4ktxrdla a4ktxmth ///
a4ktxsoc a4ktxsci a4ktxmus a4ktxart a4ktxpe a4ktxdan a4ktxthtr a4ktxfln a4kdivrd ///
a4kdivmth a4kdpwhmwk a4ktoclss a4ktostdr a4kimpprg a4keffrt a4kclspar a4kclsbhv ///
a4kcooprt a4kflldir a4kstntst a4ktstqz a4kprojct a4kwrksts a4kwrksam a4kaccptd x4kattnfs ///
a4kcntnlr a4kpaprwr a4kpsupp a4kcopstf a4krecjob a4kstndlo a4kmissio a4ksetpri x4ktchint ///
a4kencour a4kenjoy a4kmkdiff a4kcnsnss a4ktgend a4khisp a4kaminan a4kasian a4kblack ///
a4khawpi a4kwhite a4khghstd a4kyrsch a4kyrstch a4knatexm a4kstatct x2par1rac ///
t4kcmpsen t4kreads t4kwrite t4ksolve t4kstrat t4kshows t4kworks a7wtbuse x4ktchext ///
g8enjact m8behvr m8wkindp m8wkindv m8wkpeer m8wksgrp m8wklgrp m8dpwhmwk n8behvr ///
n8wkindp n8wkindv n8wkpeer n8wksgrp n8wklgrp n8dpwhmwk g9enjact m9behvr m9wkindp ///
m9wkindv m9wkpeer m9wksgrp m9wklgrp m9dpwhmwk n9behvr n9wkindp n9wkindv n9wkpeer ///
n9wksgrp n9wklgrp n9dpwhmwk s7giftyn s7mathyn s7nursyn s7psycyn s7libryn s7ctecyn ///
s8giftyn s8mathyn s8nursyn s8psycyn s8libryn s8ctecyn s9giftyn s9mathyn s9nursyn ///
s9psycyn s9libryn s9ctecyn a8tgendz a9tgendz x_raceth_r x2par1rac s2instcm ///
a1black a4black a6black a7black a8black a8blackz a9black a9blackz a1hisp a4hisp ///
a6hisp a7hisp a8hisp a8hispz a9hisp a9hispz a1aminan a4aminan a6aminan a7aminan ///
a8aminan a8aminanz a9aminan a9aminanz a1white a4white a6white a7white a8white ///
a8whitez a9white a9whitez a1asian a4asian a6asian a7asian a8asian a8asianz ///
a9asian a9asianz a1hawpi a4hawpi a6hawpi a7hawpi a8hawpi a8hawpiz a9hawpi a9hawpiz ///
s2cnsnss s4cnsnss s6cnsnss a8oftrdlz a8oftmthz a8oftsciz a8oftmusz a8oftartz ///
a8oftpez a8oftdanz a8ofthtrz a8oftflnz a9oftrdlz a9oftmthz a9oftsciz a9oftmusz ///
a9oftartz a9oftpez a9oftdanz a9ofthtrz a9oftflnz a8txrdlaz a8txmthz a8txsocz ///
a8txsciz a8txmusz a8txartz a8txpez a8txdanz a8txthtrz a8txflnz a8toclssz ///
a8tostdrz a8impprgz a8effrtz a8clsparz a8clsbhvz a8cooprtz a8flldirz a8psuppz ///
a8copstfz a8cnsnssz a8setpriz a8encourz a8enjoyz a8teachz a8yrstchz a8hghstdz ///
a9txrdlaz a9txmthz a9txsocz a9txsciz a9txmusz a9txartz a9txpez a9txdanz a9txthtrz ///
a9txflnz a9toclssz a9tostdrz a9impprgz a9effrtz a9clsparz a9clsbhvz a9cooprtz ///
a9flldirz a9psuppz a9copstfz a9cnsnssz a9stndloz a9setpriz a9encourz a9enjoyz ///
a9teachz a9yrstchz a9hghstdz s2hisp s4hisp s6hisp s7hisp s8hisp s9hisp s2black ///
s4black s6black s7black s8black s9black s2white s4white s6white s7white s8white ///
s9white s2asian s4asian s6asian s7asian s8asian s9asian s2aminan s4aminan ///
s6aminan s7aminan s8aminan s9aminan s2hawpi s4hawpi s6hawpi s7hawpi s8hawpi ///
s9hawpi s2white s4white s6white s7white s8white s9white a1timdis ///
stotenrl2 stotenrl6 stotenrl7 stotenrl8 stotenrl9 p1prmlng p9prmlng ///
t2cmpsen t2reads t2write t2solve t2strat p1oldmom a8stndloz p4prmlng p6prmlng s2bussed ///
sibtot1 sibtot2 sibtot4 sibtot6 sibtot7 sibtot8 sibtot9 ///
x1ksctyp x2ksctyp x4sctyp x6sctyp x7sctyp x8sctyp x9sctyp ///
p2attenb p2attenp p2ptconf p2attens p2volsch ///
p3sumsch p4attenb p4attenp p4ptconf p4attens p4volsch ///
p6attenb p6attenp p6ptconf p6attens p6volsch ///
p7attenb p7attenp p7ptconf p7attens p7volsch ///
p8attenb p8attenp p8ptconf p8attens p8volsch ///
p9attenb p9attenp p9ptconf p9attens p9volsch ///
t1shows t1works t2shows t2works t3shows t3works t4shows t4works ///
t5shows t5works t6shows t6works t7shows t7works ///
g8shows g8works g9shows g9works ///
p4asthma p6asthma p7asthma p8asthma p9asthma ///
x1firkdg p1wicmom p2wicmom

drop w1a0-w9c79p_9t790

/************************
SAVE AS NEW STATA DATASET  
*************************/
save "${data_directory}v02_eclsk11_clean.dta", replace

clear all 

log close

