Replication codes for 
----------------------------------------------------------------------------------------
Bisztray, Márta, Miklós Koren and Adam Szeidl: Learning to Import from Your Peers. 2018.
----------------------------------------------------------------------------------------
Please cite the above paper when using any of these programs

The codes creating the datasets used for the estimations and preparing the exhibits of the paper use STATA.

master_file_for_import_spillovers.do runs all the other codes, preparing the estimation data from raw data and creating all the tables, figures and other calculations presented in the paper.
In the beginning of master_file_for_import_spillovers.do on ecan set the access route to the input folders with the raw data and to the output folders for the constructed data and for the exhibits.

Workflow
--------

(1) Prepare the data

1.1 Prepare trade and foreign ownership data

Create importer and exporter data with do create_importer_exporter_panel.do.
Create HS-Rauch correspondence tables do hs_rauch_corresp.do.
Create data on imports by bec product category with do create_import_by_bec.do and do create_import_minyear_by_bec.do.
Create data on imports by Rauch product category with do create_import_by_rauch.do.
Create data on foreign ownership with do create_owner_panel_yearly.do.

1.2 Create firm pairs based on spatial, personal and ownership connections

Create data on neighboring and cross-street buildings with create_precise_neighbors_detailed.do.
Create different versions of firm pairs connected with ownership links with create_firm_list_with_common_owner.do.
Create different versions of person-connected firm pairs with do create_firm_pairs.do.

1.3 Prepare balance sheet data

Create a firm-year panel with 2-digit industry with create_2d_industry_data.do.
Create a yearly panel of firm headquarter addresses with create_address_data.do.
Create cleaned balance sheet data of firms with additional information with Create_firm_bsheet_data.do.
Create a firm-year panel of productivity, size, ownership and exporter groups with create_firm_groups.do.
Create a firm-year panel of productivity quartiles with create_prod_quartiles_for_peers.do.
Create firm age data with firm_age.do.

1.4 Create data on peers with country-specific experience

Create different versions of data on spatial peers with country-specific trade experience with do create_geo_neighborstats.do.
Create different versions of data on person-connected peers with country-specific trade experience with do create_person_neighborstats.do.
Create different versions of data on ownership-connected peers with country-specific trade experience with do create_ownership_links_neighborstats.do.

1.5 Create the final database 

Create different versions of the final database with experienced peers used for the estimations with create_full_spillover_db.do
Create distance to neighboring buildings data with create_distance_data.do.

(2) Create the exhibits

Create all the tables, figures and calculations presented in the text with exhibits_as_of_2018June.do.

Data used
---------

Our estimates are based on a panel dataset of import and export transactions, balance sheets and earnings statements of Hungarian firms for the period 1992 to 2003, and firm registry data from the same period. 
Because the data is confidential, we cannot make it available in this replication package.

Researchers interested in replicating our results with this same data, or conducting other academic research on this data, can access the dataset and the necessary data processing scripts at the premises of the Institute of Economics of the Hungarian Academy of Sciences and at Central European University. Please refer to http://www.mtakti.hu/english/ and https://economics.ceu.edu/ or contact the corresponding author, Márta Bisztray at bisztray dot marta at krtk dot mta dot hu.

PRIMARY DATA SOURCE

balance_sheet.dta
	source: National Tax and Customs Administration of Hungary and Complex firm registry data
	content: balance sheet statements of all Hungarian double bookkeeping firms
	time period: 1992-2012
	variables:
		originalid: firm identifier
		year
		emp: number of employees
		sales: total sales in 1000HUF 
		export: export sales in 1000HUF
		gdp: gross value added in 1000HUF (sales + capitalized value of self-manufactured assets - material)
		jetok: total capital in 1000HUF
		jetok06: foreign-owned capital in 1000HUF
		ranyag: material expenditure in 1000HUF
		teaor03_2d: 2-digit teaor'03 industry code (corresponds to NACE Rev 1.1)
		teaor_raw: 4-digit raw industry codes (teaor92 in years 1992-1997, teaor98 in years 1998-2002, teaor03 in years 2003-2007, teaor08 in years 2008-2012)
		fo2: dummy for foreign-owned share >=50%
		so2: dummy for state-owned share>=50%
		foundyear: foundation year
		persexp: payments to personnel in 1000HUF
		wbill: wage bill in 1000HUF 
		tanass: tangible assets in 1000HUF
