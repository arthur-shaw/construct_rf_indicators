capture program drop lbl_assert_vals_in_lbls
        program define lbl_assert_vals_in_lbls, rclass

  syntax varname, vals(numlist)

  qui {

    * get labelled values from data
    lbl_get_val_lbls `varlist'
    local labelled_vals "`r(lbl_vals)'"

    * determine overlap
    local missing_lbl_vals : list vals - labelled_vals

    * display results
    if (mi("`missing_lbl_vals'")) {
      noi: di as result "🎉 All values found in the value labels for `varlist'"
    }
    else if (!mi("`missing_lbl_vals'")) {
      noi: di as error "The following values are not found in the value labels for `varlist': `missing_lbl_vals'"
      return local missing_vals "`missing_lbl_vals'"
      error 9
    }

  }

end
