/*
Creates a firm-level panel of cleaned balance sheet data with additional information
	- imputes missing observations and itrapolates missing values if there are any
	- creates real values for monetary variables
	- creates foreign, domestic and state-owned dummies
	- adds the birth and death year
	- creates value added and labor productivity data
	- estimates TFP using the Levinsohn-Petrin method
	- also contains 2-digit industry and settlement codes
Inputs:
	balance_sheet.dta
	ex91.dta, ex92.dta ... ex03.dta
	im91.dta, im92.dta ... im03.dta
	firm_hqs_yearly_slices.csv
	PPI.dta
	deflators.dta
	county-nuts-city-ksh-codes.csv	
Outputs:
	firm_bsheet_data.dta
	LEVPET_prod_fc.xls
*/


clear
set more off

local in "../$in_ext"
local in1 "../$in_ext"
local in2 "../$in_ext"
local out "../$in"

tempfile bsheet_data location_data exports imports city_county PPI

use "`in'/balance_sheet.dta"

*keep originalid year emp sales export gdp jetok jetok06 ranyag teaor03_2d fo2 so2 foundyear
sum
keep originalid year emp sales export gdp jetok jetok06 ranyag teaor03_2d teaor_raw fo2 so2 foundyear persexp wbill tanass

* rename variables
rename originalid id8
rename foundyear minyear 
rename emp empl
rename export exp_sales
rename persexp gross_wage
rename wbill net_wage
rename tanass capital
rename ranyag material

* basic data check and cleaning
egen check=seq(), by(id8 year)
assert check==1
drop check
* drop firms with a negative id (no valid tax_id)
drop if id8<0
replace emp=0 if emp<0
tab minyear if minyear<1990

* generate foreign share
gen foreign_share=jetok06/jetok
drop jetok06 jetok
sum foreign_share
sum foreign_share if foreign_share>1
list id8 year foreign_share if foreign_share>1 & foreign_share!=.
replace foreign_share=. if foreign_share>1
sum

