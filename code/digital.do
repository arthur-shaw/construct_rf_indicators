* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🧑‍🤝‍🧑 in person-level data
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* mobile phone
local have_mobile_phone "s5q3"
local access_mobile_phone "s5q4"

* internet
local access_internet_member "s5q6"

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* 🏠 in household-level data
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local access_internet_hhold "s11q19"

* ==============================================================================
* 🧑‍🤝‍🧑 create person-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}"/${persons_lvl_data}, clear

* collect list of variables needed to construct inputs
delim ;
local digital_indicator_input_vars "
`have_mobile_phone'
`access_mobile_phone'
`access_internet'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `digital_indicator_input_vars'

* ------------------------------------------------------------------------------
* mobile phone
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local phone_vars "`have_mobile_phone' `access_mobile_phone'"

foreach phone_var of local phone_vars {

  confirm_type `phone_var', type(numeric)
  lbl_assert_only_vals_present `phone_var', vals(1 2)
  lbl_assert_all_vals_labelled `phone_var'

}

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#delim ;

local phone_var_names "
have_mobile_phone
access_mobile_phone
";

local phone_var_descs `"
"Own"
"Have access to"
"';

#delim cr;

local n_phone_vars : word count `phone_vars'

forvalues i = 1/`n_phone_vars' {

  local phone_var_name : word `i' of `phone_var_names'
  local phone_var : word `i' of `phone_vars'
  local phone_var_desc : word `i' of `phone_var_descs'

  gen `phone_var_name' = (`phone_var' == 1)
  label variable `phone_var_name' "`phone_var_desc' a mobile phone"

}

* ------------------------------------------------------------------------------
* internet
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `access_internet_member', type(numeric)
lbl_assert_only_vals_present `access_internet_member', vals(1 2)
lbl_assert_all_vals_labelled `access_internet_member'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen access_internet_member = (`access_internet_member' == 1)
label variable access_internet_member "Have access to the internet"

* ------------------------------------------------------------------------------
* save data temporarily
* ------------------------------------------------------------------------------

tempfile digital_data_member
save "`digital_data_member'", replace

* ==============================================================================
* 🏠 create household-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}"/${hhold_lvl_data}, clear

* collect list of variables needed to construct inputs
delim ;
local digital_indicator_input_vars "
`access_internet_hhold'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `digital_indicator_input_vars'

* ------------------------------------------------------------------------------
* internet
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `access_internet_hhold', type(numeric)
lbl_assert_only_vals_present `access_internet_hhold', vals(1 2)
lbl_assert_all_vals_labelled `access_internet_hhold'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen access_internet_hhold = (`access_internet_hhold' == 1)
label variable access_internet_hhold "Have access to the internet"

* ------------------------------------------------------------------------------
* save data temporarily
* ------------------------------------------------------------------------------

tempfile digital_data_hhold
save "`digital_data_hhold'", replace


* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* 🧑‍🤝‍🧑 member-level
* ------------------------------------------------------------------------------

use "`digital_data_member'", clear

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* keep only necessary variables
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#delim ;
local digitial_indicators "
have_mobile_phone
access_mobile_phone
access_internet_member
";
#delim cr;

keep ${hhid} ${person_id} `digitial_indicators'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* save data
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

label data "Digitial technology member-level indicators"
save "${data_clean}/digitial_member_lvl.dta", replace

* ------------------------------------------------------------------------------
* 🏠 hhold-level
* ------------------------------------------------------------------------------

use "`digital_data_hhold'", clear

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* keep only necessary variables
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#delim ;
local digitial_indicators "
access_internet_hhold
";
#delim cr;

keep ${hhid} `digitial_indicators'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* save data
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

label data "Digitial technology hhold-level indicators"
save "${data_clean}/digitial_hhold_lvl.dta", replace