county-nuts-city-ksh-codes.csv
	source: Hungarian Statistics Office
	content: city names with statistical codes, counties and NUTS3 regions
	variables:
		ksh_code: statistical code of a settlement 
		nuts3: NUTS3 region
deflators.dta
	source: Hungarian Statistics Office
	content: GDP deflator, capital deflator, wage index
	time period: 1992-2013
	variables:
		year
		K_deflator: capital deflator
		wage_index: wage index
ex91.dta - ex03.dta
	source: Hungarian customs statistics
	cotent: yearly value of export transactions by firm-country-product category (hs6)
	time period: single year from 1991 to 2003
	variables:
		e_ft91/92/../03: yearly export value in HUF
		a1: firm identifier
		szao: destination country
		hs6: 6-digit HS product category
im91.dta - im03.dta
	source: Hungarian customs statistics
	cotent: yearly value of import transactions by firm-country-product category (hs6)
	time period: single year from 1991 to 2003
	variables:
		i_ft91/92/../03: yearly import value in HUF
		a1: firm identifier
		szao: source country
		hs6: 6-digit HS product category
PPI.dta
	source: Hungarian Statistics Office
	content: material price index and producer price index by 2-digit industry - PPI also separately for exports and domestic sales
	time period: 1992-2013
	variables:
		year
		nace2: 2-digit industry category (NACE Rev. 1.1)
		PPI: producer price index
		ex_PPI: producer price index for export sales
		dom_PPI: produced price index for domestic sales
		materialPPI: material price index
	
CLASSIFICATIONS AND CORRESPONDENCE TABLES

hs02_sitc3.csv
	content: correspondence table between 6-digit hs02 and SITC Rev 3 product categories
	variables:
		hs02: 6-digit HS02
		s3: SITC Rev.3
hs6bec.csv
	content: correspondence table between hs6 and BEC product categories
	variables:
		hs6: 6-digit HS product category
		bec: 2-digit bec product category
hs92_sitc3.csv
	content: correspondence table between 6-digit hs92 and SITC Rev 3 product categories
	variables:
		hs92: 6-digit HS92
		s3: SITC Rev.3
hs96_sitc3.csv
	content: correspondence table between 6-digit hs96 and SITC Rev 3 product categories
	variables:
		hs96: 6-digit HS96
		s3: SITC Rev.3
Rauch_classification_revised.csv
	source: http://econweb.ucsd.edu/~jrauch/rauch_classification.html
	content: 4-digit SITC categories by Rauch classification
SITC_Rev_3_english_structure.txt
	source: http://econweb.ucsd.edu/~jrauch/rauch_classification.html
	content: SITC Rev 3 product categories
unique_nace11_to_teaor08.csv
	content: created from NACE Rev 1.1 - NACE Rev 2 correspondence table
	variables:
		nace: 4-digit NACE Rev. 1.1
		teaor08: 4-digit TEAOR'08 (corresponds to NACE Rev.2)

DATA BUILT FROM PRIMARY SOURCES

1992-2006.csv
	source: Complex firm registry data
	content: firm-year panel of headquarters (city, street, building)
	time period: 1992-2006
	variables:
		taxid: firm identifier
		year
		cityid: city name identifier
		streetid: street name identifier
		buildingid: building number
bp_addresses_w_geocoord.dta
	source: Complex firm registry data
	content: geocoordinates assigned to addresses in Budapest
	variables:
		cityid: city identifier
		streetid: street identifier
		buildingid: building number
		lat: latitude
		lon: longitude
country_code.dta
	source: Complex firm registry data
	content: yearly panel of country codes the firm has owners from
	time period: 1992-2003
	variables:
		tax_id: firm identifier
		year
		country_code: 2-digit ISO country code
