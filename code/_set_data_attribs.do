* ==============================================================================
* file names
* ==============================================================================

global hhold_lvl_data     "RF_all_modules.dta"
global member_lvl_data   "r_members.dta"
global biz_lvl_data       "r_business.dta"

* ==============================================================================
* ID variables
* ==============================================================================

global hhid "interview__id"
global member_id = ustrregexrf("${member_lvl_data}", "\.dta", "__id")
global biz_id = ustrregexrf("${biz_lvl_data}", "\.dta", "__id")
