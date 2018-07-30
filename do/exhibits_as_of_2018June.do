/*
Creating all the exhibits of the import spillover paper as of 2018 May
Created by Marta Bisztray in 2018 May

inputs used:
	`in2'/hs6bec.csv, clear
	`in2'/import/im91.dta
	`in2'/import/im92.dta
	...
	`in2'/import/im03.dta
	`in'/import_minyear_by_bec.dta
	`in'/firm_age.dta
	`in'/firm_bsheet_data.dta
	`in1'/frame.csv
	`in1'/geocoordinates.dta
	`in3'/PPI.dta
	`in'/db_complete_additional_rauch_rovat_13.dta
	`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta
	`in'/db_complete_for_running_the_regs_baseline_torun.dta
	`in'/db_complete_for_running_the_regs_bec_rovat_13.dta
	`in'/db_complete_for_running_the_regs_heterog_rovat_13.dta
	`in'/db_complete_for_running_the_regs_no_exclusion_rovat_13.dta
	`in'/db_complete_for_running_the_regs_numyears_rovat_13.dta
	`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta
	`in'/db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
	`in'/db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
	`in'/db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
	`in'/db_numneighbors_bec_rovat_13.dta
	`in'/db_numneighbors_heterog_rovat_13.dta
	`in'/db_numneighbors_rovat_13.dta
	`in'/db_numneighbors_prod_robust_rovat_13.dta
	`in'/db_numneighbors_sameind_rovat_13.dta
	`in'/db_numneighbors_success_rovat_13.dta
	`in'/person_neighbors_all_rovat_toadd.dta

outputs created:

	Table 1: descriptives_by_dest.txt
	Table 2: descriptives_by_year.txt
	Table 3: num_neighbors_spatial.txt
	Table 4: country_spec_imp_and_peer_experience.txt 
	Table 5: Table_reg_notyetimp.xls, baseline_hazard_imp.txt
	Table 6: Table_notyetimp_firmgroups.xls, ttest_notyetimp_firmgroups.txt
	Table 7: Table_notyetimp_neighbor_heterog.xls, ttest_notyetimp_neighbor_heterog.txt
	Table 8: Table_peer_experience_time.xls, ttest_peer_experience_time.txt
	Table 9: Table_numpeers.xls, ttest_numpeers.txt
	Table 10: Table_notyetimp_dyadic.xls
	Table 11: Table_numpeers_by_prod_separately.xls, ttest_numpeers_by_prod_separately.txt
	Table 12: Table_notyetimp_sameind_sameprod.xls, ttest_notyetimp_sameind_sameprod.txt, baseline_hazard_imp_ind_prod.txt
	Figure 1: Plot_event_study_FE.xls, Plot_event_study_OLS.xls
	Figure 2: distrib_of_5year_social_multiplier_by_prod_norm_small.pdf, multiplier_calc_5.txt
	
	Table A1: peer_patterns.txt
	Table A2: impshare_by_numpeers_in_bdng.txt
	Table A3: Table_notyetimp_full.xls
	Table A4: Table_notyetimp_person_versions.xls
	Table A5: Table_notyetimp_alternative_samples.xls
	Table A6: Table_notyetimp_succ_entry.xls, ttest_notyetimp_succ_entry.txt, baseline_hazard_succ_imp.txt
	Table A7: Table_by_ind.xls
	Table A8: Table_notyetimp_Rauch.xls
	Table A9: mover_desc.txt
	Table A10: Table_mover_event_study_new.xls
	Table A11: Table_reg_notyetexp.xls, baseline_hazard_exp.txt 
	
	Table OA1: descriptives_by_import_patterns.txt
	Table OA2: BEC_descriptives.txt
	Table OA3: peer_patterns_1.txt
	Table OA4: firm_group_desc.txt
	Table OA5: Table_notyetimp_firmgroups.xls, ttest_notyetimp_firmgroups.txt
	Table OA6: Table_notyetimp_neighbor_heterog.xls, ttest_notyetimp_neighbor_heterog.txt
	Table OA7: Table_notyetimp_sameind_sameprod.xls, ttest_notyetimp_sameind_sameprod.txt
	Table OA8: Table_by_same_bec_first_ever_imp.xls
	Table OA9: Table_notyetimp_robust.xls
	Table OA10: Table_reg_w_wo_exp_peers_compare.xls
	Table OA11: Table_mover_event_study_full.xls, multiplier_calc_1/5.txt, numfirms_in_bdngs_w_mover.txt
	Figure OA1: industry_by_country_1d.pdf
	Figure OA2: industry_by_country_2d_manu.pdf
	Figure OA3: industry_by_country_2d_serv.pdf
	Figure OA4: distrib_of_5year_treatment_effect_by_prod_norm_small.pdf
	
*/
	

	
clear
set more off

*cd "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data"

*local in ../data/reprod_2018
*local in1 ../data
*local in2 ../../audi/data/customs/
*local in3 ../../plant_closure/data
*local out ../results/tables/2018_June

local in "$in"
local in2 "$in2"
local in3 "$in3"
local in1 "$in1"
local out "$out"

***********************************
* Table 1: Descriptive statistics *
***********************************



* add balance sheet data from plant_closure
use "`in'/firm_bsheet_data.dta", clear
keep id8 year empl lsales exp_share ltfp_pred teaor03_2d_yearly fo2 so2
tempfile bsheet
save `bsheet'
use "`in'/firm_age.dta"
merge 1:1 id8 year using `bsheet'
drop _merge
rename id8 tax_id
save `bsheet', replace
* get the baseline data
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
tab country
keep tax_id year country importer not_yet_importer address
merge m:1 tax_id year using `bsheet'
drop if _merge==2
drop _merge
* demean tfp
egen avg_ltfp=mean(ltfp_pred), by(country teaor03_2d_yearly year)
gen ltfp_rel=ltfp_pred-avg_ltfp
egen check=mean(ltfp_rel), by(tax_id year)
assert ltfp_rel==check
drop check
drop if year==1992
* number of firms, importers and importers from a country, and number of addresses in each group
quietly {
    log using "`out'/descriptives_by_dest.txt", text replace
	noisily distinct tax_id address
	noisily distinct tax_id address if importer==1 
	noisily bysort country: distinct tax_id address if importer==1 
	log close
}
* descriptive statistics for all firms, importers and importers from a country  
estpost sum age empl lsales exp_share ltfp_rel fo2 so2 if country=="SK"
esttab using "`out'/descriptives_by_dest.txt", cells("mean(fmt(3)) sd(fmt(3))") title("All firms") nomtitle nonumber append
estpost sum age empl lsales exp_share ltfp_rel fo2 so2 if importer==1 
esttab using "`out'/descriptives_by_dest.txt", cells("mean(fmt(3)) sd(fmt(3))") title("Importers") nomtitle nonumber append
foreach X in CZ SK RO RU{
	estpost sum age empl lsales exp_share ltfp_rel fo2 so2 if country=="`X'" & importer==1 
	esttab using "`out'/descriptives_by_dest.txt", cells("mean(fmt(3)) sd(fmt(3))") title("Importer to `X'") nomtitle nonumber append
}



**************************************************
* Table 2: Number of firms and importers by year *
**************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop if year==1992
egen importer_from_any=max(importer), by(tax_id year)
tabout year if country=="SK" using "`out'/descriptives_by_year.txt", c(freq) f(0c) clab(All) replace
tabout year if country=="SK" & importer_from_any==1 using "`out'/descriptives_by_year.txt", c(freq) f(0c) clab(Importer) append
foreach X in SK CZ RO RU{
	tabout year if country=="`X'" & importer==1 using "`out'/descriptives_by_year.txt", c(freq) f(0c) clab("`X'") append
}
	

	
************************************************
* Table 3: Number of peers in various networks *
************************************************



* spatial peers
use "`in'/db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta", clear
drop *neighbor_3 *neighbor_4
sum tax_id  N_*
keep tax_id year N_*
tempfile geo
save `geo'
* person-connected peers
use "`in'/db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta", clear
rename N_neighbor N_pneighbor
keep tax_id year N_pneighbor
merge 1:1 tax_id year using `geo'
drop if _merge==1
drop _merge
save `geo', replace
* owner-connected peers
use "`in'/db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta", clear
rename N_neighbor N_oneighbor
keep tax_id year N_oneighbor
merge 1:1 tax_id year using `geo'
drop if _merge==1
drop _merge
replace N_pneighbor=0 if N_pneighbor==.
replace N_oneighbor=0 if N_oneighbor==.
keep if year==2003
* average number of peers from peer group in 2003
estpost sum N_* 
esttab using "`out'/num_neighbors_spatial.txt", cells("mean(fmt(1))") nomtitle nonumber replace
foreach X in samebuilding neighbor_1 neighbor_2 pneighbor oneighbor{
	replace N_`X'=5 if N_`X'>5 & N_`X'!=.
}
label var N_samebuilding "# samebuilding peers"
label var N_neighbor_1 "# cross-street peers"
label var N_neighbor_2 "# neighbor-building peers"
label var N_pneighbor "# person-connected peers"
label var N_oneighbor "# owner-connected peers"
* share of firms with X peers from peer group in 2003
tabout N_samebuilding using "`out'/num_neighbors_spatial.txt", c(col) f(1c) append
tabout N_neighbor_2 using "`out'/num_neighbors_spatial.txt", c(col) f(1c) append
tabout N_neighbor_1 using "`out'/num_neighbors_spatial.txt", c(col) f(1c) append
tabout N_pneighbor using "`out'/num_neighbors_spatial.txt", c(col) f(1c) append
tabout N_oneighbor using "`out'/num_neighbors_spatial.txt", c(col) f(1c) append



******************************************************
* Table 4: Share of importers with experienced peers *
******************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* keep the estimation sample
keep if not_yet_importer==1 & robustvar==1 & year>=1994
keep tax_id year country importer samebuilding_importer_l neighbor2_importer_l pneighbor_importer_l oneighbor_importer_l
* keep firms which start to import from any of the countries
egen importer_num=sum(importer), by(tax_id year)
drop if importer_num==0
* define firm categories based on import patterns (only from country, only from other countries, or both)
gen imp_cat=1 if importer==1 & importer_num==1
replace imp_cat=2 if importer==0 
replace imp_cat=3 if importer==1 & importer_num>1
label define imp_cat 1 "only C-importer" 2 "non-C-importer" 3 "C-plus-importer"
label values imp_cat imp_cat
* define firm categories based on peer patterns in peer group (importer peers only from country, only from other countries, or both)
foreach X in samebuilding neighbor2 pneighbor oneighbor{
	egen num`X'_importer_l=sum(`X'_importer_l), by(tax_id year)
	gen byte onlyCimp_`X'_peer=`X'_importer_l==1 & num`X'_importer_l==1
	gen byte nonCimp_`X'_peer=`X'_importer_l==0 & num`X'_importer_l>0 & num`X'_importer_l!=.
}
* share of firms with a specific import pattern among new importers by peer pattern
foreach X in samebuilding neighbor2 pneighbor oneighbor{
	if "`X'"=="samebuilding"{
		local save_spec replace
	}
	else{
		local save_spec append
	}
	tabout imp_cat if onlyCimp_`X'_peer==1 using "`out'/country_spec_imp_and_peer_experience.txt", c(col) f(0c) h2(`X' only from C) `save_spec'
	tabout imp_cat if nonCimp_`X'_peer==1 using "`out'/country_spec_imp_and_peer_experience.txt", c(col) f(0c) clab(`X' only from nonC) append
}



