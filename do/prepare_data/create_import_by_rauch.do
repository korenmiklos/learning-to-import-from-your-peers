/*
Gives the first year when a firm started to import a specific rauch product category from one of the countries (CZ,SK,RO and RU)
Inputs:
	hs92_Rauch.dta
	hs96_Rauch.dta
	hs02_Rauch.dta
	im91.dta
	...
	im03.dta
Output:
	importer_panel_rauch.dta
*/

clear
set more off

local in "../$in_ext"
local out "../$in"

tempfile imports 

clear
save `imports', replace emptyok
* read customs stats
foreach X of any 91 92 93 94 95 96 97 98 99 00 01 02 03 {
	use "`in'/import/im`X'.dta", clear
	* keep only hs6. estimate natural quantity from weight if not known
	keep i_ft`X' a1 szao hs6
	* rename variables
	ren a1 id8
	ren i_ft`X' imp_value
	ren szao country
	label variable imp_value "imported value in HUF"
	gen int year = 1900+`X'
	replace year=year+100 if year<1950
	* save the data
	compress
	append using `imports'
	save `imports', replace
}

keep if country=="CZ" | country=="SK" | country=="RO" | country=="RU"

drop if id8<10000000
drop if id8==88888888
drop if id8==99999999
drop if id8==.

gen hs92=hs6 if year<1996
gen hs96=hs6 if year>=1996 & year<2002
gen hs02=hs6 if year>=2002

foreach X in 92 96 02{
	merge m:1 hs`X' using "`out'/hs`X'_Rauch.dta", update
	drop if _merge==2
	drop _merge
	drop hs`X'
}
tab con_34, m
drop if con_34==""

drop if imp_value==0 | imp_value==.
collapse (min) first_time_to_destination=year, by( id8 country con_34)
reshape wide first_time_to_destination, i( id8 con_34) j( country) string
reshape wide first_time_to_destination??, i( id8 ) j( con_34) string
rename id8 tax_id 

save "`out'/importer_panel_rauch.dta", replace
