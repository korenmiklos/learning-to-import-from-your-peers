/* 
Creates the full database with indicators for different types of peers having country-specific experience and additional datasets with the number of experienced peers
	- versions:
		- experienced peer indicators or the number of experienced peers with versions:
			- any peers with country-sepcific import, export or ownership experience
				- with baseline definition of person-connected peers (having signing right in both firm and peer)	
				- inlcuding separate indicators for same-industry experienced peers and peers with successful experience
					- successful import experience in year t defined as importing at least twice in the 3-year period of [t-1,t+1]
			- country-specific import experience by bec product category
			- country-specific import experience by peer type based on size, ownership and industry
			- country-specific import experience by peer type based on productivity
		- experienced peer indicators
			- any peers with country-sepcific import, export or ownership experience with sub-versions:
				- person-connected peers defined using all connection types (owner, supervisor, having signing right)
				- person-connected peers defined as being an owner in the firm and having (had) signing right in the peer
			- country-specific import experience by Rauch product category
			- with spatial and person-connected peers (having signing right in both firm and peer), not excluding ownership-connected peers from these two peer groups
		- the number of experienced peers 
			- in the same industry and having country-specific import experience
			- having successful country-specific import experience
		- the maximum length of peer experience
Inputs:
	db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta
	db_ex_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
	db_ex_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
	db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
	db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta
	db_ex_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
	db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_numyears.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strict_rauch.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta
	db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_numyears.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strict_rauch.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta
	db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta
	db_im_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_numyears.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_rauch.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta
	db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta
	db_im_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
	exporter_panel.dta
	exporter_panel_yearly.dta
	importer_panel.dta
	importer_panel_yearly.dta
	owner_panel_yearly.dta	
Outputs:
	db_complete_additional_rauch_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by Rauch product category)
	db_complete_for_running_the_regs_baseline_torun.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (had signing right in peer and owner in firm) and owner-connected peer group)
	db_complete_for_running_the_regs_baseline_torun_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately for same-industry and successful experience)
	db_complete_for_running_the_regs_bec_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by BEC product category)
	db_complete_for_running_the_regs_heterog_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by ownership, size and industry)
	db_complete_for_running_the_regs_no_exclusion_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo and person-connected (with signing right) peer group, not regarding ownership links between firms)
	db_complete_for_running_the_regs_numyears_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and the length of experience which experienced peers in geo, person- (with signing right) and owner-connected peer group have, baseline and strict definition)
	db_complete_for_running_the_regs_prod_robust_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by productivity)
	db_numneighbors_bec_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by BEC product category)
	db_numneighbors_heterog_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by ownership, size and industry)
	db_numneighbors_prod_robust_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by productivity)
	db_numneighbors_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience)
	db_numneighbors_sameind_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific same-industry import, export or ownership experience)
	db_numneighbors_success_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific successful import, export or ownership experience)
	person_neighbors_all_rovat_toadd.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers person-connected (any connection) peer group)
*/

clear
set more off

*local which_rovat rovat_13
*local which_rovat sign_own
*local which_rovat all_rovat
*local heterog ""
*local heterog _heterog
*local heterog _bec
*local heterog _prod
*local heterog _rauch
*local heterog _numyears
*local no_exclusion ""
*local no_exclusion no_exclusion

*cd "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data"

*local in ../data/reprod_2018
*local out ../data/reprod_2018

local which_rovat "$which_rovat"
local heterog "$heterog"
local no_exclusion "$no_exclusion"

local in "$in"
local out "$in"

assert "`no_exclusion'"=="" | "`heterog'"==""
assert "`no_exclusion'"=="" | "`which_rovat'"=="rovat_13"
assert "`heterog'"=="" | "`which_rovat'"=="rovat_13"
	


