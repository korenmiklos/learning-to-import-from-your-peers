/*
Creates a firm-year panel with indicators for having person-connected peers with CZ, SK, RO or RU-specific import, export or ownership experience in the previous year
	- versions:
		- peers having country-specific importer or owner experience / exporter and owner experience
			- 3 different definitions of person-connected peers
				- baseline: person has signing right in both the firm and the peer
				- all connections considered (signing right, ownership or membership in the supervisory board)
				- person is an owner in the firm and had/has signing right in the peer
		- same-industry peers having country-specific importer experience 
		- peers having successful country-specific importer experience 
			- having successful importer experience in year t is defined as importing from the country at least twice in the 3-year period of [t-1,t+1]
		- peers having country-specific importer experience in a given bec product category
		- peers having country-specific importer experience in a given Rauch product category
		- peers having country-specific importer experience by ownership, size and industry group
		- peers having country-specific importer experience by productivity group
		- maximum length of country-specific importer experience peers have
			- 2 versions: all the experience or only recent continuous experience counted (allowing for single-year gaps)
	- two firms are not connected if they have the same address in the first year of being linked
	- firms in the same ownership group are not considered as person-connected peers
Inputs:
	2d_industry.dta
	address_data.dta
	directed_firm_pairs.dta
	directed_firm_pairs_13.dta
	directed_firm_pairs_from_sign_to_own.dta
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
	time_variant_prod_quartiles.dta
Outputs:
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta 
	db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta 
	db_im_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta 
	db_ex_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta 
	db_im_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta 
	db_ex_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_rauch.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_numyears.dta 
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta 
	db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta
*/



clear
set more off

local peer_expimp "$peer_expimp"
local which_rovat "$which_rovat"
local sameind "$sameind"
local success "$success"
local heterog "$heterog"
local no_exclusion "$no_exclusion"

local in "../$in"
local out "../$in"

assert "`sameind'"!="sameind" | "`success'"!="success"
assert "`success'"=="" | "`heterog'"==""
assert "`sameind'"=="" | "`heterog'"==""
assert "`no_exclusion'"=="" | "`heterog'"==""