**************************************************************
* Table 5: Effect of peer experience on same-country imports *
**************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* geo-connected import experience
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetimp.xls", label ctitle("importer geo") excel replace
* person-connected import experience
capture noisily areg importer pneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetimp.xls", label ctitle("importer person") excel append
* owner-connected import experience
capture noisily areg importer oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetimp.xls", label ctitle("importer owner") excel append
* all 3 types of peers with import experience
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetimp.xls", label ctitle("importer all types") excel append
* baseline probability of starting to import (firms in the estimation sample which have no peers with any country-specific experience
gen byte not_yet_imp_wo_exp_peers = robustvar==1 & year>=1994 & not_yet_importer==1 & neighbor1_importer_l==0 & neighbor2_importer_l==0 & samebuilding_importer_l==0 & pneighbor_importer_l==0 & oneighbor_importer_l==0 & neighbor1_exporter_l==0 & neighbor2_exporter_l==0 & samebuilding_exporter_l==0 & pneighbor_exporter_l==0 & oneighbor_exporter_l==0 & neighbor1_owner_l==0 & neighbor2_owner_l==0 & samebuilding_owner_l==0 & pneighbor_owner_l==0 & oneighbor_owner_l==0
tabout importer if not_yet_imp_wo_exp_peers==1 using "`out'/baseline_hazard_imp.txt", c(col) f(2c) clab("nonimp_firms_wo_exp_peers") replace



*****************************************************************
* Table 6: Heterogeneity of peer effect by firm characteristics *
*****************************************************************



* create size groups
use "`in'/firm_bsheet_data.dta", clear
keep id8 year empl 
sum
tempfile bsheet
save `bsheet'
rename id8 tax_id
gen byte size1=empl<=5
gen byte size2=empl>5 & empl<=20
gen byte size3=empl>20 & empl<=100
gen byte size4=empl>100
foreach X in 1 2 3 4{
	replace size`X'=. if empl==.
}
keep tax_id year size? 
tempfile firmchar
save `firmchar'
* heterogeneous effect by the size category of the firm
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge m:1 tax_id year using `firmchar'
drop if _merge==2
drop _merge
* put missing into the lowest category
replace size1=1 if size2!=1 & size3!=1 & size4!=1
foreach Y of numlist 1/4{
	replace size`Y'=0 if size`Y'==.
}
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach W in 1 2 3 4{
		gen s`W'`A'_importer_l=size`W'*`A'_importer_l
	}
}
local sRHS1 "s?samebuilding_importer_l s?neighbor2_importer_l s?neighbor1_importer_l s?pneighbor_importer_l s?oneighbor_importer_l "
capture noisily areg importer `sRHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_firmgroups.xls", label ctitle("importer by size with group NA in group1") excel replace
* test if the spillover coefficients are different by size group
quietly {
	log using "`out'/ttest_notyetimp_firmgroups.txt", replace text
	foreach G in samebuilding neighbor2 pneighbor{
		noisily test s1`G'_importer_l=s2`G'_importer_l
		noisily test s2`G'_importer_l=s3`G'_importer_l
		noisily test s3`G'_importer_l=s4`G'_importer_l
	}
	log close
}

* heterogeneous effect by the productivity category of the firm
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* get the productivity groups
merge 1:1 tax_id country year using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
rename prod_quartile_y_robust? prod?
* put missing into the lowest category
replace prod1=1 if prod2!=1 & prod3!=1 & prod4!=1
foreach Y of numlist 1/4{
	replace prod`Y'=0 if prod`Y'==.
}
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach W in 1 2 3 4{
		gen p`W'`A'_importer_l=prod`W'*`A'_importer_l
	}
}
local pRHS1 "p?samebuilding_importer_l p?neighbor2_importer_l p?neighbor1_importer_l p?pneighbor_importer_l p?oneighbor_importer_l"
capture noisily areg importer `pRHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_firmgroups.xls", label ctitle("importer by prod with group NA in group1") excel append
* test if the spillover coefficients are different by productivity group
quietly {
	log using "`out'/ttest_notyetimp_firmgroups.txt", append text
	foreach G in samebuilding neighbor2 pneighbor{
		noisily test p1`G'_importer_l=p2`G'_importer_l
		noisily test p2`G'_importer_l=p3`G'_importer_l
		noisily test p3`G'_importer_l=p4`G'_importer_l
	}
	log close
}

* create ownership groups
use "`in'/firm_bsheet_data.dta", clear
rename id8 tax_id
gen byte do2=fo2!=1
keep tax_id year fo2 do2
tempfile firmchar
save `firmchar'
* heterogeneous effect by the ownership category of the firm
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge m:1 tax_id year using `firmchar'
drop if _merge==2
drop _merge
replace fo2=0 if fo2==.
replace do2=0 if do2==.
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Z in "" _a{
		gen of`A'_importer_l`Z'=fo2*`A'_importer_l`Z'
		gen od`A'_importer_l`Z'=do2*`A'_importer_l`Z'
		* put missing into the domestic category
		replace od`A'_importer_l`Z'=`A'_importer_l`Z' if fo2!=1 & do2!=1
	}
}
local oRHS2 "odsamebuilding_importer_l ofsamebuilding_importer_l odneighbor2_importer_l ofneighbor2_importer_l odneighbor1_importer_l ofneighbor1_importer_l odpneighbor_importer_l ofpneighbor_importer_l odoneighbor_importer_l ofoneighbor_importer_l"
capture noisily areg importer `oRHS2' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_firmgroups.xls", label ctitle("importer by ownership of the firm with group NA in group1") excel append
* test if the spillover coefficients are different by ownership group
quietly {
	log using "`out'/ttest_notyetimp_firmgroups.txt", append text
	foreach G in samebuilding neighbor2 pneighbor{
		noisily test od`G'_importer_l=of`G'_importer_l
	}
	log close
}



*****************************************************************
* Table 7: Heterogeneity of peer effect by peer characteristics *
*****************************************************************



* size of the peer
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_heterog_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_heterog_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach C in size1 size2 size3 size4 {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach Z in "" num{
				replace `C'`Z'`X'_importer_l = 0 if `C'`Z'`X'_importer_l==.
		}
	}
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{ 
	assert num`X'_importer_l!=. if (size1num`X'_importer_l==1 | size2num`X'_importer_l==1 | size3num`X'_importer_l==1 | size4num`X'_importer_l==1)
}
* create a separate category for the experienced peers with missing size group
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	sum num`X'_importer_l
	gen size0num`X'_importer_l = num`X'_importer_l-size1num`X'_importer_l-size2num`X'_importer_l-size3num`X'_importer_l-size4num`X'_importer_l 
	sum size0num`X'_importer_l
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte size0`X'_importer_l=size0num`X'_importer_l>0 & size0num`X'_importer_l!=.
	replace size0`X'_importer_l=. if `X'_importer_l==.
}
* create a joint category for peers in the lowest size group and with missing size data
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte size01`X'_importer_l=size0`X'_importer_l==1 | size1`X'_importer_l==1  
	replace size01`X'_importer_l=. if `X'_importer_l==.
}
local RHSvars ""
foreach Y in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach X in size01 size2 size3 size4{
		local RHSvars "`RHSvars' `X'`Y'"
	}
}
display "`RHSvars'"
capture noisily areg importer `RHSvars' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_neighbor_heterog.xls", label ctitle("import by peer size with NA in lowest size group") excel replace
* test if the spillover coefficients are different by peer size group
quietly {
	log using "`out'/ttest_notyetimp_neighbor_heterog.txt", replace text
	foreach X in samebuilding neighbor2 pneighbor{
		noisily test size01`X'_importer_l=size2`X'_importer_l
		noisily test size2`X'_importer_l=size3`X'_importer_l
		noisily test size3`X'_importer_l=size4`X'_importer_l
	}
	log close 
}

* productivity of the peer
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_prod_robust_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
rename prod_quartile_y_robust? prob?
foreach C in prob1 prob2 prob3 prob4 {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach Z in "" num{
			replace `C'`Z'`X'_importer_l = 0 if `C'`Z'`X'_importer_l==.
		}
	}
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{ 
	assert num`X'_importer_l!=. if (prob1num`X'_importer_l==1 | prob2num`X'_importer_l==1 | prob3num`X'_importer_l==1 | prob4num`X'_importer_l==1)
}
* create a separate category for the experienced peers without productivity group
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	sum num`X'_importer_l
	gen prob0num`X'_importer_l = num`X'_importer_l-prob1num`X'_importer_l-prob2num`X'_importer_l-prob3num`X'_importer_l-prob4num`X'_importer_l 
	sum prob0num`X'_importer_l
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte prob0`X'_importer_l=prob0num`X'_importer_l>0 & prob0num`X'_importer_l!=.
	replace prob0`X'_importer_l=. if `X'_importer_l==.
}
* create a joint category for peers in the lowest productivity group and without data on productivity
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte prob01`X'_importer_l=prob0`X'_importer_l==1 | prob1`X'_importer_l==1
	replace prob01`X'_importer_l=. if `X'_importer_l==.
}
local RHSvars ""
foreach Y in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach X in prob01 prob2 prob3 prob4{
		local RHSvars "`RHSvars' `X'`Y'"
	}
}
display "`RHSvars'"
capture noisily areg importer `RHSvars' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_neighbor_heterog.xls", label ctitle("import by peer productivity with NA in lowest productivity group") excel append
* test if the spillover coefficients are different by peer productivity group
quietly {
	log using "`out'/ttest_notyetimp_neighbor_heterog.txt", append text
	foreach X in samebuilding neighbor2 pneighbor{
		noisily test prob01`X'_importer_l=prob2`X'_importer_l
		noisily test prob2`X'_importer_l=prob3`X'_importer_l
		noisily test prob3`X'_importer_l=prob4`X'_importer_l
	}
	log close
}

* ownership of the peer
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_heterog_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_heterog_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach C in fo2 do2 {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach Z in "" num{
			replace `C'`Z'`X'_importer_l = 0 if `C'`Z'`X'_importer_l==.
		}
	}
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{ 
	assert num`X'_importer_l!=. if (fo2num`X'_importer_l==1 | do2num`X'_importer_l==1)
}
* create a separate category for the experienced peers without ownership information
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	sum num`X'_importer_l
	gen no2num`X'_importer_l = num`X'_importer_l-fo2num`X'_importer_l-do2num`X'_importer_l
	sum no2num`X'_importer_l
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte no2`X'_importer_l=no2num`X'_importer_l>0 & no2num`X'_importer_l!=.
	replace no2`X'_importer_l=. if `X'_importer_l==.
}
* create a joint category for peers in domestic ownership and without data on ownership
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte no2do2`X'_importer_l=do2`X'_importer_l==1 | no2`X'_importer_l==1
	replace no2do2`X'_importer_l=. if `X'_importer_l==.
}
local RHSvars ""
foreach Y in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach X in no2do2 fo2{
		local RHSvars "`RHSvars' `X'`Y'"
	}
}
display "`RHSvars'"
capture noisily areg importer `RHSvars' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_neighbor_heterog.xls", label ctitle("import by peer ownership with NA and domestic in a joint group") excel append
* test if the spillover coefficients are different by peer ownership group
quietly{
	log using "`out'/ttest_notyetimp_neighbor_heterog.txt", append text
	foreach X in samebuilding neighbor2 pneighbor{	
		noisily test no2do2`X'_importer_l=fo2`X'_importer_l
	}
	log close
}



**********************************************************************
* Table 8: Heterogeneity of peer effect by peer success in importing *
**********************************************************************



* recent successful peer experience
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_success_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach C in "" su {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		replace num`C'`X'_importer_l = 0 if num`C'`X'_importer_l==. & samebuilding_importer_l!=.
	}
}
* take out unsuccessful peers from the number of peers
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	replace num`A'_importer_l=num`A'_importer_l-numsu`A'_importer_l
	sum `B'`A'_importer_l
	gen byte unsu`A'_importer_l=num`A'_importer_l>0 & num`A'_importer_l!=.
	tab unsu`A'_importer_l
	replace unsu`A'_importer_l=. if samebuilding_importer_l==.
	tab unsu`A'_importer_l
}
local suRHS1 ""
foreach X in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	foreach Y in su unsu{
		local suRHS1 "`suRHS1' `Y'`X'_importer_l"
	}
}
capture noisily areg importer `suRHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_peer_experience_time.xls", label ctitle("successful peer") excel replace
* test if spillovers from successful peers are different
quietly{
	log using "`out'/ttest_peer_experience_time.txt", replace text
	noisily test susamebuilding_importer_l=unsusamebuilding_importer_l
	log close
}

* length of peer experience
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_numyears_rovat_13.dta"
drop _merge
* create additional years of import experience dummy
foreach X in onumy_l pnumy_l numy_neighbor_1_l numy_neighbor_2_l numy_samebuilding_l{
	replace `X'=`X'-1 if `X'>0
}
* spec.1: additional variable shows the max number of years (above 1) a peer has experience in importing
rename numy_neighbor_1_l numy_neighbor1_l
rename numy_neighbor_2_l numy_neighbor2_l
rename pnumy_l numy_pneighbor_l
rename onumy_l numy_oneighbor_l
local RHS1 ""
foreach X in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	local RHS1 "`RHS1' `X'_importer_l numy_`X'_l"
}	
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_peer_experience_time.xls", label ctitle("numyears +") excel append
* spec.2: additional variable shows the max number of years (above 1) a peer has recent (continuous) experience in importing
rename snumy_neighbor_2_l  snumy_neighbor2_l
rename snumy_neighbor_1_l snumy_neighbor1_l 
rename psnumy_l snumy_pneighbor_l
rename osnumy_l snumy_oneighbor_l
local RHS2 ""
foreach X in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	local RHS2 "`RHS2' `X'_importer_l snumy_`X'_l"
}
capture noisily areg importer `RHS2' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_peer_experience_time.xls", label ctitle("recent numyears") excel append



****************************************************************
* Table 9: Effect of peer import experience by number of peers *
****************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Y of numlist 1/3 {
		gen byte `X'_importer_`Y'_l = num`X'_importer_l==`Y'
		replace `X'_importer_`Y'_l=. if `X'_importer_l==.
	}
	gen byte `X'_importer_4_l = num`X'_importer_l>=4 & num`X'_importer_l!=.
	replace `X'_importer_4_l=. if `X'_importer_l==.
}
* if spillover is linear in the number of experienced peers
local RHS ""
foreach Y in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	local RHS "`RHS' num`Y'_importer_l"
}		
capture noisily areg importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_numpeers.xls", label ctitle("linear") excel replace
* flexible specification
local RHS ""
foreach Y in samebuilding_importer neighbor2_importer neighbor1_importer pneighbor_importer oneighbor_importer{
	foreach X in 1 2 3 4 {
		local RHS "`RHS' `Y'_`X'_l"
	}
}
capture noisily areg importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_numpeers.xls", label ctitle("separately") excel append
* test if spillover coefficients are different by the number of experienced peers
quietly{
	log using "`out'/ttest_numpeers.txt", replace text
	foreach G in samebuilding neighbor2 pneighbor{
		noisily test `G'_importer_1_l=`G'_importer_2_l
		noisily test `G'_importer_2_l=`G'_importer_3_l
		noisily test `G'_importer_3_l=`G'_importer_4_l
	}
	log close
}



