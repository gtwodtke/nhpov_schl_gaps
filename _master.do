capture clear all 
capture set more off 

global prgmpath "C:\Users\Geoffrey Wodtke\Desktop\projects\nhood_schl_gaps\programs\"

/*DATA PROCESSING*/ 
do "${prgmpath}01_create_v01_eclsk11_raw.do" nostop
 
do "${prgmpath}02_create_v02_eclsk11_clean.do" nostop

do "${prgmpath}03_create_v03_eclsk11_ccd.do" nostop

do "${prgmpath}04_create_v04_eclsk11_valAdd.do" nostop

do "${prgmpath}05_create_v05_eclsk11_ncdb.do" nostop

do "${prgmpath}06_create_v06_eclsk11_si.do" nostop

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}07_create_v07_eclsk11_mi.R"
shell DEL "${prgmpath}07_create_v07_eclsk11_mi.Rout"

do "${prgmpath}08_create_v08_eclsk11_mi_final.do" nostop

/*ANALYSES*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}09_create_figure_1.R"
shell DEL "${prgmpath}09_create_figure_1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}10_create_figure_2.R"
shell DEL "${prgmpath}10_create_figure_2.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}11_create_figure_3.R"
shell DEL "${prgmpath}11_create_figure_3.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}12_create_figure_4.R"
shell DEL "${prgmpath}12_create_figure_4.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}13_create_figure_5.R"
shell DEL "${prgmpath}13_create_figure_5.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}14_create_figure_6.R"
shell DEL "${prgmpath}14_create_figure_6.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}15_create_table_1.R"
shell DEL "${prgmpath}15_create_table_1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}16_create_figure_7.R"
shell DEL "${prgmpath}16_create_figure_7.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}17_create_figure_8.R"
shell DEL "${prgmpath}17_create_figure_8.Rout"

/*APPENDIX A*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}18_create_figure_A1.R"
shell DEL "${prgmpath}18_create_figure_A1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}19_create_table_A1.R"
shell DEL "${prgmpath}19_create_table_A1.Rout"

/*APPENDIX B*/
do "${prgmpath}20_create_table_B1.do" nostop

/*APPENDIX C*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}21_create_figure_C1.R"
shell DEL "${prgmpath}21_create_figure_C1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}22_create_figure_C2.R"
shell DEL "${prgmpath}22_create_figure_C2.Rout"

/*APPENDIX D*/
do "${prgmpath}23_create_table_D1.do" nostop

/*APPENDIX E*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}24_create_figure_E1.R"
shell DEL "${prgmpath}24_create_figure_E1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}25_create_figure_E2.R"
shell DEL "${prgmpath}25_create_figure_E2.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}26_create_table_E1.R"
shell DEL "${prgmpath}26_create_table_E1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}27_create_table_E2.R"
shell DEL "${prgmpath}27_create_table_E2.Rout"

/*APPENDIX F*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}28_create_figure_F1.R"
shell DEL "${prgmpath}28_create_figure_F1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}29_create_table_F1.R"
shell DEL "${prgmpath}29_create_table_F1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}30_create_figure_F2.R"
shell DEL "${prgmpath}30_create_figure_F2.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}31_create_table_F2.R"
shell DEL "${prgmpath}31_create_table_F2.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}32_create_figure_F3.R"
shell DEL "${prgmpath}32_create_figure_F3.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}33_create_table_F3.R"
shell DEL "${prgmpath}33_create_table_F3.Rout"

/*APPENDIX G*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}34_create_figure_G1.R"
shell DEL "${prgmpath}34_create_figure_G1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}35_create_figure_G2.R"
shell DEL "${prgmpath}35_create_figure_G2.Rout"

/*APPENDIX H*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}36_create_table_H1.R"
shell DEL "${prgmpath}36_create_table_H1.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}37_create_table_H2.R"
shell DEL "${prgmpath}37_create_table_H2.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}38_create_table_H3.R"
shell DEL "${prgmpath}38_create_table_H3.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}39_create_table_H4.R"
shell DEL "${prgmpath}39_create_table_H4.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}40_create_table_H5.R"
shell DEL "${prgmpath}40_create_table_H5.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}41_create_table_H6.R"
shell DEL "${prgmpath}41_create_table_H6.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}42_create_table_H7.R"
shell DEL "${prgmpath}42_create_table_H7.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}43_create_table_H8.R"
shell DEL "${prgmpath}43_create_table_H8.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}44_create_table_H9.R"
shell DEL "${prgmpath}44_create_table_H9.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}45_create_table_H10.R"
shell DEL "${prgmpath}45_create_table_H10.Rout"

shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}46_create_table_H11.R"
shell DEL "${prgmpath}46_create_table_H11.Rout"

/*MISC*/
shell "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" CMD BATCH --vanilla --slave --no-restore --no-timing --no-echo "${prgmpath}47_create_misc_stats.R"
shell DEL "${prgmpath}47_create_misc_stats.Rout"