* impute missing observations (if there is only a single gap)
xtset id8 year
gen byte missingyear=F.id8==. & F2.id8!=.
tab missingyear
expand 2 if missingyear==1
egen newyear=seq() if missingyear==1, by(id8 year)
tab newyear, missing
replace year=year+1 if newyear==2
foreach X in empl sales exp_sales gdp foreign_share material teaor03_2d teaor_raw fo2 so2 net_wage gross_wage capital{
	replace `X'=. if newyear==2
}
drop missingyear newyear
xtset id8 year
save `bsheet_data'


* add data from other sources

* city-level location data
import delimited "`in'/firm_hqs_yearly_slices.csv", clear 
rename taxid id8
keep id8 year cityid
egen check=seq(), by(id8 year)
*tab check
assert check==1
drop check
sum
drop if id8==0
sum id8
save `location_data'
use `bsheet_data', clear
merge 1:1 id8 year using `location_data'
*no systematic missing years
tab year _merge, missing
drop if _merge==2
drop _merge
save `bsheet_data', replace

* assign total yearly imported and exported value
foreach K in ex im{
	local dir "`in1'/`K'port"
	if "`K'"=="ex"{
		local varn e
	}
	else if "`K'"=="im"{
		local varn i
	}
	clear
	save ``K'ports', replace emptyok
	* read customs stats
	foreach X of any 91 92 93 94 95 96 97 98 99 00 01 02 03 {
		use "`dir'/`K'`X'.dta", clear
		* keep only hs6. estimate natural quantity from weight if not known
		capture ren `varn'_msg`X' `varn'_mg`X'
		capture ren hs10 cn
		capture ren hs9 cn
		keep `varn'_mg`X' `varn'_ns`X' `varn'_ft`X' `varn'_ud`X' a1 szao hs6 cn me
		* rename variables
		ren a1 id8
		codebook id8
		foreach Y of any `varn'_mg `varn'_ns `varn'_ft `varn'_ud {
			ren `Y'`X' `Y'
		}
		ren szao country
		ren `varn'_ft `K'p_value
		label variable `K'p_value "`K'ported value in HUF"
		gen int year = 1900+`X'
		replace year=year+100 if year<1950
		* save the data
		compress
		append using ``K'ports'
		save ``K'ports', replace
	}
	* drop the invalid tax id-s
	drop if id8<10000000
	drop if id8==88888888
	drop if id8==99999999
	drop if id8==.
	* make invalid hs6 missing
	replace hs6=. if hs6==0
	* save
	save ``K'ports', replace
	* summary statistics
	collapse (sum) `K'p_value, by(id8 year)
	save ``K'ports', replace
}
use `bsheet_data', clear
merge 1:1 id8 year using `exports'
tab year _merge, missing
drop if _merge==2
drop _merge
save `bsheet_data', replace
merge 1:1 id8 year using `imports'
tab year _merge, missing
drop if _merge==2
drop _merge
* should be zero for firms missing from the trade database in years where we have detailed trade data
foreach X in exp_value imp_value{
	replace `X'=0 if year<=2003 & `X'==.
}
save `bsheet_data', replace

* intrapolate missing data

xtset id8 year
sum
* average for employment, sales, capital and material 
foreach X of any empl sales capital material {
	gen miss_`X'=0
	replace miss_`X'=1 if `X'==. & L.`X'!=. & F.`X'!=.
	replace miss_`X'=12 if `X'==. & L2.`X'!=. & F.`X'!=.
	replace miss_`X'=22 if `X'==. & L.`X'!=. & F2.`X'!=.
}
foreach X of any empl sales capital material{
	replace `X'=(L.`X'+F.`X')/2 if `X'==. & miss_`X'==1
	replace `X'=(L2.`X'+2*F.`X')/3 if `X'==. & miss_`X'==12
	replace `X'=(2*L.`X'+F2.`X')/3 if `X'==. & miss_`X'==22
}
* previous value for industry classification, county and ownership (except for missing first value)
foreach X in teaor03_2d teaor_raw fo2 so2 foreign_share cityid {
	gen miss_`X'=0
	replace miss_`X'=1 if `X'==. & L.`X'!=. & F.`X'!=.
	replace miss_`X'=11 if `X'==. & L2.`X'!=. & F.`X'!=.
	replace miss_`X'=12 if `X'==. & L.`X'!=. & F2.`X'!=.
	replace miss_`X'=10 if `X'==. & F.`X'!=. & year==minyear
}
foreach X in teaor03_2d teaor_raw fo2 so2 foreign_share cityid {
	replace `X'=L.`X' if `X'==. & miss_`X'==1
	replace `X'=L2.`X' if `X'==. & miss_`X'==11
	replace `X'=L.`X' if `X'==. & miss_`X'==12
	replace `X'=F.`X' if `X'==. & miss_`X'==10 
}	
foreach X in empl sales capital material teaor03_2d teaor_raw fo2 so2 foreign_share cityid{
	tab miss_`X'
}
drop miss*


* monetary values expressed in 1000 HUF
foreach X in imp_value exp_value{
	replace `X'=`X'/1000
}
* check the magnitude
sum exp_sales exp_value

* generate export share
gen exp_share=exp_sales/sales
sum exp_share 
sum exp_share if exp_share>1 & exp_share!=.
sum exp_share if exp_share>2 & exp_share!=., d
replace exp_share=1 if exp_share>1 & exp_share<2
replace exp_share=. if exp_share>=2

* generate domestic sales
gen dom_sales=sales-exp_sales
sum dom_sales
* make domestic sales missing if negative
sum dom_sales if dom_sales<0
replace dom_sales=0 if dom_sales<0 & exp_share==1
replace dom_sales=. if dom_sales<0

