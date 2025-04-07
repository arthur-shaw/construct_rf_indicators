* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local member_gender "s1q2"
local relationship_to_head "s1q3"
local member_age "s1q4alt"
local marital_status "s1q7"
local birth_registered "s1q6"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
delim ;
local hhroster_indicator_input_vars "
`member_gender'
`relationship_to_head'
`member_age'
`marital_status'
`birth_registered'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `hhroster_indicator_input_vars'

* ==============================================================================
* create person-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* household size
* ------------------------------------------------------------------------------

gen hhsize = .
replace hhsize = 1 if (!mi($(person_id)))
label variable hhsize "Household size"

* ------------------------------------------------------------------------------
* gender
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `member_gender', type(numeric)
lbl_assert_only_vals_present `member_gender', vals(1 2)
lbl_assert_all_vals_labelled `member_gender'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar member_gender = `member_gender'
label variable member_gender "Gender"

* ------------------------------------------------------------------------------
* dependent
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* age is numeric
confirm_type `member_age', type(numeric)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* those ages zero to 14 years or 65 years and older
gen dependent = ( ///
  (inrange(`member_age', 0, 14)) | /// between 0 and 14
  (`member_age' >= 65 & !mi(`member_age')) /// or above 65, excluding missing
)

* ------------------------------------------------------------------------------
* marital status
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local vals "1 2 3 4 5 6 7"

confirm_type `marital', type(numeric)
lbl_assert_only_vals_present `marital', vals(`vals')
lbl_assert_all_vals_labelled `marital'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen age12 = (`member_age' >= 12)

local names "married_mono married_poly inform_union divorced separated widowed never_married"
local lbls `" "Married (Mono)" "Married (Polygamous)" "Informal union" "Divorced" "Separated" "Widowed" "Never Married" "'
local n: word count `vals'

forvalues i = 1/`n' {

  * extract the ith element
  local val : word `i' of `vals'
  local name : word `i' of `names'
  local lbl : word `i' of `lbls'
  
  * create dummy
  gen n_`name' = (`marital' == `val' & age12 == 1)
  label variable n_`name' "`lbl'"

}

* ------------------------------------------------------------------------------
* registered birth
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `birth_registered', type(numeric)
lbl_assert_only_vals_present `birth_registered', vals(1 2)
lbl_assert_all_vals_labelled `birth_registered'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen birth_registered = (`birth_registered' == 1)
label variable birth_registered "Birth registered with civil authorities/registrar"

* ==============================================================================
* create data sets of indicators/attributes
* ==============================================================================

tempfile hhroster
save "`tempfile'", replace

* ------------------------------------------------------------------------------
* individual-level data
* ------------------------------------------------------------------------------

use "`tempfile'", clear

* keep constructed indicators/attributes
keep ${hhid} ${person_id} member_gender relationship_to_head member_age ///
  marital_status birth_registered

label data "Demographic indicators"
save "${data_clean}/hhroster.dta", replace

* ------------------------------------------------------------------------------
* household-level aggregates
* ------------------------------------------------------------------------------

use "`tempfile'", clear

* create count by household
collapse (count) hhsize, by(${hhid})

* keep only constructed indicator
keep ${hhid} hhsize

label data "Household size"
save "${data_clean}/hhsize.dta", replace
