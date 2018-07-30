/*
Creates a firm-year panel with indicators for having spatial peers with CZ, SK, RO or RU-specific import, export or ownership experience in the previous year
	- spatial peers assigned to subgroups: 
		- peers in the same building
		- peers in the neighboring buildings (building number +/-2 or +/-4)
		- peers in the cross-street buildings (building number +/-1 or +/-3)
	- versions:
		- peers having country-specific importer or owner experience
		- peers having country-specific exporter or owner experience
		- same-industry peers having country-specific importer experience 
		- peers having successful country-specific importer experience 
			- having successful importer experience in year t is defined as importing from the country at least twice in the 3-year period of [t-1,t+1]
		- peers having country-specific importer experience in a given bec product category
		- peers having country-specific importer experience in a given Rauch product category
		- peers having country-specific importer experience by ownership, size and industry group
		- peers having country-specific importer experience by productivity group
		- maximum length of country-specific importer experience peers have
			- 2 versions: all the experience or only recent continuous experience counted (allowing for single-year gaps)
	- firms in the same ownership group are not considered as spatial peers
Inputs:
	2d_industry.dta
	address_data.dta
	exporter_panel.dta
	firm_bsheet_data.dta
	firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
	firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
	firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
	importer_panel.dta
	importer_panel_bec.dta
	importer_panel_rauch.dta
	importer_panel_yearly.dta
	owner_panel_yearly.dta
	precise_neighbors_detailed.dta
	time_variant_prod_quartiles.dta
Outputs:
	db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta 
	db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_rauch.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_numyears.dta 
	db_im_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta 
	db_ex_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
*/

clear
set more off

local peer_expimp "$peer_expimp"
local sameind "$sameind"
local success "$success"
local heterog "$heterog"
local no_exclusion "$no_exclusion"

local in "$in"
local out "$in"

assert "`sameind'"!="sameind" | "`success'"!="success"
assert "`success'"=="" | "`heterog'"==""
assert "`sameind'"=="" | "`heterog'"==""
assert "`no_exclusion'"=="" | "`heterog'"==""

* get firm characteristics - only for the versions by firm characteristics or by heterogeneity group

