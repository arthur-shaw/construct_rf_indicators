* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local relationship_to_head "s1q3"
local member_age "s1q4alt"
local marital_status "s1q7"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
delim ;
local hhroster_indicator_input_vars "
";
#delim cr;

* check that desired variables are present
confirm_vars_present `hhroster_indicator_input_vars'

* ==============================================================================
* 
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

gen hhsize = 1

* those ages zero to 14 years or 65 years and older
gen dependent = ( ///
  (inrange(`member_age', 0, 14)) | /// between 0 and 14
  (`member_age' >= 65 & !mi(`member_age')) /// or above 65, excluding missing

)

gen age12 = (`member_age' >= 12)

gen n_married_mono  = (`marital_status' == 1 & age12 == 1)
gen n_married_poly  = (`marital_status' == 2 & age12 == 1)
gen n_inform_union  = (`marital_status' == 3 & age12 == 1)
gen n_divorced      = (`marital_status' == 4 & age12 == 1)
gen n_separated     = (`marital_status' == 5 & age12 == 1)
gen n_widowed       = (`marital_status' == 6 & age12 == 1)
gen n_never_married = (`marital_status' == 7 & age12 == 1)