frame.csv
	source: Complex firm registry data
	content: firms with birth and death dates
	time period: 1991-2011 (including earlier birth dates)
	variables:
		tax_id: firm identifier
		birth_date: date of incorporation as an 8-digit integer, using the order year month day
		death_date: date of ending operation as an 8-digit integer, using the order year month day
frame_old_format.csv
	source: Complex firm registry data
	content: firms with birth and death dates
	time period: 1991-2014 (including earlier birth dates)
	variables:
		tax_id: firm identifier
		birth_date: date of incorporation as an 8-digit integer, using the order year month day
		death_date: date of ending operation as an 8-digit integer, using the order year month day
firm_hqs_yearly_slices.csv
	source: Complex firm registry data
	content: yearly detailed headquarter addresses of firms (up to floor and door)
	time period: 1990-2014
	variables:
		taxid: firm identifier
		year
		cityid: city identifier
firmperson_important_liquidator_dummy.csv
	source: Complex firm registry data
	content: list of firms with connecting people and an indicator for liquidators
		tax_id: firm identifier
		person_id 
		felsz: dummy, 1 if person is ever a liquidator in the firm
location.dta
	source: Complex firm registry data
	content: firm-year panel of headquarters (city, street, building)
	time period: 1992-2006
	variables:
		tax_id: firm identifier 
		year 
		cityid: city identifier
		streetid: street identifier
		buildingid: building number
ownership_mixed_directed.csv
	source: Complex firm registry data
	content: list of person and firm owners of firms with start and end dates
	time period: 1991-2013
	variables:
		tax_id: firm identifier
		tax_id_owner: identifier of the owner firm
		person_id_owner: identifier of the owner person
		start: start date of the ownership, string, using the format "yyyy-mm-dd"
		end: end date of the ownership, string, using the format "yyyy-mm-dd"
person_firm_connection_in_all_rovats_using_30d_threshold.csv
	source: Complex firm registry data
	content: list of firms with connected people having any connection, with start and end dates
	time period: 1991-2013
	variables:
		tax_id: firm identifier
		person_id: identifier of the person
		date_of_start: start date of the ownership, string, using the format "yyyy-mm-dd"
		date_of_end: end date of the ownership, string, using the format "yyyy-mm-dd"
person_firm_connection_by_rovats_using_30d_threshold,csv
	source: Complex firm registry data
	content: list of firms with connected people, and type of the connection with start and end dates
	time period: 1991-2013
	variables:
		tax_id: firm identifier
		person_id: identifier of the person
		rovat_name: name of the rovat indicating the type of the relationship, string
		date_of_start: start date of the ownership, string, using the format "yyyy-mm-dd"
		date_of_end: end date of the ownership, string, using the format "yyyy-mm-dd"	

DATA WITH DO FILES

db_complete_additional_rauch_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by Rauch product category
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_rauch.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_rauch.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_rauch.dta
db_complete_for_running_the_regs_baseline_torun.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (had signing right in peer and owner in firm) and owner-connected peer group
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_im_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
		db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
		exporter_panel_yearly.dta
		importer_panel_yearly.dta
		owner_panel_yearly.dta
		exporter_panel.dta
		importer_panel.dta
db_complete_for_running_the_regs_baseline_torun_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately for same-industry and successful experience
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
		db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_sameind.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_sameind.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_sameind.dta
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_success.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_success.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_success.dta
		exporter_panel_yearly.dta
		importer_panel_yearly.dta
		owner_panel_yearly.dta
		exporter_panel.dta
		importer_panel.dta
db_complete_for_running_the_regs_bec_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by BEC product category
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta
db_complete_for_running_the_regs_heterog_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by ownership, size and industry
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta
db_complete_for_running_the_regs_no_exclusion_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo and person-connected (with signing right) peer group, not regarding ownership links between firms
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta
		db_ex_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
		db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta
		exporter_panel.dta
		importer_panel.dta