* firm characteristics - only for heterog and prod versions
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
	rename tax_id tax_id_peer
	drop if year>2003
	reshape wide fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ, i(tax_id_peer) j(year)
	tempfile firmchar
	save `firmchar'
}
else if "`heterog'"=="_prod"{	
	use "`in'/firm_bsheet_data.dta", clear
	keep id8 year 
	sum
	rename id8 tax_id
	tempfile firmchar
	save `firmchar'
		
	use "`in'/time_variant_prod_quartiles.dta", clear
	keep tax_id year prod_quartile_y_robust
	merge 1:1 tax_id year using `firmchar'
	drop _merge
	rename tax_id tax_id_peer
	drop if year>2003
	foreach Y in 1 2 3 4{
		gen byte prod_quartile_y_robust`Y'=prod_quartile_y_robust==`Y'
	}
	sum
	drop prod_quartile_y_robust
	reshape wide prod_quartile_y_robust?, i(tax_id_peer) j(year)
	save `firmchar', replace
}

if "`no_exclusion'"==""{

	use "`in'/firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta", clear
	append using "`in'/firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta"
	append using "`in'/firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta"
	duplicates drop
	drop if tax_id==neighbor_tax_id

	rename neighbor_tax_id tax_id_peer
	tempfile owner_link
	save `owner_link'
	
}

* merge export data to the peers
if "`success'"!="success" & "`heterog'"!="_rauch" & "`heterog'"!="_bec" & "`heterog'"!="_numyears"{
	use "`in'/`peer_expimp'porter_panel.dta"
	drop  firstyear lastyear
	rename tax_id tax_id_peer
}
else if "`heterog'"=="_rauch"{
	use "`in'/`peer_expimp'porter_panel_rauch.dta"
	rename tax_id tax_id_peer
}
else if "`heterog'"=="_bec"{
	use "`in'/`peer_expimp'porter_panel_bec.dta"
	rename tax_id tax_id_peer
}
else if "`success'"=="success"{
	use "`in'/`peer_expimp'porter_panel.dta"
	keep tax_id firstyear lastyear
	expand 12
	egen year=seq(), by(tax_id)
	replace year=year+1991
	drop if year<firstyear | year>lastyear
	drop firstyear lastyear
	tempfile frame
	save `frame'

	merge 1:1 tax_id year using "`in'/`peer_expimp'porter_panel_yearly.dta"
	drop if _merge==2
	drop _merge
	xtset tax_id year
	foreach X in CZ SK RO RU{
		gen byte `peer_expimp'porter_s`X'=L.`peer_expimp'porter_yearly`X'+`peer_expimp'porter_yearly`X'+F.`peer_expimp'porter_yearly`X'>=2 & L.`peer_expimp'porter_yearly`X'+`peer_expimp'porter_yearly`X'+F.`peer_expimp'porter_yearly`X'<=3
	}
	drop `peer_expimp'porter_yearly*
	rename tax_id tax_id_peer
	tempfile `peer_expimp'pstats
	save ``peer_expimp'pstats'
	*tax_id_peer year `peer_expimp'porter_s?? 
	use "`in'/owner_panel_yearly.dta", clear
	xtset tax_id year
	foreach X in CZ SK RO RU{
		gen byte owner_s`X'=L.owner_`X'+owner_`X'+F.owner_`X'>=2 & L.owner_`X'+owner_`X'+F.owner_`X'<=3
	}
	drop owner_??
	rename tax_id tax_id_peer
	merge 1:1 tax_id_peer year using ``peer_expimp'pstats'
	drop if _merge==1
	drop _merge
	foreach X in CZ SK RO RU{
		replace owner_s`X'=0 if owner_s`X'==.
	}
	save ``peer_expimp'pstats', replace

}
else if "`heterog'"=="_numyears"{
	use "`in'/`peer_expimp'porter_panel_yearly.dta", clear
	rename tax_id tax_id_peer
	*drop  firstyear lastyear
	* count the number of years a peer imported (including t)
	xtset tax_id_peer year
	rename `peer_expimp'porter_* peer_`peer_expimp'porter_*
}
tempfile `peer_expimp'pstats
save ``peer_expimp'pstats'
if "`heterog'"=="_numyears"{
	use "`in'/`peer_expimp'porter_panel.dta"
	rename tax_id tax_id_peer
	keep tax_id_peer first_time*
	tempfile tradestats
	save `tradestats'
}

* assign address data if pairs having the same address should be excluded
use "`in'/address_data"
keep tax_id year cityid streetid buildingid
rename year start
tempfile address_data
save `address_data'
foreach X in tax_id cityid streetid buildingid{
	rename `X' `X'_peer
}
tempfile peer_address_data
save `peer_address_data'

if "`sameind'"=="sameind"{
	use "`in'/2d_industry.dta", clear
	keep tax_id teaor03_2d
	duplicates drop
	tempfile industry
	save `industry'
}
*use Documents/data/firm_pairs.dta, clear

if "`which_rovat'"=="all_rovat"{
	local rovat_name ""
}
else if "`which_rovat'"=="rovat_13"{
	local rovat_name "_13"
}
else if "`which_rovat'"=="sign_own"{
	local rovat_name "_from_sign_to_own"
}
use "`in'/directed_firm_pairs`rovat_name'.dta", clear