if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
	
	* get spatial peers with import experience

	use "`in'/db_im_geo_neighborstat_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
	cap drop *neighbor_3 *neighbor_4
	if "`heterog'"=="_numyears"{
		drop *neighbor_3_?? *neighbor_4_??
	}
	tempfile alldata
	save `alldata'
		*tax_id year cityid streetid buildingid importer_?? owner_?? 
		*importer_??_neighbor_? importer_??_samebuilding 
		*owner_??_neighbor_? owner_??_samebuilding 
		*N_neighbor_? N_samebuilding

}

* get person-connected peers with import experience	
	
use "`in'/db_im_person_neighborstat_`which_rovat'_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
if "`heterog'"=="_heterog"{
	foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
		rename `C'*neighbor `C'p*neighbor
	}
	drop N_neighbor 
}
else if "`heterog'"=="_prod"{
	foreach C in prob1 prob2 prob3 prob4{
		rename `C'*neighbor `C'p*neighbor
	}
	drop N_neighbor 
}
else if "`heterog'"=="_numyears"{
	foreach C in numyears_ strictnumyears_{
		rename `C'imp?? `C'pimp??
	}
	cap drop N_neighbor cityid
}
else{
	rename *neighbor p*neighbor
}
cap drop importer* owner*
if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
	merge 1:1 tax_id year using `alldata', update
	if "`heterog'"=="" | "`heterog'"=="_bec" | "`heterog'"=="_rauch"{
		drop if _merge==1
	}
	drop _merge
}
else if "`which_rovat'"=="all_rovat"{
	tempfile alldata
}
save `alldata', replace
	*tax_id year cityid streetid buildingid importer_?? owner_??
	*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor
	*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor
	*N_neighbor_? N_samebuilding pN_neighbor
	
* get ownership-connected peers with import experience	
	
if ("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own"{
	use "`in'/db_im_owner_neighborstat_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
	if "`heterog'"=="_heterog"{
		foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			rename `C'*neighbor `C'o*neighbor
		}
	}
	else if "`heterog'"=="_prod"{
		foreach C in prob1 prob2 prob3 prob4 {
			rename `C'*neighbor `C'o*neighbor
		}
	}
	else if "`heterog'"=="_numyears"{
		foreach C in numyears_ strictnumyears_{
			rename `C'imp?? `C'oimp??
		}
		cap drop N_neighbor cityid
	}
	else{
		rename *neighbor o*neighbor
	}
	cap drop cityid
	cap drop first* lastyear
	cap drop importer* owner*

	*tax_id - year obs: oowner_??_neighbor, oimporter_??_neighbor, oN_neighbor, importer_??, owner_?? (212,863 for successful)
	merge 1:1 tax_id year using `alldata', update
	if "`heterog'"!="_heterog" & "`heterog'"!="_prod" {
		drop if _merge==1
	}
	drop _merge
	if "`heterog'"=="_heterog" | "`heterog'"=="_prod" {
		drop importer_?? owner_??  
		cap drop N_*
	}
	if "`heterog'"=="_bec" | "`heterog'"=="_heterog" | "`heterog'"=="_prod" | "`heterog'"=="_rauch" | "`heterog'"=="_numyears"{
		cap drop cityid streetid buildingid
	}
	save `alldata', replace
		*tax_id year cityid streetid buildingid importer_?? owner_??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
}
		
* peers with export experience: only for baseline (all types of person connection) and no_exclusion
	
if "`heterog'"=="" {

	* get spatial peers with export experience
	
	if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
		use "`in'/db_ex_geo_neighborstat_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
		drop *neighbor_3 *neighbor_4
		keep tax_id year exporter_*
		merge 1:1 tax_id year using `alldata', update
		drop _merge
		save `alldata', replace
			*tax_id year cityid streetid buildingid importer_?? exporter_?? owner_?? 
			*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
			*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
			*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
			*exporter_??_neighbor_? exporter_??_samebuilding
	}

	* get person-connected peers with export experience
	
	use "`in'/db_ex_person_neighborstat_`which_rovat'_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
	drop owner* 
	cap drop N_neighbor
	cap drop firs* lastyear 
	rename *neighbor p*neighbor
	drop exporter* 
	*tax_id - year obs: powner_??_neighbor, pexporter_??_neighbor, pN_neighbor, exporter_??, owner_??
	merge 1:1 tax_id year using `alldata', update
	drop if _merge==1
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid importer_?? exporter_?? owner_?? 
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor

	* get ownership-connected peers with export experience
	
	if ("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own"{
		use "`in'/db_ex_owner_neighborstat_budapest_no_ownership_link_strict`heterog'`no_exclusion'.dta", clear
		drop owner*
		cap drop N_neighbor
		rename *neighbor o*neighbor
		drop first* last
		cap drop cityid
		drop exporter_??
		*tax_id - year obs: oowner_??_neighbor, oexporter_??_neighbor, oN_neighbor, exporter_??, owner_??
		merge 1:1 tax_id year using `alldata', update
		drop if _merge==1
		drop _merge
		tempfile alldata
		save `alldata'
			*tax_id year cityid streetid buildingid importer_?? exporter_?? owner_?? 
			*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
			*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
			*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
			*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
	}
}

* dummies to 0 from missing

if "`no_exclusion'"==""{
	if "`heterog'"=="_heterog"{
		foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			foreach X in CZ SK RO RU{
				foreach Y in p o{
					replace `C'`Y'importer_`X'_neighbor=0 if `C'`Y'importer_`X'_neighbor==.
				}
				foreach Y in neighbor_1 neighbor_2 samebuilding{
					replace `C'importer_`X'_`Y'=0 if `C'importer_`X'_`Y'==.
				}
			}
		}
	}
	else if "`heterog'"=="_prod"{
		foreach C in prob1 prob2 prob3 prob4{
			foreach X in CZ SK RO RU{
				foreach Y in p o{
					replace `C'`Y'importer_`X'_neighbor=0 if `C'`Y'importer_`X'_neighbor==.
				}
				foreach Y in neighbor_1 neighbor_2 samebuilding{
					replace `C'importer_`X'_`Y'=0 if `C'importer_`X'_`Y'==.
				}
			}
		}
	}
	else if "`heterog'"=="_bec"{
		foreach C in 1_6 2_3 41_51_52 42_53{
			foreach X in CZ SK RO RU{
				foreach Y in p o{
					replace `Y'importer_`X'`C'_neighbor=0 if `Y'importer_`X'`C'_neighbor==.
				}
				foreach Y in neighbor_1 neighbor_2 samebuilding{
					replace importer_`X'`C'_`Y'=0 if importer_`X'`C'_`Y'==.
				}
			}
		}
	}
	else if "`heterog'"=="_rauch"{
		foreach C in r w n{
			foreach X in CZ SK RO RU{
				foreach Y in p o{
					replace `Y'importer_`X'`C'_neighbor=0 if `Y'importer_`X'`C'_neighbor==.
				}
				foreach Y in neighbor_1 neighbor_2 samebuilding{
					replace importer_`X'`C'_`Y'=0 if importer_`X'`C'_`Y'==.
				}
				replace importer_`X'`C'=0 if importer_`X'`C'==.
			}
		}
	}
	
	else if "`heterog'"=="_numyears"{
		rename numyears_?imp?? numy_?imp_??
		rename strictnumyears_?imp?? snumy_?imp_??
		foreach C in numy snumy{
			foreach X in CZ SK RO RU{
				foreach Y in neighbor_1 neighbor_2 samebuilding pimp oimp{
					replace `C'_`Y'_`X'=0 if `C'_`Y'_`X'==.
				}
			}
		}
	}
	else{
		if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
		
			foreach Y in p o{
				foreach X in CZ SK RO RU{
					foreach Z in exporter importer owner{
						replace `Y'`Z'_`X'_neighbor=0 if `Y'`Z'_`X'_neighbor==.
					}
				}
				replace `Y'N_neighbor=0 if `Y'N_neighbor==.
			}
		}
		else if "`which_rovat'"=="all_rovat"{
			foreach Y in p{
				foreach X in CZ SK RO RU{
					foreach Z in exporter importer owner{
						replace `Y'`Z'_`X'_neighbor=0 if `Y'`Z'_`X'_neighbor==.
					}
				}
				replace `Y'N_neighbor=0 if `Y'N_neighbor==.
			}
		}
	}

	save `alldata', replace

	* assign true yearly exports 
	if "`heterog'"=="" & ("`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own") & "`no_exclusion'"==""{

		merge 1:1 tax_id year using "`in'/exporter_panel_yearly.dta"
		drop if _merge==2
		drop _merge
		foreach X in CZ RO RU SK {
			replace exporter_yearly`X'=0 if exporter_yearly`X'==.
		}

		* assign true yearly imports 
		merge 1:1 tax_id year using "`in'/importer_panel_yearly.dta"
		drop if _merge==2
		drop _merge
		foreach X in CZ RO RU SK {
			replace importer_yearly`X'=0 if importer_yearly`X'==.
		}


		save `alldata', replace

		* assign true yearly ownership

		use "`in'/owner_panel_yearly.dta", clear
		rename owner_* owner_yearly*
		tempfile tomerge
		save `tomerge'
		use `alldata', clear
		merge 1:1 tax_id year using `tomerge', update
		drop if _merge==2
		drop _merge
		foreach X in CZ RO RU SK {
			replace owner_yearly`X'=0 if owner_yearly`X'==.
		}

		save `alldata', replace
			*tax_id year cityid streetid buildingid 
			*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly??
			*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
			*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
			*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
			*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
	}
}
else if "`no_exclusion'"=="no_exclusion"{
	foreach X in CZ SK RO RU{
		foreach Z in exporter importer owner{
			replace p`Z'_`X'_neighbor=0 if p`Z'_`X'_neighbor==.
		}
	}
	replace pN_neighbor=0 if pN_neighbor==.

	save `alldata', replace
}

* get successful and same-industry peers for the baseline version

if "`which_rovat'"=="rovat_13" & "`heterog'"=="" & "`no_exclusion'"==""{

	* get spatial peers with same-industry import experience
	use "`in'/db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta", clear
	keep tax_id year importer*
	drop importer_?? 
	drop *neighbor_3 *neighbor_4
	rename importer* si_importer*
	merge 1:1 tax_id year using `alldata', update
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding 
	
	* get person-connected peers with same-industry import experience
	use "`in'/db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta", clear
	keep tax_id year importer*neighbor
	rename importer* si_pimporter*
	merge 1:1 tax_id year using `alldata', update
	drop if _merge==1
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor 

	* get owner-connected peers with same-industry import experience
	use "`in'/db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta", clear
	keep tax_id year importer*neighbor
	rename importer* si_oimporter*
	merge 1:1 tax_id year using `alldata', update
	drop if _merge==1
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
		
	* get spatial peers with successful import experience
	use "`in'/db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta", clear
	keep tax_id year importer*
	drop *neighbor_3 *neighbor_4
	merge 1:1 tax_id year using `alldata', update
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly?? importer_s??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
		*importer_s??_neighbor_? importer_s??_samebuilding
	
	* get person-connected peers with same-industry import experience
	use "`in'/db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta", clear
	keep tax_id year importer*neighbor
	rename importer_* pimporter_s*
	merge 1:1 tax_id year using `alldata', update
	drop if _merge==1
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly?? importer_s??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
		*importer_s??_neighbor_? importer_s??_samebuilding pimporter_s??_neighbor
		
	* get owner-connected peers with same-industry import experience
	use "`in'/db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta", clear
	keep tax_id year importer*neighbor
	rename importer* oimporter*
	merge 1:1 tax_id year using `alldata', update
	drop if _merge==1
	drop _merge
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly?? importer_s??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
		*importer_s??_neighbor_? importer_s??_samebuilding pimporter_s??_neighbor oimporter_s??_neighbor

	* dummies to 0 from missing

	foreach Y in p o{
		foreach X in CZ SK RO RU{
			replace `Y'importer_s`X'_neighbor=0 if `Y'importer_s`X'_neighbor==.
			replace si_`Y'importer_`X'_neighbor=0 if si_`Y'importer_`X'_neighbor==.
		}
	}
	save `alldata', replace
}


* create data with the number of importer, exporter or owner neighbors

if "`which_rovat'"=="rovat_13" & "`heterog'"=="" & "`no_exclusion'"==""{
	foreach M in "" _sameind _success{
		use `alldata', clear
		if "`M'"==""{
			keep tax_id year ??porter_??_neighbor_? ??porter_??_samebuilding p??porter_??_neighbor o??porter_??_neighbor owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
			rename *_??_neighbor_1 numneighbor1_*_?? 
			rename *_??_neighbor_2 numneighbor2_*_?? 
			rename *_??_samebuilding numsamebuilding_*_?? 
			rename p*_??_neighbor numpneighbor_*_??
			rename o*_??_neighbor numoneighbor_*_?? 
			local tocollapse ""
			local list "importer exporter owner"
			local pre ""
		}
		else if "`M'"=="_success"{
			keep tax_id year importer_s??_neighbor_? importer_s??_samebuilding pimporter_s??_neighbor oimporter_s??_neighbor 	
			rename *_s??_neighbor_1 numsuneighbor1_*_?? 
			rename *_s??_neighbor_2 numsuneighbor2_*_?? 
			rename *_s??_samebuilding numsusamebuilding_*_?? 
			rename p*_s??_neighbor numsupneighbor_*_??
			rename o*_s??_neighbor numsuoneighbor_*_?? 
			local tocollapse ""
			local list importer
			local pre su
		}
		else if "`M'"=="_sameind"{
			keep tax_id year si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
			rename si_*_??_neighbor_1 numsineighbor1_*_?? 
			rename si_*_??_neighbor_2 numsineighbor2_*_?? 
			rename si_*_??_samebuilding numsisamebuilding_*_?? 
			rename si_p*_??_neighbor numsipneighbor_*_??
			rename si_o*_??_neighbor numsioneighbor_*_?? 
			local tocollapse ""
			local list importer
			local pre si
		}
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
			foreach Y in `list'{
				local tocollapse "`tocollapse' num`pre'`X'_`Y'_"
			}
		}
		reshape long "`tocollapse'" , i(tax_id year) j(country) string
		rename *_ *
		* panel structure to create lags
		egen groupid = group(tax_id country)
		tsset groupid year
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in `list' {
				gen num`pre'`X'_`Y'_l = L.num`pre'`X'_`Y'
			}
		}
		keep tax_id year country num*_l
		foreach Z in `list'{
			replace num`pre'pneighbor_`Z'_l=0 if num`pre'pneighbor_`Z'_l==. & num`pre'samebuilding_importer_l!=.
			replace num`pre'oneighbor_`Z'_l=0 if num`pre'oneighbor_`Z'_l==. & num`pre'samebuilding_importer_l!=.
		}
		save "`out'/db_numneighbors`M'_rovat_13.dta"
			*tax_id year country 
			*for "`M'"==""
				*numneighbor?_importer_l numsamebuilding_importer_l numpneighbor_importer_l numoneighbor_importer_l
				*numneighbor?_exporter_l numsamebuilding_exporter_l numpneighbor_exporter_l numoneighbor_exporter_l
				*numneighbor?_owner_l numsamebuilding_owner_l numpneighbor_owner_l numoneighbor_owner_l
			*for "`M'"=="_sameind"
				*numsineighbor?_importer_l numsisamebuilding_importer_l numsipneighbor_importer_l numsioneighbor_importer_l
			*for "`M'"=="_success"
				*numsuneighbor?_importer_l numsusamebuilding_importer_l numsupneighbor_importer_l numsuoneighbor_importer_l
	}
}


