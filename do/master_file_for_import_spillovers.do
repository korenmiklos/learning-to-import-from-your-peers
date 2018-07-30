* Master file for Learning to Import from Your Peers (Bisztray-Koren-Szeidl)
	
clear
set more off

* set the location of the folder with the codes
cd "C:/Users/Márta/Documents/munka/research/EXPORT_SPILLOVER/codes_2016/replication"

* set the location of the folders with the input and output data
global in "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data/reprod_2018"
global in1 "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/data"
global in2 "C:/Users/Márta/Documents/munka/CEU server/Documents/audi/data/customs"
global in3 "C:/Users/Márta/Documents/munka/CEU server/Documents/plant_closure/data"
global out "C:/Users/Márta/Documents/munka/CEU server/Documents/spillovers/results/tables/2018_June"

* A) PREPARE THE DATA


* 1) Trade and foreign ownership data

* create importer and exporter data
do create_importer_exporter_panel.do 
	* output:
		* exporter_panel.dta (first year of exporting to and being owned from CZ, SK, RO or RU)
		* exporter_panel_yearly.dta (firm-year panel with dummies showing yearly exporter status to CZ,SK,RO and RU)
		* importer_panel.dta (first year of importing and being owned from CZ, SK, RO or RU)
		* importer_panel_yearly.dta (firm-year panel with dummies showing yearly importer status from CZ,SK,RO and RU)
* create HS-Rauch correspondence tables
do hs_rauch_corresp.do
	* output:
		* hs02_Rauch.dta (Rauch categories assigned to 6-digit hs02 codes)
		* hs92_Rauch.dta (Rauch categories assigned to 6-digit hs92 codes)
		* hs96_Rauch.dta (Rauch categories assigned to 6-digit hs96 codes)
* create importer_panel_bec.dta (first year of importing a specific bec product category from CZ, SK, RO or RU)
do create_import_by_bec.do
* create import_minyear_by_bec.dta (first year of importing a BEC product category from any country of CZ, SK, RO, RU)
do create_import_minyear_by_bec.do
* create importer_panel_rauch.dta (first year of importing a specific Rauch product category from CZ, SK, RO or RU)
do create_import_by_rauch.do
* create owner_panel_yearly.dta (firm-year panel showing if the firm has owners from CZ,SK,RO or RU)
do create_owner_panel_yearly.do 


* 2) Firm pairs

* create precise_neighbors_detailed.dta (potentially existing neighbor (+/-2,4) and cross-street (+/-1,3) addresses for each address in our database)
do create_precise_neighbors_detailed.do
* create firm pairs connected with ownership links by year 
do create_firm_list_with_common_owner.do
	* output:
		* firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta (firms owning each other)
		* firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta (having a common person as an ultimate owner)
		* firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta (having a common firm as an ultimate owner)
* create person-connected firm pairs with start and end dates
foreach which_rovat in rovat_13 all_rovat sign_own{
	global which_rovat "`which_rovat'"
	do create_firm_pairs.do
}
	* output:
		* directed_firm_pairs.dta (any connected person)
		* directed_firm_pairs_13.dta (connecting person with signing right in both firm and peer) 
		* directed_firm_pairs_from_sign_to_own.dta (connecting person with signing right in peer and ownership in firm)


* 3) Balance sheet data		
		
* create 2d_industry.dta (firm-year panel with 2-digit industry)
do create_2d_industry_data.do
* create address_data.dta (yearly panel of firm headquarter addresses)
do create_address_data.do
* create firm_bsheet_data.dta (cleaned balance sheet data of firms with additional information as industry, ownership and TFP)
do Create_firm_bsheet_data.do
* create firm_groups_yearly.dta (firm-year panel of productivity, size, ownership and exporter groups )
do create_firm_groups.do
* create time_variant_prod_quartiles.dta (firm-year panel of productivity quartiles using 3 different versions)
do create_prod_quartiles_for_peers.do
* create firm_age.dta (firm age in each year)
do firm_age.do


* 4) Data on peers with country-specific experience
		
* create data on spatial peers with country-specific trade experience
foreach heterog in "" _rauch _bec _prod _heterog _numyears{
	global heterog "`heterog'"
	if "`heterog'"==""{
		foreach peer_expimp in im ex{
			global peer_expimp "`peer_expimp'"
			global sameind ""
			global success ""
			global no_exclusion ""
			do create_geo_neighborstats.do
		}
		global peer_expimp im
		global sameind sameind
		do create_geo_neighborstats.do
		global sameind ""
		global success success
		do create_geo_neighborstats.do
		global success ""
		global no_exclusion no_exclusion
		do create_geo_neighborstats.do
		global peer_expimp ex
		do create_geo_neighborstats.do
	}
	else if "`heterog'"!=""{
		global peer_expimp im
		global sameind ""
		global success ""
		global no_exclusion ""
		do create_geo_neighborstats.do
	}
}
	* output:
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta (spatial peers with country-specific import experience)
		* db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta (spatial peers with country-specific export experience )
		* db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta (spatial peers with country-specific import experience in the same industry)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta (spatial peers with country-specific succesful import experience )
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta (spatial peers with country-specific import experience by bec product category)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict_rauch.dta (spatial peers with country-specific import experience by Rauch product category)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta (spatial peers with country-specific import experience by ownership, size and industry group)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta (spatial peers with country-specific import experience by productivity group)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strict_numyears.dta (spatial peers with length of country-specific import experience)
		* db_im_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta (spatial peers with country-specific import experience, not excluding ownership-connected peers)	
		* db_ex_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta (spatial peers with country-specific export experience, not excluding ownership-connected peers)	