***************************************************************************
* Table 10: Complementarities between peer and receiver firm productivity *
***************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
foreach C of numlist 1/4 {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		replace prob`C'`X'_importer_l = 0 if prob`C'`X'_importer_l==.
	}
}
tempfile basedata
save `basedata'
* two versions: "high" group is either top quartile or above median
foreach X in p75 p50{
	use `basedata', clear
	* create peer experience dummies separately for high- and low-productivity firms
	foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		gen fprl`A'_importer_l=0
		if "`X'"=="p75"{
			replace fprl`A'_importer_l=`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 | prod_quartile_y_robust3==1 
		}
		else if "`X'"=="p50"{
			replace fprl`A'_importer_l=`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 
		}
		gen fprh`A'_importer_l=0
		if "`X'"=="p75"{
			replace fprh`A'_importer_l=`A'_importer_l if prod_quartile_y_robust4==1
		}
		else if "`X'"=="p50"{
			replace fprh`A'_importer_l=`A'_importer_l if prod_quartile_y_robust3==1 | prod_quartile_y_robust4==1
		}
	}
	* create peer experience dummies separately by high- and low-productivity peers
	foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		gen probl`A'_importer_l=prob1`A'_importer_l
		replace probl`A'_importer_l=prob2`A'_importer_l if probl`A'_importer_l==0 
		if "`X'"=="p75"{
			replace probl`A'_importer_l=prob3`A'_importer_l if probl`A'_importer_l==0 
			gen probh`A'_importer_l=prob4`A'_importer_l
		}
		else if "`X'"=="p50"{
			gen probh`A'_importer_l=prob3`A'_importer_l
			replace probh`A'_importer_l=prob4`A'_importer_l if probh`A'_importer_l==0 
		}
	}
	* create peer experience dummies separately by firm's and peers' experience group
	foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach L in flnl fhnl flnh fhnh{	
			gen `L'`A'_importer_l=0
		}
		if "`X'"=="p75"{
			replace flnl`A'_importer_l=probl`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 | prod_quartile_y_robust3==1
			replace fhnl`A'_importer_l=probl`A'_importer_l if prod_quartile_y_robust4==1
			replace flnh`A'_importer_l=probh`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 | prod_quartile_y_robust3==1
			replace fhnh`A'_importer_l=probh`A'_importer_l if prod_quartile_y_robust4==1
		}
		else if "`X'"=="p50"{
			replace flnl`A'_importer_l=probl`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 
			replace fhnl`A'_importer_l=probl`A'_importer_l if prod_quartile_y_robust3==1 | prod_quartile_y_robust4==1
			replace flnh`A'_importer_l=probh`A'_importer_l if prod_quartile_y_robust1==1 | prod_quartile_y_robust2==1 
			replace fhnh`A'_importer_l=probh`A'_importer_l if prod_quartile_y_robust3==1 | prod_quartile_y_robust4==1
		}
	}
	local RHSvars ""
	foreach RV in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l  pneighbor_importer_l oneighbor_importer_l{
		local RHSvars "`RHSvars' `RV' fprh`RV' probh`RV' fhnh`RV'"
	}
	capture noisily areg importer `RHSvars' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 , cluster(address) absorb(firmyear)
	if "`X'"=="p75"{
		local outregend replace
	}
	else{
		local outregend append
	}
	outreg2 using "`out'/Table_notyetimp_dyadic.xls", label ctitle("cutoff at `X'") excel `outregend'
}



******************************************************************************************************************************
* Table 11: Complementarities between peer and receiver firm productivity with peer effect increasing in the number of peers *
******************************************************************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_prod_robust_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach C of numlist 1/4 {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		replace prob`C'num`X'_importer_l = 0 if prob`C'num`X'_importer_l==.
	}
}
* take out high-prod (group4) peers from the number of peers
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	replace num`A'_importer_l=num`A'_importer_l-prob4num`A'_importer_l
	sum num`A'_importer_l
}
* number of peers by high (>p75) and low (<p75 or NA) peer & firm
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen flnlnum`A'_importer_l=0
	replace flnlnum`A'_importer_l=num`A'_importer_l if prod_quartile_y_robust4==0 | prod_quartile_y_robust4==.
	gen fhnlnum`A'_importer_l=0
	replace fhnlnum`A'_importer_l=num`A'_importer_l if prod_quartile_y_robust4==1
	gen flnhnum`A'_importer_l=0
	replace flnhnum`A'_importer_l=prob4num`A'_importer_l if prod_quartile_y_robust4==0 | prod_quartile_y_robust4==.
	gen fhnhnum`A'_importer_l=0
	replace fhnhnum`A'_importer_l=prob4num`A'_importer_l if prod_quartile_y_robust4==1
}
drop *prob1* *prob2* *prob3* *prob4* 
local RHS1 ""
foreach Y in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach Z in flnl flnh fhnl fhnh {
		local RHS1 "`RHS1' `Z'num`Y'"
	}
}
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 , cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_numpeers_by_prod_separately.xls", label ctitle("both - high vs any all firms") excel replace
* test if spillover coefficients vary by firm-peer group
quietly{
	log using "`out'/ttest_numpeers_by_prod_separately.txt", replace text
	foreach G in samebuilding  neighbor2 pneighbor{
		noisily test flnlnum`G'_importer_l=flnhnum`G'_importer_l
		noisily test flnlnum`G'_importer_l=fhnlnum`G'_importer_l
		noisily test fhnlnum`G'_importer_l=fhnhnum`G'_importer_l
		noisily test flnhnum`G'_importer_l=fhnhnum`G'_importer_l
	}
	log close
}



*******************************************************************
* Table 12: Effect of peer experience within industry and product *
*******************************************************************