if "`sameind'"=="sameind"{
	merge m:1 tax_id using  `industry'
	keep if _merge==3
	drop _merge
	tempfile all_pairs
	save `all_pairs'
	use `industry', clear
	rename * *_peer
	save `industry', replace
	merge 1:m tax_id_peer using  `all_pairs'
	keep if _merge==3
	drop _merge
	keep if teaor03_2d==teaor03_2d_peer & teaor03_2d!=.
	sum
	drop teaor*
	save `all_pairs', replace
}
else{
	tempfile all_pairs
	save `all_pairs'
}

* exclude pairs where address data is known to be the same in the start year of the pair
merge m:1 tax_id start using `address_data'
drop if _merge==2
drop _merge
merge m:1 tax_id_peer start using `peer_address_data'
drop if _merge==2
drop _merge
* exclude pairs living on the same address in the start year of the pair
drop if cityid==cityid_peer & streetid==streetid_peer & buildingid==buildingid_peer & cityid!=. & streetid!=. & buildingid!=.
keep tax_id_peer tax_id start end start1 start2 end_peer end_peer1 end_peer2 max_end_peer

if "`no_exclusion'"==""{

	* exclude pairs having the same owner or owning one another EVER
	merge 1:m tax_id tax_id_peer using `owner_link'
	drop if _merge==2
	sum
	egen dropvar=max(_merge), by(tax_id tax_id_peer)
	tab dropvar, missing
	drop if dropvar==3
	drop _merge year dropvar

}	
	
if "`success'"!="success" & "`heterog'"!="_numyears"{
	merge m:1 tax_id_peer using ``peer_expimp'pstats'
	* keep only those firms where export data is available for the peer
	keep if _merge==3
	drop _merge
}
else if "`heterog'"=="_numyears"{
	save `all_pairs', replace

	use `all_pairs', clear
	merge m:1 tax_id_peer using `tradestats'
	* keep only those firms where export data is available for the peer
	keep if _merge==3
	drop _merge
	save `all_pairs', replace

	* assign yearly length of experience stats to peers
	use `all_pairs', clear
	keep tax_id_peer
	duplicates drop
	expand 13
	egen year=seq(), by(tax_id_peer)
	replace year=year+1990
	rename tax_id_peer tax_id
	* keep only those years where the firm existed according to the frame
	merge m:1 tax_id using "`in'/`peer_expimp'porter_panel.dta"
	drop if _merge==2
	drop _merge
	rename tax_id tax_id_peer
	keep if firstyear<=year & lastyear>=year
	merge 1:1 tax_id_peer year using ``peer_expimp'pstats'
	drop if _merge==2
	drop _merge first* last*
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
	save ``peer_expimp'pstats', replace
	*tax_id_peer year numyears_imp?? strictnumyears_imp??

	use `all_pairs', clear
}
* keep only those pairs which have a valid start date between 1945 and 2003
keep if start>1945
keep if start<=2003
tab start
drop if end<start
drop if end>2011 & end!=2222
drop if end_peer>2011 & end_peer!=2222
if "`success'"=="success"{
	gen first=max(start,1992)
	gen last=min(2003,end)
	drop if first>last
	gen length=last-first+1
	expand length
	egen year=seq(), by(tax_id tax_id_peer)
	replace year=year+first-1
	drop first last length
	merge m:1 tax_id_peer year using ``peer_expimp'pstats'
	* keep only those firms where export data is available for the peer
	keep if _merge==3
	drop _merge
}

* give statistics of neighbors by year
save `all_pairs', replace
* number of neighbors
if "`success'"!="success" & "`heterog'"!="_numyears"{
	foreach X of numlist 1992/2003{
		gen byte N_neighbor`X'=start<=`X' & end>=`X'
	}
	collapse (sum) N_neighbor*, by(tax_id)
	reshape long N_neighbor, i(tax_id) j(year)
	if "`heterog'"=="_rauch" | "`heterog'"=="_bec"{
		drop N_neighbor
	}
	tempfile firm_neighborstats
	save `firm_neighborstats'
}
else if "`success'"=="success"{	
	gen byte N_neighbor=start<=year & end>=year
}