* create data on person-connected peers with country-specific trade experience
foreach heterog in "" _rauch _bec _prod _heterog _numyears{
	global heterog "`heterog'"
	if "`heterog'"==""{
		foreach which_rovat in rovat_13 all_rovat sign_own{
			global which_rovat "`which_rovat'"
			foreach peer_expimp in im ex{
				global peer_expimp "`peer_expimp'"
				global sameind ""
				global success ""
				global no_exclusion ""
				do create_person_neighborstats.do
			}
		}
		global which_rovat rovat_13
		global peer_expimp im
		global sameind sameind
		do create_person_neighborstats.do
		global sameind ""
		global success success
		do create_person_neighborstats.do
		global success ""
		global no_exclusion no_exclusion
		do create_person_neighborstats.do
		global peer_expimp ex
		do create_person_neighborstats.do
	}
	else if "`heterog'"!=""{
		global which_rovat rovat_13
		global peer_expimp im
		global sameind ""
		global success ""
		global no_exclusion ""
		do create_person_neighborstats.do
	}
}
	* output
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific import experience - connecting people having signature right)
		* db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific export experience (connecting people have signature right))
		* db_im_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific import experience (connecting people have any connection))
		* db_ex_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific export experience (connecting people have any connection))
		* db_im_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific import experience (connecting people have signature right in peer and are owners in the firm))
		* db_ex_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta (person-connected peers with country-specific export experience (connecting people have signature right in peer and are owners in the firm))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta (person-connected peers with country-specific import experience in the same industry (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta (person-connected peers with country-specific successful import experience (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta (person-connected peers with country-specific import experience by bec product category (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_rauch.dta (person-connected peers with country-specific import experience by Rauch product category (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta (person-connected peers with country-specific import experience by ownership, size and industry group (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta (person-connected peers with country-specific import experience by productivity group (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_numyears.dta (person-connected peers with length of country-specific import experience (connecting people have signature right))
		* db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta (person-connected peers with country-specific import experience, not excluding ownership-connected peers)
		* db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta (person-connected peers with country-specific export experience, not excluding ownership-connected peers)
* create data on ownership-connected peers with country-specific trade experience
foreach heterog in "" _rauch _bec _prod _heterog _numyears{
	global heterog "`heterog'"
	if "`heterog'"==""{
		foreach peer_expimp in im ex{
			global peer_expimp "`peer_expimp'"
			global sameind ""
			global success ""
			do create_ownership_links_neighborstats.do
		}
		global peer_expimp im
		global sameind sameind
		do create_ownership_links_neighborstats.do
		global sameind ""
		global success success
		do create_ownership_links_neighborstats.do
	}
	else if "`heterog'"!=""{
		global peer_expimp im
		global sameind ""
		global success ""
		do create_ownership_links_neighborstats.do
	}
}
	* output
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta (ownership-connected peers with country-specific import experience)		
		* db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta (ownership-connected peers with country-specific export experience)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta (ownership-connected peers with country-specific successful import experience (i.e. in min 2 recent years))
		* db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta (ownership-connected peers with country-specific import experience in the same industry)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta (ownership-connected peers with country-specific import experience by bec product category)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict_rauch.dta (ownership-connected peers with country-specific import experience by Rauch product category)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict_numyears.dta (ownership-connected peers with the length of country-specific import experience)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta (ownership-connected peers with country-specific import experience separately by productivity group)
		* db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta (ownership-connected peers with country-specific import experience by ownership, size and industry group)
			
* 5) Full database of experinced peers				
				
* create full spillover database with experienced peer dummies	
foreach heterog in "" _rauch _bec _prod _heterog _numyears{
	global heterog "`heterog'"
	if "`heterog'"==""{
		foreach which_rovat in rovat_13 sign_own all_rovat{
			global which_rovat "`which_rovat'"
			global no_exclusion ""
			do create_full_spillover_db.do
		}
		global which_rovat rovat_13
		global no_exclusion no_exclusion
		do create_full_spillover_db.do
	}
	else if "`heterog'"!=""{
		global which_rovat rovat_13
		global no_exclusion ""
		do create_full_spillover_db.do
	}
}
	* output
		* db_complete_additional_rauch_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by Rauch product category)
		* db_complete_for_running_the_regs_baseline_torun.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (had signing right in peer and owner in firm) and owner-connected peer group)
		* db_complete_for_running_the_regs_baseline_torun_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately for same-industry and successful experience)
		* db_complete_for_running_the_regs_bec_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by BEC product category)
		* db_complete_for_running_the_regs_heterog_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by ownership, size and industry)
		* db_complete_for_running_the_regs_no_exclusion_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo and person-connected (with signing right) peer group, not regarding ownership links between firms)
		* db_complete_for_running_the_regs_numyears_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and the length of experience which experienced peers in geo, person- (with signing right) and owner-connected peer group have, baseline and strict definition)
		* db_complete_for_running_the_regs_prod_robust_rovat_13.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by productivity)
		* db_numneighbors_bec_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by BEC product category)
		* db_numneighbors_heterog_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by ownership, size and industry)
		* db_numneighbors_prod_robust_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by productivity)
		* db_numneighbors_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience)
		* db_numneighbors_sameind_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific same-industry import, export or ownership experience)
		* db_numneighbors_success_rovat_13.dta (number of spatial, person-connected and ownership-connected peers with country-specific successful import, export or ownership experience)
		* person_neighbors_all_rovat_toadd.dta (country-specific importer, exporter and owner status of a firm, and existence of experienced peers person-connected (any connection) peer group)
