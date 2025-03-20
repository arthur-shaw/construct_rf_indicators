* ==============================================================================
* provision the project environment
* - use -repado- to set a local project library
* - use -require- to install project requirements in that library
* ==============================================================================

* install repkit, if it's missing
capture which repkit  
if _rc == 111 {
  di as error "{pstd}You need to have {cmd:repkit} installed to for this project."
  di as error "{pstd}Click {stata ssc install repkit} to do so.{p_end}"
}

* set the location of the project library
repado, using "${ado}"

* install -require- in the project library
capture which require
if _rc == 111 {
  di as error "{pstd}You need to have {cmd:require} installed to for this project."
  di as error "{pstd}Click {stata ssc install require} to do so.{p_end}"
}

* installs requirements in the project library
require using "${code}/requirements.txt", install

* ==============================================================================
* load local utility programs
* ==============================================================================

* load function definitions
local util_files : dir "${utils}" files "*.do"
local util_files : list clean util_files
foreach util_file of local util_files {
  run "${utils}/`util_file'""
}
