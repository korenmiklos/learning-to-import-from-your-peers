/*
Creates a firm-year panel of productivity quartiles using 3 different versions:
	- baseline productivity quartiles using firms only with a median employment of at least 5
	- robust productivity quartiles with or without firms having a median employment below 5
		- using the average percentile within the 2-digit industry of the last 3 years to create productivity quartiles
Inputs:
	firm_bsheet_data.dta
	firm_groups_yearly.dta
Output:
	time_variant_prod_quartiles.dta
*/

clear
set more off

local in "../$in"
local out "../$in"

* get the estimated productivity from the plant closure DB
use "`in'/firm_bsheet_data.dta", clear
keep ltfp_pred id8 year teaor03_2d above_5
rename id8 tax_id
tempfile prod_data
save `prod_data'

use `prod_data', clear
keep if year>=1992 & year<=2006
gsort teaor03_2d year -ltfp_pred
*list if _n<=30
egen rank=seq() if teaor03_2d!=. & ltfp_pred!=., by(teaor03_2d year)
egen numobs=count(tax_id) if teaor03_2d!=. & ltfp_pred!=., by(teaor03_2d year)
gen perc=(numobs+1-rank)/(numobs+1)
replace perc=. if numobs<8
*list if _n<=30
egen rank_5=seq() if teaor03_2d!=. & ltfp_pred!=. & above_5==1, by(teaor03_2d year)
egen numobs_5=count(tax_id) if teaor03_2d!=. & ltfp_pred!=. & above_5==1, by(teaor03_2d year)
gen perc_5=(numobs_5+1-rank_5)/(numobs_5+1)
replace perc_5=. if numobs_5<8
*list if _n<=30
tempfile yearly_perc
save `yearly_perc'


* Time-variant productivity

* 1) Baseline - above 5 only

use "`in'/firm_groups_yearly.dta", clear
keep id8 year prod_quartile_5_y
rename id8 tax_id
tempfile time_variant
save `time_variant'

* 2) Robust - all or above 5 only

use `yearly_perc'
sum
xtset tax_id year
foreach X in "" _5{
	gen avg_perc`X'=(perc`X'+L.perc`X'+L2.perc`X')/3 if perc`X'!=. & L.perc`X'!=. & L2.perc`X'!=.
	replace avg_perc`X'=(perc`X'+L.perc`X')/2 if perc`X'!=. & L.perc`X'!=. & L2.perc`X'==.
	replace avg_perc`X'=(perc`X'+L2.perc`X')/2 if perc`X'!=. & L.perc`X'==. & L2.perc`X'!=.
	replace avg_perc`X'=(L.perc`X'+L2.perc`X')/2 if perc`X'==. & L.perc`X'!=. & L2.perc`X'!=.
	replace avg_perc`X'=perc`X' if perc`X'!=. & L.perc`X'==. & L2.perc`X'==.
}
codebook tax_id if avg_perc==.
codebook tax_id if avg_perc!=.
codebook tax_id

foreach X in "" _5{
	replace avg_perc`X'=L.avg_perc`X' if avg_perc`X'==.
	foreach Y of numlist 2/14{
		replace avg_perc`X'=L`Y'.avg_perc`X' if avg_perc`X'==.
	}
}

foreach X in "" _5{
	replace avg_perc`X'=F.avg_perc`X' if avg_perc`X'==.
	foreach Y of numlist 2/14{
		replace avg_perc`X'=F`Y'.avg_perc`X' if avg_perc`X'==.
	}
}

codebook tax_id if avg_perc==.

foreach X in "" _5{
	gen prod_quartile`X'_y_robust=1 if avg_perc`X'<=0.25
	replace prod_quartile`X'_y_robust=2 if avg_perc`X'<=0.5 & avg_perc`X'>0.25
	replace prod_quartile`X'_y_robust=3 if avg_perc`X'<=0.75 & avg_perc`X'>0.5
	replace prod_quartile`X'_y_robust=4 if avg_perc`X'!=. & avg_perc`X'>0.75
}

codebook tax_id if prod_quartile_y_robust==.

sum

keep tax_id year prod_quartile*
merge 1:1 tax_id year using `time_variant'
drop _merge

sum

save "`out'/time_variant_prod_quartiles.dta"