* create distance to neighboring buildings data
do create_distance_data.do
	* output
		* geocoordinates.dta

* B) CREATE DESCRIPTIVES AND DO THE ESTIMATION		
		
* 6) Exhibits

* create all the exhibits included in the paper and in the online appendix
do exhibits_as_of_2018June.do
	* output
		*Table 1: descriptives_by_dest.txt
		*Table 2: descriptives_by_year.txt
		*Table 3: num_neighbors_spatial.txt
		*Table 4: country_spec_imp_and_peer_experience.txt 
		*Table 5: Table_reg_notyetimp.xls, baseline_hazard_imp.txt
		*Table 6: Table_notyetimp_firmgroups.xls, ttest_notyetimp_firmgroups.txt
		*Table 7: Table_notyetimp_neighbor_heterog.xls, ttest_notyetimp_neighbor_heterog.txt
		*Table 8: Table_peer_experience_time.xls, ttest_peer_experience_time.txt
		*Table 9: Table_numpeers.xls, ttest_numpeers.txt
		*Table 10: Table_notyetimp_dyadic.xls
		*Table 11: Table_numpeers_by_prod_separately.xls, ttest_numpeers_by_prod_separately.txt
		*Table 12: Table_notyetimp_sameind_sameprod.xls, ttest_notyetimp_sameind_sameprod.txt, baseline_hazard_imp_ind_prod.txt
		*Figure 1: Plot_event_study_FE.xls, Plot_event_study_OLS.xls
		*Figure 2: distrib_of_5year_social_multiplier_by_prod_norm_small.pdf, multiplier_calc_5.txt
		*Table A1: peer_patterns.txt
		*Table A2: impshare_by_numpeers_in_bdng.txt
		*Table A3: Table_notyetimp_full.xls
		*Table A4: Table_notyetimp_person_versions.xls
		*Table A5: Table_notyetimp_alternative_samples.xls
		*Table A6: Table_notyetimp_succ_entry.xls, ttest_notyetimp_succ_entry.txt, baseline_hazard_succ_imp.txt
		*Table A7: Table_by_ind.xls
		*Table A8: Table_notyetimp_Rauch.xls
		*Table A9: mover_desc.txt
		*Table A10: Table_mover_event_study_new.xls
		*Table A11: Table_reg_notyetexp.xls, baseline_hazard_exp.txt 
		*Table OA1: descriptives_by_import_patterns.txt
		*Table OA2: BEC_descriptives.txt
		*Table OA3: peer_patterns_1.txt
		*Table OA4: firm_group_desc.txt
		*Table OA5: Table_notyetimp_firmgroups.xls, ttest_notyetimp_firmgroups.txt
		*Table OA6: Table_notyetimp_neighbor_heterog.xls, ttest_notyetimp_neighbor_heterog.txt
		*Table OA7: Table_notyetimp_sameind_sameprod.xls, ttest_notyetimp_sameind_sameprod.txt
		*Table OA8: Table_by_same_bec_first_ever_imp.xls
		*Table OA9: Table_notyetimp_robust.xls
		*Table OA10: Table_reg_w_wo_exp_peers_compare.xls
		*Table OA11: Table_mover_event_study_full.xls, multiplier_calc_1/5.txt, numfirms_in_bdngs_w_mover.txt
		*Figure OA1: industry_by_country_1d.pdf
		*Figure OA2: industry_by_country_2d_manu.pdf
		*Figure OA3: industry_by_country_2d_serv.pdf
		*Figure OA4: distrib_of_5year_treatment_effect_by_prod_norm_small.pdf
