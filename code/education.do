* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

* literacy
local can_read "s2q3"
local can_write "s2q4"

local attends_school "s2q9"

local min_to_school "s2q13"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
delim ;
local educ_indicator_input_vars "
`can_read'
`can_write'
`attends_school'
`min_to_school'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `educ_indicator_input_vars'

* ==============================================================================
* create person-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* years of education
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* ------------------------------------------------------------------------------
* literacy
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* can read
confirm_type `can_read', type(numeric)
lbl_assert_only_vals_present `can_read', vals(1 2)
lbl_assert_all_vals_labelled `can_read'

* can write
confirm_type `can_write', type(numeric)
lbl_assert_only_vals_present `can_write', vals(1 2)
lbl_assert_all_vals_labelled `can_write'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen literate = (`can_read' == 1 & `can_write' == 1)

* ------------------------------------------------------------------------------
* attends school
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `attends_school', type(numeric)
lbl_assert_only_vals_present `attends_school', vals(1 2)
lbl_assert_all_vals_labelled `attends_school'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar attends_school = `attends_school'
label variable attends_school "Attends school"

* ------------------------------------------------------------------------------
* qualification attained
* ------------------------------------------------------------------------------
/* Qualification Attained (as share of persons aged 3 years and older) 	Education	Tab 19 */

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* ------------------------------------------------------------------------------
* school proximity
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `min_to_school', type(numeric)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local time_min "0 16 31 46 61"
local time_max "15 30 46 60 none"
local n_intervals : word count `time_min'

forvalues i = 1/`n_intervals' {

  if (`time_in' != 61) {
    local min : word `i' of `time_min'
    local max : word `i' of `time_max'
    gen time_to_school_`min'_`max'm = inrange(`min_to_school', `min', `max')
    label variable "Time to reach school: between `min' and `max' minutes"
  }
  else {
    local min : word `i' of `time_min'
    gen time_to_school_`min'm_plus = `min_to_school' >= 61 & !mi(`min_to_school')
    label variable "Time to reach school: `min'+ minutes"
  }

}

* ==============================================================================
* save data
* ==============================================================================

* keep only constructed indicators
keep ${hhid} ${person_id} ///
  literate ///
  attends_school ///
  time_to_school_* ///

label data "Education indicators" size"
save "${data_clean}/education.dta", replace
