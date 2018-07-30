/* 
Creates a firm-year panel of building-level addresses for the whole country
Input:
	1992-2006.csv
Output:
	address_data.dta
*/

clear
set more off

local in "$in1"
local out "$in"

* Use location data

insheet using "`in'/1992-2006.csv"
rename taxid tax_id
* keep data only for the period 1992-2003
tab year
keep if year>=1992 & year<=2003
* keep only those observations for which precise building-level data is given
keep if  tax_id!=. &  year!=. &  cityid!=. &  streetid!=. &  buildingid!=.

* generate building-level addresses
egen address=group(cityid streetid buildingid)
sum
duplicates drop tax_id year, force

save "`out'/address_data.dta", replace