* get industry data
use "`in'/firm_bsheet_data.dta", clear
rename id8 tax_id
keep tax_id year teaor03_2d_yearly
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
gen byte manu=teaor03_1d_yearly=="D"
replace manu=. if teaor03_1d_yearly==""
drop teaor03_1d_yearly teaor03_2d_yearly
tempfile firmchar
save `firmchar'
* get same-industry peers
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_sameind_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
cap drop *_l_a 
foreach C in "" si {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		replace num`C'`X'_importer_l = 0 if num`C'`X'_importer_l==. & samebuilding_importer_l!=.
	}
}
* get the number of peers in different industries
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen numdi`A'_importer_l=num`A'_importer_l-numsi`A'_importer_l
	sum numdi`A'_importer_l
	gen byte di`A'_importer_l=numdi`A'_importer_l>0 & numdi`A'_importer_l!=.
	tab di`A'_importer_l
	replace di`A'_importer_l=. if samebuilding_importer_l==.
	tab di`A'_importer_l
}
merge m:1 tax_id year using `firmchar'
drop if _merge==2
drop _merge
local RHS ""
foreach X in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	foreach Y in di si{
		local RHS "`RHS' `Y'`X'_importer_l"
	}
}
* same-industry peers, firms in all industries
capture noisily areg importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_sameind_sameprod.xls", label ctitle("import same-ind") excel replace
* test if spillover from same-industry peers is different
quietly{
	log using "`out'/ttest_notyetimp_sameind_sameprod.txt", replace text
	* same-industry, all firms
	foreach X in samebuilding neighbor2 pneighbor{
		noisily test si`X'_importer_l=di`X'_importer_l
	}
	log close 
}
* same-industry peers, firms in manufacturing
capture noisily areg importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & manu==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_sameind_sameprod.xls", label ctitle("import same-ind manu") excel append
* test if spillover from same-industry peers is different
quietly{
	log using "`out'/ttest_notyetimp_sameind_sameprod.txt", append text
	* same-industry, all firms
	foreach X in samebuilding neighbor2 pneighbor{
		noisily test si`X'_importer_l=di`X'_importer_l
	}
	log close 
}
* baseline probability of starting to import (firms in the estimation sample which have no peers with any country-specific experience
gen byte not_yet_imp_wo_exp_peers = robustvar==1 & year>=1994 & not_yet_importer==1 & neighbor1_importer_l==0 & neighbor2_importer_l==0 & samebuilding_importer_l==0 & pneighbor_importer_l==0 & oneighbor_importer_l==0 & neighbor1_exporter_l==0 & neighbor2_exporter_l==0 & samebuilding_exporter_l==0 & pneighbor_exporter_l==0 & oneighbor_exporter_l==0 & neighbor1_owner_l==0 & neighbor2_owner_l==0 & samebuilding_owner_l==0 & pneighbor_owner_l==0 & oneighbor_owner_l==0
tabout importer if not_yet_imp_wo_exp_peers==1 using "`out'/baseline_hazard_imp_ind_prod.txt", c(col) f(2c) clab(all) replace
tabout importer if not_yet_imp_wo_exp_peers==1 & manu==1 using "`out'/baseline_hazard_imp_ind_prod.txt", c(col) f(2c) clab(manu) append

* get peers importing different product categories
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop su*_l su*_l_a
drop si*_l si*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_bec_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_bec_rovat_13.dta", update
drop _merge
cap drop *_l_a 
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	replace num`X'_importer_l = 0 if num`X'_importer_l==. & samebuilding_importer_l!=.
	foreach C in 1_6 2_3 41_51_52 42_53 {
			replace n`X'`C'importer_l = 0 if n`X'`C'importer_l==. & samebuilding_importer_l!=.
	}
}
* get the number of peers importing different product categories 
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach C in 1_6 2_3 41_51_52 42_53 {
		gen o`A'`C'importer_l=num`A'_importer_l-n`A'`C'importer_l
		sum o`A'`C'importer_l
		gen byte d`A'`C'importer_l=o`A'`C'importer_l>0 & o`A'`C'importer_l!=.
		tab d`A'`C'importer_l
		replace d`A'`C'importer_l=. if samebuilding_importer_l==.
		tab d`A'`C'importer_l
	}
}
* add the first year of importing a product in a specific category by firm and source country
rename tax_id id8
merge m:1 id8 country using "`in'/import_minyear_by_bec.dta"
drop if _merge==2
rename minyear* minimpyear*
drop _merge
* create importer and not-yet-importer dummies by source country and product category
foreach X in 1_6 2_3 42_53 41_51_52{
	gen not_yet_imp`X'=year<=minimpyear`X'
	gen importer`X'=year>=minimpyear`X'
}
foreach X in 1_6 2_3 42_53 41_51_52{
	foreach Z in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		replace `Z'_`X'importer_l=. if `Z'_importer_l==.
		replace d`Z'`X'importer_l=. if `Z'_importer_l==.
	}
}
* estimate the effect of peers having experience with the same product category by product category
foreach Y in 1_6 2_3 41_51_52 42_53{
	local RHS ""
	foreach T in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
		local RHS "`RHS' d`T'`Y'importer_l `T'_`Y'importer_l"
	}
	capture noisily areg importer`Y' not_yet_importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_imp`Y'==1, cluster(address) absorb(firmyear)
	outreg2 using "`out'/Table_notyetimp_sameind_sameprod.xls", label ctitle("import same-product bec `Y'") excel append
	* test if spillover from same-product peers is different
	quietly{
		log using "`out'/ttest_notyetimp_sameind_sameprod.txt", append text
		foreach X in samebuilding neighbor2 pneighbor{
			noisily test `X'_`Y'importer_l=d`X'`Y'importer_l
		}
		log close
	}	
}
* baseline probability of starting to import (firms in the estimation sample which have no peers with any country-specific experience
gen byte sample_wo_exp_peers = robustvar==1 & year>=1994 & neighbor1_importer_l==0 & neighbor2_importer_l==0 & samebuilding_importer_l==0 & pneighbor_importer_l==0 & oneighbor_importer_l==0 & neighbor1_exporter_l==0 & neighbor2_exporter_l==0 & samebuilding_exporter_l==0 & pneighbor_exporter_l==0 & oneighbor_exporter_l==0 & neighbor1_owner_l==0 & neighbor2_owner_l==0 & samebuilding_owner_l==0 & pneighbor_owner_l==0 & oneighbor_owner_l==0
foreach Y in 1_6 2_3 41_51_52 42_53{
	tabout importer`Y' if sample_wo_exp_peers==1 & not_yet_imp`Y'==1 using "`out'/baseline_hazard_imp_ind_prod.txt", c(col) f(2c) clab(`Y') append
}



**************************************************************************************
* Figure 1 - Effect of experienced peer moving into building on same-country imports *
**************************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
xtset groupid year
* flag movers in the year of the move
gen byte mover=L.address!=address & address!=. & L.address!=.
* flag movers with previous import experience from the country in the year of the move
gen byte expmover=L.importer==1 & mover==1
* flag all firms in an address in such a year when there was a mover (including the mover)
egen addry_w_mover=max(mover), by(year address)
* flag all firm-country pairs in an address in such a year when there was a mover (including the mover) with previous import experience from the country
egen addry_w_expmover=max(expmover), by(year address country)
* flag address-country pairs in those years when there was no country-specific same-building or neighbor-building import experience in t-1
gen byte noprevexpinaddress=neighbor2_importer_l==0 & samebuilding_importer_l==0 & address==L.address
egen no_prevexp_in_address=max(noprevexpinaddress), by(address country year)
drop noprevexpinaddress
* add number of importer peers
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Y in exporter owner {
		cap drop `X'_`Y'_l 
		cap drop num`X'_`Y'_l 
	}
}
gen importer_mover=importer*mover
* number of movers on the address importing from the country up to year t 
egen numimpmovers=sum(importer_mover), by(country year address)
* number of importers in year t 
egen numimporter=sum(importer), by(address year country)
xtset groupid year
gen byte noexpinaddress=F.neighbor2_importer_l==0 & numimporter-numimpmovers==0 
* flag all firm-country pairs on an address in year t, where no import experience up to t in same or neighboring building, apart from an importer firm moving in
egen no_exp_in_address=max(noexpinaddress), by(address country year)
drop noexpinaddress
* create the estimation sample
gen byte in_smpl=addry_w_mover==1 & mover!=1 & no_prevexp_in_address==1 & no_exp_in_address==1 & robustvar==1 & year>=1994 & not_yet_importer==1 
egen in_sample=max(in_smpl), by(tax_id country)
* create the year of the first event for each firm: first time a mover comes to the firm's address and there is no country-specific experience in same and neighbor building at that time
gen event_y=year if in_smpl==1
egen year_of_event=min(event_y) if in_sample==1, by(tax_id)
tab year_of_event
* the average number of incumbent firms in a building with a mover by the time of the move for events in 1994-1998 where event-year 5 is still in our data
preserve
egen numfirminbdg=count(tax_id), by(address year country)
egen nummover=sum(mover), by(address year country)
gen numfirminbdg_wo_mover=numfirminbdg-nummover
noisily assert numfirminbdg_wo_mover>=0
collapse (min) numfirminbdg_wo_mover if year==year_of_event & robustvar==1 & year>=1994 & year<=1998 & in_sample==1 , by(address country year)
estpost sum numfirminbdg_wo_mover
esttab using "`out'/numfirms_in_bdngs_w_mover.txt", cells("mean(fmt(3)) sd(fmt(3))") title("# incumbents in buildings with movers") nomtitle nonumber replace
restore
* create the estimation sample when the mover has country-specific experience
gen byte yoe_exp=year==year_of_event & addry_w_expmover==1
egen in_sample_exp=max(yoe_exp), by(tax_id country)
tab in_sample in_sample_exp, m
tab year_of_event in_sample, m
tab year_of_event in_sample_exp, m
* create event-year dummies
foreach X of numlist 0/7{
	local Z=8-`X'
	gen byte ey_`Z'=year==year_of_event-`Z'
}
foreach X of numlist 0/9{
	gen byte ey`X'=year==year_of_event+`X'
}
* interact event-year dummies with experienced mover dummy
foreach X of numlist 0/7{
	local Z=8-`X'
	gen ey_exp_`Z'=ey_`Z'*in_sample_exp
}
foreach X of numlist 0/9{
	gen ey_exp`X'=ey`X'*in_sample_exp
}
* assign a single dummy to event-years more than 5 or less then -5
gen ey_5plus=ey_5
replace ey_5plus=1 if ey_6==1 | ey_7==1 | ey_8==1 
gen ey5plus=ey5
replace ey5plus=1 if ey6==1 | ey7==1 | ey8==1 | ey9==1
gen ey_exp_5plus=ey_exp_5
replace ey_exp_5plus=1 if ey_exp_6==1 | ey_exp_7==1 | ey_exp_8==1 
gen ey_exp5plus=ey_exp5
replace ey_exp5plus=1 if ey_exp6==1 | ey_exp7==1 | ey_exp8==1 | ey_exp9==1
* OLS regression
capture noisily reg importer ey1-ey4 ey5plus ey_exp1-ey_exp4 ey_exp5plus if (ey1==1 | ey2==1 | ey3==1 | ey4==1 | ey5plus==1) & robustvar==1 & year>=1994 & in_sample==1, nocons cluster(address) 
outreg2 using "`out'/Table_mover_event_study_new.xls", label ctitle("base") excel replace
* plot from the OLS regression
matrix Var=e(V)
matrix beta=e(b)'
matrix M_int=beta[6..10,1]
matrix M_int=(0\ M_int)
svmat float M_int
matrix var_diag=vecdiag(Var)'
matrix M_int_ste=var_diag[6..10,1]
matrix M_int_ste=(0\ M_int_ste)
svmat float M_int_ste
gen ste_M_int=(M_int_ste1)^0.5
gen upper=M_int1+1.96*ste_M_int
gen lower=M_int1-1.96*ste_M_int
egen y=seq() if M_int1!=.
replace y=y-1
foreach X in M_int1 upper lower{
	replace `X'=`X'*100
}
line M_int1 y, lwidth(thick) || line upper y, lcolor(navy) lpattern(dash) lwidth(thick) || line lower y, lcolor(navy) lpattern(dash) lwidth(thick) legend(off) title(" ") yline(0) ylabel(-0.5(0.5)2.5) xline(0) xtitle("event-year after the mover comes") ytitle("% points") xlabel(0(1)5) graphregion(color(white))
graph export "`out'/Plot_event_study_OLS.pdf", replace
drop *M_int* upper lower y 
* FE regression
capture noisily areg importer ey1-ey4 ey5plus ey_exp1-ey_exp4 ey_exp5plus _Icountryye_* if (ey1==1 | ey2==1 | ey3==1 | ey4==1 | ey5plus==1) & robustvar==1 & year>=1994 & in_sample==1, cluster(address) absorb(firmyear) 
outreg2 using "`out'/Table_mover_event_study_new.xls", label ctitle("fy FE cy FE") excel append
* plot from the FE regression
matrix Var=e(V)
matrix beta=e(b)'
matrix M_int=beta[6..10,1] 
matrix M_int=(0\ M_int) 
svmat float M_int
matrix var_diag=vecdiag(Var)'
matrix M_int_ste=var_diag[6..10,1]
matrix M_int_ste=(0\ M_int_ste)
svmat float M_int_ste
gen ste_M_int=(M_int_ste1)^0.5
gen upper=M_int1+1.96*ste_M_int
gen lower=M_int1-1.96*ste_M_int
egen y=seq() if M_int1!=.
replace y=y-1
foreach X in M_int1 upper lower{
	replace `X'=`X'*100
}
line M_int1 y, lwidth(thick) || line upper y, lcolor(navy) lpattern(dash) lwidth(thick) || line lower y, lcolor(navy) lpattern(dash) lwidth(thick) legend(off) title(" ") yline(0) ylabel(-0.5(0.5)2.5) xline(0) xtitle("event-year after the mover comes") ytitle("% points") xlabel(0(1)5) graphregion(color(white))
graph export "`out'/Plot_event_study_FE.pdf", replace
drop *M_int* upper lower y



*************************************************************************************************************
* Figure 2 - Distribution of the 5-year social multiplier for firms with non-importer peers in the building *
*************************************************************************************************************



tempfile torestore teffect
* define a program for calculating the T-year multiplier effect of treating X random firms in different buildings
program define get_multiplier_by_bdng, rclass
	local X "$X"
	local T "$T"
	preserve
	local r1=rand[$i ,1] 
	set seed `r1'
	gen rand=uniform()
	sort address country rand
	collapse (first) rand_teffect_in_bdng=t`T'_effect, by(address country)
	local r2=rand[$i ,2] 
	set seed `r2'
	gen rand=uniform()
	sort rand
	sum rand_teffect_in_bdng if _n<=`X', d
	scalar sp_output=r(sum)
	global i = $i + 1
	restore
end
* get the data to calculate baseline probabilities
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
* get the baseline probability for high-productivity firms (prob_h)
tab importer if robustvar==1 & year>=1994 & not_yet_importer==1 & samebuilding_importer_l==0 & prod_quartile_y_robust4==1
* get the baseline probability for low-productivity firms (prob_l)
tab importer if robustvar==1 & year>=1994 & not_yet_importer==1 & samebuilding_importer_l==0 & prod_quartile_y_robust4!=1
* give the previously calculated firm-peer productivity group-specific spillovers (from Table 11)
local effect_ll=0.00121
local effect_lh=0.00159
local effect_hl=0.00311
local effect_hh=0.00729
local prob_l=0.00177
local prob_h=0.00472
set matsize 3000
* do the calculations for 1-5 years separately
foreach T of numlist 1/5{
	* create the transition matrix separately for building size 2-50
	foreach N of numlist 2/50{
		display "`N'"
		local colnum=(`N'+1)*`N'*0.5
		matrix M_result_low_`N'=J(`N',`colnum',.)
		matrix M_result_high_`N'=J(`N',`colnum',.)
		foreach N1 of numlist 0/`N'{
			local trans_m_size=(`N1'+1)*(`N'-`N1'+1)
			local N2=`N'-`N1'
			matrix M_A=J(`trans_m_size',`trans_m_size',0)
			foreach K1 of numlist 0/`N1'{
				foreach K2 of numlist 0/`N2'{
					foreach L1 of numlist 0/`N1'{
						foreach L2 of numlist 0/`N2'{
							if `K1'<=`L1' & `K2'<=`L2' {
								local t_row=`K2'*(`N1'+1)+`K1'+1
								local t_col=`L2'*(`N1'+1)+`L1'+1
								matrix M_A[`t_row',`t_col']=comb(`N1'-`K1',`L1'-`K1')*((`prob_l'+`K1'*`effect_ll'+`K2'*`effect_lh')^(`L1'-`K1'))*((1-`prob_l'-`K1'*`effect_ll'-`K2'*`effect_lh')^(`N1'-`L1'))*comb(`N2'-`K2',`L2'-`K2')*((`prob_h'+`K1'*`effect_hl'+`K2'*`effect_hh')^(`L2'-`K2'))*((1-`prob_h'-`K1'*`effect_hl'-`K2'*`effect_hh')^(`N2'-`L2'))
							}
						}
					}
				}
			}
			matrix M_A2=M_A*M_A
			matrix M_A3=M_A2*M_A
			matrix M_A4=M_A3*M_A
			matrix M_A5=M_A4*M_A
			matrix N_COL=J(`trans_m_size',1,0)
			foreach L1 of numlist 0/`N1'{
				foreach L2 of numlist 0/`N2'{
					local t_col=`L2'*(`N1'+1)+`L1'+1
					matrix N_COL[`t_col',1]=`L1'+`L2'
				}
			}
			foreach m in `T'{
				if "`m'"=="1"{
					local n ""
				}
				else{
					local n=`m'
				}
				matrix M_A`n'_m=M_A`n'*N_COL
				local N1_0=`N1'-1
				local N2_0=`N2'-1
				if `N1'>0{
					foreach s1 of numlist 0/`N1_0'{
						foreach s2 of numlist 0/`N2'{
							local m0_row=`s2'*(`N1'+1)+`s1'+1
							local m1_row=`s2'*(`N1'+1)+`s1'+2	
							scalar diff`n'_`s1'_`s2'=M_A`n'_m[`m1_row',1]-M_A`n'_m[`m0_row',1]
							local M_col=(`s1'+`s2'+1)*(`s1'+`s2')*0.5+`s1'+1
							matrix M_result_low_`N'[`N1',`M_col']=diff`n'_`s1'_`s2'
						}
					}
				}
				if `N2'>0{
					foreach s1 of numlist 0/`N1'{
						foreach s2 of numlist 0/`N2_0'{
							local m0_row=`s2'*(`N1'+1)+`s1'+1
							local m1_row=(`s2'+1)*(`N1'+1)+`s1'+1
							scalar diff`n'_`s1'_`s2'=M_A`n'_m[`m1_row',1]-M_A`n'_m[`m0_row',1]
							local M_col=(`s1'+`s2'+1)*(`s1'+`s2')*0.5+`s1'+1
							matrix M_result_high_`N'[`N1'+1,`M_col']=diff`n'_`s1'_`s2'
						}
					}
				}		
			}
		}
	}
	* normalized version
	foreach N of numlist 2/50{
		display "`N'"
		matrix M_result_low_`N'_norm=M_result_low_`N'
		matrix M_result_high_`N'_norm=M_result_high_`N'
		foreach N1 of numlist 0/`N'{
			local N2=`N'-`N1'
			local n=`T'
			local m=`n'
			local N1_0=`N1'-1
			local N2_0=`N2'-1
			if `N1'>0{
				foreach s1 of numlist 0/`N1_0'{
					foreach s2 of numlist 0/`N2'{
						local M_col=(`s1'+`s2'+1)*(`s1'+`s2')*0.5+`s1'+1
						matrix M_result_low_`N'_norm[`N1',`M_col']=M_result_low_`N'_norm[`N1',`M_col']/((1-`prob_l')^`n')
					}
				}
			}
			if `N2'>0{
				foreach s1 of numlist 0/`N1'{
					foreach s2 of numlist 0/`N2_0'{
						local M_col=(`s1'+`s2'+1)*(`s1'+`s2')*0.5+`s1'+1
						matrix M_result_high_`N'_norm[`N1'+1,`M_col']=M_result_high_`N'_norm[`N1'+1,`M_col']/((1-`prob_h')^`n')
					}
				}
			}		
		}
	}
	* get the data to calculate the T-year social multiplier
	use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
	drop si*_l su*_l si*_l_a su*_l_a
	merge 1:1 tax_id year country using "`in'/db_numneighbors_prod_robust_rovat_13.dta", update
	drop _merge
	merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
	drop _merge
	merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
	drop if _merge==2
	drop _merge
	cap drop *exporter* *owner* 
	cap drop *_l_a 
	* get the number of firms and importers (both total and high-productivity)
	egen numfirms=count(tax_id), by(address year country)
	egen numimporters=sum(importer), by(address year country)
	gen byte firm_high=prod_quartile_y_robust4==1
	gen byte importer_high=firm_high*importer
	egen numfirms_high=sum(prod_quartile_y_robust4), by(address year country)
	egen numimporters_high=sum(importer_high), by(address year country)
	* keep year 2003, non-importer firms in buildings with at most 50 firms which have at least another non-importer firm (by country)
	keep if year==2003
	keep if importer==0
	keep if robustvar==1
	keep if numfirms>1 & numimporters+1<numfirms
	sum tax_id
	keep tax_id year country address firm_high numfirms numfirms_high numimporters numimporters_high
	* calculate the T-year effect and the social multiplier
	gen row_num_Ml=numfirms-numfirms_high
	gen row_num_Mh=numfirms-numfirms_high+1
	gen col_num_Mlh=numimporters*(numimporters+1)*0.5+(numimporters-numimporters_high)+1
	gen t`T'_effect_norm=.
	foreach N of numlist 2/50{
		replace t`T'_effect_norm=M_result_low_`N'_norm[row_num_Ml,col_num_Mlh] if numfirms==`N' & firm_high==0
		replace t`T'_effect_norm=M_result_high_`N'_norm[row_num_Mh,col_num_Mlh] if numfirms==`N' & firm_high==1
	}
	tab numfirms if t`T'_effect_norm==.
	sort t`T'_effect_norm
	gen perc=_n/_N
	sum t`T'_effect_norm, d
	list perc if t`T'_effect_norm==r(p90)
	* create the T-year multiplier plot
	preserve
	gen todrop=mod(_n,500)
	keep if todrop==437 | _n==1
	line t`T'_effect_norm perc, xtitle("percentile") ytitle("") xline(0.5) xlabel(0(0.1)1) ylabel(0.8(0.2)1.8) graphregion(color(white))
	graph export "`out'/distrib_of_`T'year_social_multiplier_by_prod_norm_small.pdf", replace
	restore
	* save percentiles of the T-year social multiplier
	quietly{
		log using "`out'/multiplier_calc_`T'.txt", replace text
		noisily display "Distribution of the social multiplier"
		noisily sum t`T'_effect_norm, d
		log close
	}
	* get the T-year treatment effect
	gen num_not_yet_imp= numfirms-numimporters
	gen spillover= t`T'_effect_norm-1
	gen t`T'_effect=.
	foreach N of numlist 2/50{
		replace t`T'_effect=M_result_low_`N'[row_num_Ml,col_num_Mlh] if numfirms==`N' & firm_high==0
		replace t`T'_effect=M_result_high_`N'[row_num_Mh,col_num_Mlh] if numfirms==`N' & firm_high==1
	}
	tab numfirms if t`T'_effect==.
	sort t`T'_effect
	gen perc2=_n/_N
	* create the T-year treatment effect plot
	preserve
	gen todrop=mod(_n,500)
	keep if todrop==437 | _n==1
	line t`T'_effect perc2, xtitle("percentile") ytitle("") xline(0.5) xlabel(0(0.1)1) graphregion(color(white))
	graph export "`out'/distrib_of_`T'year_treatment_effect_by_prod_norm_small.pdf", replace
	restore
	* save percentiles of the T-year treatment effect
	quietly{
		log using "`out'/multiplier_calc_`T'.txt", append text
		noisily display "Distribution of the treatment effect"
		noisily sum t`T'_effect, d
		log close
	}
	* take the top 1000 treatment effect firms which belong to different building-country pairs:
	local X 1000
	preserve
	collapse (max) max_teffect_in_bdng=t`T'_effect, by(address country)
	gsort -max_teffect_in_bdng
	quietly{
		log using "`out'/multiplier_calc_`T'.txt", append text
		noisily display "The number of importers induced to import by the top `X' firms located in different buildings"
		noisily sum max_teffect_in_bdng if _n<=`X', d
		noisily display r(sum)
		log close
	}
	restore
	* bootstrap for random 1000 (# of building-country pairs) firms:
	gen id=_n
	local X 1000 
	global X "`X'"
	global T "`T'"
	global i 1
	set seed 170418
	gen r1=uniform() if _n<=1000
	gen r2=uniform() if _n<=1000
	mkmat r1 r2 if _n<=1000, matrix(rand)
	drop r1 r2
	bootstrap sp_output, reps(1000) cluster(id) idcluster(id_clust) saving("`out'/bootstrap_by_address`X'_`T'", replace): get_multiplier_by_bdng
	matrix beta=e(b)'
	matrix conf_int=e(ci_normal)'
	matrix conf_int_low=conf_int[1,1]
	matrix conf_int_high=conf_int[1,2]
	svmat float beta
	svmat float conf_int_low
	svmat float conf_int_high
	quietly{
		log using "`out'/multiplier_calc_`T'.txt", append text
		noisily display "The number of importers induced to import by a random sample of `X' firms located in different buildings, bootstrap sampling with 1000 repetitions"
		noisily display "mean:"
		noisily display beta
		noisily display "lower bound of the confidence interval:"
		noisily display conf_int_low
		noisily display "upper bound of the confidence interval:"
		noisily display conf_int_high
		log close
	}
}



*****************************************************************************
* Table A1: Share of importers with different patterns of experienced peers * 
*****************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
keep if year>=1994
* get experience type of peers
foreach X in export import own{
	foreach Y in "" _a{
		gen byte `X'_experience_l`Y'=neighbor1_`X'er_l`Y'==1 | neighbor2_`X'er_l`Y'==1 | samebuilding_`X'er_l`Y'==1 | pneighbor_`X'er_l`Y'==1 | oneighbor_`X'er_l`Y'==1
	}
}
* get type of peers
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Y in "" _a{
		gen byte `X'_l`Y'=`X'_exporter_l`Y'==1 | `X'_importer_l`Y'==1 | `X'_owner_l`Y'==1
	}
}
* peer experience patterns - general and country-specific
foreach X in spec ""{
	if "`X'"==""{
		local Y _a
	}
	else if "`X'"=="spec"{
		local Y ""
	}
	* by type of experience
	gen `X'exp_type="none" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'exp_type="exponly" if export_experience_l`Y'==1 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'exp_type="imponly" if export_experience_l`Y'==0 & import_experience_l`Y'==1 & own_experience_l`Y'==0 
	replace `X'exp_type="ownonly" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==1 
	replace `X'exp_type="expimponly" if export_experience_l`Y'==1 & import_experience_l`Y'==1 & own_experience_l`Y'==0 
	replace `X'exp_type="expownonly" if export_experience_l`Y'==1 & import_experience_l`Y'==0 & own_experience_l`Y'==1 
	replace `X'exp_type="impownonly" if export_experience_l`Y'==0 & import_experience_l`Y'==1 & own_experience_l`Y'==1 
	replace `X'exp_type="expimpown" if export_experience_l`Y'==1 & import_experience_l`Y'==1 & own_experience_l`Y'==1 
	* by type of peer
	gen `X'peer_type="none" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'peer_type="geoonly" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==0 & oneighbor_l`Y'==0
	replace `X'peer_type="personly" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==1 & oneighbor_l`Y'==0
	replace `X'peer_type="ownonly" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==0 & oneighbor_l`Y'==1
	replace `X'peer_type="geopersonly" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==1 & oneighbor_l`Y'==0
	replace `X'peer_type="geoownonly" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==0 & oneighbor_l`Y'==1
	replace `X'peer_type="persownonly" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==1 & oneighbor_l`Y'==1
	replace `X'peer_type="geopersown" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==1 & oneighbor_l`Y'==1
}
* share of importers by peer experience patterns
tabout specexp_type using "`out'/peer_patterns.txt", cells(mean importer) f(3c) replace sum	
tabout specpeer_type using "`out'/peer_patterns.txt", cells(mean importer) f(3c) append sum	
tabout exp_type using "`out'/peer_patterns.txt", cells(mean importer) f(3c) append sum	
tabout peer_type using "`out'/peer_patterns.txt", cells(mean importer) f(3c) append sum	



******************************************************************************
* Table A2: Share of importers with different numbers of same-building peers *
******************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
keep if year>=1994
* number of peers and importer peers in the same building
egen numneighbors=count(tax_id), by(address year country)
replace numneighbors=numneighbors-1
egen numimpneighbor=sum(importer), by(address year country)
replace numimpneighbor=numimpneighbor-importer
sum num*
keep if robustvar==1 
sum num*
* distribution of # same-building peers
sum numneighbors, d
foreach X in 25 50 75 90{
	scalar c`X' = r(p`X')
}
* distribution of # same-building importer peers
sum numimpneighbor, d
* share of importers by the number of peers and importer peers in the same building
tabout numneighbors if numneighbors==c25 | numneighbors==c50 | numneighbors==c75 | numneighbors==c90 using "`out'/impshare_by_numpeers_in_bdng.txt", cells(mean importer N importer) f(3c 0c) replace sum
tabout numimpneighbor if numimpneighbor==0 | numimpneighbor==1 | numimpneighbor==2 using "`out'/impshare_by_numpeers_in_bdng.txt", cells(mean importer N importer) f(3c 0c) append sum



***************************************************************
* Table A3: Effect of peer experience on same-country imports *
***************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* only for the period 1999-2003
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1999 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_full.xls", label ctitle("from 1999") excel replace
* controlling for country-specific exporter and owner experience of the firm
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l exporter owner _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_full.xls", label ctitle("country_spec_control") excel append
* all 3 types of peers with import and export experience 
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_full.xls", label ctitle("import & export experience all types") excel append
* all 3 types of peers with import and ownership experience 
capture noisily areg importer samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_owner_l neighbor2_owner_l neighbor1_owner_l pneighbor_owner_l oneighbor_owner_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_full.xls", label ctitle("import & ownership experience all types") excel append




***********************************************************************
* Table A4: Peer effects with different definitions of person network *
***********************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
local RHS1 "samebuilding_importer_l  neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l" 
local RHS2 "samebuilding_importer_l  neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_owner_l neighbor2_owner_l neighbor1_owner_l pneighbor_owner_l oneighbor_owner_l"
* using all people connected to firms
drop pneighbor* 
cap drop neighbor_*
merge 1:1 tax_id year country using "`in'/person_neighbors_all_rovat_toadd.dta", update
drop if _merge==2
drop _merge
cap drop si*_l si*_l_a
cap drop su*_l su*_l_a
foreach Y in "" _a{
	foreach A in p {
		foreach B in exporter importer owner{
				replace `A'neighbor_`B'_l`Y'=0 if `A'neighbor_`B'_l`Y'==.
		}
	}
}
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_person_versions.xls", label ctitle("all_rovat") excel replace
capture noisily areg importer `RHS2' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_person_versions.xls", label ctitle("all_rovat") excel append
* using people with a signing right in the peer and being an onwer in the firm
use "`in'/db_complete_for_running_the_regs_baseline_torun.dta", clear
cap drop si*_l si*_l_a
cap drop su*_l su*_l_a
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_person_versions.xls", label ctitle("sign2own") excel append
capture noisily areg importer `RHS2' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_person_versions.xls", label ctitle("sign2own") excel append



************************************************************
* Table A5: Peer effects with different sample definitions *
************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
local RHS1 "samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l"
local RHS2 "samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_owner_l neighbor2_owner_l neighbor1_owner_l pneighbor_owner_l oneighbor_owner_l"
* all firms with or without import experience
capture noisily areg importer_yearly `RHS1' _Icountryye_* if robustvar==1 & year>=1994 , cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("all yearly imp") excel replace
capture noisily areg importer_yearly `RHS2' _Icountryye_* if robustvar==1 & year>=1994 , cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("all yearly imp") excel append
* include each firm in a single year, but with 4 observations (one for each country) - when it imported for the first time from the group of 4 countries (from any of the 4) and never importer before
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & first_ever_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("first ever importer") excel append
capture noisily areg importer `RHS2' _Icountryye_* if robustvar==1 & year>=1994 & first_ever_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("first ever importer") excel append
* similar to the baseline "not-yet-importer" sample, stricter condition: not imported from any of the 4 countries up to t-1, but can import in t
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & no_importer_experience==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("not yet importer to any") excel append
capture noisily areg importer `RHS2' _Icountryye_* if robustvar==1 & year>=1994 & no_importer_experience==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_alternative_samples.xls", label ctitle("not yet importer to any") excel append



******************************************************************
* Table A6: Effect of peer experience on successful import entry *
******************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_success_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
cap drop *_l_a 
foreach C in "" su {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		assert num`C'`X'_importer_l!=1 if samebuilding_importer_l==.
		replace num`C'`X'_importer_l = 0 if num`C'`X'_importer_l==. & samebuilding_importer_l!=.
	}
}
* take out unsuccessful peers from the number of peers
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen numunsu`A'_importer_l=num`A'_importer_l-numsu`A'_importer_l
	assert numunsu`A'_importer_l>=0 | numunsu`A'_importer_l==.
	sum numunsu`A'_importer_l
	gen byte unsu`A'_importer_l=numunsu`A'_importer_l>0 & numunsu`A'_importer_l!=.
	tab unsu`A'_importer_l
	assert unsu`A'_importer_l!=1 if samebuilding_importer_l==.
	replace unsu`A'_importer_l=. if samebuilding_importer_l==.
	tab unsu`A'_importer_l
}
local RHS1 "samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l"
local suRHS1 "susamebuilding_importer_l unsusamebuilding_importer_l suneighbor2_importer_l unsuneighbor2_importer_l suneighbor1_importer_l unsuneighbor1_importer_l supneighbor_importer_l unsupneighbor_importer_l suoneighbor_importer_l unsuoneighbor_importer_l"
xtset groupid year
* successful entry
capture noisily areg F.importer_s `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_succ_entry.xls", label ctitle("successful import") excel replace
capture noisily areg F.importer_s `suRHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_succ_entry.xls", label ctitle("successful import") excel append
* test if spillover from successful peers is different
quietly{
	log using "`out'/ttest_notyetimp_succ_entry.txt", replace text
	noisily test susamebuilding_importer_l=unsusamebuilding_importer_l
	log close
}
* baseline probability of starting to import (firms in the estimation sample which have no peers with any country-specific experience)
gen byte not_yet_imp_wo_exp_peers = robustvar==1 & year>=1994 & not_yet_importer==1 & neighbor1_importer_l==0 & neighbor2_importer_l==0 & samebuilding_importer_l==0 & pneighbor_importer_l==0 & oneighbor_importer_l==0 & neighbor1_exporter_l==0 & neighbor2_exporter_l==0 & samebuilding_exporter_l==0 & pneighbor_exporter_l==0 & oneighbor_exporter_l==0 & neighbor1_owner_l==0 & neighbor2_owner_l==0 & samebuilding_owner_l==0 & pneighbor_owner_l==0 & oneighbor_owner_l==0
gen f_importer_s=F.importer_s
tabout f_importer_s if not_yet_imp_wo_exp_peers==1 using "`out'/baseline_hazard_succ_imp.txt", c(col) f(2c) clab("nonimp_firms_wo_exp_peers") replace



