/*
Assigns Rauch classification to 6-digit HS product categories
	- separately for HS92, HS96 and HS02
	- using Rauch - SITC Rev. 3 and SITC Rev. 3 - HS correspondence
	- based on the code - and also using the input data - from James Rauch's website (http://econweb.ucsd.edu/~jrauch/rauch_classification.html - last accessed on 10 Feb 2016)
Inputs:
	Rauch_classification_revised.csv
	SITC_Rev_3_english_structure.txt
	hs92_sitc3.csv	
	hs96_sitc3.csv	
	hs02_sitc3.csv	
Outputs:
	hs92_Rauch.dta
	hs96_Rauch.dta
	hs02_Rauch.dta
*/

clear
set more off

global datafold "../$in_ext"
global stable "../$in"

* STEP 1. RAUCH - SITC Rev 3 correspondence
* based on the code - and also using the input data - from James Rauch's website (http://econweb.ucsd.edu/~jrauch/rauch_classification.html - last accessed on 10 Feb 2016)

import delimited "$datafold/Rauch_classification_revised.csv", clear
rename sitc4 sitc2_T4
save  "$stable/Rauch_classification_revised.dta", replace

gen sitc2_T3=int(sitc2_T4/10)
gen sitc4thdig=10*[(sitc2_T4/10)-sitc2_T3]
keep if sitc4thdig==0
drop sitc4thdig sitc2_T4
save "$stable/Rauch_classification_revised_T3.dta", replace

import delimited "$datafold/SITC_Rev_3_english_structure.txt", delimiter(space) clear 
drop if v1=="ÿþCode"
gen Tier_Rev3=length(v1)-1
keep if Tier_Rev3>=4
destring v1, gen(sitcnum) ignore(".") 
egen descrip=concat(v9-v58), punct(" ")
rename v1 raw_code
drop v*

*Create Tier variables

gen sitc3_T4=sitcnum if Tier_Rev3==4
replace sitc3_T4=sitcnum*10 if Tier_Rev3==3
gen sitc3_T3=sitcnum if Tier_Rev3==3
replace sitc3_T3=int(sitcnum/10) if Tier_Rev3==4
gen sitc3_T2=sitcnum if Tier_Rev3==2
replace sitc3_T2=int(sitcnum/10) if Tier_Rev3==3
replace sitc3_T2=int(sitcnum/100) if Tier_Rev3==4
sort sitc3_T2 sitc3_T3 sitc3_T4

*Only keep those that are Tier 3 or 4

drop if sitc3_T4==. & sitc3_T3==.
rename sitc3_T4 sitc2_T4
rename sitc3_T3 sitc2_T3

*Merge in 4-digit classification

merge m:1 sitc2_T4 using "$stable/Rauch_classification_revised.dta", gen(_merge_revclas)
gen con_4=con
gen lib_4=lib

*Merge in 3-digit classification

merge m:1 sitc2_T3 using "$stable/Rauch_classification_revised_T3.dta", gen(_merge_revclasT3) update
rename con con_34
rename lib lib_34
rename sitc2_T4 sitc3_T4
rename sitc2_T3 sitc3_T3

keep if sitcnum!=.
keep con_34 sitcnum

save "$stable/SITC_Rev_3_Rauch.dta", replace


* STEP 2. HS - SITC Rev 3 correspondence

import delimited "$datafold/hs92_sitc3.csv", clear
rename s3 sitcnum
merge m:1 sitcnum using "$stable/SITC_Rev_3_Rauch.dta"
keep if _merge==3
drop _merge
keep hs92 con_34
save "$stable/hs92_Rauch.dta", replace

import delimited "$datafold/hs96_sitc3.csv", clear
rename s3 sitcnum
merge m:1 sitcnum using "$stable/SITC_Rev_3_Rauch.dta"
keep if _merge==3
drop _merge
keep hs96 con_34
save "$stable/hs96_Rauch.dta", replace

import delimited "$datafold/hs02_sitc3.csv", clear
rename s3 sitcnum
merge m:1 sitcnum using "$stable/SITC_Rev_3_Rauch.dta"
keep if _merge==3
drop _merge
keep hs02 con_34
save "$stable/hs02_Rauch.dta", replace