if "`heterog'"=="_prod"{
	use "`in'/firm_bsheet_data.dta", clear
	keep id8 year 
	sum
	rename id8 tax_id
	tempfile firmchar
	save `firmchar'
	*tax_id year
	use "`in'/time_variant_prod_quartiles.dta", clear
	keep tax_id year prod_quartile_y_robust
	merge 1:1 tax_id year using `firmchar'
	drop _merge
	foreach Y in 1 2 3 4{
		gen byte prod_quartile_y_robust`Y'=prod_quartile_y_robust==`Y'
	}
	sum
	drop prod_quartile_y_robust
	save `firmchar', replace
		*tax_id year prod_quartile_y_robust1-prod_quartile_y_robust4
}
if "`heterog'"=="_heterog"{
	use "`in'/firm_bsheet_data.dta", clear
	keep id8 year empl teaor03_2d_yearly fo2
	sum
	rename id8 tax_id

	gen teaor03_1d_yearly="A" if teaor03_2d_yearly<=2
	replace teaor03_1d_yearly="B" if teaor03_2d_yearly>2 & teaor03_2d_yearly<=5
	replace teaor03_1d_yearly="C" if teaor03_2d_yearly>5 & teaor03_2d_yearly<=14
	replace teaor03_1d_yearly="D" if teaor03_2d_yearly>14 & teaor03_2d_yearly<=37
	replace teaor03_1d_yearly="E" if teaor03_2d_yearly>37 & teaor03_2d_yearly<=41
	replace teaor03_1d_yearly="F" if teaor03_2d_yearly>41 & teaor03_2d_yearly<=45
	replace teaor03_1d_yearly="G" if teaor03_2d_yearly>45 & teaor03_2d_yearly<=52
	replace teaor03_1d_yearly="H" if teaor03_2d_yearly>52 & teaor03_2d_yearly<=55
	replace teaor03_1d_yearly="I" if teaor03_2d_yearly>55 & teaor03_2d_yearly<=64
	replace teaor03_1d_yearly="J" if teaor03_2d_yearly>64 & teaor03_2d_yearly<=67
	replace teaor03_1d_yearly="K" if teaor03_2d_yearly>67 & teaor03_2d_yearly<=74
	replace teaor03_1d_yearly="L" if teaor03_2d_yearly>74 & teaor03_2d_yearly<=75
	replace teaor03_1d_yearly="M" if teaor03_2d_yearly>75 & teaor03_2d_yearly<=80
	replace teaor03_1d_yearly="N" if teaor03_2d_yearly>80 & teaor03_2d_yearly<=85
	replace teaor03_1d_yearly="O" if teaor03_2d_yearly>85 & teaor03_2d_yearly<=93
	replace teaor03_1d_yearly="P" if teaor03_2d_yearly>93 & teaor03_2d_yearly<=97
	replace teaor03_1d_yearly="Q" if teaor03_2d_yearly>97 & teaor03_2d_yearly<=99

	gen byte size1=empl<=5
	gen byte size2=empl>5 & empl<=20
	gen byte size3=empl>20 & empl<=100
	gen byte size4=empl>100
	foreach X in 1 2 3 4{
		replace size`X'=. if empl==.
	}
	gen byte indAC=teaor03_1d_yearly=="A" | teaor03_1d_yearly=="B" | teaor03_1d_yearly=="C"
	gen byte indD=teaor03_1d_yearly=="D" 
	gen byte indEF=teaor03_1d_yearly=="E" | teaor03_1d_yearly=="F"
	gen byte indG=teaor03_1d_yearly=="G" 
	gen byte indHI=teaor03_1d_yearly=="H" | teaor03_1d_yearly=="I" 
	gen byte indJK=teaor03_1d_yearly=="J" | teaor03_1d_yearly=="K" 
	gen byte indLQ=teaor03_1d_yearly=="L" | teaor03_1d_yearly=="M" | teaor03_1d_yearly=="N" | teaor03_1d_yearly=="O" | teaor03_1d_yearly=="P" | teaor03_1d_yearly=="Q"
	foreach X in AC D EF G HI JK LQ{
		replace ind`X'=. if teaor03_2d_yearly==.
	}
	keep tax_id year size? ind* fo2 
	gen do2=1-fo2
	tempfile firmchar
	save `firmchar'
		*tax_id year size1-size4 indAC-indLQ fo2 do2
}

* get firm pairs with owner links in each year

if "`no_exclusion'"==""{
	use "`in'/firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta", clear
	append using "`in'/firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta"
	append using "`in'/firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta"
	duplicates drop
	tempfile owner_link
	save `owner_link'
		*tax_id year neighbor_tax_id

	* update owner links keeping only same-industry pairs - only for the same-industry peer version

	if "`sameind'"=="sameind"{
		use "`in'/2d_industry.dta", clear
		keep tax_id teaor03_2d
		duplicates drop
		tempfile industry
		save `industry'
			*tax_id teaor03_2d
		merge 1:m tax_id using  `owner_link'
		keep if _merge==3
		drop _merge
		save `owner_link', replace
		use `industry', clear
		rename * neighbor_*
		save `industry', replace
		*neighor_tax_id neighbor_teaor03_2d
		merge 1:m neighbor_tax_id using  `owner_link'
		keep if _merge==3
		drop _merge
		keep if teaor03_2d==neighbor_teaor03_2d & teaor03_2d!=.
		sum
		drop neighbor_teaor03_2d
		save `owner_link', replace
			*tax_id year neighbor_tax_id
	}
}

* get address data

use "`in'/address_data", clear
keep tax_id year cityid streetid buildingid 
tempfile address_data
save `address_data'
	*tax_id year cityid streetid buildingid 

* keep all firms with import/export data, operating in Budapest

* firm-year panel with importer/exporter and owner information
use "`in'/`peer_expimp'porter_panel.dta", clear
if "`success'"=="success" | "`heterog'"=="_rauch" | "`heterog'"=="_bec" | "`heterog'"=="_numyears"{
	keep tax_id firstyear lastyear
}
codebook tax_id
if "`heterog'"!="_numyears"{
	expand 12
	egen year=seq(), by(tax_id)
	replace year=year+1991
}
else if "`heterog'"=="_numyears"{
	expand 13
	egen year=seq(), by(tax_id)
	replace year=year+1990	
}
drop if year<firstyear | year>lastyear
drop firstyear lastyear
if "`success'"=="success"{
	merge 1:1 tax_id year using "`in'/`peer_expimp'porter_panel_yearly.dta"
	drop if _merge==2
	drop _merge
	xtset tax_id year
	foreach X in CZ SK RO RU{
		gen byte `peer_expimp'porter_s`X'=L.`peer_expimp'porter_yearly`X'+`peer_expimp'porter_yearly`X'+F.`peer_expimp'porter_yearly`X'>=2 & L.`peer_expimp'porter_yearly`X'+`peer_expimp'porter_yearly`X'+F.`peer_expimp'porter_yearly`X'<=3
	}
	drop `peer_expimp'porter_yearly*
	tempfile all_bp_firms
	save `all_bp_firms'
	use "`in'/owner_panel_yearly.dta", clear
	xtset tax_id year
	foreach X in CZ SK RO RU{
		gen byte owner_s`X'=L.owner_`X'+owner_`X'+F.owner_`X'>=2 & L.owner_`X'+owner_`X'+F.owner_`X'<=3
	}
	drop owner_??
	merge 1:1 tax_id year using `all_bp_firms'
	drop if _merge==1
	drop _merge
	foreach X in CZ SK RO RU{
		replace owner_s`X'=0 if owner_s`X'==.
	}
}
else if "`heterog'"=="" | "`heterog'"=="_prod" | "`heterog'"=="_heterog" {
	foreach X in CZ RO RU SK{
		gen byte `peer_expimp'porter_`X'=first_time_to_destination`X'<=year
		gen byte owner_`X'=first_owned_from_country`X'<=year
	}
	drop first*
}
tempfile all_bp_firms
save `all_bp_firms'
	*tax_id year if rauch, bec or numyears
	*tax_id year importer_?? owner_?? if baseline, prod or heterog
	*tax_id year importer_s?? owner_s?? if success
	
* keep only firms with addresses in Budapest
merge 1:1 tax_id year using `address_data'
keep if _merge==3
drop _merge
keep if cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139
save `all_bp_firms', replace
	*tax_id year cityid streetid buildingid if rauch or bec
	*tax_id year cityid streetid buildingid importer_?? owner_?? if baseline, prod or heterog
	*tax_id year cityid streetid buildingid first_time_to_destination?? first_owned_from_country?? if numyears
	*tax_id year cityid streetid buildingid importer_s?? owner_s?? if success
	
* get all potential pairs (being active in the same 2-digit industry) - only for the same-industry peer version

if "`sameind'"=="sameind"{
	use `industry', clear
	rename neighbor_* * 
	merge 1:m tax_id using  `all_bp_firms'
	keep if _merge==3
	drop _merge
	drop if teaor03_2d==.
	save `all_bp_firms', replace
		*tax_id year teaor03_2d cityid streetid buildingid importer_?? owner_?? if sameind
	levelsof teaor03_2d, local(teaor_list)
}

* get the number of years with experience - only for the version with the length of experience

if "`heterog'"=="_numyears"{
	use `all_bp_firms', clear
	merge 1:1 tax_id year using "`in'/`peer_expimp'porter_panel_yearly.dta"
	drop if _merge==2
	drop _merge
	rename `peer_expimp'porter_yearly* peer_`peer_expimp'porter_yearly*
	rename tax_id tax_id_peer
	foreach X in CZ SK RO RU{
		replace peer_`peer_expimp'porter_yearly`X'=0 if peer_`peer_expimp'porter_yearly`X'==.
	}
	xtset tax_id_peer year
	egen minyear=min(year), by(tax_id_peer)
	foreach X in CZ SK RO RU{
		gen numyears_`peer_expimp'p`X'=peer_`peer_expimp'porter_yearly`X' if year==minyear
		foreach Y of numlist 1992/2003{
			replace numyears_`peer_expimp'p`X'=peer_`peer_expimp'porter_yearly`X'+L.numyears_`peer_expimp'p`X' if year==`Y' & year>minyear
		}
	}
	foreach X in CZ SK RO RU{
		gen strictnumyears_`peer_expimp'p`X'=peer_`peer_expimp'porter_yearly`X' if year==minyear
		foreach Y of numlist 1992/2003{
			replace strictnumyears_`peer_expimp'p`X'=peer_`peer_expimp'porter_yearly`X'+L.strictnumyears_`peer_expimp'p`X' if year==`Y' & year>minyear 
			replace strictnumyears_`peer_expimp'p`X'=0 if year==`Y' & year>minyear & L.peer_`peer_expimp'porter_yearly`X'==0 & peer_`peer_expimp'porter_yearly`X'==0
		}
	}
	drop minyear peer_`peer_expimp'p*
	tempfile `peer_expimp'pstats
	save ``peer_expimp'pstats'
		*tax_id year numyears_imp?? strictnumyears_imp?? if numyears
}

* get neighboring addresses
	
use "`in'/precise_neighbors_detailed", clear
drop counter
* keep addresses only in Budapest
keep if cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139

* dataset of neighbors defined for each address extended to address-year observations
gen index = _n
expand 12
* create a year variable
egen year = seq(), by(index)
drop index
replace year = year+1992-1
tempfile address_pairs
save `address_pairs'
	*year cityid streetid buildingid neighbor_cityid neighbor_streetid neighbor_buildingid categ

* same-industry version (only for the baseline peer version)

if "`sameind'"=="sameind"{
	assert "`heterog'"=="" & "`success'"!="success"
	tempfile final_list
	log using "`in'/sameind_tocheck", replace text
	
	* one by one for each 2-digit industry
	
	foreach T in `teaor_list'{
		display "`T'"
		use `all_bp_firms', clear
		keep if teaor03_2d==`T'
		tempfile ind_firms
		save `ind_firms'
			*tax_id year teaor03_2d cityid streetid buildingid importer_?? owner_?? if sameind
		
		collapse (sum) `peer_expimp'porter_?? owner_?? (count) N=tax_id, by(year cityid streetid buildingid)

		* create a dataset with the number of importers/exporters per 'neighbor addresses'
		
		foreach X of var cityid streetid buildingid {
			ren `X' neighbor_`X'
		}
		tempfile neighborstats
		save `neighborstats', replace
			*importer_?? owner_?? N year neighbor_cityid neighbor_streetid neighbor_buildingid
		scalar Nobs=_N
		
		* skip if empty dataset
		
		if Nobs!=0{

			* assign number of firms and exporters in different neighborhoods (same and neighboring building) to each building-level address in each year
			use `address_pairs', clear
			* merged with number of exporters and foreign owners in each neighborhood
			merge m:1 neighbor_cityid neighbor_streetid neighbor_buildingid year using `neighborstats'
			keep if _merge==3
			* number of exporters and foreign owners given within same building, and neighboring buildings
			collapse (sum) `peer_expimp'porter_?? owner_?? N, by(cityid streetid buildingid year categ)
			reshape wide `peer_expimp'porter_?? owner_?? N, i(cityid streetid buildingid year) j(categ) string
			*year - building (cityid-streetid-buildingid) obs: exporter_??"categ" owner_??"categ" N"categ" (categ: _neighbor_1... _neighbor_4 _samebuilding)
			save `neighborstats', replace
				*year cityid streetid buildingid importer_??_samebuilding importer_??_neighbor_? owner_??_samebuilding owner_??_neighbor_? N_samebuilding N_neighbor_? 
		
			* Create exporter to and importer/owner from country in same building and in neighboring buildings

			* assign number of firms, exporters and owners in different neighborhoods (same and neighboring building) to each firm in each year
			use `ind_firms', clear
			cap drop teaor03_2d
			*tax_id - year obs: building (cityid-streetid-buildingid) first_time_to_?? exporter_?? (whenever year>first_tim_to_??)
			* merge exporters with neighbor statistics
			merge m:1 cityid streetid buildingid year using `neighborstats'
			keep if _merge==3
			drop _m
			* drop years before 1992 and after 2003 as no export data from there
			drop if year<1992 | year>2003
			* peers do not include yourself
			replace N_samebuilding = N_samebuilding-1
			*tax_id - year obs: building (cityid streetid buildingid) exporter_?? owner_?? first_time_to_destination?? first_owned_from_country?? - also for _samebuilding _neighbor_? (just as N)
			
			foreach X in CZ SK RO RU{
				replace `peer_expimp'porter_`X'_samebuilding=`peer_expimp'porter_`X'_samebuilding-1 if `peer_expimp'porter_`X'==1
				replace owner_`X'_samebuilding=owner_`X'_samebuilding-1 if owner_`X'==1
			}
				*tax_id year teaor03_2d cityid streetid buildingid importer_?? owner_?? importer_??_samebuilding importer_??_neighbor_? owner_??_samebuilding owner_??_neighbor_? N_samebuilding N_neighbor_? 
		
			* take out firms with ownership links
			
			preserve
			keep tax_id year cityid streetid buildingid
			merge 1:m tax_id year using `owner_link'
			drop if _merge==2
			drop _merge
			cap drop teaor03_2d
			tempfile tomatch
			save `tomatch'
				*tax_id year cityid streetid buildingid neighbor_tax_id
			
			use `ind_firms', clear
			rename * neighbor_*
			rename neighbor_year year
			cap drop *teaor03_2d
			merge 1:m neighbor_tax_id year using `tomatch'
			drop if _merge==1
			drop _merge
			drop if tax_id==neighbor_tax_id
			save `tomatch', replace
			scalar numobs=_N
			
			* skip if empty dataset
			
			if numobs!=0{
				
				* create experienced peer data
				
				use "`in'/precise_neighbors_detailed", clear
				duplicates drop cityid streetid buildingid neighbor_cityid neighbor_streetid neighbor_buildingid, force
				merge 1:m cityid streetid buildingid neighbor_cityid neighbor_streetid neighbor_buildingid using `tomatch'
				keep if _merge==3
				scalar numo=_N
				
				* skip if empty dataset
				
				if numo!=0{
					drop counter _merge
					foreach X in CZ SK RO RU{
						replace neighbor_`peer_expimp'porter_`X'=0 if neighbor_`peer_expimp'porter_`X'==.
						replace neighbor_owner_`X'=0 if neighbor_owner_`X'==.
					}
					collapse (sum) *_CZ *_SK *_RO *_RU, by(categ year tax_id)
					rename neighbor_`peer_expimp'porter* sameown*
					rename neighbor_owner* sameoo*
					reshape wide sameown_?? sameoo_??, i(tax_id year) j(categ) string
					foreach X in CZ SK RO RU{
						foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
							capture noisily replace sameown_`X'_`Y'=0 if sameown_`X'_`Y'==.
							capture noisily replace sameoo_`X'_`Y'=0 if sameoo_`X'_`Y'==.
						}
					}

					save `tomatch', replace
					restore
					
					merge 1:1 tax_id year using `tomatch'
					drop _merge
					foreach X in CZ SK RO RU{
						foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
							capture noisily replace sameown_`X'_`Y'=0 if sameown_`X'_`Y'==.
							capture noisily replace sameoo_`X'_`Y'=0 if sameoo_`X'_`Y'==.
						}
					}
					foreach X in CZ SK RO RU{
						foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
							capture noisily replace `peer_expimp'porter_`X'_`Y'=0 if `peer_expimp'porter_`X'_`Y'==.
							capture noisily replace owner_`X'_`Y'=0 if owner_`X'_`Y'==.
						}
					}
					foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
						capture noisily replace N_`Y'=0 if N_`Y'==.
					}
					foreach X in CZ SK RO RU{
						foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
							capture noisily replace `peer_expimp'porter_`X'_`Y'=`peer_expimp'porter_`X'_`Y'-sameown_`X'_`Y'
							capture noisily replace owner_`X'_`Y'=owner_`X'_`Y'-sameoo_`X'_`Y'
						}
					}
					drop sameown* sameoo* 
				}
				else{
					restore
				}
			}
			else{
				restore
			}
			if "`T'"!="1"{
				append using `final_list'
			}
			save `final_list', replace
				*tax_id year teaor03_2d cityid streetid buildingid importer_?? owner_?? importer_??_samebuilding importer_??_neighbor_? owner_??_samebuilding owner_??_neighbor_? N_samebuilding N_neighbor_? 
		}
	}
	log close
}

