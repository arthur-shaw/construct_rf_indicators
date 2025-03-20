* ==============================================================================
* get ado from remote repos
* ==============================================================================

* TOOD
* examples: 
* - install -repkit- target version either globally or locally
* - use -repkit- to get and project-locally install labeller, selector

* ==============================================================================
* load local utility programs
* ==============================================================================

* load function definitions
local util_files : dir "${utils}" files "*.do"
local util_files : list clean util_files
foreach util_file of local util_files {
  run "${utils}/`util_file'""
}
