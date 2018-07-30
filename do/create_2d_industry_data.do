/*
Creates a firm-year panel with 2-digit industry data (and time-invariant 2-digit 'most common activity')
Input:
	balance_sheet.dta
Output:
	2d_industry.dta
*/

clear
set more off

local in "$in3"
local out "$in"

use "`in'/balance_sheet.dta"
keep originalid year teaor03_2d
rename originalid tax_id

xtset tax_id year
local X teaor03_2d
* count the number of entries with a nace code per firm
egen count_`X'=count(`X') if `X'!=., by(tax_id)
* count the number of entries for each nace code per firm
egen count_per_`X'=count(`X') if `X'!=., by(tax_id `X')
* calculate the ratio of the given nace code within the total number of nace entries per firm - missing if no nace code at all
gen `X'_ratio=count_per_`X'/count_`X'
* calculate the highest ratio
egen max_`X'_ratio=max(`X'_ratio), by(tax_id)
sum tax_id `X' count_`X' count_per_`X' `X'_ratio max_`X'_ratio
* get the most popular nace code
gen `X'_firm=`X' if `X'_ratio==max_`X'_ratio
* check if the most popular nace code is unique for each firm
egen unique_`X'=mean(`X'_firm) if `X'_firm!=., by(tax_id)
gen unique_`X'_test=`X'_firm- unique_`X'
sum unique_`X'_test if unique_`X'_test!=0
* get the earliest from the most frequent ones if there are more than one
egen min_`X'=min(year) if `X'_firm!=., by(tax_id)
sum unique_`X'_test if unique_`X'_test!=0 & year==min_`X'
sum tax_id if unique_`X'_test==0 & year==min_`X'
gen `X'_firm_new=`X'_firm if year==min_`X'
egen `X'_firm_final=min(`X'_firm_new), by(tax_id)
* drop the unnecessary variables
drop count_`X' count_per_`X' `X'_ratio max_`X'_ratio `X'_firm unique_`X' unique_`X'_test min_`X' `X'_firm_new
rename `X' `X'_yearly
rename `X'_firm_final `X'


save "`out'/2d_industry.dta", replace