******************************************************
* Table A7: Heterogeneity of peer effect by industry *
******************************************************



* get the industry of the firms
use "`in'/firm_bsheet_data.dta", clear
rename id8 tax_id
keep tax_id year teaor03_2d_yearly
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
drop teaor03_2d_yearly
tempfile firmchar
save `firmchar'
* heterogeneous effect by the industry of the firm
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop su*_l su*_l_a
drop si*_l si*_l_a
merge m:1 tax_id year using `firmchar'
drop if _merge==2
drop _merge
tab teaor03_1d, m
gen byte teaorABC=teaor03_1d=="A" | teaor03_1d=="B" | teaor03_1d=="C"
gen byte teaorD=teaor03_1d=="D"
gen byte teaorEF=teaor03_1d=="E" | teaor03_1d=="F"
gen byte teaorG=teaor03_1d=="G"
gen byte teaorHI=teaor03_1d=="H" | teaor03_1d=="I"
gen byte teaorJK=teaor03_1d=="J" | teaor03_1d=="K"
gen byte teaorL=teaor03_1d=="L" | teaor03_1d=="M" | teaor03_1d=="N" | teaor03_1d=="O" | teaor03_1d=="P" | teaor03_1d=="Q"
gen byte teaorNA=teaor03_1d==""
foreach X in ABC D EF G HI JK L NA {
	foreach Y in neighbor1_importer_l neighbor2_importer_l samebuilding_importer_l pneighbor_importer_l oneighbor_importer_l{
		gen `Y'`X'=`Y'*teaor`X'
	}
}
local RHSimp1d ""
foreach Y in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach X in ABC D EF G HI JK L NA{
		local RHSimp1d "`RHSimp1d' `Y'`X'"
	}
}
capture noisily areg importer `RHSimp1d' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_by_ind.xls", label ctitle("firm by ind") excel replace

* peers by industry
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge 1:1 tax_id year country using "`in'/db_numneighbors_heterog_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_heterog_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
foreach C in indAC indD indEF indG indHI indJK indLQ {
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
		foreach Z in "" num{
			replace `C'`Z'`X'_importer_l = 0 if `C'`Z'`X'_importer_l==.
		}
	}
}
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{ 
	assert num`X'_importer_l!=. if (indACnum`X'_importer_l==1 | indDnum`X'_importer_l==1 | indEFnum`X'_importer_l==1 | indGnum`X'_importer_l==1 | indHInum`X'_importer_l==1 | indJKnum`X'_importer_l==1 | indLQnum`X'_importer_l==1)
}
* number of peers having no data on industry
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	sum num`X'_importer_l
	gen indNAnum`X'_importer_l = num`X'_importer_l-indACnum`X'_importer_l-indDnum`X'_importer_l-indEFnum`X'_importer_l-indGnum`X'_importer_l-indHInum`X'_importer_l-indJKnum`X'_importer_l-indLQnum`X'_importer_l 
	assert indNAnum`X'_importer_l>=0
	sum indNAnum`X'_importer_l
}
* existence of peers having no data on industry
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen byte indNA`X'_importer_l=indNAnum`X'_importer_l>0 & indNAnum`X'_importer_l!=.
	replace indNA`X'_importer_l=. if `X'_importer_l==.
}
local RHSvars ""
foreach X in samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l{
	foreach Y in indAC indD indEF indG indHI indJK indLQ indNA{
		local RHSvars "`RHSvars' `Y'`X'"
	}
}
display "`RHSvars'"
capture noisily areg importer `RHSvars' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_by_ind.xls", label ctitle("peer by ind") excel append



**********************************************************
* Table A8: Heterogeneity of peer effect by product type *
**********************************************************



* get the experienced peers by Rauch-type product category
use "`in'/db_complete_additional_rauch_rovat_13.dta", clear
merge 1:1 tax_id year country using "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", update
drop _merge
drop si*_l si*_l_a
drop su*_l su*_l_a
foreach Z in n r w{
	foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
		replace `X'_importer_`Z'_l = 0 if  `X'_importer_`Z'_l==. & `X'_importer_n_l!=.
	}
}
* put unclassified goods in group w (groups sold in an organized exchange)
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor {
	replace `X'_importer_w_l=1 if `X'_importer_l==1 & `X'_importer_n_l!=1 & `X'_importer_r_l!=1 & `X'_importer_w_l!=1 
}
local RHS1 ""
foreach X in samebuilding neighbor2 neighbor1 pneighbor oneighbor{
	foreach Y in _w _n _r {
		local RHS1 "`RHS1' `X'_importer`Y'_l"
	}
}
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_Rauch.xls", label ctitle("importer Rauch") excel replace



