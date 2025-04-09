* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local difficulty_seeing "s3cq1"
local difficulty_hearing "s3cq2"
local difficulty_movement "s3cq3"
local difficulty_cognitive "s3cq4"
local difficulty_care "s3cq5"
local difficulty_communication "s3cq6"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
delim ;
local functioning_indicator_input_vars "
`difficulty_seeing'
`difficulty_hearing'
`difficulty_movement'
`difficulty_cognitive'
`difficulty_care'
`difficulty_communication'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `functioning_indicator_input_vars'

* ==============================================================================
* create person-level attributes
* ==============================================================================

* ------------------------------------------------------------------------------
* disability
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

local difficulties "seeing yearing movement cognitive care communication"

foreach difficulty of local difficulties {

  confirm_type `difficulty_`difficulty'', type(numeric)
  lbl_assert_only_vals_present `difficulty_`difficulty'', vals(1 2 3 4)
  lbl_assert_all_vals_labelled `difficulty_`difficulty''

}

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* types of disabilities
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

#delim ;
local difficulty_descs "
"seeing"
"hearing"
"walking/climbing steps"
"concentrating/remembering"
"self care"
"communicating"
";
#delim cr;

local n_difficulties : word count `difficulties'

forvalues i = 1/`n_difficulties' {

  local difficulty : word `i' of `difficulties'
  local difficulty_desc : word `i' of `difficulty_descs'

  clonevar difficulty_`difficulty' = inlist(`difficulty_`difficulty'', 2, 3, 4)
  label variable difficulty_`difficulty' "Has difficulty `difficulty_desc'"

}

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* any / no disability
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

* count the number of difficulties, letting all missings result in missing
egen n_difficulties = rowtotal(difficulty_*), missing


* create indicators for any or no difficulties,
* letting missing counts result in missing indicator values
gen difficulty_any = (n_difficulties >= 1) if (!mi(n_difficulties))
gen difficulty_none = (n_difficulties == 0) if (!mi(n_difficulties))

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local functioning_indicators "
difficulty_seeing
difficulty_hearing
difficulty_movement
difficulty_cognitive
difficulty_care
difficulty_communication
difficulty_any
difficulty_none
";
#delim cr;

keep ${hhid} ${person_id} `functioning_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Functioning indicators"
save "${data_clean}/functioning.dta", replace
