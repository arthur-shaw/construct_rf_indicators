* ==============================================================================
* setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🛖 hhold-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local has_business "FILTER1_S15A" // NOTE: is a computed variable

local biz_constraint_to_start "s15aq11"
local biz_constraint_to_ops_growth "s15aq12"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🏪 enterprise-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local biz_main_activity "s15bq1c"

local biz_sources_startup_captial "s15bq24"

* enterprise characteristics
local biz_registered "s15bq15" // NOTE: mutli-select y/n where items are registration entities
local biz_n_workers_hhold "s15bq17a" // NOTE: multi-select checkbox where members are selected
local biz_n_workers_hired "s15bq19"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🛖 hhold-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* ingest
use "${data_clean}/${hhold_lvl_data}", clear

* collect list of variables needed to construct inputs
#delim ;
local hhbiz_hhold_lvl_input_vars "
`has_business'
`biz_constraint_to_start'
`biz_constraint_to_ops_growth'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `hhbiz_hhold_lvl_input_vars'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🏪 enterprise-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* ingest
use "${data_clean}/${biz_lvl_data}", clear

* collect list of variables needed to construct inputs
#delim ;
local hhbiz_biz_lvl_input_vars "
`biz_main_activity'
`biz_sources_startup_captial'
`biz_registered'
`biz_n_workers_hhold'
`biz_n_workers_hired'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `hhbiz_biz_lvl_input_vars'

* ==============================================================================
* construct indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* 🛖 hhold-level
* ------------------------------------------------------------------------------

use "${data_clean}/${hhold_lvl_data}", clear

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* has a business
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `has_business', type(numeric)

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen has_business = (`has_business' == 1)
label variable has_business "Has a business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* main constraint to starting a business
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `biz_constraint_to_start', type(numeric)
lbl_assert_all_vals_labelled `biz_constraint_to_start'

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen biz_constraint_to_start = `biz_constraint_to_start'
label variable biz_constraint_to_start "Main constraint to starting a business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* main constraint to operating and growing a business
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `biz_constraint_to_ops_growth', type(numeric)
lbl_assert_all_vals_labelled `biz_constraint_to_ops_growth'

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen biz_constraint_to_ops_growth = biz_constraint_to_ops_growth
label variable biz_constraint_to_ops_growth "Main constraint to operating and growing a business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* save data temporarily
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

tempfile biz_data_hhold_lvl
save "`biz_data_hhold_lvl'", replace

* ------------------------------------------------------------------------------
* 🏪 enterprise-level
* ------------------------------------------------------------------------------

use "${data_clean}/${biz_lvl_data}", clear

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* enterprise activity
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `has_business', type(numeric)

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen has_business = (`has_business' == 1)
label variable has_business "Has a non-farm enterprise"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* main source of startup capital
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

// note: not checking values since they may change and are not necessary for indicator
confirm_type `biz_main_activity', type(numeric)
lbl_assert_all_vals_labelled `biz_main_activity'

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen biz_main_activity = `biz_main_activity'
label variable biz_main_activity "Main activity of the business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* business registered
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `biz_registered'__1, type(numeric)
confirm_type `biz_registered'__2, type(numeric)


* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen biz_registered = (`biz_registered'__1 == 1 | `biz_registered'__2 == 1)
label variable biz_registered "Business is registered"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* number of household workers
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm_type `biz_n_workers_hhold'__0, type(numeric)

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

egen biz_n_workers_hhold = rownonmiss(`biz_n_workers_hhold'__)
label variable biz_n_workers_hhold "Number of household members working in business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* number of hired workers
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check ✅
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

confirm type `biz_n_workers_hired', type(numeric)

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* construct 🏗️
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen biz_n_workers_hired = `biz_n_workers_hired'
label variable "Number of non-household members working in business"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* save data temporarily
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

tempfile biz_data_biz_lvl
save "`biz_data_biz_lvl'", replace

* ==============================================================================
* save to disk
* ==============================================================================

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🛖 hhold-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

use "`biz_data_hhold_lvl'", clear

#delim ;
local hhbiz_indicators_hhold "
has_business
biz_constraint_to_start
biz_constraint_to_ops_growth
";
#delim cr;

keep ${hhid} `hhbiz_indicators_hhold'

* save data
label data "Household business hhold-level indicators"
save "${data_clean}/hhold_business_hhold_lvl.dta", replace

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🏪 enterprise-level
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

use "`biz_data_biz_lvl'", clear

#delim ;
local hhbiz_indicators_biz "
biz_main_activity
biz_sources_startup_captial
biz_registered
biz_n_workers_hhold
biz_n_workers_hired
";
#delim cr;

keep ${hhid} ${biz_id} `hhbiz_indicators_biz'

* save data
label data "Household business enterprise-level indicators"
save "${data_clean}/hhold_business_biz_lvl.dta", replace
