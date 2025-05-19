* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

* shocks
local shocks "s16aq1"

* ------------------------------------------------------------------------------
* check metadata
* ------------------------------------------------------------------------------

check_metadata, file("shocks.xlsx")

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}/${hhold_lvl_data}", clear

* collect list of variables needed to construct inputs
delim ;
local shocks_input_vars "
`shocks'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `shocks_input_vars'

* ==============================================================================
* create hhold-level attributes
* ==============================================================================

* Household  reporting  severe or extremely severe shocks (as share of households reporting each type of shock)
* Frequency of shocks to Households since January 2022 (Number of times)	Shocks & Coping	Tab 96
* Importance of Household Shock Coping Mechanisms in the Past 12 Months (as share of Households reporting any shock)	Shocks & Coping	Tab 97
* Household Shock Coping Mechanisms in the Past 12 Months (as share of Households reporting any shock)	Shocks & Coping	Tab 98a


* ------------------------------------------------------------------------------
* food consumption shocks
* ------------------------------------------------------------------------------

* Households reporting at least one (1) food consumption shocks in last 12 months (as share of Households)	Shocks & Coping	Tab 92

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



* ------------------------------------------------------------------------------
* household reporting shocks
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* check that survey data and metadata contain same values
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

* save temporary data sets
* shocks
tempfile shocks_indicators
save "`shocks_indicators'", replace
* metadata
import excel using "${data_meta}/shocks.xlsx", clear
tempfile "`shocks_metadata'"
save "`shocks_metadata'", replace

* count the number of matching shocks variables
qui: ds `shocks'__*, has(type numeric)
local shocks_vars "`r(varlist)'"
local n_shocks_vars : word count `shocks_vars'
local shock_codes_from_var = subinstr("`shocks_vars'", "`shocks'__", "", .)

* check that number of variables matches number of codes
use "`metadata'", clear
local n_codes = r(N)
levelsof code, local(shock_codes_from_meta)

local codes_match : list shock_codes_from_var === shock_codes_from_meta
capture assert `codes_match' == 1
if (_rc != 0) {
  di as error "Mismatch between variable and metadata."
  di as error "The mutli-select variable has values: `shock_codes_from_var'"
  di as error "The metadata has values: `shock_codes_from_meta'"
}

* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
* create indicators for each "level" of shocks
* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

local shock_vals "`shock_codes_from_var'"

local n : word count `shock_vals'

forvalues i = 1/`n' {

  local shock_val : word `i' of `shock_vals'

  * load metadata
  use "`shocks_metadata'", clear
  * keep the single observation corresponding to that code
  keep if (code == `shock_val')

  * extract the values as macros
  local shock_name = name[1]
  local shock_code = code[1]
  local shock_desc = desc[1]

  * load survey microdata
  use "`shocks_indicators'", clear

  * create an indicator for that code value
  gen shock_`shock_name' = (`shocks'__`shock_code' == 1)
  label variable shock_`shock_name' `"Shock: `shock_desc'"'

  * save updated version of survey data
  tempfile shocks_indicators
  save "`shocks_indicators'", replace

}

* reload survey data (if needed)
use "`shocks_indicators'", clear

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local shocks_indicators "
";
#delim cr;

keep ${hhid} ${person_id} `shocks_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Shocks indicators"
save "${data_clean}/shocks.dta", replace
