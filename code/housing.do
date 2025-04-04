* ==============================================================================
* Setup
* ==============================================================================

* ------------------------------------------------------------------------------
* set variables
* ------------------------------------------------------------------------------

local dwelling_ownership "s11q2"

local has_occupancy_doc "s11q7"
local type_occupancy_doc "s11q8"

local num_rooms "s11q18"
local hhsize "hhsize"

local roof_material "s11q16"
local floor_material "s11q17"
local wall_material "s11q15"

* ------------------------------------------------------------------------------
* load and check data
* ------------------------------------------------------------------------------

* ingest
use "${data_clean}", clear

* collect list of variables needed to construct inputs
#delim ;
local housing_indicator_input_vars "
`dwelling_ownership'
`has_occupancy_doc'
`type_occupancy_doc'
`num_rooms'
`hhsize'
`roof_material'
`floor_material'
`wall_material'
";
#delim cr;

* check that desired variables are present
confirm_vars_present `housing_indicator_input_vars'

* ==============================================================================
* dwelling ownership
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `dwelling_ownership', type(numeric)
lbl_assert_only_vals_present `dwelling_ownership', vals(1 2 3 4)
lbl_assert_all_vals_labelled `dwelling_ownership'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar dwelling_ownership = `dwelling_ownership'

* ==============================================================================
* occupancy documentation
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

* has documentation
confirm_type `has_occupancy_doc', type(numeric)
lbl_assert_only_vals_present `has_occupancy_doc', vals(1 2 3 4)
lbl_assert_all_vals_labelled `has_occupancy_doc'

* type of documentation
confirm_type `type_occupancy_doc', type(numeric)
lbl_assert_only_vals_present `type_occupancy_doc', vals(1 2 3 4)
lbl_assert_all_vals_labelled `type_occupancy_doc'


* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

* has documentation
clonevar has_occupancy_doc = `has_occupancy_doc'
* type of documentation
clonevar type_occupancy_doc = `type_occupancy_doc'

* ==============================================================================
* number of rooms
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

* number of rooms
confirm_type `num_rooms', type(numeric)

* household size

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* number of rooms
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen num_rooms = .
replace num_rooms = 1 if (`num_rooms' == 1)
replace num_rooms = 2 if (`num_rooms' == 2)
replace num_rooms = 3 if (`num_rooms' == 3)
replace num_rooms = 4 if (`num_rooms' == 4)
replace num_rooms = 5 if (`num_rooms' >= 5 & !mi(`num_rooms'))

label define num_rooms 1 "One", modify
label define num_rooms 2 "Two", modify
label define num_rooms 2 "Two", modify
label define num_rooms 3 "Three", modify
label define num_rooms 4 "Four", modify
label define num_rooms 5 "Five or more", modify
label values num_rooms num_rooms

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* rooms per capita
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

gen n_rooms_per_capita = .
replace n_rooms_per_capita = (`num_rooms' / `hhsize') ///
  if (!mi(`num_rooms') & !mi(`hhsize'))
label variable n_rooms_per_capita "Rooms per capita in the household's dwelling"

* ==============================================================================
* roof material
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `roof_material', type(numeric)
lbl_assert_only_vals_present `roof_material', vals(1 2 3 4 5 6 7 8 9 96)
lbl_assert_all_vals_labelled `roof_material'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar roof_material = `roof_material'

* ==============================================================================
* floor material
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `floor_material', type(numeric)
lbl_assert_only_vals_present `floor_material', vals(1 2 3 4 5 6 96)
lbl_assert_all_vals_labelled `floor_material'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar floor_material = `floor_material '

* ==============================================================================
* wall material 
* ==============================================================================

* ------------------------------------------------------------------------------
* check
* ------------------------------------------------------------------------------

confirm_type `wall_material', type(numeric)
lbl_assert_only_vals_present `wall_material', vals(1 2 3 4 5 6 7 8 96)
lbl_assert_all_vals_labelled `wall_material'

* ------------------------------------------------------------------------------
* construct
* ------------------------------------------------------------------------------

clonevar wall_material = `wall_material'

* ==============================================================================
* save indicators
* ==============================================================================

* ------------------------------------------------------------------------------
* keep only necessary variables
* ------------------------------------------------------------------------------

#delim ;
local housing_indicators "
dwelling_ownership
has_occupancy_doc
type_occupancy_doc
num_rooms
n_rooms_per_capita
roof_material
floor_material
wall_material
";
#delim cr;

keep ${hhid} `housing_indicators'

* ------------------------------------------------------------------------------
* save data
* ------------------------------------------------------------------------------

label data "Housing indicators"
save "${data_clean}/housing.dta", replace
