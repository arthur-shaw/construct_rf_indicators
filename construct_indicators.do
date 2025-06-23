* ==============================================================================
* setup
* ==============================================================================

* ⚠️ USER INPUT NEEDED ⚠️
* provide path to project root
global proj_root "C:/Users/WB393438/resilient_futures/construct_rf_indicators"

* set paths
do "${proj_root}/code/_set_paths.do"

* set data attributes: names and ID variables
do "${proj_root}/code/_set_data_attributes.do"

* load project dependencies
do "${code}/_load_proj_environment.do"

* ==============================================================================
* determine modules to run
* ==============================================================================

* TODO

* ==============================================================================
* run selected modules
* ==============================================================================

do "${code}/energy.do"