if "`heterog'"=="_bec" | "`heterog'"=="_heterog" | "`heterog'"=="_prod"{
	use `alldata', clear
	local VARLIST ""
	if "`heterog'"=="_bec"{
		foreach AA in 1_6 2_3 41_51_52 42_53{
			local VARLIST "`VARLIST' `AA'`BB'"
		}
		foreach W in `VARLIST'{
			foreach Z in CZ SK RO RU{
				foreach X in importer_`Z' {
					foreach Y in 1 2{
						rename `X'`W'_neighbor_`Y' nneighbor`Y'`W'`X' 
					}
					rename `X'`W'_samebuilding nsamebuilding`W'`X' 
					rename p`X'`W'_neighbor npneighbor`W'`X' 
					rename o`X'`W'_neighbor noneighbor`W'`X' 
				}
			}
		}
		local tocollapse ""
		foreach W in `VARLIST'{	
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
				foreach Y in importer {
					local tocollapse "`tocollapse' n`X'`W'`Y'_"
				}
			}
		}
	}
	else if "`heterog'"=="_heterog"{
		foreach AA in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			local VARLIST "`VARLIST' `AA'`BB'"
		}
		foreach W in `VARLIST'{
			foreach Z in CZ SK RO RU{
				foreach X in importer_`Z' {
					foreach Y in 1 2{
						rename `W'`X'_neighbor_`Y' `W'numneighbor`Y'`X' 
					}
					rename `W'`X'_samebuilding `W'numsamebuilding`X' 
					rename `W'p`X'_neighbor `W'numpneighbor`X' 
					rename `W'o`X'_neighbor `W'numoneighbor`X' 
				}
			}
		}
		local tocollapse ""
		foreach W in `VARLIST'{	
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
				foreach Y in importer {
					local tocollapse "`tocollapse' `W'num`X'`Y'_"
				}
			}
		}
	}
	else if "`heterog'"=="_prod"{
		foreach AA in prob1 prob2 prob3 prob4{
			local VARLIST "`VARLIST' `AA'`BB'"
		}
		foreach W in `VARLIST'{
			foreach Z in CZ SK RO RU{
				foreach X in importer_`Z' {
					foreach Y in 1 2{
						rename `W'`X'_neighbor_`Y' `W'numneighbor`Y'`X' 
					}
					rename `W'`X'_samebuilding `W'numsamebuilding`X' 
					rename `W'p`X'_neighbor `W'numpneighbor`X' 
					rename `W'o`X'_neighbor `W'numoneighbor`X' 
				}
			}
		}
		local tocollapse ""
		foreach W in `VARLIST'{	
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
				foreach Y in importer {
					local tocollapse "`tocollapse' `W'num`X'`Y'_"
				}
			}
		}
	}
	
	
	reshape long "`tocollapse'" , i(tax_id year) j(country) string
	rename *_ *
	* panel structure to create lags
	egen groupid = group(tax_id country)
	tsset groupid year
	if "`heterog'"=="_bec"{
		foreach W in `VARLIST'{	
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
				foreach Y in  importer {
					cap gen n`X'`W'`Y'_l = L.n`X'`W'`Y'
				}
			}
		}
		keep tax_id year country n*_l
	}
	else{
		foreach W in `VARLIST'{	
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
				foreach Y in  importer {
					cap gen `W'num`X'_`Y'_l = L.`W'num`X'`Y'
				}
			}
		}
		keep tax_id year country *num*_l
	}
	if "`heterog'"=="_bec" | "`heterog'"=="_heterog"{
		save "`out'/db_numneighbors`heterog'_rovat_13.dta"
	}
	else if "`heterog'"=="_prod"{
		save "`out'/db_numneighbors`heterog'_robust_rovat_13.dta"
	}
}

