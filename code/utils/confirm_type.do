capture program drop confirm_type
        program define confirm_type, rclass

  syntax namelist(max=1), type(string asis) [Verbose]

  qui {

    * check that type is in expected set
    local type_ok = inlist("`type'", "numeric", "string")
    if (`type_ok' != 1) {
      noi: di as error "Incorrect variable type provided. Please use either -numeric- or -string- (without a dash)."
      error 9
    }

    * first, check that variable exists
    capture confirm variable `namelist'
    if _rc != 0 {
      noi: di as error "Variable -`namelist'- not found. Please check the data and the variable name."
      error 9
    }

    * get the variable's actual type
    local actual_type_detailed : type `namelist'

    * then, check that variable is of desired type
    capture confirm `type' variable `namelist'
    if _rc != 0 {
      * translate that into a human-readable type
      if (inlist("`actual_type_detailed'", "byte", "int", "long", "float", "double")) {
        local actual_type_general "numeric"
      }
      else if (ustrregexm("`actual_type_detailed'", "^str")) {
        local actual_type_general "numeric"
      }
      * communicate the error back to the user
      noi: di as error "`namelist' is `actual_type_general' (`actual_type_detailed'), not `type'."
      error 9
    }
    else {
      if (!mi("`verbose'")) {
        noi: di as result "✅ Confirmed that `namelist' is `type' (`actual_type_detailed')."
      }
    }

  }

end
