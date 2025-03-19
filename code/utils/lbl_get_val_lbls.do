capture program drop lbl_get_val_lbls
        program define lbl_get_val_lbls, rclass

  syntax varname, [Verbose]

  qui {

    * issue error if variable does not have any value labels
    local val_lbl_name : value label `varlist'
    if ("`val_lbl_name'" == "") {
      noi: di as error "This variable has no value labels attached."
      error 9
    }

    * collect labelled values
    preserve

      * create a data frame of value labels
      uselabel `val_lbl_name', clear

      local n_obs = _N

      local lbl_vals ""
      local lbl_labels ""

      * iteratively collect value labels value and labels
      forvalues i = 1/`n_obs' {
        local lbl_vals "`lbl_vals' `= value[`i']'"
        local lbl_labels "`lbl_labels' `= label[`i']'"
      }

    restore

    * display standard results
    noi: di as result "Labels exist for the following values: `lbl_vals'"

    * if verbose flag passed, display verbose results as well
    if (!mi("`verbose'")) {

      local val_lbl_name : value label `varlist'
      noi: label list `val_lbl_name'

    }

    * return label values and text as local macros
    return local lbl_vals "`lbl_vals'"
    return local lbl_labels "`lbl_labels'"

  }

end