***************************************************************************
* Table A9: Descriptive statistics for buildings with new firms moving in *
***************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
xtset groupid year
* flag movers in the year of the move
gen byte mover=L.address!=address & address!=. & L.address!=.
* flag movers with previous import experience from the country in the year of the move
gen byte expmover=L.importer==1 & mover==1
* flag all firms in an address in such a year when there was a mover (including the mover)
egen addry_w_mover=max(mover), by(year address)
* flag all firm-country pairs in an address in such a year when there was a mover (including the mover) with previous import experience from the country
egen addry_w_expmover=max(expmover), by(year address country)
* flag address-country pairs in those years when there was no country-specific same-building or neighbor-building import experience in t-1
gen byte noprevexpinaddress=neighbor2_importer_l==0 & samebuilding_importer_l==0 & address==L.address
egen no_prevexp_in_address=max(noprevexpinaddress), by(address country year)
drop noprevexpinaddress
* add number of importer peers
merge 1:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop _merge
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Y in exporter owner {
		cap drop `X'_`Y'_l 
		cap drop num`X'_`Y'_l 
	}
}
gen importer_mover=importer*mover
* number of movers on the address importing from the country up to year t 
egen numimpmovers=sum(importer_mover), by(country year address)
* number of importers in year t 
egen numimporter=sum(importer), by(address year country)
xtset groupid year
gen byte noexpinaddress=F.neighbor2_importer_l==0 & numimporter-numimpmovers==0 
* flag all firm-country pairs on an address in year t, where no import experience up to t in same or neighboring building, apart from an importer firm moving in
egen no_exp_in_address=max(noexpinaddress), by(address country year)
drop noexpinaddress
* drop year 1992
keep if year>=1993
quietly{
	log using "`out'/mover_desc.txt", replace text
	noisily display "Number of incumbents and addresses with incumbents - all / having movers / having experienced movers"
	foreach X in "" "& addry_w_mover==1" "& addry_w_expmover==1"{
		noisily display "`X'"
		noisily distinct tax_id if mover==0 `X'
		noisily distinct address if mover==0 `X'
	}
	noisily display "Number of addresses without import experience, and number of incumbents on these addresses - all / having movers / having experienced movers"
	foreach X in "" "& addry_w_mover==1" "& addry_w_expmover==1"{
		noisily display "`X'"
		noisily distinct tax_id if no_exp_in_address==1 & no_prevexp_in_address==1 & mover==0 `X' 
		noisily distinct address if no_exp_in_address==1 & no_prevexp_in_address==1 & mover==0 `X' 
	}
	noisily display "Number of incumbents and addresses with incumbents having experienced movers, by country"
	foreach X in CZ SK RO RU{
		noisily display "`X'"
		noisily distinct tax_id if addry_w_expmover==1 & mover==0  & country=="`X'"
		noisily distinct address if addry_w_expmover==1 & mover==0 & country=="`X'"
	}
	noisily display "Number of addresses without import experience having experienced movers, and number of incumbents on these addresses, by country"
	foreach X in CZ SK RO RU{
		noisily display "`X'"
		noisily distinct tax_id if addry_w_expmover==1 & no_exp_in_address==1 & no_prevexp_in_address==1 & mover==0  & country=="`X'"
		noisily distinct address if addry_w_expmover==1 & no_exp_in_address==1 & no_prevexp_in_address==1 & mover==0 & country=="`X'"
	}
	log close 
}



*************************************************************************************
* Table A10: Effect of experienced peer moving into building on same-country imports *
*************************************************************************************



*see `out'/Table_mover_event_study_new.xls from Figure 1
	
	

************************************************
* Table A11: Peer effect in exporting behavior *
************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* geo-connected export experience
capture noisily areg exporter samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("exporter geo") excel replace
* person-connected export experience
capture noisily areg exporter pneighbor_exporter_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("exporter person") excel append
* owner-connected export experience
capture noisily areg exporter oneighbor_exporter_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("exporter owner") excel append
* all 3 types of peers with export experience
capture noisily areg exporter samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("exporter all types") excel append
* all 3 types of peers with export and import experience 
capture noisily areg exporter samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("export & import experience all types") excel append
* all 3 types of peers with export and ownership experience 
capture noisily areg exporter samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l samebuilding_owner_l neighbor2_owner_l neighbor1_owner_l pneighbor_owner_l oneighbor_owner_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_exporter==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_reg_notyetexp.xls", label ctitle("export & ownership experience all types") excel append
* baseline probability of starting to export (firms in the estimation sample which have no peers with any country-specific experience
gen byte not_yet_exp_wo_exp_peers = robustvar==1 & year>=1994 & not_yet_exporter==1 & neighbor1_importer_l==0 & neighbor2_importer_l==0 & samebuilding_importer_l==0 & pneighbor_importer_l==0 & oneighbor_importer_l==0 & neighbor1_exporter_l==0 & neighbor2_exporter_l==0 & samebuilding_exporter_l==0 & pneighbor_exporter_l==0 & oneighbor_exporter_l==0 & neighbor1_owner_l==0 & neighbor2_owner_l==0 & samebuilding_owner_l==0 & pneighbor_owner_l==0 & oneighbor_owner_l==0
tabout exporter if not_yet_exp_wo_exp_peers==1 using "`out'/baseline_hazard_exp.txt", c(col) f(2c) clab("nonexp_firms_wo_exp_peers") replace



***********************************************************
* Table OA1: Distribution of the number of import markets *
***********************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
keep tax_id year country importer importer_s
keep if year>=1994
collapse (max) importer importer_s, by(tax_id country)
collapse (sum) importer importer_s, by(tax_id)
tabout importer using "`out'/descriptives_by_import_patterns.txt", c(col) f(2c) clab(Importer) replace
tabout importer_s using "`out'/descriptives_by_import_patterns.txt", c(col) f(2c) clab(Successful) append



************************************************************
* Table OA2: Distribution of imports by product categories *
************************************************************