* version with neighbors in any industry

else if "`sameind'"==""{

	if "`heterog'"!="_numyears"{
		use `all_bp_firms', clear
		
		if "`heterog'"=="_rauch"{
			merge m:1 tax_id using "`in'/`peer_expimp'porter_panel_rauch.dta"
			drop if _merge==2
			drop _merge
			foreach X in CZ SK RO RU{
				foreach Y in n r w{
					gen byte `peer_expimp'porter_`X'`Y'=year>=first_time_to_destination`X'`Y'
				}
			}
			sum
			drop first*
		}
		else if "`heterog'"=="_bec"{
			merge m:1 tax_id using "`in'/`peer_expimp'porter_panel_bec.dta"
			drop if _merge==2
			drop _merge
			foreach X in CZ SK RO RU{
				foreach Y in 1_6 2_3 42_53 41_51_52{
					gen byte `peer_expimp'porter_`X'`Y'=year>=minyear`X'`Y'
				}
			}
			sum
			drop minyear*
		}
		else if "`heterog'"=="_prod" | "`heterog'"=="_heterog"{
			merge 1:1 tax_id year using `firmchar'
			keep if _merge==3
			drop _merge
			sum
		}
		
		
		tempfile ind_firms
		save `ind_firms'
	}	
	if "`heterog'"=="_numyears"{
		use ``peer_expimp'pstats', clear

		foreach X of numlist 1/12{
			foreach Y in "" strict{
				foreach Z in CZ SK RO RU{
					gen byte num_`Y'numyears_`Z'_`X'=`Y'numyears_imp`Z'==`X'
				}
			}
		}

		collapse (sum) num_*, by(year cityid streetid buildingid)
		foreach X of var cityid streetid buildingid {
			ren `X' neighbor_`X'
		}

		* create a dataset with number of exporters per 'neighbor addresses'
		tempfile neighborstats
		save `neighborstats', replace
		
		* assign number of firms and exporters in different neighborhoods (same and neighboring building) to each building-level address in each year
		use `address_pairs', clear
		* merged with number of exporters and foreign owners in each neighborhood
		merge m:1 neighbor_cityid neighbor_streetid neighbor_buildingid year using `neighborstats'
		keep if _merge==3
		* number of exporters and foreign owners given within same building, and neighboring buildings
		collapse (sum) num_*, by(cityid streetid buildingid year categ)
		rename num_numyears_??_* numy??_*
		rename num_strictnumyears_??_* snumy??_*
		reshape wide numy??_* snumy??_*, i(cityid streetid buildingid year) j(categ) string
		*year - building (cityid-streetid-buildingid) obs: exporter_??"categ" owner_??"categ" N"categ" (categ: _neighbor_1... _neighbor_4 _samebuilding)
		save `neighborstats', replace
	}
	else if "`heterog'"=="_prod"{
		tempfile neighborstats neighborcat
		foreach D in 1 2 3 4{
			display "prod_quartile_y_robust`D'"
			use `ind_firms', clear
			keep if prod_quartile_y_robust`D'==1
			collapse (sum) `peer_expimp'porter_?? , by(year cityid streetid buildingid)

			* create a dataset with number of exporters per 'neighbor addresses'
			foreach X of var cityid streetid buildingid {
				ren `X' neighbor_`X'
			}
			save `neighborcat', replace

			* assign number of firms and exporters in different neighborhoods (same and neighboring building) to each building-level address in each year
			use `address_pairs', clear
			* merged with number of exporters and foreign owners in each neighborhood
			merge m:1 neighbor_cityid neighbor_streetid neighbor_buildingid year using `neighborcat'
			keep if _merge==3
			* number of exporters and foreign owners given within same building, and neighboring buildings
			collapse (sum) `peer_expimp'porter_??, by(cityid streetid buildingid year categ)
			reshape wide `peer_expimp'porter_?? , i(cityid streetid buildingid year) j(categ) string
			*year - building (cityid-streetid-buildingid) obs: exporter_??"categ" owner_??"categ" N"categ" (categ: _neighbor_1... _neighbor_4 _samebuilding)
			rename importer* prob`D'importer*
			if "`D'"!="1"{
				merge 1:1 cityid streetid buildingid year using `neighborstats'
				drop _merge
			}
			save `neighborstats', replace
		}
	}
	else if "`heterog'"=="_heterog"{
		tempfile neighborstats neighborcat
		foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			display "`C'"
			use `ind_firms', clear
			keep if `C'==1
			collapse (sum) `peer_expimp'porter_?? , by(year cityid streetid buildingid)

			* create a dataset with number of exporters per 'neighbor addresses'
			foreach X of var cityid streetid buildingid {
				ren `X' neighbor_`X'
			}
			
			save `neighborcat', replace

			* assign number of firms and exporters in different neighborhoods (same and neighboring building) to each building-level address in each year
			use `address_pairs', clear
			* merged with number of exporters and foreign owners in each neighborhood
			merge m:1 neighbor_cityid neighbor_streetid neighbor_buildingid year using `neighborcat'
			keep if _merge==3
			* number of exporters and foreign owners given within same building, and neighboring buildings
			collapse (sum) `peer_expimp'porter_??, by(cityid streetid buildingid year categ)
			reshape wide `peer_expimp'porter_?? , i(cityid streetid buildingid year) j(categ) string
			*year - building (cityid-streetid-buildingid) obs: exporter_??"categ" owner_??"categ" N"categ" (categ: _neighbor_1... _neighbor_4 _samebuilding)
			rename importer* `C'importer*
			if "`C'"!="fo2"{
				merge 1:1 cityid streetid buildingid year using `neighborstats'
				drop _merge
			}
			save `neighborstats', replace
		}
	}
	
	else if "`heterog'"!="_prod" & "`heterog'"!="_heterog" & "`heterog'"!="_numyears"{
		
		if "`success'"!="success"{	
			if "`heterog'"=="" {
				collapse (sum) `peer_expimp'porter_?? owner_?? (count) N=tax_id, by(year cityid streetid buildingid)
			}
			else if "`heterog'"=="_rauch" | "`heterog'"=="_bec"{
				collapse (sum) `peer_expimp'porter_*, by(year cityid streetid buildingid)
			}
		}
		else if "`success'"=="success"{	
			collapse (sum) `peer_expimp'porter_s?? owner_s?? (count) N=tax_id, by(year cityid streetid buildingid)
		}
		
		* create a dataset with number of exporters per 'neighbor addresses'
		foreach X of var cityid streetid buildingid {
			ren `X' neighbor_`X'
		}
		tempfile neighborstats
		save `neighborstats', replace

		* assign number of firms and exporters in different neighborhoods (same and neighboring building) to each building-level address in each year
		use `address_pairs', clear
		* merged with number of exporters and foreign owners in each neighborhood
		merge m:1 neighbor_cityid neighbor_streetid neighbor_buildingid year using `neighborstats'
		keep if _merge==3
		* number of exporters and foreign owners given within same building, and neighboring buildings
		if "`success'"!="success"{
			if "`heterog'"==""{
				collapse (sum) `peer_expimp'porter_?? owner_?? N, by(cityid streetid buildingid year categ)
				reshape wide `peer_expimp'porter_?? owner_?? N, i(cityid streetid buildingid year) j(categ) string
			}
			else if "`heterog'"=="_rauch"{
				collapse (sum) `peer_expimp'porter_???, by(cityid streetid buildingid year categ)
				reshape wide `peer_expimp'porter_???, i(cityid streetid buildingid year) j(categ) string
			}
			else if "`heterog'"=="_bec"{
				collapse (sum) `peer_expimp'porter_*, by(cityid streetid buildingid year categ)
				reshape wide `peer_expimp'porter_??1_6 `peer_expimp'porter_??2_3 `peer_expimp'porter_??42_53 `peer_expimp'porter_??41_51_52, i(cityid streetid buildingid year) j(categ) string
			}
		}
		else if "`success'"=="success"{
			collapse (sum) `peer_expimp'porter_s?? owner_s?? N, by(cityid streetid buildingid year categ)
			reshape wide `peer_expimp'porter_s?? owner_s?? N, i(cityid streetid buildingid year) j(categ) string
		}
		*year - building (cityid-streetid-buildingid) obs: exporter_??"categ" owner_??"categ" N"categ" (categ: _neighbor_1... _neighbor_4 _samebuilding)
		save `neighborstats', replace
	}
	
	* Create exporter to and owner from destination in same building and in neighboring buildings

	* assign number of firms, exporters and owners in different neighborhoods (same and neighboring building) to each firm in each year
	if "`heterog'"!="_prod" & "`heterog'"!="_heterog" & "`heterog'"!="_numyears"{
		use `ind_firms', clear
		cap drop teaor03_2d
	}
	else if "`heterog'"=="_prod" | "`heterog'"=="_heterog"{
		use `all_bp_firms', clear
		merge 1:1 tax_id year using `firmchar'
		drop if _merge==2
		drop _merge
	}
	else if "`heterog'"=="_numyears"{
		use ``peer_expimp'pstats', clear
		rename tax_id_peer tax_id
	}
	*tax_id - year obs: building (cityid-streetid-buildingid) first_time_to_?? exporter_?? (whenever year>first_tim_to_??)
	* merge exporters with neighbor statistics
	merge m:1 cityid streetid buildingid year using `neighborstats'
	keep if _merge==3
	drop _m
	* drop years before 1992 and after 2003 as no export data from there
	drop if year<1992 | year>2003
	* peers do not include yourself
	cap replace N_samebuilding = N_samebuilding-1
	*tax_id - year obs: building (cityid streetid buildingid) exporter_?? owner_?? first_time_to_destination?? first_owned_from_country?? - also for _samebuilding _neighbor_? (just as N)

	if "`heterog'"=="_prod"{
		foreach X in CZ SK RO RU{
			foreach D in 1 2 3 4{
				foreach K in samebuilding neighbor_1 neighbor_2 neighbor_3 neighbor_4{
					replace prob`D'`peer_expimp'porter_`X'_`K'=0 if prob`D'`peer_expimp'porter_`X'_`K'==.
				}
			}
		}
		foreach X in CZ SK RO RU{
			foreach D in 1 2 3 4{
				replace prob`D'`peer_expimp'porter_`X'_samebuilding=prob`D'`peer_expimp'porter_`X'_samebuilding-1 if `peer_expimp'porter_`X'==1 & prod_quartile_y_robust`D'==1
			}
		}
	}
	else if "`heterog'"=="_heterog"{
		foreach X in CZ SK RO RU{
			foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
				foreach K in samebuilding neighbor_1 neighbor_2 neighbor_3 neighbor_4{
					replace `C'`peer_expimp'porter_`X'_`K'=0 if `C'`peer_expimp'porter_`X'_`K'==.
				}
			}
		}

		foreach X in CZ SK RO RU{
			foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{	
				replace `C'`peer_expimp'porter_`X'_samebuilding=`C'`peer_expimp'porter_`X'_samebuilding-1 if `peer_expimp'porter_`X'==1 & `C'==1
			}
		}	
	}
	else if "`heterog'"!="_prod" & "`heterog'"!="_heterog" & "`heterog'"!="_numyears"{
		if "`success'"!="success"{
			if "`heterog'"==""{
				foreach X in CZ SK RO RU{
					replace `peer_expimp'porter_`X'_samebuilding=`peer_expimp'porter_`X'_samebuilding-1 if `peer_expimp'porter_`X'==1
					replace owner_`X'_samebuilding=owner_`X'_samebuilding-1 if owner_`X'==1
				}
			}
			else if "`heterog'"=="_rauch"{
				foreach X in CZ SK RO RU{
					foreach Y in r w n{
						replace `peer_expimp'porter_`X'`Y'_samebuilding=`peer_expimp'porter_`X'`Y'_samebuilding-1 if `peer_expimp'porter_`X'`Y'==1
					}
				}
			}
			else if "`heterog'"=="_bec"{
				foreach X in CZ SK RO RU{
					foreach Y in 1_6 2_3 41_51_52 42_53{
						replace `peer_expimp'porter_`X'`Y'_samebuilding=`peer_expimp'porter_`X'`Y'_samebuilding-1 if `peer_expimp'porter_`X'`Y'==1
					}
				}
			}
		}
		else if "`success'"=="success"{
			foreach X in CZ SK RO RU{
				replace `peer_expimp'porter_s`X'_samebuilding=`peer_expimp'porter_s`X'_samebuilding-1 if `peer_expimp'porter_s`X'==1
				replace owner_s`X'_samebuilding=owner_s`X'_samebuilding-1 if owner_s`X'==1
			}
		}
	}
	if "`no_exclusion'"==""{
		* take out firms with ownership links
		preserve
		keep tax_id year cityid streetid buildingid
		merge 1:m tax_id year using `owner_link'
		drop if _merge==2
		drop _merge
		cap drop teaor03_2d
		tempfile tomatch
		save `tomatch'
		
		* difference from previous version: less obs as only Bp firms
		if "`heterog'"=="_prod" | "`heterog'"=="_heterog"{
			use `all_bp_firms', clear
			merge 1:1 tax_id year using `firmchar'
			keep if _merge==3
			drop _merge
			drop owner*
			rename *id neighbor_*id
			rename importer* neighbor_importer*
		}
		else if "`heterog'"=="_numyears"{
			use `all_bp_firms', clear
			rename * neighbor_*
			rename neighbor_year year
		}
		else if "`heterog'"!="_prod" & "`heterog'"!="_heterog" & "`heterog'"!="_numyears"{
			use `ind_firms', clear
			rename * neighbor_*
			rename neighbor_year year
		}
		merge 1:m neighbor_tax_id year using `tomatch'
		drop if _merge==1
		drop _merge
		drop if tax_id==neighbor_tax_id
		save `tomatch', replace
		use "`in'/precise_neighbors_detailed", clear
		duplicates drop cityid streetid buildingid neighbor_cityid neighbor_streetid neighbor_buildingid, force
		merge 1:m cityid streetid buildingid neighbor_cityid neighbor_streetid neighbor_buildingid using `tomatch'
		keep if _merge==3
		drop counter _merge
		if "`success'"!="success"{
			if "`heterog'"==""{
				foreach X in CZ SK RO RU{
					replace neighbor_`peer_expimp'porter_`X'=0 if neighbor_`peer_expimp'porter_`X'==.
					replace neighbor_owner_`X'=0 if neighbor_owner_`X'==.
				}
				collapse (sum) *_CZ *_SK *_RO *_RU, by(categ year tax_id)
			}
			else if "`heterog'"=="_rauch"{
				foreach X in CZ SK RO RU{
					foreach Y in w r n{
						replace neighbor_`peer_expimp'porter_`X'`Y'=0 if neighbor_`peer_expimp'porter_`X'`Y'==.
					}
				}
				collapse (sum) *_CZ? *_SK? *_RO? *_RU?, by(categ year tax_id)
			}
			else if "`heterog'"=="_bec"{
				foreach X in CZ SK RO RU{
					foreach Y in 1_6 2_3 41_51_52 42_53{
						replace neighbor_`peer_expimp'porter_`X'`Y'=0 if neighbor_`peer_expimp'porter_`X'`Y'==.
					}
				}
				collapse (sum) *CZ* *SK* *RO* *RU*, by(categ year tax_id)
				
			}
			else if "`heterog'"=="_prod"{
				foreach X in CZ SK RO RU{
					replace neighbor_`peer_expimp'porter_`X'=0 if neighbor_`peer_expimp'porter_`X'==.
				}
			}
			else if "`heterog'"=="_heterog"{
				foreach X in CZ SK RO RU{
					replace neighbor_`peer_expimp'porter_`X'=0 if neighbor_`peer_expimp'porter_`X'==.
				}
			}
		}
		else if "`success'"=="success"{
			foreach X in CZ SK RO RU{
				replace neighbor_`peer_expimp'porter_s`X'=0 if neighbor_`peer_expimp'porter_s`X'==.
				replace neighbor_owner_s`X'=0 if neighbor_owner_s`X'==.
			}
			collapse (sum) *_sCZ *_sSK *_sRO *_sRU, by(categ year tax_id)
		}
		if "`heterog'"=="_prod"{
			tempfile tocollapse
			save `tocollapse'
			
			foreach D in 1 2 3 4{
				display "prod_quartile_y_robust`D'"
				use `tocollapse', clear
				keep if prod_quartile_y_robust`D'==1
				collapse (sum) *_CZ *_SK *_RO *_RU, by(categ year tax_id)
				rename neighbor_`peer_expimp'porter* sameownprob`D'*
				reshape wide sameownprob`D'_CZ sameownprob`D'_SK sameownprob`D'_RO sameownprob`D'_RU, i(tax_id year) j(categ) string
				foreach X in CZ SK RO RU{
					foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
						capture noisily replace sameownprob`D'_`X'_`Y'=0 if sameownprob`D'_`X'_`Y'==.
					}
				}
				if "`D'"!="1"{
					merge 1:1 tax_id year using `tomatch'
					drop _merge
				}
				save `tomatch', replace
			}
		}
		else if "`heterog'"=="_heterog"{
			tempfile tocollapse
			save `tocollapse'
			
			foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
				display "`C'"
				use `tocollapse', clear
				keep if `C'==1
				collapse (sum) *_CZ *_SK *_RO *_RU, by(categ year tax_id)
				rename neighbor_`peer_expimp'porter* sameown`C'*
				reshape wide sameown`C'_CZ sameown`C'_SK sameown`C'_RO sameown`C'_RU, i(tax_id year) j(categ) string
				foreach X in CZ SK RO RU{
					foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
						capture noisily replace sameown`C'_`X'_`Y'=0 if sameown`C'_`X'_`Y'==.
					}
				}
				if "`C'"!="fo2"{
					merge 1:1 tax_id year using `tomatch'
					drop _merge
				}
				save `tomatch', replace
			}
		}
		else if "`heterog'"=="_numyears"{
			keep tax_id neighbor_tax_id year categ
			rename neighbor_tax_id tax_id_peer
			merge m:1 tax_id_peer year using ``peer_expimp'pstats'
			keep if _merge==3
			drop _merge cityid streetid buildingid
				
			foreach X of numlist 1/12{
				foreach Y in "" strict{
					foreach Z in CZ SK RO RU{
						gen byte num_`Y'numyears_`Z'_`X'=`Y'numyears_imp`Z'==`X'
					}
				}
			}
			collapse (sum) num_*, by(tax_id year categ)
			rename num_numyears_??_* onumy??_*
			rename num_strictnumyears_??_* osnumy??_*
			reshape wide onumy??_* osnumy??_*, i(tax_id year) j(categ) string
			foreach X in CZ SK RO RU{
				foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
					foreach Z of numlist 1/12{
						capture noisily replace onumy`X'_`Z'_`Y'=0 if onumy`X'_`Z'_`Y'==.
						capture noisily replace osnumy`X'_`Z'_`Y'=0 if osnumy`X'_`Z'_`Y'==.
					}
				}
			}
			
			save `tomatch', replace
		}
		else if "`heterog'"!="_prod" & "`heterog'"!="_heterog" & "`heterog'"!="_numyears"{
			rename neighbor_`peer_expimp'porter* sameown*
			if "`success'"!="success"{	
				if "`heterog'"==""{
					rename neighbor_owner* sameoo*
					reshape wide sameown_?? sameoo_??, i(tax_id year) j(categ) string
				}
				else if "`heterog'"=="_rauch"{
					reshape wide sameown_??? , i(tax_id year) j(categ) string
				}
				else if "`heterog'"=="_bec"{
					reshape wide sameown_??1_6 sameown_??2_3 sameown_??41_51_52 sameown_??42_53, i(tax_id year) j(categ) string
				}
			}
			else if "`success'"=="success"{
				rename neighbor_owner* sameoo*
				reshape wide sameown_s?? sameoo_s??, i(tax_id year) j(categ) string
			}
			foreach X in CZ SK RO RU{
				foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
					if "`success'"!="success"{
						if "`heterog'"==""{
							capture noisily replace sameown_`X'_`Y'=0 if sameown_`X'_`Y'==.
							capture noisily replace sameoo_`X'_`Y'=0 if sameoo_`X'_`Y'==.
						}
						else if "`heterog'"=="_rauch"{
							foreach Z in w r n{
								capture noisily replace sameown_`X'`Z'_`Y'=0 if sameown_`X'`Z'_`Y'==.
							}
						}
						else if "`heterog'"=="_bec"{
							foreach Z in 1_6 2_3 41_51_52 42_53{
								capture noisily replace sameown_`X'`Z'_`Y'=0 if sameown_`X'`Z'_`Y'==.
							}
						}
					}
					else if "`success'"=="success"{
						foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
							capture noisily replace sameown_s`X'_`Y'=0 if sameown_s`X'_`Y'==.
							capture noisily replace sameoo_s`X'_`Y'=0 if sameoo_s`X'_`Y'==.
						}
					}
				}
			}

			save `tomatch', replace
		}
		restore
		
		merge 1:1 tax_id year using `tomatch'
		drop _merge
	}
	foreach X in CZ SK RO RU{
		foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
			if "`success'"!="success"{
				if "`heterog'"==""{
					capture noisily replace sameown_`X'_`Y'=0 if sameown_`X'_`Y'==.
					capture noisily replace sameoo_`X'_`Y'=0 if sameoo_`X'_`Y'==.
				}
				else if "`heterog'"=="_rauch"{
					foreach Z in r w n{
						capture noisily replace sameown_`X'`Z'_`Y'=0 if sameown_`X'`Z'_`Y'==.
					}
				}
				else if "`heterog'"=="_bec"{
					foreach Z in 1_6 2_3 41_51_52 42_53{
						capture noisily replace sameown_`X'`Z'_`Y'=0 if sameown_`X'`Z'_`Y'==.
					}
				}
				else if "`heterog'"=="_prod"{
					foreach D in 1 2 3 4{	
						capture noisily replace sameownprob`D'_`X'_`Y'=0 if sameownprob`D'_`X'_`Y'==.
					}
				}
				else if "`heterog'"=="_heterog"{
					foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
						capture noisily replace sameown`C'_`X'_`Y'=0 if sameown`C'_`X'_`Y'==.
					}
				}
				else if "`heterog'"=="_numyears"{
					foreach Z of numlist 1/12{
						capture noisily replace numy`X'_`Z'_`Y'=0 if numy`X'_`Z'_`Y'==.
						capture noisily replace snumy`X'_`Z'_`Y'=0 if snumy`X'_`Z'_`Y'==.
					}
				}
			}
			else if "`success'"=="success"{
				capture noisily replace sameown_s`X'_`Y'=0 if sameown_s`X'_`Y'==.
				capture noisily replace sameoo_s`X'_`Y'=0 if sameoo_s`X'_`Y'==.
			}
		}
	}
	foreach X in CZ SK RO RU{
		foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
			if "`success'"!="success"{
				if "`heterog'"==""{
					capture noisily replace `peer_expimp'porter_`X'_`Y'=0 if `peer_expimp'porter_`X'_`Y'==.
					capture noisily replace owner_`X'_`Y'=0 if owner_`X'_`Y'==.
				}
				else if "`heterog'"=="_rauch"{
					foreach Z in r w n{
						capture noisily replace `peer_expimp'porter_`X'`Z'_`Y'=0 if `peer_expimp'porter_`X'`Z'_`Y'==.
					}
				}
				else if "`heterog'"=="_bec"{
					foreach Z in 1_6 2_3 41_51_52 42_53{
						capture noisily replace `peer_expimp'porter_`X'`Z'_`Y'=0 if `peer_expimp'porter_`X'`Z'_`Y'==.
					}
				}
				else if "`heterog'"=="_prod"{
					foreach D in 1 2 3 4{	
						capture noisily replace prob`D'`peer_expimp'porter_`X'_`Y'=0 if prob`D'`peer_expimp'porter_`X'_`Y'==.
					}						
				}
				else if "`heterog'"=="_heterog"{
					foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
						capture noisily replace `C'`peer_expimp'porter_`X'_`Y'=0 if `C'`peer_expimp'porter_`X'_`Y'==.
					}					
				}
				else if "`heterog'"=="_numyears"{
					foreach Z of numlist 1/12{
						capture noisily replace onumy`X'_`Z'_`Y'=0 if onumy`X'_`Z'_`Y'==.
						capture noisily replace osnumy`X'_`Z'_`Y'=0 if osnumy`X'_`Z'_`Y'==.
					}
				}
			}
			else if "`success'"=="success"{
				capture noisily replace `peer_expimp'porter_s`X'_`Y'=0 if `peer_expimp'porter_s`X'_`Y'==.
				capture noisily replace owner_s`X'_`Y'=0 if owner_s`X'_`Y'==.
			}
		}
	}
	foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
		capture noisily replace N_`Y'=0 if N_`Y'==.
	}
	if "`no_exclusion'"==""{
		foreach X in CZ SK RO RU{
			foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
				if "`success'"!="success"{
					if "`heterog'"==""{
						capture noisily replace `peer_expimp'porter_`X'_`Y'=`peer_expimp'porter_`X'_`Y'-sameown_`X'_`Y'
						capture noisily replace owner_`X'_`Y'=owner_`X'_`Y'-sameoo_`X'_`Y'
					}
					else if "`heterog'"=="_rauch"{
						foreach Z in r w n{
							capture noisily replace `peer_expimp'porter_`X'`Z'_`Y'=`peer_expimp'porter_`X'`Z'_`Y'-sameown_`X'`Z'_`Y'
						}
					}
					else if "`heterog'"=="_bec"{
						foreach Z in 1_6 2_3 41_51_52 42_53{
							capture noisily replace `peer_expimp'porter_`X'`Z'_`Y'=`peer_expimp'porter_`X'`Z'_`Y'-sameown_`X'`Z'_`Y'
						}
					}
					else if "`heterog'"=="_prod"{
						foreach D in 1 2 3 4{	
							capture noisily replace prob`D'`peer_expimp'porter_`X'_`Y'=prob`D'`peer_expimp'porter_`X'_`Y'-sameownprob`D'_`X'_`Y'
						}
					}
					else if "`heterog'"=="_heterog"{
						foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
							capture noisily replace `C'`peer_expimp'porter_`X'_`Y'=`C'`peer_expimp'porter_`X'_`Y'-sameown`C'_`X'_`Y'
						}
					}
					else if "`heterog'"=="_numyears"{
						foreach Z of numlist 1/12{
							capture noisily replace numy`X'_`Z'_`Y'=numy`X'_`Z'_`Y'-onumy`X'_`Z'_`Y'
							capture noisily replace snumy`X'_`Z'_`Y'=snumy`X'_`Z'_`Y'-osnumy`X'_`Z'_`Y'
						}
					}
				}
				else if "`success'"=="success"{
					capture noisily replace `peer_expimp'porter_s`X'_`Y'=`peer_expimp'porter_s`X'_`Y'-sameown_s`X'_`Y'
					capture noisily replace owner_s`X'_`Y'=owner_s`X'_`Y'-sameoo_s`X'_`Y'
				}
			}
		}
		cap drop sameown* 
		cap drop sameoo* 
		cap drop onumy* osnumy*
	}
}