db_complete_for_running_the_regs_numyears_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and the length of experience which experienced peers in geo, person- (with signing right) and owner-connected peer group have, baseline and strict definition
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_numyears.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_numyears.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_numyears.dta
db_complete_for_running_the_regs_prod_robust_rovat_13.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers in geo, person- (with signing right) and owner-connected peer group, separately by productivity
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta
db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience 
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel.dta
		precise_neighbors_detailed
db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
db_numneighbors_bec_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by BEC product category
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta
db_numneighbors_heterog_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by ownership, size and industry
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta
db_numneighbors_prod_robust_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience, separately by productivity
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta
db_numneighbors_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific import, export or ownership experience
	inputs:
		db_im_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta
		db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
		db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
db_numneighbors_sameind_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific same-industry import, export or ownership experience
		db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta
db_numneighbors_success_rovat_13.dta
	created with create_full_spillover_db.do
	content: number of spatial, person-connected and ownership-connected peers with country-specific successful import, export or ownership experience
		db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta
		db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta
		db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta
firm_age.dta
	created with firm_age.do
	content: firm age in each year
	inputs:
		frame_old_format.csv
		firm_bsheet_data.dta
firm_bsheet_data.dta
	created with Create_firm_bsheet_data.do
	content: cleaned balance sheet data of firms with additional information (e.g. 4-digit industry, ownership, TFP)
	inputs:
		balance_sheet.dta
		ex91.dta, ex92.dta ... ex03.dta
		im91.dta, im92.dta ... im03.dta
		firm_hqs_yearly_slices.csv
		audi/data/unique_nace11_to_teaor08.csv
		PPI.dta
		deflators.dta
		county-nuts-city-ksh-codes.csv
geocoordinates.dta
	created with create_distance_data.do
	content: geocoordinates and distance to neighboring buildings for geocoded addresses in Budapest
	inputs:
		address_data.dta
		bp_addresses_w_geocoord.dta
		db_complete_for_running_the_regs_baseline_torun_rovat_13.dta
import_minyear_by_bec.dta
	created with create_import_minyear_by_bec.do
	content: first year of importing a BEC product category from a specific country for each firm
	inputs:
		im91.dta, im92.dta ... im03.dta
		hs6bec.csv		
person_neighbors_all_rovat_toadd.dta
	created with create_full_spillover_db.do
	content: country-specific importer, exporter and owner status of a firm, and existence of experienced peers person-connected (any connection) peer group
	inputs:
		db_im_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
		db_ex_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
		
ADDITIONAL INPUT DATA WITH DO FILES

2d_industry.dta
	created with create_2d_industry_data.do
	content: firm-year panel with 2-digit industry data (and time-invariant 2-digit 'most common activity')
	inputs:
		balance_sheet.dta
address_data.dta
	created with create_address_data.do
	content: yearly panel of firm headquarter addresses (city, street and building)
	inputs:
		1992-2006.csv
db_ex_geo_neighborstat_budapest_no_ownership_link_strict.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific export experience 
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		exporter_panel.dta
		precise_neighbors_detailed
db_ex_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific export experience, not excluding ownership-connected peers
	inputs:
		address_data
		exporter_panel.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strictsameind.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience in the same industry
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		2d_industry.dta
		address_data
		importer_panel.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strictsuccess.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific succesful import experience 
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel.dta
		importer_panel_yearly.dta
		owner_panel_yearly.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strict_bec.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience by bec product category
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel_bec.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strict_rauch.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience by Rauch product category
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel_rauch.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strict_heterog.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience by ownership, size and industry group
	inputs:
		firm_bsheet_data.dta
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strict_prod.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience by productivity group
	inputs:
		firm_bsheet_data.dta
		time_variant_prod_quartiles.dta
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strict_numyears.dta
	created with create_geo_neighborstats.do
	content: spatial peers with length of country-specific import experience 
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		importer_panel.dta
		importer_panel_yearly.dta
		precise_neighbors_detailed