* add info on first year when imported from, exported to or was owned from

if ("`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own") & "`heterog'"==""{
	use `alldata', clear
	merge m:1 tax_id using "`in'/importer_panel.dta"
	drop if _merge==2
	drop _merge firstyear lastyear
	rename first_time_to_* first_time_from_*
	merge m:1 tax_id using "`in'/exporter_panel.dta", update
	drop if _merge==2
	drop _merge firstyear lastyear
	save `alldata', replace
		*tax_id year cityid streetid buildingid 
		*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly?? importer_s??
		*importer_??_neighbor_? importer_??_samebuilding pimporter_??_neighbor oimporter_??_neighbor 
		*owner_??_neighbor_? owner_??_samebuilding  powner_??_neighbor oowner_??_neighbor
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*exporter_??_neighbor_? exporter_??_samebuilding pexporter_??_neighbor oexporter_??_neighbor
		*si_importer_??_neighbor_? si_importer_??_samebuilding si_pimporter_??_neighbor si_oimporter_??_neighbor 
		*importer_s??_neighbor_? importer_s??_samebuilding pimporter_s??_neighbor oimporter_s??_neighbor
		*first_owned_from_country?? first_time_to_destination?? first_time_from_destination??
}

* Generate dummies being one if there is at least one exporter or owner to the given destination in the given neighborhood

if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
	use `alldata', clear
	if "`heterog'"==""{
		foreach Z in CZ SK RO RU{
			foreach X in exporter importer owner {
				foreach Y in 1 2{
					gen byte neighbor`Y'_dummy_`X'_`Z' = `X'_`Z'_neighbor_`Y'>0 & `X'_`Z'_neighbor_`Y'!=.
				}
				gen byte samebuilding_dummy_`X'_`Z' = `X'_`Z'_samebuilding>0 & `X'_`Z'_samebuilding!=.
				gen byte pneighbor_dummy_`X'_`Z' = p`X'_`Z'_neighbor>0 & p`X'_`Z'_neighbor!=.
				if "`no_exclusion'"==""{
					gen byte oneighbor_dummy_`X'_`Z' = o`X'_`Z'_neighbor>0 & o`X'_`Z'_neighbor!=.
				}
			}
		}
	}
	else if "`heterog'"=="_heterog"{
		foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
			foreach Z in CZ SK RO RU{
				foreach Y in 1 2{
					gen byte `C'neighbor`Y'_d_importer_`Z' = `C'importer_`Z'_neighbor_`Y'>0 & `C'importer_`Z'_neighbor_`Y'!=.
					tab `C'neighbor`Y'_d_importer_`Z'
				}
				gen byte `C'samebuilding_d_importer_`Z' = `C'importer_`Z'_samebuilding>0 & `C'importer_`Z'_samebuilding!=.
				tab `C'samebuilding_d_importer_`Z'
				gen byte `C'pneighbor_d_importer_`Z' = `C'pimporter_`Z'_neighbor>0 & `C'pimporter_`Z'_neighbor!=.
				tab `C'pneighbor_d_importer_`Z'
				gen byte `C'oneighbor_d_importer_`Z' = `C'oimporter_`Z'_neighbor>0 & `C'oimporter_`Z'_neighbor!=.
				tab `C'oneighbor_d_importer_`Z'
			}
		}
		drop *importer_??_neighbor_? *importer_??_samebuilding *pimporter_??_neighbor *oimporter_??_neighbor
	}
	else if "`heterog'"=="_prod"{
		foreach C in prob1 prob2 prob3 prob4{
			foreach Z in CZ SK RO RU{
				foreach Y in 1 2{
					gen byte `C'neighbor`Y'_d_importer_`Z' = `C'importer_`Z'_neighbor_`Y'>0 & `C'importer_`Z'_neighbor_`Y'!=.
					tab `C'neighbor`Y'_d_importer_`Z'
				}
				gen byte `C'samebuilding_d_importer_`Z' = `C'importer_`Z'_samebuilding>0 & `C'importer_`Z'_samebuilding!=.
				tab `C'samebuilding_d_importer_`Z'
				gen byte `C'pneighbor_d_importer_`Z' = `C'pimporter_`Z'_neighbor>0 & `C'pimporter_`Z'_neighbor!=.
				tab `C'pneighbor_d_importer_`Z'
				gen byte `C'oneighbor_d_importer_`Z' = `C'oimporter_`Z'_neighbor>0 & `C'oimporter_`Z'_neighbor!=.
				tab `C'oneighbor_d_importer_`Z'
			}
		}
		drop *importer_??_neighbor_? *importer_??_samebuilding *pimporter_??_neighbor *oimporter_??_neighbor
	}
	else if "`heterog'"=="_bec"{
		foreach C in 1_6 2_3 41_51_52 42_53{
			foreach Z in CZ SK RO RU{
				foreach Y in 1 2{
					gen byte neighbor`Y'_`C'importer_`Z' = importer_`Z'`C'_neighbor_`Y'>0 & importer_`Z'`C'_neighbor_`Y'!=.
					tab neighbor`Y'_`C'importer_`Z'
				}
				gen byte samebuilding_`C'importer_`Z' = importer_`Z'`C'_samebuilding>0 & importer_`Z'`C'_samebuilding!=.
				tab samebuilding_`C'importer_`Z'
				gen byte pneighbor_`C'importer_`Z' = pimporter_`Z'`C'_neighbor>0 & pimporter_`Z'`C'_neighbor!=.
				tab pneighbor_`C'importer_`Z'
				gen byte oneighbor_`C'importer_`Z' = oimporter_`Z'`C'_neighbor>0 & oimporter_`Z'`C'_neighbor!=.
				tab oneighbor_`C'importer_`Z'
			}
		}
		drop importer_*_neighbor_? importer_*_samebuilding pimporter_*_neighbor oimporter_*_neighbor
	}
	else if "`heterog'"=="_rauch"{
		foreach C in r w n{
			foreach Z in CZ SK RO RU{
				foreach Y in 1 2{
					gen byte neighbor`Y'_`C'importer_`Z' = importer_`Z'`C'_neighbor_`Y'>0 & importer_`Z'`C'_neighbor_`Y'!=.
					tab neighbor`Y'_`C'importer_`Z'
				}
				gen byte samebuilding_`C'importer_`Z' = importer_`Z'`C'_samebuilding>0 & importer_`Z'`C'_samebuilding!=.
				tab samebuilding_`C'importer_`Z'
				gen byte pneighbor_`C'importer_`Z' = pimporter_`Z'`C'_neighbor>0 & pimporter_`Z'`C'_neighbor!=.
				tab pneighbor_`C'importer_`Z'
				gen byte oneighbor_`C'importer_`Z' = oimporter_`Z'`C'_neighbor>0 & oimporter_`Z'`C'_neighbor!=.
				tab oneighbor_`C'importer_`Z'
			}
		}
		drop importer_*_neighbor_? importer_*_samebuilding pimporter_*_neighbor oimporter_*_neighbor
	}
}