if "`heterog'"=="_numyears"{
	* take out own firm stats from neighborstats in building

	foreach X in CZ SK RO RU{
		foreach Z of numlist 1/12{
			capture noisily replace numy`X'_`Z'_samebuilding=numy`X'_`Z'_samebuilding-1 if numyears_`peer_expimp'p`X'==`Z'
			capture noisily replace snumy`X'_`Z'_samebuilding=snumy`X'_`Z'_samebuilding-1 if strictnumyears_`peer_expimp'p`X'==`Z'
		}
	}

	* collapse to max years per neighborhood

	foreach X in CZ SK RO RU{
		foreach Y in neighbor_1 neighbor_2 neighbor_3 neighbor_4 samebuilding{
			gen numy_`Y'_`X'=0
			gen snumy_`Y'_`X'=0
			foreach Z of numlist 1/12{
				replace numy_`Y'_`X'=`Z' if numy`X'_`Z'_`Y'>0
				replace snumy_`Y'_`X'=`Z' if snumy`X'_`Z'_`Y'>0
			}
		}
	}

	keep tax_id year numyears* strictnumyears* numy*CZ numy*SK numy*RO numy*RU snumy*CZ snumy*SK snumy*RO snumy*RU

}

save "`out'/db_`peer_expimp'_geo_neighborstat_budapest_no_ownership_link_strict`sameind'`success'`heterog'`no_exclusion'.dta", replace





