/*
Creates a firm-country panel gicing the first year of importing a BEC product category from CZ, SK, RO or RU
Inputs:
	hs6bec.csv	
	im91.dta
	... 
	im03.dta	
Output:
	import_minyear_by_bec.dta
*/

clear
set more off

local in2 "$in2"
local out "$in"

* Create the db by product
tempfile imports
foreach K in im{
	local dir "`in2'/`K'port"
	local varn i
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
}

import delimited using "`in2'/hs6bec.csv", clear
gen byte bec1_6=bec==11 | bec==12 | bec==61 | bec==62 | bec==63
gen byte bec2_3=bec==21 | bec==22 | bec==31 | bec==32
gen byte bec42_53=bec==42 | bec==53
gen byte bec41_51_52=bec==41 | bec==51 | bec==52
tempfile bec
save `bec'

use `imports', clear
keep id8 country hs6 cn imp_value year
keep if country=="SK" | country=="CZ" | country=="RO" | country=="RU"
merge m:1 hs6 using `bec'
drop if _merge==2
drop _merge bec

foreach X in CZ SK RO RU{
	foreach Y in 1_6 2_3 41_51_52 42_53{
		display "`X' `Y'"
		sum id8 if country=="`X'" & bec`Y'==1
	}
}
save `imports', replace

* First year of importing by firm, country and BEC category
drop if imp_value==0
collapse (sum) imp_value, by(id8 country year bec1_6 bec2_3 bec42_53 bec41_51_52)
sum
drop imp_value
egen minyear=min(year), by(id8 country bec1_6 bec2_3 bec42_53 bec41_51_52)
sum
drop year
duplicates drop
gen bec="1_6" if bec1_6==1
tab bec
replace bec="2_3" if bec2_3==1
tab bec
replace bec="42_53" if bec42_53==1
tab bec
replace bec="41_51_52" if bec41_51_52==1
tab bec
drop if bec==""
drop bec*_*
reshape wide minyear, i(id8 country) j(bec) string
save "`out'/import_minyear_by_bec.dta", replace