else if "`which_rovat'"=="all_rovat"{
	foreach Z in CZ SK RO RU{
		foreach X in exporter importer owner {
			gen byte pneighbor_dummy_`X'_`Z' = p`X'_`Z'_neighbor>0 & p`X'_`Z'_neighbor!=.
		}
	}
}

if "`which_rovat'"=="rovat_13" & "`no_exclusion'"=="" & "`heterog'"==""{
	foreach M in si su{
		if "`M'"=="si"{
			local v1 si_
			local v2 ""
		}
		else if "`M'"=="su"{
			local v1 ""
			local v2 s
		}
		foreach Z in CZ SK RO RU{
			foreach X in importer{
				foreach Y in 1 2{
					gen byte `M'neighbor`Y'_dummy_`X'_`Z' = `v1'`X'_`v2'`Z'_neighbor_`Y'>0 & `v1'`X'_`v2'`Z'_neighbor_`Y'!=.
				}
				gen byte `M'samebuilding_dummy_`X'_`Z' = `v1'`X'_`v2'`Z'_samebuilding>0 & `v1'`X'_`v2'`Z'_samebuilding!=.
				gen byte `M'pneighbor_dummy_`X'_`Z' = `v1'p`X'_`v2'`Z'_neighbor>0 & `v1'p`X'_`v2'`Z'_neighbor!=.
				gen byte `M'oneighbor_dummy_`X'_`Z' = `v1'o`X'_`v2'`Z'_neighbor>0 & `v1'o`X'_`v2'`Z'_neighbor!=.
			}
		}
	}
}

