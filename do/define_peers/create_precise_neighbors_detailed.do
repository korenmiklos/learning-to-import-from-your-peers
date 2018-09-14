/*
Creates potentially existing neighbor (+/-2,4) and cross-street (+/-1,3) addresses for each address in our database
	- unit of observation: building-level address - neighbor building (9 observations per building)
Input:
	location.dta
Output:
	precise_neighbors_detailed
*/

clear
set more off

local in "../$in_ext"
local out "../$in"

* Generate building-level database of addresses in Budapest

* use location data, ignore korut.csv et al because of mismatch with location.dta
use "`in'/location.dta", clear
* drop those addresses where something is missing
keep if  cityid!=. &  streetid!=. &  buildingid!=.
* generate building-level observations
collapse (min) year, by(cityid streetid buildingid)
drop year

keep cityid streetid buildingid
order cityid streetid buildingid 

duplicates drop cityid streetid buildingid, force

* Assign neighbor address data to each building

* create new observations for 2+2 direct neighbors and 2+2 other neighbors across the street
expand 9
* neighbor address variables
gen neighbor_cityid = cityid
gen neighbor_streetid = streetid
* get the five "neighbor buildings" for each building
egen counter = seq(), by(cityid streetid buildingid)
* 1,2,3,4,5,6,7,8,9 becomes -2,-1,0,1,2
gen neighbor_buildingid = (counter-5)+buildingid
* neighbors are (#-4) #-2, #, #+2 (#+4)

* tell apart same and neighboring buildings
gen helpvar=abs(buildingid-neighbor_buildingid)
keep if helpvar>=0 & helpvar<=4
gen str categ = "_neighbor_" + string(helpvar) if helpvar!=0
replace categ = "_samebuilding" if helpvar==0
tab categ, missing
drop if missing(categ)
drop helpvar
drop if neighbor_buildingid<=0

sort cityid streetid buildingid
sum

save "`out'/precise_neighbors_detailed.dta", replace
