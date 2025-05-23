* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local cookstove_type "s12q2"
local cookstove_location "s12q8"

local cookstove_injury "s12q28"

local elec_access "s12q13"
local source_electricity "s12q14"

local blackout_number "s12q24"
local blackout_duration "s12q25"

local elec_avail_24hr "s12q19"
local elec_avail_evening "s12q20"

local elec_quality "s12q27"

local use_grid_elec "S12_filter1"
local elec_formality "s12q15"
local elec_pay_no_one_val "11"

local elec_cons_pkg_price ""
local tot_monthly_consump ""

local elec_safety "s12q28"

* ==============================================================================
* load and check data
* ==============================================================================

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
#delim ;
local energy_indicator_input_vars "
`cookstove_type'
`cookstove_location'
`cookstove_injury'
`elec_access'
`source_electricity'
`blackout_number'
`blackout_duration'
`elec_avail_24hr'
`elec_avail_evening'
`elec_quality'
`use_grid_elec'
`elec_formality'
`elec_pay_no_one_val'
`elec_cons_pkg_price'
`tot_monthly_consump'
`elec_safety'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `energy_indicator_input_vars'

* ==============================================================================
* documentation
* ==============================================================================

/*
Indicators contructed in line with guidance in energy guidebook:
https://documents1.worldbank.org/curated/en/557341633679857128/pdf/Measuring-Energy-Access-A-Guide-to-Collecting-Data-Using-the-Core-Questions-on-Household-Energy-Use.pdf
*/

* ==============================================================================
* primary cookstove type
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

lbl_assert_only_vals_present `cookstove_type', vals(1 2 3 4 5 6 96)
lbl_assert_all_vals_labelled `cookstove_type'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar cookstove_type = `cookstove_type'

* ==============================================================================
* primary cookstove location
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

lbl_assert_only_vals_present `cookstove_location', vals(1 2 3 4 5 6 96)
lbl_assert_all_vals_labelled `cookstove_location'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar cookstove_location = `cookstove_location'

* ==============================================================================
* cookstove injury
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

lbl_assert_only_vals_present `cookstove_injury', vals(1 2 99)
lbl_assert_all_vals_labelled `cookstove_injury'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar cookstove_type = `cookstove_type'

* ==============================================================================
* access to electricity
* ==============================================================================

* ------------------------------------------------------------------------------
* access to any source
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

lbl_assert_only_vals_present `elec_access', vals(1 2)
lbl_assert_all_vals_labelled `elec_access'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar elec_access = `elec_access' == 1

* ------------------------------------------------------------------------------
* main source
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

lbl_assert_only_vals_present `electricity_main_source', vals(1 2 99)
lbl_assert_all_vals_labelled `electricity_main_source'

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

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

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `elec_avail_24hr', type(numeric)
confirm_type `elec_avail_evening', type(numeric)

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

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

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

lbl_assert_only_vals_present `elec_quality', vals(1 2 -98)
lbl_assert_all_vals_labelled `elec_quality'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar elec_quality = `elec_quality'

* ==============================================================================
* formality
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

lbl_assert_only_vals_present `elec_formality', vals(0 1 2 3 4 5 6 7 8 9 10 96)
lbl_assert_all_vals_labelled `elec_formality'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

gen elec_formality = .
replace elec_formality = 3 if (
  use_grid_elec == 1 & ///
  `elec_formality' == `elec_pay_no_one_val' ///
)
replace elec_formality = 5 if ( ///
  use_grid_elec == 1 & ///
  (`elec_formality' != `elec_pay_no_one_val') & !mi(`elec_formality') ///
)

/*
TODOs:
1. See if it makes sense to have labelled values that cannot occur.
Only tiers 3 and 5 appear possible. See also Rwanda code.
2. Consider changing labels to match graphic of "formal" and "informal" access.
See figure 23 in Ethiopia report
*/

label define elec_formality 0 "Formality tier 0", modify
label define elec_formality 1 "Formality tier 1", modify
label define elec_formality 2 "Formality tier 2", modify
label define elec_formality 3 "Formality tier 3", modify
label define elec_formality 4 "Formality tier 4", modify
label define elec_formality 5 "Formality tier 5", modify
label values elec_formality elec_formality
label variable elec_formality "Formality of electricity access"

* ==============================================================================
* affordability
* ==============================================================================

/*
PENDING

- Clarification on how / where to get price of standard energy bundle
- Clarification on how to compute monthly consumption
- Elaboration of consumption aggregate file
*/

* ------------------------------------------------------------------------------
* check inputs
* ------------------------------------------------------------------------------

* total monthly consumption
confirm_type `tot_monthly_consump', type(numeric)

* price of standard energy consumption bundle
capture !mi("`elec_cons_pkg_price'")
if (_rc != 0 ) {
  di as error "The value of the energy consumption bundle is missing."
  error 9
}

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

* capture components of expressions in macros for reuse
local five_pct_tot_monthly_cons "(0.05 * `tot_monthly_consump')"
local tot_monthly_cons_not_miss "!mi(`tot_monthly_consump')"

* construct indicator
gen elec_affordability = .
replace elec_affordability = 2 if ///
  (`five_pct_tot_monthly_cons' < `elec_cons_pkg_price') & ///
  (`tot_monthly_cons_not_miss')
replace elec_affordability = 5 if ///
  (`five_pct_tot_monthly_cons' >= `elec_cons_pkg_price') & ///
  (`tot_monthly_cons_not_miss')

* ==============================================================================
* affordability
* ==============================================================================

* ------------------------------------------------------------------------------
* check inputs
* ------------------------------------------------------------------------------

confirm_type `elec_safety', type(numeric)
lbl_assert_only_vals_present `elec_safety', vals(1 2 -98)
lbl_assert_all_vals_labelled `elec_safety'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

gen elec_safety = .
replace elec_safety = 0 if (`elec_safety' == 1)
replace elec_safety = 5 if (`elec_safety' == 1)
label define elec_safety 0 "Accidents", modify
label define elec_safety 0 "No accidents", modify
label values elec_safety elec_safety
label variable elec_safety "Safety of electricity source"

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local energy_indicators "
cookstove_type
cookstove_location
cookstove_injury
elec_access
source_electricity
blackout_number
blackout_duration
elec_avail_24hr
elec_avail_evening
elec_quality
use_grid_elec
elec_formality
elec_pay_no_one_val
elec_cons_pkg_price
tot_monthly_consump
elec_safety
";
#delim cr;

keep ${hhid} `energy_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Energy indicators"
save "${data_clean}/energy.dta", replace
