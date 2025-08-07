* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local gender "s1q2"
local relationship "s1q3"
local age "s1q4alt"
local marital_status "s1q7"
local birth_registered "s1q6"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}/${member_lvl_data}", clear

* collect list of variables needed to construct inputs
#delim ;
local hhroster_indicator_input_vars "
`gender'
`relationship'
`age'
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
replace hhsize = 1 if (!mi(${person_id}))
label variable hhsize "Household size"

* ------------------------------------------------------------------------------
* gender
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `gender', type(numeric)
lbl_assert_only_vals_present `gender', vals(1 2)
lbl_assert_all_vals_labelled `gender'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar gender = `gender'
label variable gender "Gender"

* ------------------------------------------------------------------------------
* relationship to head
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `relationship', type(numeric)
lbl_assert_only_vals_present `relationship', vals(1/13)
lbl_assert_all_vals_labelled `relationship'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar relationship = `relationship'
label variable relationship "Relationship"

* ------------------------------------------------------------------------------
* age
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `age', type(numeric)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar age = `age'
label variable age "Age"

* ------------------------------------------------------------------------------
* dependent
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* age is numeric
confirm_type `age', type(numeric)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* those ages zero to 14 years or 65 years and older
gen dependent = ( ///
  (inrange(`age', 0, 14)) | /// between 0 and 14
  (`age' >= 65 & !mi(`age')) /// or above 65, excluding missing
)

* ------------------------------------------------------------------------------
* marital status
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `marital_status', type(numeric)
lbl_assert_only_vals_present `marital_status', vals(1 2 3 4 5 6 7)
lbl_assert_all_vals_labelled `marital_status'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar marital_status = `marital_status'
label variable marital_status "Marital status"

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
keep ${hhid} ${person_id} gender relationship age ///
  marital_status birth_registered

label data "Demographic indicators"
save "${data_constructed}/hhroster.dta", replace

* ------------------------------------------------------------------------------
* household-level aggregates
* ------------------------------------------------------------------------------

use "`tempfile'", clear

* create count by household
collapse (count) hhsize, by(${hhid})

* keep only constructed indicator
keep ${hhid} hhsize

label data "Household size"
save "${data_constructed}/hhsize.dta", replace
