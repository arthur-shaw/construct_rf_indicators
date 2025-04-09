* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local had_health_event "s3q5"
local had_health_consultation "s3q8"
local health_facility_visited "s3q9"

local reason_no_treatment "s3q13"

* NOTE: CAPI app does not match paper questionnaire
local hospitalized "s3q24"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
delim ;
local health_indicator_input_vars "
`had_health_event'
`had_health_consultation'
`health_facility_visited'
`reason_no_treatment'
`hospitalized'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `health_indicator_input_vars'

* ==============================================================================
* create person-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* facility visited
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* got sick
confirm_type `had_health_event', type(numeric)
lbl_assert_only_vals_present `had_health_event', vals(1 2)
lbl_assert_all_vals_labelled `had_health_event'

* consulted a provider
confirm_type `had_health_consultation', type(numeric)
lbl_assert_only_vals_present `had_health_consultation', vals(1 2)
lbl_assert_all_vals_labelled `had_health_consultation'

* which health faciltiy visited
confirm_type `health_facility_visited', type(numeric)
lbl_assert_only_vals_present `health_facility_visited', vals(1 2 3 4 5 6 7 8 9 96)
lbl_assert_all_vals_labelled `health_facility_visited'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen no_health_visit = (`had_health_event' == 2 | `had_health_consultation' == 2)
label variable "No health consultation"

clonevar health_facility_visited = `health_facility_visited'
label variable health_facility_visited "Health facility visited for consultation"

* ------------------------------------------------------------------------------
* reason for no consultation
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `reason_no_treatment', type(numeric)
lbl_assert_only_vals_present `reason_no_treatment', vals(1 2 3 4 5 6 7 8 9 96)
lbl_assert_all_vals_labelled `reason_no_treatment'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar reason_no_treatment = `reason_no_treatment'
label variable "Reason did not seek treatment for injury or illness"

* ------------------------------------------------------------------------------
* hospitalized
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `hospitalized', type(numeric)
lbl_assert_only_vals_present `hospitalized', vals(1 2)
lbl_assert_all_vals_labelled `hospitalized'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen hospitalized = (`hospitalized' == 1)
label variable hospitalized "Hospitalized"


* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local health_indicators "
no_health_visit
health_facility_visited
reason_no_treatment
hospitalized
";
#delim cr;

keep ${hhid} ${person_id} `health_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Health indicators"
save "${data_clean}/health.dta", replace
