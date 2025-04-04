* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local toilet_type "s13q11"

local drinking_water "s13q2"

local water_collection_time "s13q4"

local treat_water "s13q5"
local water_treatment_type "s13q6"

local refuse_disposal_type "s13q19"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
#delim ;
`wash_indicator_input_vars'
`toilet_type'
`drinking_water'
`water_collection_time'
`treat_water'
`water_treatment_type'
`refuse_disposal_type'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `wash_indicator_input_vars'

* ==============================================================================
* toilet
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `toilet_type', type(numeric)
lbl_assert_only_vals_present `toilet_type', vals(1/14 96)
lbl_assert_all_vals_labelled `toilet_type'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar toilet_type = `toilet_type'
label variable toilet_type "Toilet facilities"

* ==============================================================================
* drinking water 
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `drinking_water', type(numeric)
lbl_assert_only_vals_present `drinking_water', vals(1/17 96)
lbl_assert_all_vals_labelled `drinking_water'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar drinking_water = `drinking_water'
label variable drinking_water "Source of drinking water"

* ==============================================================================
* water collection time
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `water_collection_time', type(numeric)

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar water_collection_time = `water_collection_time'
* recode "do not collect" code as missing, since it is not a zero
replace water_collection_time = . if (water_collection_time == 0)
label variable water_collection_time "Time to get water"

* ==============================================================================
* water treatment 
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

* whether treat water
confirm_type `treat_water', type(numeric)
lbl_assert_only_vals_present `treat_water', vals(1 2)
lbl_assert_all_vals_labelled `treat_water'

* type of water treatment
confirm_type `water_treatment_type', type(numeric)
lbl_assert_only_vals_present `water_treatment_type', vals(1/6 96)
lbl_assert_all_vals_labelled `water_treatment_type'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

* whether treat water
clonevar treat_water = `treat_water'
label variable treat_water "Treat water to make it safe to drink"

* type of water treatment
clonevar water_treatment_type = `water_treatment_type'
label variable water_treatment_type "Type of water treatment"

* ==============================================================================
* trash disposal 
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `refuse_disposal_type', type(numeric)
lbl_assert_only_vals_present `refuse_disposal_type', vals(1/8 96)
lbl_assert_all_vals_labelled `refuse_disposal_type'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar refuse_disposal_type = `refuse_disposal_type'
label variable "How dispose of refuse"

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local wash_indicators "
wash_indicator_input_vars
toilet_type
drinking_water
water_collection_time
treat_water
water_treatment_type
refuse_disposal_type
";
#delim cr;

keep ${hhid} `wash_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "WASH indicators"
save "${data_clean}/wash.dta", replace
