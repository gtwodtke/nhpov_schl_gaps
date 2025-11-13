#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}06_create_v06_eclsk11_si.log", replace 

/****************************************************
PROGRAM NAME: 06_create_v06_eclsk11_si.do
PURPOSE: single imputation for select school measures
*****************************************************/

/*********
INPUT DATA
**********/
use "${data_directory}\eclsk11\v05_eclsk11_ncdb.dta", clear

/*********************************************
TRANSFORM ALL MISSING VALUES TO SYSTEM MISSING
**********************************************/
ds, has(type numeric)

foreach var of varlist `r(varlist)' {
	replace `var' = . if `var' == .i | `var' == .p
}

/*********************************************************
IMPUTE SELECTED SCHOOL VAR BY SHARING DATA ACROSS STUDENTS
**********************************************************/
bysort s3_id: egen i_rdvaladd = mean(rdvaladd)
bysort s3_id: egen i_mtvaladd = mean(mtvaladd)

replace rdvaladd = i_rdvaladd if rdvaladd == . & s3_id != ""
replace mtvaladd = i_mtvaladd if mtvaladd == . & s3_id != ""

drop i*valadd

foreach var of varlist ///
	sblk4 stotell4 sfrlnch4 sgif4 shspnc4 ///
	sspced4 swht4 strg_pp_4 ccd_dstr_exppp4 start_pp_4 stesl_pp_4 ///
	stgft_pp_4 stgym_pp_4 stcmp_pp_4 stlib_pp_4 stnrs_pp_4 stpar_pp_4 ///
	pyrspr4 pyrstch4 stfpsy_pp_4 stsp_pp_4 tyrsch4 sttrn4 tyrstch4 ///
	sainst4 sattnd4 { 
		quietly bysort s4_id: egen i_`var' = mean(`var')
		replace `var' = i_`var' if `var' == . & s4_id != ""
		drop i_`var'
}

foreach var of varlist ///
	sapri4 saenc4 sacns4 tenjy4 tmkdff4 tchstch4 tacpt4 ///
	tideas4 tppwrk4 tstfrec4 tlstd4 tmssn4 sthft4 scnfl4 sblly4 sdsrd4 spsupp4 ///
	srptcrd4 ststinf4 sptcnf4 sprnpar4 sspprt4 tord4 tomth4 tosci4 tomus4 toart4 ///
	togym4 todan4 tothtr4 tofln4 ttrd4 ttmth4 ttsoc4 ttsci4 ttmus4 ttart4 ttgym4 ///
	ttdan4 ttthtr4 ttfln4 ttsgrp4 ttlgrp4 ttindv4 ttpeer4 tevlclss4 tevlstd4 ///
	tevlimp4 tevleff4 tevlpart4 tevlbhv4 tevlcoop4 tevldir4 tevltst4 tevlqz4 tevlprj4 ///
	tevlwrksh4 tevlwrksa4 tachrd4 tachmth4 thw4 a4usebsl4 a4uselev4 a4usenew4 a4usekit4 ///
	a4usecmp4 a4usetrd4 a4useoth4 a4useman4 a4usebgbk4 a4usedecb4 a4useaubk4 a4useanth4 ///
	a4mainid4 a4retell4 a4deschar4 a4senses4 a4whotell4 a4maintext4 a4reassup4 ///
	a4simdiff4 a4ficnonf4 a4cmpxinf4 a4cmpxpro4 a4segword4 a4manpho4 a4sndwrd4 ///
	a4irregwd4 a4paceint4 a4rdaccr4 a4useglos4 a4senctxt4 a4charplot4 a4gencsp4 ///
	a4predict4 a4opinion4 a4infpiec4 a4narrtv4 a4cnt20qty4 a4relqty4 ///
	a4slvadsb4 a4slvadd34 a4ctadsub4 a4eqlsign4 a4sidequa4 a4slvuknm4 ///
	a4cnt1204 a4nmrl1204 a4numqty4 a4tenones4 a4relsym4 a4addto1004 ///
	a4find104 a4skipcnt4 a4arr3obj4 a4lng2by34 a4lngmult4 a4meatool4 ///
	a4estlng4 a4telltime4 a4wrttime4 a4slvcoin4 a4drwgrph4 a4ansgrph4 ///
	a4attrshp4 a4dimcomp4 a4parteql4 a4triquad4 tosoc4 tbhvr4 ped4 pgender4 ///
	prace4 sartok4 saudok4 scafeok4 sclssok4 scompok4 sgymok4 slibok4 smultok4 ///
	smusok4 splayok4 sfnddc4 shighgrd4 slowgrd4 sstffdec4 sstfffrz4 sstffinc4 ///
	strnsl4 stype4 syrrnd4 tcrt4 tnexm4 ted4 tgender4 trace4 ttlone4 spd4 { 
		quietly bysort s4_id: egen i_`var' = mode(`var')
		replace `var' = i_`var' if `var' == . & s4_id != ""
		drop i_`var'
}			

/***************
DROP UNUSED VARS
****************/
drop ///
	t1_id t2_id t3_id t4_id t5_id t6_id t7_id ///
	t8r_id t8rclass t8m_id t8mclass t8s_id t8sclass t9r_id t9rclass t9m_id t9mclass t9s_id t9sclass ///
	d2t_id d4t_id d6t_id d7t_id d8t_id d9t_id ///
	cc_id twin_id ///
	x1asmtmm x2asmtmm x3asmtmm x4asmtmm x5asmtmm x6asmtmm x7asmtmm x8asmtmm x9asmtmm ///
	x1asmtdd x2asmtdd x3asmtdd x4asmtdd x5asmtdd x6asmtdd x7asmtdd x8asmtdd x9asmtdd ///
	x1asmtyy x2asmtyy x3asmtyy x4asmtyy x5asmtyy x6asmtyy x7asmtyy x8asmtyy x9asmtyy ///
	x_dobmm_r x_dobyy_r ///
	x3grdlvl x4grdlvl x5grdlvl x6grdlvl x7grdlvl x8grdlvl x9grdlvl ///
	x2schbdd x4schbdd x6schbdd x7schbdd x8schbdd x9schbdd ///
	x2schbmm x4schbmm x6schbmm x7schbmm x8schbmm x9schbmm ///
	x2schbyy x4schbyy x6schbyy x7schbyy x8schbyy x9schbyy ///
	x2schedd x4schedd x6schedd x7schedd x8schedd x9schedd ///
	x2schemm x4schemm x6schemm x7schemm x8schemm x9schemm ///
	x2scheyy x4scheyy x6scheyy x7scheyy x8scheyy x9scheyy ///
	f1ccdlea f2ccdlea f3ccdlea f4ccdlea f5ccdlea f6ccdlea f7ccdlea f8ccdlea f9ccdlea ///
	f1ccdsid f2ccdsid f3ccdsid f4ccdsid f5ccdsid f6ccdsid f7ccdsid f8ccdsid f9ccdsid ///
	f1fipsct f2fipsct f3fipsct f4fipsct f5fipsct f6fipsct f7fipsct f8fipsct f9fipsct ///
	f1fipsst f2fipsst f3fipsst f4fipsst f5fipsst f6fipsst f7fipsst f8fipsst f9fipsst ///
	f1schpin f2schpin f3schpin f4schpin f5schpin f6schpin f7schpin f8schpin f9schpin ///
	f1schzip f2schzip f3schzip f4schzip f5schzip f6schzip f7schzip f8schzip f9schzip ///
	hcensus1 hcensus2 hcensus3 hcensus4 hcensus5 hcensus6 hcensus7 hcensus8 hcensus9 geo2010 ///
	scensus1 scensus2 scensus3 scensus4 scensus5 scensus6 scensus7 scensus8 scensus9 ///
	p1homzip p2homzip p3homzip p4homzip p5homzip p6homzip p7homzip p8homzip p9homzip
	
/********
SAVE DATA
*********/
saveold "${data_directory}\eclsk11\v06_eclsk11_si.dta", replace v(12)

clear

log close
 




