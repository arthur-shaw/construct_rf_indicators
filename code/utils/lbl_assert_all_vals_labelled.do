capture program drop lbl_assert_all_vals_labelled
        program define lbl_assert_all_vals_labelled, rclass

  syntax varname

  qui {

    * issue error if variable does not have any value labels
    local has_val_lbls : value label `varlist'
    if ("`has_val_lbls'" == "") {
      noi: di as error "This variable has no value labels attached."
      error 9
    }

    * collect labelled values
    preserve

      uselabel `varlist', clear

      local n_obs = _N

      local lbl_vals ""
      local lbl_labels ""

      forvalues i = 1/`n_obs' {
        local lbl_vals "`lbl_vals' `= value[`i']'"
        local lbl_labels "`lbl_labels' `= label[`i']'"
      }

    restore

    * collect levels present in the data
    local levelsof `varlist', local(lvls)

    * identify any unlabelled values
    * that is, values in the set of levels but not in the set of labelled values
    local unlabelled_vals : list lvls - lbl_vals

    local n_unlabelled_vals : list sizeof unlabelled_vals
    if (`n_unlabelled_vals' == 0) {
      noi: di as result "🎉 All values of `varlist' are labelled."
    }
    else if (`n_unlabelled_vals' > 0) {
      noi: di as error "There are `n_unlabelled_vals' values of `varlist' without labels: `unlabelled_vals'"
      error 9

    }

  }

end
