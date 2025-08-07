capture program drop lbl_assert_only_vals_present
        program define lbl_assert_only_vals_present, rclass

  syntax varname, vals(numlist)

  qui {

    * get labelled values from data
    lbl_get_val_lbls `varlist'
    local labelled_vals "`r(lbl_vals)'"

    * repare macros for comparison
    local labelled_vals : list sort labelled_vals
    local vals : list sort vals

    * check that the set is the same
    local has_all_vals : list vals == labelled_vals

    * display results
    if (`has_all_vals' == 1) {
      noi: di as result "🎉 All values found in the value labels for `varlist'"
    }
    else if (`has_all_vals' == 0) {
      noi: di as error "The following values are not found in the value labels for `varlist': `has_all_vals'"
      local missing_vals : list vals - labelled_vals
      return local missing_vals "`missing_vals'"
      error 9
    }

  }

end

