/*
Creates person-connected firm pairs with start and end dates
	- person-connected firms defined as having the same person being connected to both firms at some point
	- creates 3 versions based on the type of firm-person connection
		- person can have any connection to both firms (owership, signing right, supervisor)
		- person is connected to both firms by having signing right
		- person had/has signing right in peer and is an owner in the firm of interest
	- liquidators and people connected to more than 15 firms excluded
Inputs:
	firmperson_important_liquidator_dummy.csv
	person_firm_connection_in_all_rovats_using_30d_threshold.csv
	person_firm_connection_by_rovats_using_30d_threshold,csv
Outputs:
	directed_firm_pairs.dta
	directed_firm_pairs_13.dta
	directed_firm_pairs_from_sign_to_own.dta
*/

clear
set more off

local in "$in1"
local out "$in"
local which_rovat "$which_rovat"

import delimited using "`in'/firmperson_important_liquidator_dummy.csv"
keep if felsz==1
keep person_id tax_id
duplicates drop 
tempfile liquidators
save `liquidators', replace

* use the full firm-person link database

* drop those firm-person pairs where the person ever acted as a liquidator
if "`which_rovat'"=="all_rovat"{
	import delimited "`in'/person_firm_connection_in_all_rovats_using_30d_threshold.csv", varnames(1) clear 
}
else if "`which_rovat'"=="rovat_13"{
	import delimited "`in'/person_firm_connection_by_rovats_using_30d_threshold.csv", varnames(1) clear 
	keep if rovat_name=="rovat_13"
}
else if "`which_rovat'"=="sign_own"{
	import delimited "`in'/person_firm_connection_by_rovats_using_30d_threshold.csv", varnames(1) clear 
	keep if rovat_name=="rovat_13"
	drop rovat_name
	duplicates drop
	merge m:1 tax_id person_id using `liquidators'
	* descriptives
	egen firm_person=group( tax_id person_id)
	codebook firm_person
	codebook firm_person if _merge==3
	codebook tax_id
	codebook tax_id if _merge==3
	codebook person_id 
	codebook person_id if _merge==3
	keep if _merge==1
	drop _merge
	* give the minimum start year for each firm-person pair
	gen start_year=substr(date_of_start,1,4)
	destring start_year, replace
	egen start=min(start_year), by( tax_id person_id)
	** give the maximum end year for each firm-person pair
	gen end_year=substr(date_of_end,1,4)
	destring end_year, replace
	egen end=max(end_year), by( tax_id person_id)
	* get the number of firms each person is connected to
	duplicates drop tax_id person_id start, force
	egen numfirm=count(tax_id), by(person_id)
	* descriptives
	preserve
	duplicates drop person_id, force
	tab numfirm
	sum if numfirm>15
	restore
	* drop those people who are connected to more than 15 firms
	drop if numfirm>15
	* drop those people who do not connect any firms
	drop if numfirm==1
	keep  tax_id person_id numfirm start end
	*saveold Documents/data/liquidators.dta
	tempfile all_links
	save `all_links'
	
	import delimited "`in'/person_firm_connection_by_rovats_using_30d_threshold.csv", varnames(1) clear 
	drop if rovat_name=="rovat_13" | rovat_name=="rovat_15"
	drop rovat_name
	duplicates drop
}
merge m:1 tax_id person_id using `liquidators'
* descriptives
egen firm_person=group( tax_id person_id)
codebook firm_person
codebook firm_person if _merge==3
codebook tax_id
codebook tax_id if _merge==3
codebook person_id 
codebook person_id if _merge==3
keep if _merge==1
drop _merge
* give the minimum start year for each firm-person pair
gen start_year=substr(date_of_start,1,4)
destring start_year, replace
egen start=min(start_year), by( tax_id person_id)
** give the maximum end year for each firm-person pair
gen end_year=substr(date_of_end,1,4)
destring end_year, replace
egen end=max(end_year), by( tax_id person_id)
* get the number of firms each person is connected to
duplicates drop tax_id person_id start, force
egen numfirm=count(tax_id), by(person_id)
* descriptives
preserve
duplicates drop person_id, force
tab numfirm
sum if numfirm>15
restore
* drop those people who are connected to more than 15 firms
drop if numfirm>15
* drop those people who do not connect any firms
drop if numfirm==1
keep  tax_id person_id numfirm start end
*saveold Documents/data/liquidators.dta
tempfile full_person_firm
save `full_person_firm'