* assign a single 2-digit industry for each firm (used for the longest period or for the first time if there is more than one longest)
xtset id8 year
local X teaor03_2d
* count the number of entries with a nace code per firm
egen count_`X'=count(`X') if `X'!=., by(id8)
* count the number of entries for each nace code per firm
egen count_per_`X'=count(`X') if `X'!=., by(id8 `X')
* calculate the ratio of the given nace code within the total number of nace entries per firm - missing if no nace code at all
gen `X'_ratio=count_per_`X'/count_`X'
* calculate the highest ratio
egen max_`X'_ratio=max(`X'_ratio), by(id8)
sum id8 `X' count_`X' count_per_`X' `X'_ratio max_`X'_ratio
* get the most popular nace code
gen `X'_firm=`X' if `X'_ratio==max_`X'_ratio
* check if the most popular nace code is unique for each firm
egen unique_`X'=mean(`X'_firm) if `X'_firm!=., by(id8)
gen unique_`X'_test=`X'_firm- unique_`X'
sum unique_`X'_test if unique_`X'_test!=0
* get the earliest from the most frequent ones if there are more than one
egen min_`X'=min(year) if `X'_firm!=., by(id8)
sum unique_`X'_test if unique_`X'_test!=0 & year==min_`X'
sum id8 if unique_`X'_test==0 & year==min_`X'
gen `X'_firm_new=`X'_firm if year==min_`X'
egen `X'_firm_final=min(`X'_firm_new), by(id8)
* drop the unnecessary variables
drop count_`X' count_per_`X' `X'_ratio max_`X'_ratio `X'_firm unique_`X' unique_`X'_test min_`X' `X'_firm_new
rename `X' `X'_yearly
rename `X'_firm_final `X'

save `bsheet_data', replace


******************** MISSING *****************

* assign 4-digit teaor03, harmonized using data from other years and 2-digit teaor03 info
* assign most popular 4-digit teaor03 for each firm

**********************************************

* flag manufacturing firms
gen byte manufacturing = teaor03_2d>=15 & teaor03_2d<=37
replace manufacturing=. if teaor03_2d==.
tab manufacturing, missing
save `bsheet_data', replace

* deflating

