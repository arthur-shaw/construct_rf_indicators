capture program drop confirm_vars_present
        program define confirm_vars_present, rclass

  syntax namelist

  qui {

    * use varlist macro name for simplicity
    local varlist "`namelist'"

    * initialize container to collect missing variables
    local missing_vars ""

    * iteratively check whether each variable is present
    foreach var in `varlist' {

      capture confirm variable `var'
      if _rc != 0 {
        local missing_vars "`missing_vars' `var'"
      }

    }

    * issue error if at least one variable is missing
    local n_missing_vars : list sizeof missing_vars
    if (`n_missing_vars' > 0) {
      if (`n_missing_vars' == 1) {
        noi: display as error "Variable missing: `missing_vars'"
      }
      else if (`n_missing_vars' > 1) {
        noi: display as error "Variables missing: `missing_vars'"
      }
      error 9
    }

  }

end