cap drop *importer_??_* *exporter_??_* *owner_??_* 
cap drop *importer_s??_*
if "`heterog'"=="_bec"{
	drop importer_*
}
save `alldata', replace
	*tax_id year cityid streetid buildingid 
	*importer_?? exporter_?? owner_?? importer_yearly?? exporter_yearly?? owner_yearly?? importer_s??
	*neighbor?_dummy_importer_?? samebuilding_dummy_importer_?? pneighbor_dummy_importer_?? oneighbor_dummy_importer_??
	*neighbor?_dummy_owner_?? samebuilding_dummy_owner_?? pneighbor_dummy_owner_?? oneighbor_dummy_owner_??
	*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
	*neighbor?_dummy_exporter_?? samebuilding_dummy_exporter_?? pneighbor_dummy_exporter_?? oneighbor_dummy_exporter_??
	*sineighbor?_dummy_importer_?? sisamebuilding_dummy_importer_?? sipneighbor_dummy_importer_?? sioneighbor_dummy_importer_??
	*suneighbor?_dummy_importer_?? susamebuilding_dummy_importer_?? supneighbor_dummy_importer_?? suoneighbor_dummy_importer_??
	*first_owned_from_country?? first_time_to_destination?? first_time_from_destination??

* Generate firm-year-destination observations

local tocollapse ""
if (("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own") & "`heterog'"==""{
	foreach X in importer exporter owner{
		local tocollapse "`tocollapse' `X'_ `X'_yearly" 
		foreach Y in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			local tocollapse "`tocollapse' `Y'_dummy_`X'_"
		}
	}
	local tocollapse "`tocollapse' first_time_from_destination first_owned_from_country first_time_to_destination"
}
else if "`heterog'"=="_heterog"{
	foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
		foreach X in neighbor1_d_importer_ neighbor2_d_importer_ samebuilding_d_importer_ pneighbor_d_importer_ oneighbor_d_importer_{
			local tocollapse "`tocollapse' `C'`X'"
		}
	}
}
else if "`heterog'"=="_prod"{
	foreach C in prob1 prob2 prob3 prob4{
		foreach X in neighbor1_d_importer_ neighbor2_d_importer_ samebuilding_d_importer_ pneighbor_d_importer_ oneighbor_d_importer_{
			local tocollapse "`tocollapse' `C'`X'"
		}
	}
}

else if "`heterog'"=="_bec"{
	foreach C in 1_6 2_3 41_51_52 42_53{
		foreach X in neighbor1 neighbor2 samebuilding  pneighbor  oneighbor {
			local tocollapse "`tocollapse' `X'_`C'importer_"
		}
	}
}
else if "`heterog'"=="_rauch"{
	foreach C in r w n{
		rename importer_??`C' importer`C'_??
		local tocollapse "`tocollapse' importer`C'_"
		foreach X in neighbor1 neighbor2 samebuilding  pneighbor  oneighbor {
			local tocollapse "`tocollapse' `X'_`C'importer_"
		}
	}
}
else if "`heterog'"=="_numyears"{
	local tocollapse "`tocollapse' numyears_imp strictnumyears_imp"
	foreach C in numy snumy{
		foreach X in neighbor_1 neighbor_2 samebuilding oimp pimp {
			local tocollapse "`tocollapse' `C'_`X'_"
		}
	}
}
else if "`which_rovat'"=="all_rovat"{
	foreach X in importer exporter owner{
		local tocollapse "`tocollapse' pneighbor_dummy_`X'_"
	}
}
else if "`no_exclusion'"=="no_exclusion"{
	foreach X in importer exporter owner{
		local tocollapse "`tocollapse' `X'_ `X'_yearly" 
		foreach Y in neighbor1 neighbor2 samebuilding pneighbor{
			local tocollapse "`tocollapse' `Y'_dummy_`X'_"
		}
	}
	local tocollapse "`tocollapse' first_time_from_destination first_owned_from_country first_time_to_destination"
}
if "`which_rovat'"=="rovat_13" & "`no_exclusion'"=="" & "`heterog'"==""{
	local tocollapse "`tocollapse' importer_s"
	foreach X in si su{
		foreach Y in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			local tocollapse "`tocollapse' `X'`Y'_dummy_importer_"
		}
	}
}