db_im_geo_neighborstat_budapest_no_ownership_link_strictno_exclusion.dta
	created with create_geo_neighborstats.do
	content: spatial peers with country-specific import experience, not excluding ownership-connected peers
	inputs:
		address_data
		importer_panel.dta
		precise_neighbors_detailed
		
db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific export experience (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		exporter_panel.dta
db_im_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience (connecting people have any connection)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs.dta
		importer_panel.dta
db_ex_person_neighborstat_all_rovat_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific export experience (connecting people have any connection)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs.dta
		exporter_panel.dta
db_im_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience (connecting people have signature right in peer and are owners in the firm)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_from_sign_to_own.dta
		importer_panel.dta
db_ex_person_neighborstat_sign_own_budapest_no_ownership_link_strict.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific export experience (connecting people have signature right in peer and are owners in the firm)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_from_sign_to_own.dta
		exporter_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsameind.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience in the same industry (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		2d_industry.dta
		directed_firm_pairs_13.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictsuccess.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific successful import experience (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
		importer_panel_yearly.dta
		owner_panel_yearly.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_bec.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience by bec product category (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel_bec.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_rauch.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience by Rauch product category (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel_rauch.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_heterog.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience by ownership, size and industry group (connecting people have signature right)
	inputs:
		firm_bsheet_data.dta
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_prod.dta
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience by productivity group (connecting people have signature right)
	inputs:
		firm_bsheet_data.dta
		time_variant_prod_quartiles.dta
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strict_numyears.dta
	created with create_person_neighborstats.do
	content: person-connected peers with length of country-specific import experience (connecting people have signature right)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
		importer_panel_yearly.dta
db_im_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta 
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific import experience (connecting people have signature right), not excluding ownership-connected peers
	inputs:
		address_data
		directed_firm_pairs_13.dta
		importer_panel.dta
db_ex_person_neighborstat_rovat_13_budapest_no_ownership_link_strictno_exclusion.dta 
	created with create_person_neighborstats.do
	content: person-connected peers with country-specific export experience (connecting people have signature right), not excluding ownership-connected peers
	inputs:
		address_data
		directed_firm_pairs_13.dta
		exporter_panel.dta

db_ex_owner_neighborstat_budapest_no_ownership_link_strict.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific export experience
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		exporter_panel.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strictsuccess.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific successful import experience (i.e. in min 2 recent years)
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel.dta
		importer_panel_yearly.dta
		owner_panel_yearly.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strictsameind.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience in the same industry
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		2d_industry.dta
		importer_panel.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strict_bec.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience by bec product category
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel_bec.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strict_rauch.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience by Rauch product category
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel_rauch.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strict_numyears.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with the length of country-specific import experience
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel.dta
		importer_panel_yearly.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strict_prod.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience separately by productivity group
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel.dta
		firm_bsheet_data.dta
		time_variant_prod_quartiles.dta
db_im_owner_neighborstat_budapest_no_ownership_link_strict_heterog.dta
	created with create_ownership_links_neighborstats.do
	content: ownership-connected peers with country-specific import experience by ownership, size and industry group
	inputs:
		firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
		firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
		firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
		address_data.dta
		importer_panel.dta
		firm_bsheet_data.dta
directed_firm_pairs.dta
	created with create_firm_pairs.do
	content: firm pairs having a connecting person with start and end years
	inputs:
		firmperson_important_liquidator_dummy.csv
		person_firm_connection_in_all_rovats_using_30d_threshold.csv
		person_firm_connection_by_rovats_using_30d_threshold,csv
directed_firm_pairs_13.dta
	created with create_firm_pairs.do
	content: firm pairs having a connecting person who had signing right in the peer and who has signing right in the firm, with start and end years
	inputs:
		firmperson_important_liquidator_dummy.csv
		person_firm_connection_by_rovats_using_30d_threshold.csv
directed_firm_pairs_from_sign_to_own.dta
	created with create_firm_pairs.do
	content: firm pairs having a connecting person who had signing right in the peer and who is an owner in the firm, with start and end years
	inputs:
		firmperson_important_liquidator_dummy.csv
		person_firm_connection_by_rovats_using_30d_threshold.csv
exporter_panel.dta
	created with create_importer_exporter_panel.do
	content: first year of exporting to and being owned from a country (CZ,SK,RO,RU), with first and last years of a firm
	inputs:
		ex91.dta
		...
		ex03.dta
		country_code.dta	
		frame.csv
exporter_panel_yearly.dta
	created with create_importer_exporter_panel.do
	content: firm-year panel with dummies showing yearly exporter status to CZ,SK,RO and RU
	inputs:
		ex91.dta
		...
		ex03.dta
firm_groups_yearly.dta
	created with create_firm_groups.do
	content: firm-year panel of productivity, size, ownership and exporter groups 
	inputs: 
		firm_bsheet_data.dta
firm_year_list_of_ultimate_firm_ownerships_2016Jan.dta
	created with create_firm_list_with_common_owner.do
	content: firm pairs by year with firms owning each other
	inputs:	
		ownership_mixed_directed.csv
firm_year_list_with_common_ultimate_personid_owners_2016Jan.dta
	created with create_firm_list_with_common_owner.do
	content: firm pairs by year having a common person as an ultimate owner
	inputs:
		ownership_mixed_directed.csv
firm_year_list_with_common_ultimate_taxid_owners_2016Jan.dta
	created with create_firm_list_with_common_owner.do
	content: firm pairs by year having a common firm as an ultimate owner
	inputs:
		ownership_mixed_directed.csv
hs02_Rauch.dta
	created with hs_rauch_corresp.do
	content: Rauch categories assigned to 6-digit hs02 codes
	inputs:
		Rauch_classification_revised.csv
		SITC_Rev_3_english_structure.txt
		hs02_sitc3.csv
hs92_Rauch.dta
	created with hs_rauch_corresp.do
	content: Rauch categories assigned to 6-digit hs92 codes
	inputs:
		Rauch_classification_revised.csv
		SITC_Rev_3_english_structure.txt
		hs92_sitc3.csv
hs96_Rauch.dta
	created with hs_rauch_corresp.do
	content: Rauch categories assigned to 6-digit hs96 codes
	inputs:
		Rauch_classification_revised.csv
		SITC_Rev_3_english_structure.txt
		hs96_sitc3.csv
importer_panel.dta
	created with create_importer_exporter_panel.do
	content: first year of importing and being owned from a country (CZ,SK,RO,RU), with first and last years of a firm
	inputs:
		im91.dta
		...
		im03.dta
		country_code.dta	
		frame.csv
importer_panel_bec.dta
	created with create_import_by_bec.do
	content: the first year when a firm started to import a specific bec product category from one of the countries (CZ,SK,RO and RU)
	inputs:
		im91.dta
		...
		im03.dta
		hs6bec.csv
importer_panel_rauch.dta
	created with create_import_by_rauch.do
	content: the first year when a firm started to import a specific rauch product category from one of the countries (CZ,SK,RO and RU)
	inputs:
		im91.dta
		...
		im03.dta
		hs92_Rauch.dta
		hs96_Rauch.dta
		hs02_Rauch.dta
importer_panel_yearly.dta
	created with create_importer_exporter_panel.do
	content: firm-year panel with dummies showing yearly importer status from CZ,SK,RO and RU
	inputs:
		im91.dta
		...
		im03.dta
owner_panel_yearly.dta
	created with create_owner_panel_yearly.do
	content: firm-year panel showing if the firm has owners from CZ,SK,RO or RU 
	inputs:
		country_code.dta
precise_neighbors_detailed
	created with create_precise_neighbors_detailed.do
	content: potentially existing neighbor (+/-2,4) and cross-street (+/-1,3) addresses for each address in our database
	inputs:
		location.dta
time_variant_prod_quartiles.dta
	created with create_prod_quartiles_for_peers.do
	content: firm-year panel of productivity quartiles using 3 different versions
	inputs:
		firm_bsheet_data.dta
		firm_groups_yearly.dta