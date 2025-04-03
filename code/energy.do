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

local elec_avail_24hr "s12q19"
local elec_avail_evening "s12q20"

local elec_quality "s12q27"


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

* ==============================================================================
* availability
* ==============================================================================

* check
confirm_type `elec_avail_24hr', type(numeric)
confirm_type `elec_avail_evening', type(numeric)

* construct
* for 24 hours
clonevar elec_avail_24hr = `elec_avail_24hr'
* for evening
* if available for 24 hours, then available for 4 evening hours
* otherwise, the reported number of hours
gen elec_avail_evening = .
replace elec_avail_evening = 4 if (elec_avail_24hr == 24)
replace elec_avail_evening = `elec_avail_evening' if (elec_avail_24hr < 24)

* ==============================================================================
* quality
* ==============================================================================

* check
lbl_assert_only_vals_present `elec_quality', vals(1 2 -98)
lbl_assert_all_vals_labelled `elec_quality'

* construct
clonevar elec_quality = `elec_quality'