reshape long `tocollapse', i(tax_id year) j(country) string

rename *_ *

if "`heterog'"==""{
	ren *_dummy_exporter *_exporter_dummy
	ren *_dummy_owner *_owner_dummy
	ren *_dummy_importer *_importer_dummy

	* create a dummy being one if there is at least one importer, exporter or owner to any of the four destinations in the given neighborhood

	if ("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own"{

		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in exporter importer owner{
				egen `X'_`Y'_dummy_a = max(`X'_`Y'_dummy), by(tax_id year)
			}
		}
	}
	else if "`which_rovat'"=="all_rovat"{
		foreach X in pneighbor {
			foreach Y in exporter importer owner{
				egen `X'_`Y'_dummy_a = max(`X'_`Y'_dummy), by(tax_id year)
			}
		}
	}
	if "`no_exclusion'"=="no_exclusion"{

		foreach X in neighbor1 neighbor2 samebuilding pneighbor{
			foreach Y in exporter importer owner{
				egen `X'_`Y'_dummy_a = max(`X'_`Y'_dummy), by(tax_id year)
			}
		}
	}
	if "`which_rovat'"=="rovat_13" & "`no_exclusion'"==""{

		foreach Z in si su{
			foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
				egen `Z'`X'_importer_dummy_a = max(`Z'`X'_importer_dummy), by(tax_id year)
			}
		}
	}

	save `alldata', replace
		*tax_id year country cityid streetid buildingid 
		*importer exporter owner importer_yearly exporter_yearly owner_yearly importer_s
		*neighbor?_importer_dummy samebuilding_importer_dummy pneighbor_importer_dummy oneighbor_importer_dummy
		*neighbor?_owner_dummy samebuilding_owner_dummy pneighbor_owner_dummy oneighbor_owner_dummy
		*N_neighbor_? N_samebuilding pN_neighbor oN_neighbor
		*neighbor?_exporter_dummy samebuilding_exporter_dummy pneighbor_exporter_dummy oneighbor_exporter_dummy
		*sineighbor?_importer_dummy sisamebuilding_importer_dummy sipneighbor_importer_dummy sioneighbor_importer_dummy
		*suneighbor?_importer_dummy susamebuilding_importer_dummy supneighbor_importer_dummy suoneighbor_importer_dummy
		*first_owned_from_country first_time_to_destination first_time_from_destination
		*neighbor?_importer_dummy_a samebuilding_importer_dummy_a pneighbor_importer_dummy_a oneighbor_importer_dummy_a
		*neighbor?_owner_dummy_a samebuilding_owner_dummy_a pneighbor_owner_dummy_a oneighbor_owner_dummy_a
		*neighbor?_exporter_dummy_a samebuilding_exporter_dummy_a pneighbor_exporter_dummy_a oneighbor_exporter_dummy_a
		*sineighbor?_importer_dummy_a sisamebuilding_importer_dummy_a sipneighbor_importer_dummy_a sioneighbor_importer_dummy_a
		*suneighbor?_importer_dummy_a susamebuilding_importer_dummy_a supneighbor_importer_dummy_a suoneighbor_importer_dummy_a

	if "`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own"{
			
		* Create address variable if geo neighbor considered 

		egen address = group(cityid streetid buildingid)

		* Generate first ever exporter and not yet exporter with or without experience categories

		foreach X in exporter importer owner{
			if "`X'"=="exporter"{
				local Y first_time_to_destination
			}
			else if "`X'"=="importer"{
				local Y first_time_from_destination
			}
			else if "`X'"=="owner"{
				local Y first_owned_from_country
			}

			egen first_ever_`X' = min(`Y'), by(tax_id)
			
			gen byte not_yet_`X' = (year<=`Y')
			replace not_yet_`X'=. if year==1992 | year==1993
			
			gen byte no_`X'_experience = (year<=first_ever_`X')
			replace no_`X'_experience=. if year==1992 | year==1993
			replace no_`X'_experience=. if not_yet_`X'==0 | not_yet_`X'==.
			
			replace first_ever_`X' = (first_ever_`X'==year)
			replace first_ever_`X'=. if year==1992 | year==1993
			
		}
			
		drop first_time_to_destination first_time_from_destination first_owned_from_country

		* Give a "firm-country x year" panel structure

		* create country-year and firm-country groups
		egen countryyear = group(country year)
	}
}

egen groupid = group(tax_id country)
* panel structure
tsset groupid year

* generate lagged neighbor dummies
if (("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own") & "`heterog'"==""{

	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach Y in exporter importer owner{
			gen `X'_`Y'_l = L.`X'_`Y'_dummy
			gen `X'_`Y'_l_a = L.`X'_`Y'_dummy_a
		}
	}
}
else if "`heterog'"=="_heterog"{
	foreach C in fo2 do2 size1 size2 size3 size4 indAC indD indEF indG indHI indJK indLQ{
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in  importer {
				gen `C'`X'_`Y'_l = L.`C'`X'_d_`Y'
			}
		}
	}
}
else if "`heterog'"=="_prod"{
	foreach C in prob1 prob2 prob3 prob4{
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in  importer {
				gen `C'`X'_`Y'_l = L.`C'`X'_d_`Y'
			}
		}
	}
}

else if "`heterog'"=="_bec"{
	foreach C in 1_6 2_3 41_51_52 42_53{
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in  importer {
				gen `X'_`C'`Y'_l = L.`X'_`C'`Y'
			}
		}
	}
}
else if "`heterog'"=="_rauch"{
	foreach C in r w n{
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			foreach Y in  importer {
				gen `X'_`Y'_`C'_l = L.`X'_`C'`Y'
			}
		}
	}
}
else if "`heterog'"=="_numyears"{
	foreach C in numy snumy{
		foreach X in neighbor_1 neighbor_2 samebuilding {
			gen `C'_`X'_l = L.`C'_`X'
		}
		foreach X in p o{
			gen `X'`C'_l = L.`C'_`X'imp
		}
	}
}
else if "`no_exclusion'"=="no_exclusion"{

	foreach X in neighbor1 neighbor2 samebuilding pneighbor {
		foreach Y in exporter importer owner{
			gen `X'_`Y'_l = L.`X'_`Y'_dummy
			gen `X'_`Y'_l_a = L.`X'_`Y'_dummy_a
		}
	}
}
else if "`which_rovat'"=="all_rovat"{

	foreach X in pneighbor {
		foreach Y in exporter importer owner{
			gen `X'_`Y'_l = L.`X'_`Y'_dummy
			gen `X'_`Y'_l_a = L.`X'_`Y'_dummy_a
		}
	}
}

if "`which_rovat'"=="rovat_13" & "`no_exclusion'"=="" & "`heterog'"==""{
	foreach Z in si su{
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			gen `Z'`X'_importer_l = L.`Z'`X'_importer_dummy
			gen `Z'`X'_importer_l_a = L.`Z'`X'_importer_dummy_a
		}
	}
}
cap drop *dummy*
if "`heterog'"!=""{
	cap drop *_d_*
}
if "`heterog'"=="_bec"{
	keep tax_id year country *_l groupid
}
if "`heterog'"=="_rauch"{
	keep tax_id year country importer? *_l groupid
}
if "`heterog'"=="_numyears"{
	keep tax_id year country *numyears_imp *_l groupid
}

* add labels to the experienced peer dummies
if (("`which_rovat'"=="rovat_13" & "`no_exclusion'"=="") | "`which_rovat'"=="sign_own") & "`heterog'"==""{

	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		if "`X'"=="neighbor1"{
			local Y "in +/-1 bldg"
		}
		else if "`X'"=="neighbor2"{
			local Y "in +/-2 bldg"
		}
		else if "`X'"=="samebuilding"{
			local Y "in same bldg"
		}
		else if "`X'"=="pneighbor"{
			local Y "person-conn neighbor"
		} 
		else if "`X'"=="oneighbor"{
			local Y "ownership-conn neighbor"
		} 
		foreach Z in "" _a{
			if "`Z'"==""{
				local W "same"
			}
			else if "`Z'"=="_a"{
				local W "any"
			}
			label variable `X'_importer_l`Z' "`W' dest importer `Y'"
			label variable `X'_exporter_l`Z' "`W' dest exporter `Y'"
			label variable `X'_owner_l`Z' "`W' dest owner `Y'"
		}
	}
}
else if "`no_exclusion'"=="no_exclusion"{

	foreach X in neighbor1 neighbor2 samebuilding pneighbor {
		if "`X'"=="neighbor1"{
			local Y "in +/-1 bldg"
		}
		else if "`X'"=="neighbor2"{
			local Y "in +/-2 bldg"
		}
		else if "`X'"=="samebuilding"{
			local Y "in same bldg"
		}
		else if "`X'"=="pneighbor"{
			local Y "person-conn neighbor"
		} 
		else if "`X'"=="oneighbor"{
			local Y "ownership-conn neighbor"
		} 
		foreach Z in "" _a{
			if "`Z'"==""{
				local W "same"
			}
			else if "`Z'"=="_a"{
				local W "any"
			}
			label variable `X'_importer_l`Z' "`W' dest importer `Y'"
			label variable `X'_exporter_l`Z' "`W' dest exporter `Y'"
			label variable `X'_owner_l`Z' "`W' dest owner `Y'"
		}
	}
}
else if "`which_rovat'"=="all_rovat"{
	foreach Z in "" _a{
		if "`Z'"==""{
			local W "same"
		}
		else if "`Z'"=="_a"{
			local W "any"
		}
		label variable pneighbor_importer_l`Z' "`W' dest importer person-conn neighbor"
		label variable pneighbor_exporter_l`Z' "`W' dest exporter person-conn neighbor"
		label variable pneighbor_owner_l`Z' "`W' dest owner person-conn neighbor"
	}
}
if "`which_rovat'"=="rovat_13" & "`no_exclusion'"=="" & "`heterog'"==""{
	foreach S in si su{
		
		else if "`S'"=="si"{
			local M "same-industry "
		}
		else if "`S'"=="su"{
			local M "successful "
		}
		foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
			if "`X'"=="neighbor1"{
				local Y "in +/-1 bldg"
			}
			else if "`X'"=="neighbor2"{
				local Y "in +/-2 bldg"
			}
			else if "`X'"=="samebuilding"{
				local Y "in same bldg"
			}
			else if "`X'"=="pneighbor"{
				local Y "person-conn neighbor"
			} 
			else if "`X'"=="oneighbor"{
				local Y "ownership-conn neighbor"
			} 
			foreach Z in "" _a{
				if "`Z'"==""{
					local W "same"
				}
				else if "`Z'"=="_a"{
					local W "any"
				}
				label variable `S'`X'_importer_l`Z' "`W' dest `M'importer `Y'"
			}
		}
	}
}

* generate additional variables for the regressions

if ("`which_rovat'"=="rovat_13" | "`which_rovat'"=="sign_own") & "`heterog'"=="" {

	* foreign owner (not the same as the export market but from the 3 other markets
	egen f_owner=max(owner), by(tax_id year)
	replace f_owner=f_owner-owner if f_owner==1
	* firm-year groups and country-year dummies for the regressions
	egen firmyear=group(tax_id year)
	xi i.countryyear
	* create a dummy for firms in and next to "not too large" buildings
	gen byte robustvar=N_neighbor_1<50 & N_neighbor_2<50 & N_samebuilding<50

}
cap drop cityid streetid buildingid *N_*

if "`heterog'"!=""{
	cap drop *importer 
	drop groupid 
	if "`heterog'"!="_rauch"{
		cap drop importer*
	}
}

if "`which_rovat'"=="rovat_13" & "`heterog'"=="" & "`no_exclusion'"==""{
	save "`out'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta"
}
else if "`which_rovat'"=="sign_own"{
	save "`out'/db_complete_for_running_the_regs_baseline_torun.dta"
}
else if "`which_rovat'"=="all_rovat"{
	save "`out'/person_neighbors_all_rovat_toadd.dta"
}
else if "`no_exclusion'"=="no_exclusion"{
	save "`out'/db_complete_for_running_the_regs_no_exclusion_rovat_13.dta"
}
else if "`heterog'"=="_bec" | "`heterog'"=="_heterog" | "`heterog'"=="_numyears"{
	save "`out'/db_complete_for_running_the_regs`heterog'_rovat_13.dta"
}
else if "`heterog'"=="_prod"{
	save "`out'/db_complete_for_running_the_regs`heterog'_robust_rovat_13.dta"
}
else if "`heterog'"=="_rauch"{
	save "`out'/db_complete_additional`heterog'_rovat_13.dta"
}

	*tax_id year country address countryyear groupid f_owner firmyear robustvar
	*importer exporter owner importer_yearly exporter_yearly owner_yearly importer_s
	*neighbor?_importer_l samebuilding_importer_l pneighbor_importer_l oneighbor_importer_l
	*neighbor?_owner_l samebuilding_owner_l pneighbor_owner_l oneighbor_owner_l
	*neighbor?_exporter_l samebuilding_exporter_l pneighbor_exporter_l oneighbor_exporter_l
	*sineighbor?_importer_l sisamebuilding_importer_l sipneighbor_importer_l sioneighbor_importer_l
	*suneighbor?_importer_l susamebuilding_importer_l supneighbor_importer_l suoneighbor_importer_l
	*neighbor?_importer_l_a samebuilding_importer_l_a pneighbor_importer_l_a oneighbor_importer_l_a
	*neighbor?_owner_l_a samebuilding_owner_l_a pneighbor_owner_l_a oneighbor_owner_l_a
	*neighbor?_exporter_l_a samebuilding_exporter_l_a pneighbor_exporter_l_a oneighbor_exporter_l_a
	*sineighbor?_importer_l_a sisamebuilding_importer_l_a sipneighbor_importer_l_a sioneighbor_importer_l_a
	*suneighbor?_importer_l_a susamebuilding_importer_l_a supneighbor_importer_l_a suoneighbor_importer_l_a
	*first_ever_importer first_ever_exporter first_ever_owner not_yet_importer not_yet_exporter not_yet_owner no_import_experience no_export_experience no_owner_experience
	*_Icountryye_2-_Icountryye_48
