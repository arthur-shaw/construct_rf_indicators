* ==============================================================================
* setup
* ==============================================================================

/*

TODO:

[x] Proportion of adults (15+) with an account at a bank or other financial institution or with a mobile-money-service provider
[ ] Number of people and number of women that that use financial services
[ ] Percentage of adults reporting owning a formal financial account
[ ] Percentage of adults reporting using digital payments
[ ] Percentage point gap in adults reporting formal account ownership between regions
[ ] Percentage point gender gap in adults reporting formal account ownership between regions
[?] Percentage of adults reporting using formal savings

*/

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local have_financial_account "s6q3"
local have_fin_acct_val "1"

local use_formal_savings_account "s6q14"
local use_savings_acct_val "1"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
#delim ;
local financial_indicator_input_vars "
`have_financial_account'
`use_formal_savings_account'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `financial_indicator_input_vars'

* ==============================================================================
* create indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* have financial account
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `have_financial_account', type(numeric)
lbl_assert_only_vals_present `have_financial_account', vals(1 2)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

clonevar have_financial_account = (`have_financial_account' == `have_fin_acct_val')
label variable have_financial_account "Have a formal financial account"

* ------------------------------------------------------------------------------
* use formal savings account
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* check
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

confirm_type `use_formal_savings_account', type(numeric)
lbl_assert_only_vals_present `use_formal_savings_account', vals(1 2)

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* construct
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen use_formal_savings_account = (`use_formal_savings_account' == `use_savings_acct_val')
label variable use_formal_savings_account "Use a formal savings account"

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local functioning_indicators "
have_financial_account
use_formal_savings_account
";
#delim cr;

keep ${hhid} ${person_id} `functioning_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Functioning indicators"
save "${data_clean}/functioning.dta", replace
