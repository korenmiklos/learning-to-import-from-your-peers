/*
Creates a firm-year panel of productivity, size, ownership and exporter groups 
	- includes size and productivity tertiles and quartiles
	- versions including all firms or only firms having a median employment above 5
Input:
	firm_bsheet_data.dta
Output:
	firm_groups_yearly.dta
*/
			
clear
set more off

*local in "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data/reprod_2018"
*local out "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data/reprod_2018"

local in "$in"
local out "$in"

tempfile alldata

use "`in'/firm_bsheet_data.dta"
sum
keep id8 year above_5 fo2 minyear empl teaor03_2d ltfp_pred not_yet_exp sales
sum
*set more on
*tab teaor03_2d
*set more off

* yearly groupings *
********************

* size and productivity groups

* all firms or only if median employment is above 5
foreach X in "" "& above_5==1"{
	if "`X'"=="& above_5==1"{
		local Z "5_"
	}
	else{
		local Z ""
	}
	gen size_quartile_`Z'y=.
	gen prod_quartile_`Z'y=.
	gen size_tertile_`Z'y=.
	gen prod_tertile_`Z'y=.
	* yearly groups
	foreach Y of numlist 1992/2012{	
		* size quartiles
		sum empl if empl>0 `X' & year==`Y', d
		replace size_quartile_`Z'y=1 if empl>0 & empl<=r(p25) `X' & year==`Y'
		replace size_quartile_`Z'y=2 if empl>r(p25) & empl<=r(p50) `X' & year==`Y'
		replace size_quartile_`Z'y=3 if empl>r(p50) & empl<=r(p75) `X' & year==`Y'
		replace size_quartile_`Z'y=4 if empl>r(p75) `X' & year==`Y'
		replace size_quartile_`Z'y=. if empl==. `X' & year==`Y'
		save `alldata', replace
		* size tertiles
		keep if year==`Y' `X'
		sum empl if empl==0
		scalar numzero=r(N)
		display numzero
		sum empl if empl>0 & empl!=.
		scalar numpos=r(N)
		display numpos
		scalar groupsize=int(numpos/3)
		display groupsize
		sort empl
		sum empl if _n>numzero & _n<=numzero+groupsize
		scalar cutoff1=r(max)
		display cutoff1
		sum empl if _n>numzero+groupsize & _n<=numzero+2*groupsize
		scalar cutoff2=r(max)
		display cutoff2
		replace size_tertile_`Z'y=1 if empl>0 & empl<=cutoff1
		replace size_tertile_`Z'y=2 if empl>cutoff1 & empl<=cutoff2
		replace size_tertile_`Z'y=3 if size_tertile_`Z'y==. & empl!=. & empl!=0
		keep id8 year size_tertile_`Z'y
		merge 1:1 id8 year using `alldata', update
		drop _merge
		save `alldata', replace
		foreach W of numlist 1 2 5 10/37 40 41 45 50/52 55 60/67 70/75 80 85 90/93 95 99{
			display "`Z'" "`Y'" "`W'"
			* prod quartiles by 2-digit industry
			sum ltfp_pred if year==`Y' `X'  & teaor03_2d==`W', d
			replace prod_quartile_`Z'y=1 if ltfp_pred<=r(p25) `X' & year==`Y' & teaor03_2d==`W'
			replace prod_quartile_`Z'y=2 if ltfp_pred>r(p25) & ltfp_pred<=r(p50) `X' & year==`Y' & teaor03_2d==`W'
			replace prod_quartile_`Z'y=3 if ltfp_pred>r(p50) & ltfp_pred<=r(p75) `X' & year==`Y' & teaor03_2d==`W'
			replace prod_quartile_`Z'y=4 if ltfp_pred>r(p75) `X' & year==`Y' & teaor03_2d==`W'
			replace prod_quartile_`Z'y=. if ltfp_pred==. `X' & year==`Y' & teaor03_2d==`W'
			save `alldata', replace
			* prod tertiles by 2-digit industry
			keep if year==`Y' `X' & teaor03_2d==`W'
			sum ltfp_pred if ltfp_pred!=.
			scalar numpos=r(N)
			display numpos
			scalar groupsize=int(numpos/3)
			display groupsize
			sort ltfp_pred
			sum ltfp_pred if _n<=groupsize
			scalar cutoff1=r(max)
			display cutoff1
			sum ltfp_pred if _n>groupsize & _n<=2*groupsize
			scalar cutoff2=r(max)
			display cutoff2
			replace prod_tertile_`Z'y=1 if ltfp_pred<=cutoff1
			replace prod_tertile_`Z'y=2 if ltfp_pred>cutoff1 & ltfp_pred<=cutoff2
			replace prod_tertile_`Z'y=3 if prod_tertile_`Z'y==. & ltfp_pred!=. 
			keep id8 year prod_tertile_`Z'y
			merge 1:1 id8 year using `alldata', update
			drop _merge
			save `alldata', replace
		}
	}
}

codebook prod* size*
sum

replace prod_tertile_y=. if ltfp_pred==.
replace prod_tertile_5_y=. if ltfp_pred==.

sum emp ltfp_pred if above_5==1

sum prod* size*

* cutoffs are changing year by year (natural for productivity, might not be for size...)

* employment cutoffs at 20-100-500
gen size_groups_fixed_y=.
replace size_groups_fixed_y=1 if empl>0 & empl<20 
replace size_groups_fixed_y=2 if empl>=20 & empl<100
replace size_groups_fixed_y=3 if empl>=100 & empl<500
replace size_groups_fixed_y=4 if empl>=500 
replace size_groups_fixed_y=. if empl==. 

tab size_groups_fixed_y, missing
tab size_groups_fixed_y size_quartile_y, missing

save `alldata', replace

* TFP cutoffs at overall p75-p95-p99 of above_5 firms, by 2-digit industry 
* similar to employment cutoffs without being rounded 
gen prod_groups_fixed_y=.
foreach W of numlist 1 2 5 10/37 40 41 45 50/52 55 60/67 70/75 80 85 90/93 95 99{
	sum ltfp_pred if above_5==1 & teaor03_2d==`W', d
	replace prod_groups_fixed_y=1 if ltfp_pred<=r(p75)  & teaor03_2d==`W'
	replace prod_groups_fixed_y=2 if ltfp_pred>r(p75) & ltfp_pred<=r(p95)  & teaor03_2d==`W'
	replace prod_groups_fixed_y=3 if ltfp_pred>r(p95) & ltfp_pred<=r(p99)  & teaor03_2d==`W'
	replace prod_groups_fixed_y=4 if ltfp_pred>r(p99) & teaor03_2d==`W'
	replace prod_groups_fixed_y=. if ltfp_pred==.  & teaor03_2d==`W'
}

* drop prod_groups_fixed if less than 100 above_5 firms in the 2-digit industry - but no such cases
egen check=count(year) if above_5==1 & ltfp_pred!=., by(teaor03_2d)
egen check2=max(check), by(teaor03_2d)
tab teaor03_2d if check2==.
*replace prod_groups_fixed_y=. if check2==.
drop check check2

*no above_5 ltfp_pred!=. obs in teaors: 10,11,12,13,16,23,62,66,75,95,99

tab prod_groups_fixed_y, missing
tab prod_groups_fixed_y prod_quartile_y, missing

sum prod*

save `alldata', replace

* drop prod tertiles if less than 15 obs that year and prod quartiles if less than 20 obs that year, drop prod_groups fixed if less than 500 obs in the industry

egen numobs=count(id8) if ltfp_pred!=., by(year teaor03_2d)
sum numobs, d
sum ltfp_pred if numobs<15
*no obs
sum ltfp_pred if numobs<20
*34 obs
gen prod_tertile_y_strict=prod_tertile_y if numobs>=15
gen prod_quartile_y_strict=prod_quartile_y if numobs>=20
drop numobs

egen numobs=count(id8) if above_5==1 & ltfp_pred!=., by(year teaor03_2d)
sum numobs, d
sum ltfp_pred if numobs<15
*117 obs
sum ltfp_pred if numobs<20
*187 obs
gen prod_tertile_5_y_strict=prod_tertile_5_y if numobs>=15 
gen prod_quartile_5_y_strict=prod_quartile_5_y if numobs>=20 
drop numobs

egen numobs=count(id8) if above_5==1 & ltfp_pred!=., by(teaor03_2d)
sum numobs, d
sum ltfp_pred if numobs<500
*459 obs
gen prod_groups_fixed_y_strict=prod_groups_fixed_y if numobs>=500
drop numobs

sum prod*

codebook id8
*872,648 firms

sum

keep id8 year prod_tertile_5_y prod_tertile_y prod_quartile_5_y prod_quartile_y size_tertile_5_y size_tertile_y size_quartile_5_y size_quartile_y fo2 not_yet_exp size_groups_fixed_y prod_groups_fixed_y prod_tertile_y_strict prod_quartile_y_strict prod_tertile_5_y_strict prod_quartile_5_y_strict prod_groups_fixed_y_strict

save "`out'/firm_groups_yearly.dta", replace

