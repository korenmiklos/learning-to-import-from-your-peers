/* 
Creates a firm-year panel with indicators for having ownership-connected peers with CZ, SK, RO or RU-specific import, export or ownership experience in the previous year
	- ownership-connected defined as
		- one firm owning the other
		- firms having a common person or firm as an ultimate owner
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
	time_variant_prod_quartiles.dta
Outputs:
	db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
	db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_rauch.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_numyears.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta
*/



clear
set more off

local in "../$in"
local out "../$in"

local peer_expimp "$peer_expimp"
local sameind "$sameind"
local success "$success"
local heterog "$heterog"

assert "`sameind'"!="sameind" | "`success'"!="success"
assert "`success'"=="" | "`heterog'"==""
assert "`sameind'"=="" | "`heterog'"==""

if "`heterog'"=="_heterog"{
	
	* firm characteristics

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

if "`heterog'"=="_prod"{
		
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

use "`in'/firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta", clear
append using "`in'/firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta"
append using "`in'/firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta"

duplicates drop
rename neighbor_tax_id tax_id_peer
drop if tax_id==tax_id_peer
collapse (min) start=year (max) end=year, by(tax_id tax_id_peer)
tempfile all_pairs
save `all_pairs'
*tax_id tax_id_peer start end

if "`sameind'"=="sameind"{
	use "`in'/2d_industry.dta", clear
	keep tax_id teaor03_2d
	duplicates drop
	tempfile industry
	save `industry'
	merge 1:m tax_id using  `all_pairs'
	keep if _merge==3
	drop _merge
	save `all_pairs', replace
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

* keep only firms in Budapest
use "`in'/address_data", clear
keep tax_id year cityid 
tempfile address_data
save `address_data'

* merge export data to the peers
if "`heterog'"!="_rauch" & "`heterog'"!="_bec" & "`heterog'"!="_numyears" & "`success'"!="success"{
	use "`in'/`peer_expimp'porter_panel.dta"
	drop  firstyear lastyear
}
else if "`heterog'"=="_rauch"{
	use "`in'/`peer_expimp'porter_panel_rauch.dta"
}
else if "`heterog'"=="_bec"{
	use "`in'/`peer_expimp'porter_panel_bec.dta"
}
else if "`heterog'"=="_numyears"{
	use "`in'/`peer_expimp'porter_panel_yearly.dta", clear
}
else if "`success'"=="success"{
	use "`in'/`peer_expimp'porter_panel.dta", clear
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
}
rename tax_id tax_id_peer
if "`heterog'"=="_numyears"{
	* count the number of years a peer imported (including t)
	xtset tax_id_peer year
	rename `peer_expimp'porter_* peer_`peer_expimp'porter_*
}
tempfile `peer_expimp'pstats
save ``peer_expimp'pstats'
*tax_id_peer first_owned_from_country?? first_time_to_destination??


if "`success'"=="success"{
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

if "`heterog'"=="_numyears"{
	use "`in'/`peer_expimp'porter_panel.dta"
	rename tax_id tax_id_peer
	keep tax_id_peer
	tempfile tradestats
	save `tradestats'
}

use `all_pairs', clear
if "`success'"=="success"{
	gen length=end-start+1
	expand length
	egen year=seq(), by(tax_id tax_id_peer)
	replace year=year+start-1
	drop start end length
	drop if year>2003
	merge m:1 tax_id_peer year using ``peer_expimp'pstats'
}
if "`heterog'"!="_numyears" & "`success'"!="success"{
	merge m:1 tax_id_peer using ``peer_expimp'pstats'
}
else if "`heterog'"=="_numyears"{
	merge m:1 tax_id_peer using `tradestats'
}
* keep only those firms where export data is available for the peer
keep if _merge==3
drop _merge
* give statistics of neighbors by year
save `all_pairs', replace
*tax_id tax_id_peer start end first_owned_from_country?? first_time_to_destination??
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
}
else if "`success'"=="success"{
	collapse (count) N_neighbor=tax_id_peer (sum) `peer_expimp'porter* owner*, by(tax_id year)
	rename `peer_expimp'porter* `peer_expimp'porter*_neighbor
	rename owner* owner*_neighbor
}
if "`heterog'"!="_numyears"{
	tempfile firm_neighborstats
	save `firm_neighborstats'
}
else if "`heterog'"=="_numyears"{
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
}
*tax_id year N_neighbor
* number of neighbors exporting to the given direction
foreach Y in CZ RO SK RU{
	if "`heterog'"!="_rauch" & "`heterog'"!="_bec" & "`heterog'"!="_numyears" & "`success'"!="success"{
		use `all_pairs', clear
		foreach X of numlist 1992/2003{
			gen byte `peer_expimp'porter_`Y'_neighbor`X'=start<=`X' & end>=`X' & first_time_to_destination`Y'<=`X'
		}
	}
	if "`heterog'"=="_heterog"{
		drop first* start end
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
	else if "`heterog'"=="" & "`success'"!="success"{
		collapse (sum) `peer_expimp'porter_*, by(tax_id)
		reshape long `peer_expimp'porter_`Y'_neighbor, i(tax_id) j(year)
	}
	if "`heterog'"=="_prod"{
		drop first* start end
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
	if "`heterog'"!="_rauch" & "`heterog'"!="_bec" & "`heterog'"!="_numyears" & "`success'"!="success"{
		merge 1:1 tax_id year using `firm_neighborstats'
		drop _merge
		save `firm_neighborstats', replace
		*tax_id year exporter_??_neighbor N_neighbor
	}
	else if "`heterog'"=="_rauch"{
		foreach Z in r n w{
			use `all_pairs', clear
			foreach X of numlist 1992/2003{
				gen byte `peer_expimp'porter_`Y'`Z'_neighbor`X'=start<=`X' & end>=`X' & first_time_to_destination`Y'`Z'<=`X'
			}
			collapse (sum) `peer_expimp'porter_*, by(tax_id)
			reshape long `peer_expimp'porter_`Y'`Z'_neighbor, i(tax_id) j(year)
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
			save `firm_neighborstats', replace
		*tax_id year exporter_??_neighbor N_neighbor
		}
	}
	else if "`heterog'"=="_bec"{
		foreach Z in 1_6 2_3 41_51_52 42_53{
			use `all_pairs', clear
			foreach X of numlist 1992/2003{
				gen byte `peer_expimp'porter_`Y'`Z'_neighbor`X'=start<=`X' & end>=`X' & minyear`Y'`Z'<=`X'
			}
			collapse (sum) `peer_expimp'porter_*, by(tax_id)
			reshape long `peer_expimp'porter_`Y'`Z'_neighbor, i(tax_id) j(year)
			merge 1:1 tax_id year using `firm_neighborstats'
			drop _merge
			save `firm_neighborstats', replace
		*tax_id year exporter_??_neighbor N_neighbor
		}
	}
}
if "`heterog'"=="" & "`success'"!="success"{
	foreach Y in CZ RO SK RU{
		use `all_pairs', clear
		foreach X of numlist 1992/2003{
			gen byte owner_`Y'_neighbor`X'=start<=`X' & end>=`X' & first_owned_from_country`Y'<=`X'
		}
		collapse (sum) owner_*, by(tax_id)
		reshape long owner_`Y'_neighbor, i(tax_id) j(year)
		merge 1:1 tax_id year using `firm_neighborstats'
		drop _merge
		save `firm_neighborstats', replace
		*tax_id year owner_??_neighbor exporter_??_neighbor N_neighbor 
	}
}
if "`heterog'"=="_numyears"{
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

	* neighbors with the maximum number of years exporting to the given direction
	tempfile firm_neighborstats
	foreach X of numlist 1992/2003{
		use `all_pairs', clear 
		keep if start<=`X' & end>=`X'
		gen year=`X'
		merge m:1 tax_id_peer year using ``peer_expimp'pstats'
		keep if _merge==3
		collapse (max) *numyears*, by(tax_id year)
		if "`X'"!="1992"{
			append using `firm_neighborstats'
		}
		save `firm_neighborstats', replace
	}
}
if "`success'"!="success" {
	* assign exporter and owner info to each firm
	merge m:1 tax_id using "`in'/`peer_expimp'porter_panel.dta"
	drop if _merge==1
	drop _merge
	* keep only those years where the firm existed according to the frame
	keep if firstyear<=year & lastyear>=year
	if "`heterog'"=="_rauch" | "`heterog'"=="_bec" | "`heterog'"=="_numyears"{
		drop first* last*
	}
	else if "`heterog'"=="" {
		foreach X in CZ RO RU SK{
			gen byte `peer_expimp'porter_`X'=first_time_to_destination`X'<=year
			gen byte owner_`X'=first_owned_from_country`X'<=year
		}
	}
	else if "`heterog'"=="_heterog"{
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
}
else if "`success'"=="success"{
		
	* assign exporter and owner info to each firm
	use ``peer_expimp'pstats', clear
	rename tax_id_peer tax_id
	merge 1:1 tax_id year using `firm_neighborstats'
	drop if _merge==2
	drop _merge

}
* keep only firms in Budapest
merge 1:1 tax_id year using `address_data'
drop if _merge==2
drop _merge
keep if cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139

save "`out'/db_`peer_expimp'_owner_neighborstat_budapest_no_ownership_link_strict`success'`sameind'`heterog'.dta"


