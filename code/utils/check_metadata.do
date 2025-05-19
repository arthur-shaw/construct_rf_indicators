capture program drop check_metadata
        program define check_metadata, rclass

  syntax , file(string)

  qui {

    * check that metadata exists
    capture confirm file "`file'"
    if (_rc != 1) {
      di as error "Metadata file does not exist."
      di as error "The program expects `file' in the metadata folder."
      di as error "Please create this file and place it in /data/00_meta/"
      error 9
    }

    * check that file contains a sheet named -var_metadata-
    capture import excel using "${data_meta}/`file'", sheet("var_metadata")
    if (_rc != 0) {
      noi: di as error "Metadata file does not contain expected sheet"
      noi: di as error "The program expects metadata to be stored in a sheet named var_metadata."
      noi: di as error "Please fix the contents of the file."
      error 9
    }

    * confirm that metadata has the expected form
    import excel using "${data_meta}/`file'", sheet("var_metadata") clear

    local metadata_col_names "name code desc"
    local metadata_col_types "string numeric string"

    local n : word count `metadata_col_names'

    forvalues i = 1/`n' {

      * extract ith elment of macro
      local metadata_col_name : word `i' `metadata_col_names'
      local metadata_col_type : word `i' `metadata_col_types'

      * column exists
      capture confirm variable `metadata_col_name', exact
      if (_rc != 0) {
        noi: di as error "Column not found in metadata: `metadata_col_name'"
        noi: di as error "The program expects to find the following columns `metadata_col_names'"
        noi: di as error "Please correct the file found here: ${data_meta}/shocks.xlsx"
        error 9
      }
      * column of expected type
      capture confirm string variable `metadata_col_name', exact
      if (_rc != 0) {
        local var_type_found : type `metadata_col_name'
        noi: di as error "Column `metadata_col_name' of unexpected type"
        noi: di as error "Type expected: `metadata_col_type'"
        noi: di as error "Type found: `var_type_found'"
        error 9
      }

    }

    * check whether there are any duplicate entries, checking in each column
    foreach metadata_col_name of local metadata_col_names {

      * create a variable to identify duplicates
      duplicates tag `metadata_col_names', generate(dup_tag)
      summarize dup_tag if dup_tag > 0

      if r(N) > 0 {
        noi: display as error "Duplicate values of `metadata_col_name' found"
        noi: duplicates list `metadata_col_names'
        exit 9
      } else {
        capture drop dup_tag
      }

    }

  }

end
