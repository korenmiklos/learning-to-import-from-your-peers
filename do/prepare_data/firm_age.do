/* 
Creates a firm-year panel with the current age of the firms
Inputs:
	frame_old_format.csv
	firm_bsheet_data.dta
Output:
	firm_age.dta
*/

clear
set more off

local in "../$in_ext"
local out "../$in"

* get year of birth from Complex
import delimited "`in'/frame_old_format.csv"
gen birth_year = int(birth_date/(10^4))
keep tax_id birth_year
rename tax_id id8
duplicates drop
tempfile birth_date
save `birth_date'

* add firm age to balance sheet data
use "`out'/firm_bsheet_data.dta"
keep id8 year
merge m:1 id8 using `birth_date'
drop if _merge==2
egen minyear=min(year), by(id8)
* if birth year if missing, change it to the year of the first balance sheet observation
replace birth_year=minyear if birth_year==.
* change birth year if there is balance sheet data before birth year given in Complex
tab year if year<birth_year
gen byte flag = year<birth_year
egen tochange = max(flag), by(id8)
tab tochange
tab tochange if year<birth_year
replace birth_year=minyear if tochange==1
gen age = year-birth_year+1
tab age, missing
sum age, d
* censore firm age at 65
replace age=65 if age>65
keep id8 year age
label var age "Firm age censored at 65"

save "`out'/firm_age.dta"