* merge with deflator price indices
gen nace2=teaor03_2d
merge m:1 year nace2 using "`in'/PPI.dta"
tab year _merge, missing
tab year _merge if nace2!=., missing
tab nace2 _merge, missing
drop if _merge==2
drop _merge
drop nace2
* if nace2 is incorrect or unknown average PPI attached (used for services)
save `bsheet_data', replace
use "`in'/PPI.dta", clear
keep if nace2==99
drop nace2
foreach X in PPI dom_PPI exp_PPI materialPPI{
	rename `X' `X'_
}
sum
save `PPI', replace
use `bsheet_data', clear
merge m:1 year using `PPI'
drop if _merge==2
foreach X in PPI dom_PPI exp_PPI materialPPI{
	replace `X'=`X'_ if `X'==.
}
drop PPI_ dom_PPI_ exp_PPI_ materialPPI_ _merge
merge m:1 year using "`in'/deflators.dta"
tab year _merge, missing
drop if _merge==2
drop _merge
foreach X in sales gdp imp_value{
	replace `X'=`X'/PPI
}
replace dom_sales=dom_sales/dom_PPI
foreach X in exp_sales exp_value{
	replace `X'=`X'/exp_PPI
}
replace capital=capital/K_deflator
foreach X in material{
	replace `X'=`X'/materialPPI
}
foreach X in gross_wage net_wage{
	replace `X'=`X'/wage_index
}
drop PPI dom_PPI exp_PPI materialPPI GDP_deflator K_deflator avg_gross_wage_monthly wage_index
save `bsheet_data', replace

* generate per capita wage
gen percap_wage = net_wage/empl
sum percap_wage, d
sum percap_wage if percap_wage>6000, d
replace percap_wage=. if percap_wage>12000

* generate log labor productivity
gen lVA_per_capita=log(gdp/empl)
sum id8 gdp empl lVA_per_capita

* estimate productivity using Levinsohn-Petrin

tab teaor03_2d if sales!=. & sales!=0 & material!=. & material!=0 & capital!=. & capital!=0 & empl!=. & empl!=0, missing 
foreach X in empl material sales capital dom_sales exp_sales gdp net_wage gross_wage exp_value imp_value percap_wage{
	gen l`X'=log(`X')
}
egen id=group(id8)
xtset id year
levpet lsales if teaor03_2d==1, free(lempl) proxy(lmaterial) capital(lcapital) revenue i(id) t(year)
outreg2 using "`out'/LEVPET_prod_fc.xls", excel ctitle("teaor03 1") replace 
predict predtfp_1, omega
replace predtfp_1=. if teaor03_2d!=1
gen ltfp_pred=log(predtfp_1) if teaor03_2d==1
drop predtfp_1
*foreach X of numlist 2 14/37 45 50/52 55 60 63 70/74 85 90 92 93{
foreach X of numlist 2 5 14/15 17/22 24/37 40/41 45 50/52 55 60/61 63/65 67 70/74 80 85 90/93{
	display "`X'"
	levpet lsales if teaor03_2d==`X', free(lempl) proxy(lmaterial) capital(lcapital) revenue i(id) t(year)
	outreg2 using "`out'/LEVPET_prod_fc.xls", excel ctitle("teaor03 `X'") append 
	predict predtfp_`X', omega
	replace predtfp_`X'=. if teaor03_2d!=`X'
	replace ltfp_pred=log(predtfp_`X') if teaor03_2d==`X'
	drop predtfp_`X'
}
drop id
xtset id8 year

save `bsheet_data', replace

* generate foreign from the beginning dummy
egen min_in_sample=min(year), by(id8)
tab min_in_sample, missing
gen byte start_for=fo2==1 & year==min_in_sample
replace start_for=. if fo2==. & year==min_in_sample
replace start_for=. if year!=min_in_sample
tab start_for if year==min_in_sample, missing
egen foreign_start=max(start_for), by(id8)
tab fo2 foreign_start if year==min_in_sample, missing
tab start_for foreign_start, missing
drop start_for

* generate always domestic dummies
egen max_for_share=max(foreign_share), by(id8)
gen byte domestic=max_for_share==0
replace domestic=. if max_for_share==.
gen byte domestic20=max_for_share<=0.2
replace domestic20=. if max_for_share==.
tab domestic domestic20, missing
drop max_for_share

* generate last year in sample
egen last_year=max(year), by(id8)
tab last_year, missing

* above 5 median employment
egen med_emp=median(empl), by(id8)
gen byte above_5=med_emp>=5
replace above_5=. if med_emp==.
tab above_5, missing
tab above_5 manufacturing, missing
drop med_emp

* ever exporter dummy
gen byte exp=exp_sales>0 & exp_sales!=.
replace exp=1 if exp_value>0 & exp_value!=.
tab exp, missing
egen ever_exporter=max(exp), by(id8)
tab exp ever_exporter, missing

* not yet exported dummy (even not in the year regarded)
egen firstyear_exp=min(year) if exp==1, by(id8)
egen first_exp=min(firstyear_exp), by(id8)
gen byte not_yet_exp=year<first_exp
tab not_yet_exp exp, missing
tab not_yet_exp ever_exporter, missing
list id8 year exp_sales exp_value exp ever_exporter firstyear_exp first_exp min_in_sample not_yet_exp if  _n<=25
list id8 year exp_sales exp_value exp ever_exporter firstyear_exp first_exp min_in_sample not_yet_exp if first_exp>min_in_sample & first_exp!=. & _n<=1000
rename exp exports_that_year
drop firstyear_exp first_exp min_in_sample 
save `bsheet_data', replace

* add the county
import delimited "`in2'/county-nuts-city-ksh-codes.csv", clear 
keep ksh_code nuts3
rename ksh_code cityid
rename nuts3 county
save `city_county'
use `bsheet_data', clear
merge m:1 cityid using `city_county'
codebook cityid if _merge==1
tab cityid _merge if _merge!=3, missing
drop if _merge==2
drop _merge
tab county

* check the number of firms changing headquarter city
egen modecity=mode(cityid), by(id8) minmode
codebook id8
codebook id8 if cityid!=.
codebook id8 if cityid!=modecity & cityid!=.
*154,439 out of 780,335 with headquarter data (and 872,648 overall) change their headquarter city at least once
drop modecity
egen modecity=mode(cityid) if county!="HU101", by(id8) minmode
codebook id8 if cityid!=modecity & county!="HU101" & cityid!=.
*50,288 change their headquarter city at least once when excluding changes from/to Bp
drop modecity
* check the number of firms changing headquarter county
gen nuts3=substr(county,3,3)
destring nuts3, replace
tab nuts3
egen modecounty=mode(nuts3), by(id8) minmode
codebook id8 if nuts3!=modecounty & nuts3!=.
*59,764 out of 780,335 with headquarter data (and 872,648 overall) change their headquarter county at least once
drop modecounty
replace nuts3=. if nuts3==101
egen modecounty=mode(nuts3), by(id8) minmode
codebook id8 if nuts3!=modecounty & nuts3!=.
*only 15,462 out of 780,335 with headquarter data (and 872,648 overall) change their headquarter county at least once when excluding changes from/to Bp
drop nuts3 modecounty

* checks
egen check=seq(), by(id8 year)
assert check==1
drop check
sum
save `bsheet_data', replace

* labeling
label variable sales `"Sales 1000HUF, in 1998 HUF"'
label variable exp_sales `"Export sales 1000HUF, in 1998 HUF"'
label variable gdp `"Gross Value Added: sales+aktivalt-material 1000HUF, in 1998 HUF"'
label variable material `"Sum of material type expenditures 1000HUF, in 1998 HUF"'
label variable foreign_share `"Share of foreign owners"'
label variable cityid `"KSH code of the headquarter city"'
label variable minyear `"Foundation year of the firm (fixed within firm)"'
label variable net_wage `"bérköltség in 1000 HUF, 1998 HUF"'
label variable material `"Anyagköltség in 1000 HUF, 1998 HUF "'
label variable capital `"Tárgyi eszközök ért.záróállománya, in 1000 HUF, 1998 HUF"'
label variable gross_wage `"ber + szem.jell.egyeb + tb, in 1000 HUF, 1998 HUF"'
label variable exp_value `"value exported from trade data, in 1000 HUF, 1998 HUF"'
label variable imp_value `"value imported from trade data, in 1000 HUF, 1998 HUF"'
label variable dom_sales `"domestic sales, in 1000 HUF, 1998 HUF"'
label variable manufacturing `"dummy for manufacturing firms (NACE in 15-37) (fixed within a firm)"'
label variable ltfp_pred `"log TFP using Levinsohn-Petrin"'
label variable percap_wage `"per capita net wage"'
label variable lVA_per_capita `"log of per capita value added"'
label variable exp_share `"share of export sales in total sales"'
label variable foreign_start `"dummy for firms being foreign from their start on (fixed within a firm)"'
label variable domestic `"dummy for firms never having any foreign share in ownership (fixed within a firm"'
label variable domestic20 `"dummy for firms having at most 20% foreign ownership (fixed within a firm)"'
label variable last_year `"last year of the firm in the data (fixed within a firm)"'
label variable above_5 `"firms with a median employment of at least 5 (fixed within a firm)"'
label variable exports_that_year `"dummy for a firm exporting that year"'
label variable ever_exporter `"dummy for a firm ever exporting (fixed within a firm)"'
label variable not_yet_exp `"dummy for a firm not yet exported including the current year"'
label variable county `"NUTS code for the county"'
label variable teaor03_2d "Firm's (first) most frequent 2-digit TEAOR v2003 code, fixed within firm"
label variable teaor03_2d_yearly "Firm's yearly 2-digit TEAOR v2003 code, same as teaor03_2d in raw data"

* check berkoltseg and anyagkoltseg and capital

* correct for minyear (can be changing within firm)
rename minyear foundyear
egen minyear=min(foundyear), by(id8)
drop foundyear

* save the data
save "`out'/firm_bsheet_data.dta", replace