* get import transactions by firm, country, year and hs6 product category
tempfile imports
clear
save `imports', replace emptyok	
* read customs stats
foreach X of any 91 92 93 94 95 96 97 98 99 00 01 02 03 {
	use "`in2'/import/im`X'", clear
	* keep only hs6
	keep i_ft`X' a1 szao hs6
	* rename variables
	ren a1 id8
	ren i_ft`X' imp_value
	ren szao country
	label variable imp_value "imported value in HUF"
	gen int year = 1900+`X'
	replace year=year+100 if year<1950
	* save the data
	compress
	append using `imports'
	save `imports', replace
}
* make invalid hs6 missing
replace hs6=. if hs6==0
* save
save `imports', replace
* assign bec categories to hs6
import delimited using "`in2'/hs6bec.csv", clear
gen bec_cat="1_6" if bec==11 | bec==12 | bec==61 | bec==62 | bec==63
replace bec_cat="2_3" if bec==21 | bec==22 | bec==31 | bec==32
replace bec_cat="42_53" if bec==42 | bec==53
replace bec_cat="41_51_52" if bec==41 | bec==51 | bec==52
drop bec
tempfile bec
save `bec'
use `imports', clear
keep if country=="SK" | country=="CZ" | country=="RO" | country=="RU"
merge m:1 hs6 using `bec'
drop if _merge==2
drop _merge 
save `bec', replace
* keep only firms in Budapest in 1994-2003
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
keep if year>=1994
keep tax_id year
rename tax_id id8
duplicates drop
merge 1:m id8 year using `bec'
keep if _merge==3
tabout bec_cat using "`out'/BEC_descriptives.txt", c(col) f(0c) clab(all) replace mi
foreach X in CZ SK RO RU{
	tabout bec_cat if country=="`X'" using "`out'/BEC_descriptives.txt", c(col) f(0c) clab(`X') append mi
}



******************************************
* Table OA3: Patterns of peer experience *
******************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
keep if year>=1994
* get experience type of peers
foreach X in export import own{
	foreach Y in "" _a{
		gen byte `X'_experience_l`Y'=neighbor1_`X'er_l`Y'==1 | neighbor2_`X'er_l`Y'==1 | samebuilding_`X'er_l`Y'==1 | pneighbor_`X'er_l`Y'==1 | oneighbor_`X'er_l`Y'==1
	}
}
* get type of peers
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach Y in "" _a{
		gen byte `X'_l`Y'=`X'_exporter_l`Y'==1 | `X'_importer_l`Y'==1 | `X'_owner_l`Y'==1
	}
}
* peer experience patterns - general and country-specific
foreach X in spec ""{
	if "`X'"==""{
		local Y _a
	}
	else if "`X'"=="spec"{
		local Y ""
	}
	* by type of experience
	gen `X'exp_type="none" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'exp_type="exponly" if export_experience_l`Y'==1 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'exp_type="imponly" if export_experience_l`Y'==0 & import_experience_l`Y'==1 & own_experience_l`Y'==0 
	replace `X'exp_type="ownonly" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==1 
	replace `X'exp_type="expimponly" if export_experience_l`Y'==1 & import_experience_l`Y'==1 & own_experience_l`Y'==0 
	replace `X'exp_type="other" if export_experience_l`Y'==1 & import_experience_l`Y'==0 & own_experience_l`Y'==1 
	replace `X'exp_type="other" if export_experience_l`Y'==0 & import_experience_l`Y'==1 & own_experience_l`Y'==1 
	replace `X'exp_type="other" if export_experience_l`Y'==1 & import_experience_l`Y'==1 & own_experience_l`Y'==1 
	* by type of peer
	gen `X'peer_type="none" if export_experience_l`Y'==0 & import_experience_l`Y'==0 & own_experience_l`Y'==0 
	replace `X'peer_type="geoonly" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==0 & oneighbor_l`Y'==0
	replace `X'peer_type="personly" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==1 & oneighbor_l`Y'==0
	replace `X'peer_type="ownonly" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==0 & oneighbor_l`Y'==1
	replace `X'peer_type="other" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==1 & oneighbor_l`Y'==0
	replace `X'peer_type="geoownonly" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==0 & oneighbor_l`Y'==1
	replace `X'peer_type="other" if neighbor1_l`Y'==0 & neighbor2_l`Y'==0 & samebuilding_l`Y'==0 & pneighbor_l`Y'==1 & oneighbor_l`Y'==1
	replace `X'peer_type="other" if (neighbor1_l`Y'==1 | neighbor2_l`Y'==1 | samebuilding_l`Y'==1) & pneighbor_l`Y'==1 & oneighbor_l`Y'==1
}
* share of importers by peer experience patterns
tabout specexp_type using "`out'/peer_patterns_1.txt", c(col) f(1c) clab(spec) replace mi
tabout specpeer_type using "`out'/peer_patterns_1.txt", c(col) f(1c) clab(spec) append mi
tabout exp_type using "`out'/peer_patterns_1.txt", c(col) f(1c) clab(all) append mi
tabout peer_type using "`out'/peer_patterns_1.txt", c(col) f(1c) clab(all) append mi	
* get other patterns by type of experience

* get other patterns by peer group



**************************************************
* Table OA4: Size and composition of firm groups *
**************************************************



* get size groups and ownership
use "`in'/firm_bsheet_data.dta", clear
keep id8 year empl fo2
rename id8 tax_id
gen size=1 if empl<=5
replace size=2 if empl>5 & empl<=20
replace size=3 if empl>20 & empl<=100
replace size=4 if empl>100 & empl!=.
keep tax_id year size fo2
tempfile firmchar
save `firmchar'
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge m:1 tax_id year using `firmchar'
drop if _merge==2
drop _merge
* get productivity groups
merge 1:1 tax_id country year using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
rename prod_quartile_y_robust? prod?
gen prod=1 if prod1==1
replace prod=2 if prod2==1
replace prod=3 if prod3==1
replace prod=4 if prod4==1
replace size=0 if size==.
replace prod=0 if prod==.
replace fo2=0 if fo2==.
tabout size if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", c(col) f(1c) clab(not-yet-imp) replace 
tabout prod if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", c(col) f(1c) clab(not-yet-imp) append 
tabout fo2 if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", c(col) f(1c) clab(not-yet-imp) append 
tabout size if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 
tabout prod if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 
tabout fo2 if robustvar==1 & year>=1994 & not_yet_importer==1 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 
tabout size if robustvar==1 & year>=1994 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 
tabout prod if robustvar==1 & year>=1994 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 
tabout fo2 if robustvar==1 & year>=1994 using "`out'/firm_group_desc.txt", cells(mean importer) f(3c) append sum 



************************************************************
* Table OA5: Heterogeneity of peer effect across receivers *
************************************************************



*see `out'/Table_notyetimp_firmgroups.xls and `out'/ttest_notyetimp_firmgroups.txt from Table 7



********************************************************
* Table OA6: Heterogeneity of peer effect across peers *
********************************************************



*see `out'/Table_notyetimp_neighbor_heterog.xls and `out'/ttest_notyetimp_neighbor_heterog.txt from Table 8


	
********************************************************************
* Table OA7: Effect of peer experience within industry and product *
********************************************************************



*see `out'/Table_notyetimp_sameind_sameprod.xls and `out'/ttest_notyetimp_sameind_sameprod.txt from Table 12



*********************************************************************************
* Table OA8: Effect of peer experience on same-country and same-product imports *
*********************************************************************************



use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* keep only the first importers from a country
keep if robustvar==1 & year>=1994 & not_yet_importer==1 & importer==1
drop *exporter* *owner* *_a importer_s importer_yearly first_ever* *experience* importer
* create a separate observation for each product category
expand 4
egen check=seq(), by(tax_id year country)
gen bec="1_6" if check==1
replace bec="2_3" if check==2
replace bec="41_51_52" if check==3
replace bec="42_53" if check==4
drop check
rename tax_id id8
* add data on the first year of imports by country and product category for each firm
merge m:1 id8 country using "`in'/import_minyear_by_bec.dta"
drop if _merge==2
drop _merge
* create an importer dummy showing that the first importing firm imported the given product category from the country
gen importer=0
foreach X in 1_6 2_3 41_51_52 42_53{
	replace importer=1 if year>=minyear`X' & bec=="`X'"
}
* get peers having experience in the specific product category
rename id8 tax_id 
merge m:1 tax_id year country using "`in'/db_numneighbors_rovat_13.dta", update
drop if _merge==2
drop _merge
merge m:1 tax_id year country using "`in'/db_numneighbors_bec_rovat_13.dta", update
drop if _merge==2
drop _merge
merge m:1 tax_id year country using "`in'/db_complete_for_running_the_regs_bec_rovat_13.dta", update
drop if _merge==2
drop _merge
cap drop *exporter* *owner* 
cap drop *_l_a 
* get the number of peers importing different product categories 
foreach X in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	replace num`X'_importer_l = 0 if num`X'_importer_l==. & samebuilding_importer_l!=.
	foreach C in 1_6 2_3 41_51_52 42_53 {
			replace n`X'`C'importer_l = 0 if n`X'`C'importer_l==. & samebuilding_importer_l!=.
	}
}
foreach A in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach C in 1_6 2_3 41_51_52 42_53 {
		gen o`A'`C'importer_l=num`A'_importer_l-n`A'`C'importer_l
		sum o`A'`C'importer_l
		gen byte d`A'`C'importer_l=o`A'`C'importer_l>0 & o`A'`C'importer_l!=.
		tab d`A'`C'importer_l
		replace d`A'`C'importer_l=. if samebuilding_importer_l==.
		tab d`A'`C'importer_l
	}
}
foreach Y in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	gen `Y'_importer_same=0
	gen `Y'_importer_diff=0
	foreach X in 1_6 2_3 41_51_52 42_53{
		replace `Y'_importer_same = 1 if bec=="`X'" & `Y'_`X'importer_l==1
		replace `Y'_importer_same = . if samebuilding_importer_l==.
		replace `Y'_importer_diff = 1 if bec=="`X'" & d`Y'`X'importer_l==1
		replace `Y'_importer_diff = . if samebuilding_importer_l==.
	}
}
foreach Y in neighbor1 neighbor2 samebuilding pneighbor oneighbor{
	foreach X in 1_6 2_3 41_51_52 42_53{
		drop `Y'_`X'importer_l d`Y'`X'importer_l o`Y'`X'importer_l n`Y'`X'importer_l 
	}
}
local RHSimp "samebuilding_importer_diff samebuilding_importer_same neighbor2_importer_diff neighbor2_importer_same neighbor1_importer_diff neighbor1_importer_same pneighbor_importer_diff pneighbor_importer_same oneighbor_importer_diff oneighbor_importer_same"
drop _Icountryye_*
capture noisily areg importer `RHSimp' i.countryyear, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_by_same_bec_first_ever_imp.xls", label ctitle("by bec") excel replace
quietly{
	log using "`out'/ttest_by_same_bec_first_ever_imp.txt", replace text
	noisily test samebuilding_importer_same=samebuilding_importer_diff
	log close
}



********************************
* Table OA9: Robustness checks *
********************************



* ownership-connected peers not excluded from the group of closely located and person-connected peers
use "`in'/db_complete_for_running_the_regs_no_exclusion_rovat_13.dta", clear
local RHS "samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l"
capture noisily areg importer `RHS' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_robust.xls", label ctitle("no control for ownership") excel replace
* subsample: firms not having ownership experience from any of the four countries
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
local RHS1 "samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_exporter_l neighbor2_exporter_l neighbor1_exporter_l pneighbor_exporter_l oneighbor_exporter_l"
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & f_owner==0 & owner==0, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_robust.xls", label ctitle("importer not 4country-owned") excel append
local RHS1 "samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l samebuilding_owner_l neighbor2_owner_l neighbor1_owner_l pneighbor_owner_l oneighbor_owner_l"
capture noisily areg importer `RHS1' _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & f_owner==0 & owner==0, cluster(address) absorb(firmyear)
outreg2 using "`out'/Table_notyetimp_robust.xls", label ctitle("importer not 4country-owned") excel append



**********************************************************************
* Table OA10: Comparing importers with and without experienced peers *
**********************************************************************



