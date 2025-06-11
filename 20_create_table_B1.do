#delimit cr
capture log close 
capture clear all 

global data_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\data\eclsk11\" 
global log_directory "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\_LOGS\" 

log using "${log_directory}20_create_table_B1.log", replace 

/****************************************************
PROGRAM NAME: 20_create_table_B1.do
AUTHOR: GW
PURPOSE: compute school descriptives by nhood poverty
*****************************************************/

/***INPUT DATA***/
use "${data_directory}v08_eclsk11_mi_final.dta"   
keep if minum != 0

/***DEFINE VARIABLE SETS***/
global vars_schl_com ///
	sfrlnch4 sblk4 swht4 shspnc4 stotell4 sgif4 sspced4 ///
	tgender4 trace4 pgender4 prace4 

global vars_schl_res ///
	stype4 syrrnd4 slowgrd4 shighgrd4 ///
	sfnddc4 sstffdec4 sstfffrz4 sstffinc4 ccd_dstr_exppp4 ///
	stcmp_pp_4 start_pp_4 stgym_pp_4 stesl_pp_4 stlib_pp_4 stpar_pp_4 stfpsy_pp_4 stnrs_pp_4 stsp_pp_4 ///
		stgft_pp_4 strg_pp_4 strnsl4 sttrn4 ///
	ped4 pyrstch4 pyrspr4 ted4 tyrstch4 tcrt4 tnexm4 tyrsch4 ///
	sclssok4 saudok4 slibok4 sgymok4 splayok4 smusok4 sartok4 scompok4 smultok4 scafeok4

global vars_schl_ins ///
	tord4 ttrd4 tomth4 ttmth4 ///
	ttsgrp4 ttlgrp4 ttpeer4 ttindv4 tachrd4 tachmth4 a4usedecb4 a4usekit4 a4usebsl4 ///
		a4usebgbk4 a4usecmp4 a4useman4 a4useanth4 a4uselev4 a4useaubk4 ///
	a4usenew4 a4usetrd4 a4useoth4 a4useglos4 a4reassup4 a4charplot4 a4simdiff4 a4whotell4 a4gencsp4 a4maintext4 ///
		a4senses4 a4mainid4 a4ficnonf4 a4senctxt4 a4rdaccr4 a4retell4 a4paceint4 a4predict4 a4sndwrd4 a4deschar4 ///
		a4cmpxinf4 a4segword4 a4manpho4 a4cmpxpro4 a4irregwd4 a4infpiec4 a4opinion4 a4narrtv4 ///
	a4arr3obj4 a4lng2by34 a4lngmult4 a4estlng4 a4meatool4 a4relqty4 a4relsym4 a4dimcomp4 a4cnt1204 a4slvadd34 /// 
		a4slvadsb4 a4attrshp4 a4slvuknm4 a4drwgrph4 a4ansgrph4 a4eqlsign4 a4sidequa4 a4numqty4 a4slvcoin4 ///
		a4wrttime4 a4telltime4 a4skipcnt4 a4tenones4 a4ctadsub4 a4cnt20qty4 a4addto1004 a4find104 a4parteql4 ///
		a4nmrl1204 a4triquad4 ///
	thw4 tevlwrksa4 tevlprj4 tevlwrksh4 tevlqz4 tevltst4 tevlclss4 tevlstd4 tevleff4 tevlimp4 ///
	tevlpart4 tevlbhv4 tevlcoop4 tevldir4

global vars_schl_cli ///
	sattnd4 ///
	sptcnf4 srptcrd4 ststinf4 sprnpar4 ///
	spsupp4 sspprt4 ///
	tenjy4 tmkdff4 tchstch4 tacpt4 tlstd4 ///
	sapri4 tideas4 saenc4 tstfrec4 tmssn4 tppwrk4 sacns4 ///
	tbhvr4 sdsrd4 sthft4 sblly4 scnfl4

global vars_schl_efx ///
	 rdvaladd mtvaladd

global vars_schl_cat ///
  pgender4 prace4 tgender4 trace4 sttrn4 ped4 sartok4 saudok4 scafeok4 sclssok4 ///
  scompok4 sgymok4 slibok4 smultok4 smusok4 splayok4 sfnddc4 shighgrd4 slowgrd4 ///
  sstffdec4 sstfffrz4 sstffinc4 strnsl4 stype4 syrrnd4 tcrt4 tnexm4 ted4 

/***RECODE VARIABLES***/
foreach v in $vars_schl_cat {
	quietly replace `v' = `v'-1
}
/***SCHOOL DESCRIPTIVES***/

/*COMPOSITION*/
tabstat $vars_schl_com, stat(mean sd min max) columns(stat)

/*RESOURCES*/
tabstat $vars_schl_res, stat(mean sd min max) columns(stat)

/*INSTRUCTION*/
tabstat $vars_schl_ins, stat(mean sd min max) columns(stat)

/*CLIMATE*/
tabstat $vars_schl_cli, stat(mean sd min max) columns(stat)

/*EFFECTIVENESS*/
tabstat $vars_schl_efx, stat(mean sd min max) columns(stat)

log close
