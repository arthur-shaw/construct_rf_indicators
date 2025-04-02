* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local cookstove_type "s12q2"
local cookstove_location "s12q8"

local cookstove_injury "s12q28"

local source_electricity "s12q14"

local blackout_number "s12q24"
local blackout_duration "s12q25"



* ==============================================================================
* load and check data
* ==============================================================================

* ingest
use "${data_clean}", clear

* check that desired variables are present
confirm_vars_present `cookstove_type' `cookstove_location'

* ==============================================================================
* primary cookstove type
* ==============================================================================

* check that all expected values are present and labelled
lbl_assert_only_vals_present `cookstove_type', vals(1 2 3 4 5 6 96)
lbl_assert_all_vals_labelled `cookstove_type'

* clone variable
clonevar cookstove_type = `cookstove_type'

* ==============================================================================
* primary cookstove location
* ==============================================================================

* check that all expected values are present and labelled
lbl_assert_only_vals_present `cookstove_location', vals(1 2 3 4 5 6 96)
lbl_assert_all_vals_labelled `cookstove_location'

* clone variable
clonevar cookstove_location = `cookstove_location'

* ==============================================================================
* cookstove injury
* ==============================================================================

* check that all expected values are present and labelled
lbl_assert_only_vals_present `cookstove_injury', vals(1 2 99)
lbl_assert_all_vals_labelled `cookstove_injury'

* clone variable
clonevar cookstove_type = `cookstove_type'

* ==============================================================================
* access to electricity
* ==============================================================================

* ------------------------------------------------------------------------------
* access to any source
* ------------------------------------------------------------------------------

* check that all expected values are present and labelled
lbl_assert_only_vals_present `electricity_access', vals(1 2)
lbl_assert_all_vals_labelled `electricity_access'

* clone variable
clonevar electricity_access = `electricity_access' == 1

* ------------------------------------------------------------------------------
* main source
* ------------------------------------------------------------------------------

* check that all expected values are present and labelled
lbl_assert_only_vals_present `electricity_main_source', vals(1 2 99)
lbl_assert_all_vals_labelled `electricity_main_source'

* clone variable
clonevar electricity_main_source = `electricity_main_source'

* ==============================================================================
* blackouts in the past 7 days
* ==============================================================================

* number
confirm_type `blackout_number', type(numeric)
clonevar blackout_number = `blackout_number'

* total duration
confirm_type `blackout_duration', type(numeric)
clonevar blackout_duration = `blackout_duration'
