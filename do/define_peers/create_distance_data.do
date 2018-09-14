/*
Assigns distance to neighboring building for geocoded addresses in Budapest
Inputs:
	address_data.dta
	bp_addresses_w_geocoord.dta
	db_complete_for_running_the_regs_baseline_torun_rovat_13.dta
Output:
	geocoordinates.dta
*/

clear
set more off

local in "../$in"
local in1 "../$in_ext"
local out "../$in"

use tax_id year using "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
duplicates drop
merge 1:1 tax_id year using "`in'/address_data.dta", keepusing(cityid streetid buildingid)
drop if _merge==2
keep cityid streetid buildingid
duplicates drop
tempfile addresses
save `addresses'
use "`in1'/bp_addresses_w_geocoord.dta", clear
rename buildingid buildingid_n
rename l?? l??_n
tempfile geo
save `geo'
rename *_n *
gen i=_n
expand 2
egen c=seq(), by(i)
gen buildingid_n=buildingid-2 if c==1
replace buildingid_n=buildingid+2 if c==2
merge m:1 cityid streetid buildingid_n using `geo'
drop _merge
drop i
gen peer="m" if c==1
replace peer="p" if c==2
drop c
tempfile geo
save `geo'
merge m:1 cityid streetid buildingid using `addresses'
keep if _merge==3
drop _merge
sum
foreach X in lat lon lat_n lon_n {
gen `X'_pi=`X'*_pi/180
}
gen dist_n=6371*acos( cos(lon_pi-lon_n_pi)*cos( lat_pi)*cos(lat_n_pi)+sin( lat_pi)*sin(lat_n_pi)) 
foreach X in lat lon lat_n lon_n {
drop `X'_pi
}
sum dist
save "`out'/geocoordinates.dta"
