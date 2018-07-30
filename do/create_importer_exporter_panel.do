/*
Creates importer, exporter and owner panels
	- gives the country-specific yearly export/import behavior and foreign ownership of each firm considering 4 destinations: CZ, SK, RO and RU
	- additionally, for each firm it shows the first year of exporting to/importing from that destination and the first year of being owned from the country
	- also adds firm-level start and end dates from Complex 
Inputs:
	country_code.dta	
	ex91.dta
	...
	ex03.dta
	frame.csv	
	im91.dta
	...
	im03.dta
Outputs:
	exporter_panel.dta
	exporter_panel_yearly.dta
	importer_panel.dta
	importer_panel_yearly.dta
*/

clear
set more off

*cd "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data"
*local in1 ../data
*local in2 ../../audi/data/customs
*local out ../data/reprod_2018

local in1 "$in1"
local in2 "$in2"
local out "$in"

* create yearly trade panel

tempfile imports exports
foreach K in im ex{
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
		use "`in2'/`K'port/`K'`X'.dta", clear
		* keep only hs6. estimate natural quantity from weight if not known
		keep `varn'_ft`X' a1 szao hs6
		* rename variables
		ren a1 id8
		ren `varn'_ft`X' `K'p_value
		ren szao country
		label variable `K'p_value "`K'ported value in HUF"
		gen int year = 1900+`X'
		replace year=year+100 if year<1950
		* save the data
		compress
		append using ``K'ports'
		save ``K'ports', replace
	}
	* make invalid hs6 missing
	replace hs6=. if hs6==0
	keep if country=="SK" | country=="CZ" | country=="RO" | country=="RU"
	* collapse to country-year
	collapse (sum) `K'p_value, by(id8 country year)
	drop if `K'p_value==0
	drop `K'p_value
	gen `K'porter_yearly=1
	reshape wide `K'porter_yearly, i(id8 year) j(country) string
	foreach X in CZ SK RO RU{
		replace `K'porter_yearly`X'=0 if `K'porter_yearly`X'==.
	}
	rename id8 tax_id
	save "`out'/`K'porter_panel_yearly.dta", replace

}

* get first and last year of each firm
import delimited using "`in1'/frame.csv", clear
* generate start and end years
gen start=int( birth_date/10000)
gen firstyear=start
replace firstyear=1992 if start<1992
gen end =int( death_date/10000)
gen lastyear=end
replace lastyear=2003 if end>2003
* keep data only for the period 1992-2003
drop if firstyear>2003
drop if lastyear<1992
tab firstyear, missing
tab lastyear, missing
keep tax_id firstyear lastyear
egen check=seq(), by(tax_id)
tab check
drop check
tempfile frame_92_03
save `frame_92_03', replace

* get first year of ownership

* create first_owned_from_country data
use "`in1'/country_code.dta", clear
tab year if country_code=="SK"
tab year if country_code=="CZ"
tab year if country_code=="RO"
tab year if country_code=="RU"
egen first_owned_from_country=min(year), by( tax_id country_code)
sum
collapse (min) first_owned_from_country, by(tax_id country_code)
* keep only CZ, SK, RO and RU
rename country_code country
local destinations CZ SK RO RU
gen keepvar=0
foreach X in `destinations' {
	replace keepvar=1 if country=="`X'"
}
* check if really the chosen countries are flagged
tab country if keepvar==1
sum country if keepvar==0 & (country=="CZ" | country=="RO" | country=="SK" | country=="RU")
* drop all the other destinations
keep if keepvar==1
keep tax_id  country first_owned_from_country
* put into wide format (one variable for each destination)
reshape wide first_owned_from_country, i(tax_id) j(country) string
tempfile owners
save `owners'

* add first year of export and import

foreach K in im ex{
	use "`out'/`K'porter_panel_yearly.dta", clear
	reshape long `K'porter_yearly, i(tax_id year) j(country) string
	keep if `K'porter_yearly==1
	drop `K'porter_yearly
	collapse (min) first_time_to_destination=year, by( tax_id country)
	reshape wide first_time_to_destination, i(tax_id) j(country) string
	merge 1:1 tax_id using `owners'
	drop _merge
	merge 1:1 tax_id using `frame_92_03'
	drop _merge
	save "`out'/`K'porter_panel.dta", replace
}


