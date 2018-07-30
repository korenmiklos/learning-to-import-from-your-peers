/* 
Creates firm pairs connected with ownership links by year, including
	- firms owning one another
	- firms having the same person as an ultimate owner
	- firms having the same firm as an ultimate owner
Input:
	ownership_mixed_directed.csv
Outputs:
	firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
	firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
	firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
*/

clear
set more off

*cd /home/bisztray/Documents/spillovers/codes
*local in ../data
*local out ../data/reprod_2018

local in "$in1"
local out "$in"

tempfile firm_list numfirms full_list firm_owners create_list_person create_list_firm create_list_full

import delimited "`in'/ownership_mixed_directed.csv", clear

sum

gen start_year=substr(start,1,4)
destring start_year, replace
gen end_year=substr(end,1,4)
destring end_year, replace
drop start end
drop if end_year<1992
drop if start_year>2006

duplicates drop
expand 15
egen year=seq(), by(tax_id person_id_owner tax_id_owner start_year end_year)
replace year=year+1991
drop if year<start_year
drop if year>end_year
tab year

drop start_year end_year

* firms sharing an ultimate owner

duplicates drop

save `full_list'

gen dist=1
save `create_list_full'

use `full_list', clear

rename tax_id_owner tax_id_owners_owner
rename tax_id tax_id_owner
rename person_id_owner person_id_owners_owner

egen check=seq(), by(tax_id_owner year)

save `full_list', replace

collapse (max) check, by(tax_id_owner year)

save `numfirms', replace

use `create_list_full', clear

keep if dist==1
keep if tax_id_owner!=.
drop person_id_owner
duplicates drop

merge m:1 tax_id_owner year using `numfirms'
drop if _merge==2
gen id=_n
expand check
drop check
egen check=seq(), by(id)
drop id _merge

merge m:1 tax_id_owner year check using `full_list'
sum tax_id if _merge==3, d
if r(N)>0{
	keep if _merge==3
	drop _merge
	keep tax_id year person_id_owners_owner tax_id_owners_owner
	rename *owners_owner *owner
	duplicates drop
	drop if tax_id==tax_id_owner
	merge 1:1 tax_id year person_id_owner tax_id_owner using `create_list_full'
	sum tax_id if _merge==1
	if r(N)>0{
		replace dist=2 if _merge==1
	}
	drop _merge
	drop if tax_id==tax_id_owner
	save `create_list_full', replace
}

local stopvar 0
local num=2

while "`stopvar'"=="0"{

	keep if dist==`num'
	local num=`num'+1
	keep if tax_id_owner!=.
	drop person_id_owner
	if _N>0{
		duplicates drop

		merge m:1 tax_id_owner year using `numfirms'
		drop if _merge==2
		gen id=_n
		expand check
		drop check
		egen check=seq(), by(id)
		drop id _merge

		merge m:1 tax_id_owner year check using `full_list'
		sum tax_id if _merge==3, d
		if r(N)>0{
			keep if _merge==3
			drop _merge
			keep tax_id year person_id_owners_owner tax_id_owners_owner
			rename *owners_owner *owner
			duplicates drop
			drop if tax_id==tax_id_owner
			merge 1:1 tax_id year person_id_owner tax_id_owner using `create_list_full'
			sum tax_id if _merge==1, d
			if r(N)>0{
				replace dist=`num' if _merge==1
			}
			else{
				local stopvar 1
			}
			drop _merge
			drop if tax_id==tax_id_owner
			save `create_list_full', replace
		}
		else{
			local stopvar 1
		}
	}
	else{
		local stopvar 1
	}
}

use `create_list_full', clear
sum
*max dist is 13

save "`out'/ultimate_owners_2016Jan.dta", replace

* firms owned by the same person

keep if person_id_owner!=""
drop tax_id_owner dist
duplicates drop
codebook person_id_owner
*992,898
egen check=seq(), by(person_id_owner year)
rename tax_id neighbor_tax_id

save `firm_list', replace

preserve

collapse (max) numfirms=check , by(person_id_owner year)
save `numfirms', replace

restore

rename neighbor_tax_id tax_id 
merge m:1 person_id_owner year using `numfirms'
expand numfirms
drop numfirms _merge check
egen check=seq(), by(person_id_owner tax_id year)

merge m:1 person_id_owner year check using `firm_list'

drop _merge
codebook tax_id neighbor_tax_id
*initially 554,653 firms
sum
sum check if check==1
*9,315,084 obs without 
codebook tax_id if check!=1
drop if tax_id==neighbor_tax_id
drop person_id_owner check
duplicates drop
codebook tax_id neighbor_tax_id
*386,294 firms sharing an owner with another firm

save "`out'/firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta", replace

* firms owning each other

use "`out'/ultimate_owners_2016Jan.dta", clear

keep if tax_id_owner!=.
drop person_id_owner dist
duplicates drop
codebook tax_id_owner

save `firm_owners', replace

rename tax_id tax_id_owned 
rename tax_id_owner tax_id
rename tax_id_owned tax_id_owner
append using `firm_owners'
duplicates drop
rename tax_id_owner neighbor_tax_id
codebook
sum

save "`out'/firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta", replace

* firms being owned by the same firm

use `firm_owners', clear

egen sameowner=group(year tax_id_owner)
codebook sameowner
egen numfirms_in_group=count(tax_id), by(sameowner)
tab numfirms_in_group
* max 934
drop tax_id_owner
duplicates drop

keep if numfirms_in_group>1
egen check=seq(), by(sameowner)
save `numfirms', replace

expand numfirms_in_group
drop check
rename tax_id neighbor_tax_id
egen check=seq(), by(sameowner neighbor_tax_id year)

merge m:1 sameowner check using `numfirms'
drop _merge check sameowner numfirms_in_group
drop if tax_id==neighbor_tax_id
duplicates drop
codebook tax_id

save "`out'/firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta", replace