* create firm pairs connected by people

use `full_person_firm', clear
egen id=seq(), by(person_id)
tab id
tempfile original_data
save `original_data', replace
if "`which_rovat'"=="sign_own"{
	use `all_links', clear
	egen id=seq(), by(person_id)
	tab id
}
tab numfirm
rename tax_id tax_id_peer
rename start start_peer
rename end end_peer
expand numfirm
rename id id0
egen id=seq(), by( person_id tax_id_peer)
merge m:1 person_id id using `original_data'
* keep only pairs if these are not the same firm
drop if id==id0
** keep only those pairs where the neighbor was connected before
drop if start_peer>start
* generate the start date of becoming a pair per connecting person: the first time when the person have links to both firms
*gen start_year=max(start, start_peer)
gen start_year=start 
gen end_year=end
gen end_year_peer=end_peer
keep  tax_id tax_id_peer start_year end_year end_year_peer
* the overall start year of a pair: minimum over all possible connecting people
egen start=min(start_year), by( tax_id tax_id_peer)
sum tax_id
sum tax_id if start==start_year
sum tax_id if start!=start_year
egen end=max(end_year), by( tax_id tax_id_peer)
egen end_peer=max(end_year_peer) if start==start_year, by(tax_id tax_id_peer)
tab end_peer
egen start2=min(start_year) if start!=start_year, by(tax_id tax_id_peer)
egen start1=min(start2), by(tax_id tax_id_peer)
sum tax_id
sum tax_id if start1==start
sum tax_id if start1==start2
sum tax_id if start1!=.
sum tax_id if start2!=.
sum tax_id if start!=.
sum tax_id if start_year==start1
sum tax_id if start_year==start2
egen end_peer2=max(end_year_peer) if start_year==start1, by(tax_id tax_id_peer)
egen end_peer1=min(end_peer2), by(tax_id tax_id_peer)
sum tax_id if end_peer1==end_peer
sum tax_id if end_peer1==end_peer2
sum tax_id if end_peer1!=.
sum tax_id if end_peer2!=.
sum tax_id if end_peer!=.
sum tax_id if end_year_peer==end_peer1
sum tax_id if end_year_peer==end_peer2
sum tax_id if start_year!=start & start_year!=start1
sum tax_id if end_year_peer>end_peer & end_year_peer>end_peer1
egen max_end_peer=max(end_year_peer), by(tax_id tax_id_peer)
tab max_end_peer if max_end_peer>end_peer
tab max_end_peer if max_end_peer>end_peer & max_end_peer>end_peer1
drop start2 end_peer2
egen start3=min(start_year) if start_year!=start & start_year!=start1, by(tax_id tax_id_peer)
egen start2=min(start3) , by(tax_id tax_id_peer)
tab start2
egen end_peer3=max(end_year_peer) if start_year==start3 , by(tax_id tax_id_peer)
egen end_peer2=min(end_peer3) , by(tax_id tax_id_peer)
tab max_end_peer if max_end_peer>end_peer
tab max_end_peer if max_end_peer>end_peer & max_end_peer>end_peer1
tab max_end_peer if max_end_peer>end_peer & max_end_peer>end_peer1 & max_end_peer>end_peer2
preserve
collapse (min) start start1 start2 end_peer end_peer1 end_peer2 max_end_peer, by(tax_id tax_id_peer)
tab max_end_peer if end_peer!=max_end_peer
tab max_end_peer if end_peer!=max_end_peer & end_peer1!=max_end_peer
tab max_end_peer if end_peer!=max_end_peer & end_peer1!=max_end_peer & end_peer2!=max_end_peer
restore
drop start3 end_peer3
egen end_peer3=min(end_peer), by(tax_id tax_id_peer)
drop end_peer
rename end_peer3 end_peer
duplicates drop tax_id tax_id_peer, force
drop start_year end_year end_year_peer 
sum
replace start1=start if start1==.
replace start2=start1 if start2==.
replace end_peer1=end_peer if end_peer1==.
replace end_peer2=end_peer1 if end_peer2==.
sum

if "`which_rovat'"=="all_rovat"{
	save "`out'/directed_firm_pairs.dta", replace
}
else if "`which_rovat'"=="rovat_13"{
	save "`out'/directed_firm_pairs_13.dta", replace
}
else if "`which_rovat'"=="sign_own"{
	save "`out'/directed_firm_pairs_from_sign_to_own.dta", replace
}