* get data on firm characteristics
use "`in'/firm_bsheet_data.dta", clear
keep id8 year lempl teaor03_2d lVA_per_capita exp_share exp_sales exp_value fo2 minyear 
replace exp_share=0 if exp_share==. & (exp_sales==. | exp_sales==0) & (exp_value==0 | exp_value==.)
drop exp_sales exp_value
gen lage=log(year-minyear+1)
drop minyear
rename id8 tax_id
tempfile bsheet
save `bsheet'
* get yearly import values by country
tempfile imports
clear
save `imports', replace emptyok
foreach X of any 91 92 93 94 95 96 97 98 99 00 01 02 03 {
	use "`in2'/import/im`X'.dta", clear
	keep i_ft`X' a1 szao hs6
	ren a1 id8
	ren szao country
	ren i_ft`X' imp_value
	label variable imp_value "imported value in HUF"
	gen int year = 1900+`X'
	replace year=year+100 if year<1950
	compress
	append using `imports'
	save `imports', replace
}
replace hs6=. if hs6==0
keep if inlist(country,"CZ","SK","RO","RU")
collapse (sum) imp_value, by( id8 country year)
rename id8 tax_id
* monetary values expressed in 1000 HUF
replace imp_value=imp_value/1000
save `imports', replace
* add the industry of firms
use `bsheet', clear
keep tax_id year teaor03_2d
rename teaor03_2d nace2
tempfile nace
save `nace'
use `imports', clear
merge m:1 tax_id year using `nace'
drop if _merge==2
drop _merge
* deflate import value with PPI of the corresponding 2-digit industry
merge m:1 year nace2 using "`in3'/PPI.dta"
drop if _merge==2
drop _merge nace2 dom_PPI materialPPI exp_PPI
save `imports', replace
* if nace2 is incorrect or unknown average PPI attached (used for services) 
use "`in3'/PPI.dta", clear
keep if nace2==99
drop nace2
drop dom_PPI materialPPI exp_PPI
rename PPI PPI_
merge 1:m year using `imports'
drop if _merge==1
replace PPI=PPI_ if PPI==.
drop PPI_  _merge
replace imp_value=imp_value/PPI
save `imports', replace
* add firm charachteristics and data on import values to the baseline dataset
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
merge m:1 tax_id year using `bsheet'
drop if _merge==2
drop _merge
merge 1:1 tax_id country year using `imports'
drop if _merge==2
replace imp_value=0 if imp_value==.
drop _merge
* generate dummies for the firm's experience with any of the 4 countries
foreach X in exporter owner{
	egen `X'_any=max(`X'), by(tax_id year)
}
gen limp_value=log(imp_value)
xtset groupid year
* new importers
capture noisily reg F.importer_yearly samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l exporter exporter_any owner owner_any lemp lVA_per_capita lage exp_share fo2 i.teaor03_2d _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & importer==1, cluster(address) 
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firm-year controls") excel replace
capture noisily areg F.importer_yearly samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & importer==1, cluster(address) absorb(tax_id)
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firm FE") excel append
capture noisily reg limp_value samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l exporter exporter_any owner owner_any lemp lVA_per_capita lage exp_share fo2 i.teaor03_2d _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & importer==1, cluster(address) 
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firm-year controls") excel append
capture noisily areg limp_value samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==1 & importer==1, cluster(address) absorb(tax_id)
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firmFE") excel append
* continuing importers
capture noisily reg limp_value samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l exporter exporter_any owner owner_any lemp lVA_per_capita lage exp_share fo2 i.teaor03_2d _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==0 & importer==1, cluster(address) 
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firm-year controls") excel append
capture noisily areg limp_value samebuilding_importer_l neighbor2_importer_l neighbor1_importer_l pneighbor_importer_l oneighbor_importer_l _Icountryye_* if robustvar==1 & year>=1994 & not_yet_importer==0 & importer==1, cluster(address) absorb(tax_id)
outreg2 using "`out'/Table_reg_w_wo_exp_peers_compare.xls", label ctitle("`X', firmFE") excel append



***********************************************************
* Table OA11: Spillover effect of treating 1000 buildings *
***********************************************************



*see `out'/Table_mover_event_study_new.xls and `out'/numfirms_in_bdngs_w_mover.txt from Figure 1 and `out'/multiplier_calc_1/5.txt from Figure 2



*******************************************************************
* Figure OA1: Industry composition of importers by source country *
*******************************************************************



* get the industry of firms
use "`in'/firm_bsheet_data.dta", clear
keep id8 year teaor03_2d_yearly 
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
rename id8 tax_id
drop teaor03_2d_yearly
tempfile bsheet
save `bsheet'
* add industry to baseline data
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
merge m:1 tax_id year using `bsheet'
drop if _merge==2
keep if year>=1994 & importer==1
drop if teaor03_1d_yearly==""
* get the share of each 1-digit industry among the importers from a country
collapse (sum) importer, by(country teaor03_1d_yearly)
egen total_c=sum(importer), by(country)
gen share=100*importer/total_c
drop importer total
* drop the industries which always have a share above 1%
egen minshare=min(share), by(teaor03_1d_yearly)
keep if minshare>1 & minshare!=.
replace country=lower(country)
reshape wide share, i( teaor03_1d_yearly) j( country) string
graph bar sharecz sharesk sharero shareru, over( teaor03_1d_yearly) legend(label(1 "Czech Republic") label(2 "Slovakia") label(3 "Romania")  label(4 "Russia") ) ytitle("%") bar(1, color(navy) fintensity(inten0)) bar(2, color(navy) fintensity(inten30)) bar(3, color(navy) fintensity(inten60)) bar(4, color(navy) fintensity(inten90)) title("") graphregion(color(white))
graph export "`out'/industry_by_country_1d.pdf", replace



************************************************************************************
* Figure OA2: Industry composition of importers in manufacturing by source country *
************************************************************************************



* get the industry of firms
use "`in'/firm_bsheet_data.dta", clear
keep id8 year teaor03_2d_yearly 
rename id8 tax_id
tempfile bsheet
save `bsheet'
* add industry to baseline data
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
merge m:1 tax_id year using `bsheet'
drop if _merge==2
keep if year>=1994 & importer==1
drop if teaor03_2d_yearly==.
* get the share of each 2-digit industry among the importers from a country
collapse (sum) importer, by(country teaor03_2d_yearly)
egen total_c=sum(importer), by(country)
gen share=100*importer/total_c
drop importer total
* drop the industries which always have a share above 1%
egen minshare=min(share), by(teaor03_2d_yearly)
* top 6 in manufacturing
preserve
keep if teaor03_2d_yearly>=15 & teaor03_2d_yearly<=37
gsort -minshare
keep if _n<=24
replace country=lower(country)
reshape wide share, i( teaor03_2d_yearly) j( country) string
graph bar sharecz sharesk sharero shareru, over( teaor03_2d_yearly) legend(label(1 "Czech Republic") label(2 "Slovakia") label(3 "Romania")  label(4 "Russia") ) ytitle("%") bar(1, color(navy) fintensity(inten0)) bar(2, color(navy) fintensity(inten30)) bar(3, color(navy) fintensity(inten60)) bar(4, color(navy) fintensity(inten90)) title("") graphregion(color(white))
graph export "`out'/industry_by_country_2d_manu.pdf", replace
restore
* top 6 in services
preserve
keep if teaor03_2d_yearly>37
gsort -minshare
keep if _n<=24
replace country=lower(country)
reshape wide share, i( teaor03_2d_yearly) j( country) string
graph bar sharecz sharesk sharero shareru, over( teaor03_2d_yearly) legend(label(1 "Czech Republic") label(2 "Slovakia") label(3 "Romania")  label(4 "Russia") ) ytitle("%") bar(1, color(navy) fintensity(inten0)) bar(2, color(navy) fintensity(inten30)) bar(3, color(navy) fintensity(inten60)) bar(4, color(navy) fintensity(inten90)) title("") graphregion(color(white))
graph export "`out'/industry_by_country_2d_serv.pdf", replace
restore




**************************************************************************************************
* Figure OA3: Industry composition of importers in trade and business services by source country *
**************************************************************************************************



*see `out'/industry_by_country_2d_serv.pdf from Figure OA2



*************************************************************************************************************
* Figure OA4: Distribution of the 5-year treatment effect for firms with non-importer peers in the building *
*************************************************************************************************************



*see `out'/distrib_of_5year_treatment_effect_by_prod_norm.pdf from Figure 2



**********************************
* Additional numbers in the text *
**********************************



* Share of firms in Budapest
import delimited "`in1'\frame.csv", clear 
keep tax_id
merge 1:m tax_id using "C:\Users\Márta\Documents\munka\CEU server\Documents\spillovers\data\address_data.dta"
gen byte bp=cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139
collapse (max) bp, by(tax_id)
quietly {
    log using "`out'/additional_descriptives.txt", text replace
	noisily display "Share of firms in Budapest"
	log close
}
tabout bp using "`out'/additional_descriptives.txt", c(cell) f(0c) append

* Number of observations in the main sample
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
keep tax_id year
duplicates drop
drop if year==1992
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Number of firms and firm-year observations in the main sample"
	noisily distinct tax_id
	log close
}

* Number of observations in the analysis sample
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
egen minyear=min(year), by(tax_id)
drop if year==1992
merge m:1 tax_id year using "`in'/address_data.dta", keepusing(cityid streetid buildingid)
drop if _merge==2
xtset groupid year
gen byte anal_smpl=robustvar==1 & cityid!=. & streetid!=. & buildingid!=. & year>=1994 & L.cityid!=. & L.streetid!=. & L.buildingid!=.
preserve
collapse (min) cityid streetid buildingid (max) minyear, by(tax_id year)
xtset tax_id year
quietly {
	log using "`out'/additional_descriptives.txt", text append
	noisily display "Number of firm-year observations without address data from the previous year, except for first year"
	noisily distinct tax_id if (L.cityid==. | L.streetid==. | L.buildingid==.) & year!=minyear & year>=1994
	log close
}
restore
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of firm-country-year observations in the estimation sample"
	log close
}
tabout anal_smpl using "`out'/additional_descriptives.txt", c(cell) f(0c) append
preserve
collapse (max) anal_smpl, by(tax_id)
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of firms in the estimation sample"
	log close
}
tabout anal_smpl using "`out'/additional_descriptives.txt", c(cell) f(0c) append
restore
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Number of firm-country-year observations in the estimation sample in which the firm has not yet imported from the country until the previous year"
	noisily distinct tax_id if anal_smpl==1 & not_yet_importer==1 
	log close
}
collapse (max) importer, by(tax_id)
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of firms in the estimation sample which ever import from CZ,SK,RO or RU in the period 1993-2003"
	log close
}
tabout importer using "`out'/additional_descriptives.txt", c(cell) f(0c) append

* Share of firms which move at least once
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
xtset groupid year
gen byte mover=address!=L.address & address!=. & L.address!=.
collapse (max) mover, by(tax_id)
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of movers among firms in the main sample"
	log close
}
tabout mover using "`out'/additional_descriptives.txt", c(cell) f(0c) append

* Probability of starting to import by productivity group
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si*_l si*_l_a
drop su*_l su*_l_a
* get the productivity groups
merge 1:1 tax_id country year using "`in'/db_complete_for_running_the_regs_prod_robust_rovat_13.dta", update
drop if _merge==2
drop _merge
rename prod_quartile_y_robust? prod?
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of not-yet-importer firms starting to import by productivity quartile"
	log close
}
foreach X of numlist 1/4{
	tabout importer if prod`X'==1 & not_yet_importer==1 & robustvar==1 & year>=1994 using "`out'/additional_descriptives.txt", c(col) f(2c) clab("prod_quart_`X'") append
}

* Share of addresses with geocodes
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
drop si* su*
drop if year==1992
merge m:1 tax_id year using "`in'/address_data.dta", keepusing(cityid streetid buildingid)
drop if _merge==2
drop _merge
keep tax_id year cityid streetid buildingid address
duplicates drop
gen i=_n
expand 2
egen c=seq(), by(i)
gen peer="m" if c==1
replace peer="p" if c==2
drop i c
merge m:1 cityid streetid buildingid peer using "`in1'/geocoordinates.dta"
preserve
gen byte geocoded=_merge==3
collapse (max) geocoded, by(address)
quietly {
    log using "`out'/additional_descriptives.txt", text append
	noisily display "Share of geocoded addresses in the main sample"
	log close
}
tabout geocoded using "`out'/additional_descriptives.txt", c(cell) f(0c) append
restore

* Average distance between neighboring firms
use "`in'/address_data.dta", clear
keep if cityid==9566 | cityid==3179 | cityid==18069 | cityid==5467 | cityid==29586 | cityid==13392 | cityid==16586 | cityid==29744 | cityid==25405 | cityid==10700 | cityid==14216 | cityid==24697 | cityid==24299 | cityid==16337 | cityid==4011 | cityid==11314 | cityid==8208 | cityid==2112 | cityid==29285 | cityid==6026 | cityid==13189 | cityid==10214 | cityid==34139
keep cityid streetid buildingid
duplicates drop
merge 1:m cityid streetid buildingid using "`in'/geocoordinates.dta"
keep if _merge==3
drop _merge
estpost sum dist_n
esttab using "`out'/additional_descriptives.txt", cells("mean(fmt(4)) sd(fmt(4))") title("Average distance between neighboring firms") nomtitle nonumber append

* Share of importers importing goods in a specific Rauch category
use "`in'/db_complete_for_running_the_regs_baseline_torun_rovat_13.dta", clear
merge 1:1 tax_id year country using "`in'/db_complete_additional_rauch_rovat_13.dta", keepusing(importern importerr importerw)
collapse (max) importern importerr importerw if importer==1, by(tax_id)
*quietly {
*    log using "`out'/additional_descriptives.txt", text append
*	noisily display "Share of importers importing a specific Rauch product category"
*	log close
*}
foreach X in n r w{
	if "`X'"=="n"{
		local Y differentiated
	}
	else if "`X'"=="r"{
		local Y reference_priced
	}
	else if "`X'"=="w"{
		local Y organized_exchange
	}
	tabout importer`X' using "`out'/additional_descriptives.txt", c(col) f(2c) clab("`Y'") append
}