* number of neighbors exporting to the given direction
foreach Y in CZ RO SK RU{
	if "`success'"!="success" & "`heterog'"!="_rauch" & "`heterog'"!="_bec" & "`heterog'"!="_numyears"{
		use `all_pairs', clear
		foreach X of numlist 1992/2003{
			gen byte `peer_expimp'porter_`Y'_neighbor`X'=start<=`X' & end>=`X' & first_time_to_destination`Y'<=`X' & first_time_to_destination`Y'<=end_peer 
		}
		if "`heterog'"=="_heterog"{
			merge m:1 tax_id_peer using `firmchar'
			keep if _merge==3
			drop _merge
			foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
				foreach X of numlist 1992/2003{
					replace `C'`X' = `C'`X'*`peer_expimp'porter_`Y'_neighbor`X'
					rename `C'`X' `C'`peer_expimp'porter_`Y'_neighbor`X'
				}
			}
			drop `peer_expimp'porter*
			collapse (sum) *`peer_expimp'porter_*, by(tax_id)
			reshape long indAC`peer_expimp'porter_`Y'_neighbor indD`peer_expimp'porter_`Y'_neighbor indEF`peer_expimp'porter_`Y'_neighbor indG`peer_expimp'porter_`Y'_neighbor indHI`peer_expimp'porter_`Y'_neighbor indJK`peer_expimp'porter_`Y'_neighbor indLQ`peer_expimp'porter_`Y'_neighbor fo2`peer_expimp'porter_`Y'_neighbor do2`peer_expimp'porter_`Y'_neighbor size1`peer_expimp'porter_`Y'_neighbor size2`peer_expimp'porter_`Y'_neighbor size3`peer_expimp'porter_`Y'_neighbor size4`peer_expimp'porter_`Y'_neighbor, i(tax_id) j(year)
		}
		else if "`heterog'"=="_prod"{
			merge m:1 tax_id_peer using `firmchar'
			keep if _merge==3
			drop _merge
			foreach C in 1 2 3 4{
				foreach X of numlist 1992/2003{
					replace prod_quartile_y_robust`C'`X' = prod_quartile_y_robust`C'`X'*`peer_expimp'porter_`Y'_neighbor`X'
					rename prod_quartile_y_robust`C'`X' prob`C'`peer_expimp'porter_`Y'_neighbor`X'
				}
			}
			drop `peer_expimp'porter*
			collapse (sum) *`peer_expimp'porter_*, by(tax_id)
			
			local varlist ""
			foreach NUM in 1 2 3 4{
				local varlist "`varlist' prob`NUM'`peer_expimp'porter_`Y'_neighbor"
			}
			reshape long `varlist', i(tax_id) j(year)
		}
		else if "`heterog'"==""{
			collapse (sum) `peer_expimp'porter_*, by(tax_id)
			reshape long `peer_expimp'porter_`Y'_neighbor, i(tax_id) j(year)
		}
		merge 1:1 tax_id year using `firm_neighborstats'
		drop _merge
		save `firm_neighborstats', replace
		
		* number of neighbors being owned from the givn country
		
		if "`heterog'"==""{
			use `all_pairs', clear
			foreach X of numlist 1992/2003{
				gen byte owner_`Y'_neighbor`X'=start<=`X' & end>=`X' & first_owned_from_country`Y'<=`X' & first_owned_from_country`Y'<=end_peer 
			}
			collapse (sum) owner_*, by(tax_id)
			reshape long owner_`Y'_neighbor, i(tax_id) j(year)
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
			save `firm_neighborstats', replace
		}
	}
	else if "`heterog'"=="_rauch"{
		foreach Z in r w n{
			use `all_pairs', clear
			foreach X of numlist 1992/2003{
				gen byte `peer_expimp'porter_`Y'`Z'_neighbor`X'=start<=`X' & end>=`X' & first_time_to_destination`Y'`Z'<=`X' & first_time_to_destination`Y'`Z'<=end_peer 
			}
			collapse (sum) `peer_expimp'porter_*, by(tax_id)
			reshape long `peer_expimp'porter_`Y'`Z'_neighbor, i(tax_id) j(year)
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
			save `firm_neighborstats', replace
		}
	}
	else if "`heterog'"=="_bec"{
		foreach Z in 1_6 2_3 41_51_52 42_53{
			use `all_pairs', clear
			foreach X of numlist 1992/2003{
				gen byte `peer_expimp'porter_`Y'`Z'_neighbor`X'=start<=`X' & end>=`X' & minyear`Y'`Z'<=`X' & minyear`Y'`Z'<=end_peer 
			}
			collapse (sum) `peer_expimp'porter_*, by(tax_id)
			reshape long `peer_expimp'porter_`Y'`Z'_neighbor, i(tax_id) j(year)
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
			save `firm_neighborstats', replace
		}
	}
	else if "`success'"=="success"{
		gen byte `peer_expimp'porter_`Y'_neighbor=start<=year & end>=year & `peer_expimp'porter_s`Y'==1 & year<=end_peer 
		gen byte owner_`Y'_neighbor=start<=year & end>=year & owner_s`Y'<=year & year<=end_peer 	
	}
}
if "`success'"=="success"{
	collapse (sum) N_neighbor `peer_expimp'porter_??_neighbor owner_??_neighbor, by(tax_id year)
	tempfile firm_neighborstats
	save `firm_neighborstats'
}
if "`heterog'"=="_numyears"{
	* neighbors with the maximum number of years exporting to the given direction
	tempfile firm_neighborstats
	tempfile helpdata
	foreach Y in CZ SK RO RU{
		foreach X of numlist 1992/2003{
			use `all_pairs', clear 
			keep if start<=`X' & end>=`X' & first_time_to_destination`Y'<=end_peer 
			gen year=`X'
			merge m:1 tax_id_peer year using ``peer_expimp'pstats'
			keep if _merge==3
			collapse (max) *numyears_`peer_expimp'p`Y', by(tax_id year)
			if "`X'"!="1992"{
				append using `helpdata'
			}
			save `helpdata', replace
		}
		if "`Y'"!="CZ"{
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
		}
		save `firm_neighborstats', replace
	}
}
if "`success'"!="success"{
	* assign exporter and owner info to each firm
	merge m:1 tax_id using "`in'/`peer_expimp'porter_panel.dta"
	drop if _merge==1
	drop _merge
	* keep only those years where the firm existed according to the frame
	keep if firstyear<=year & lastyear>=year
}
else if "`success'"=="success"{
	use ``peer_expimp'pstats'
	rename tax_id_peer tax_id
	merge 1:1 tax_id year using `firm_neighborstats'
	drop if _merge==2
	drop _merge

}
if "`heterog'"=="" & "`success'"!="success"{
	* generate the panel version of exporter and owner statistics
	foreach X in CZ RO RU SK{
		gen byte `peer_expimp'porter_`X'=first_time_to_destination`X'<=year
		gen byte owner_`X'=first_owned_from_country`X'<=year
	}
}
else if "`heterog'"=="_heterog"{		
	* make missing neighbors zero
	foreach Y in CZ RO SK RU{
		foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			replace `C'`peer_expimp'porter_`Y'_neighbor=0 if `C'`peer_expimp'porter_`Y'_neighbor==.
		}
	}
}
else if "`heterog'"=="_prod"{	
	* make missing neighbors zero
	foreach Y in CZ RO SK RU{
		foreach D in 1 2 3 4{
			replace prob`D'`peer_expimp'porter_`Y'_neighbor=0 if prob`D'`peer_expimp'porter_`Y'_neighbor==.
		}
	}
}
* keep only firms in Budapest
save `all_pairs', replace
use `address_data', clear
keep tax_id start cityid 
rename start year
save `address_data', replace
use `all_pairs', clear
merge 1:1 tax_id year using `address_data'
drop if _merge==2
drop _merge
keep if cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139


cap drop first* last* 
cap drop cityid

save "`out'/db_`peer_expimp'_person_neighborstat_`which_rovat'_budapest_no_ownership_link_strict`sameind'`success'`heterog'`no_exclusion'.dta"

