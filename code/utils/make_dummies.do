capture program drop make_dummies
        program define make_dummies, rclass

  syntax varname [if], prefix(string) [names(string) dryrun]
  * , [names(string) lbls(string)]

  qui {

    * minimum Stata version required for this command
    version 16.0
      * frames: 16
      * Unicode regex: 14

    * use local with more descriptive name
    local varname "`varlist'"

    * get the name of the value label
    local val_lbl_name : value label `varname'

    * issue an error if the variable does not have attached variable labels
    if (mi("`val_lbl_name'")) {
      noi: di as error "`varname' has no associated value label"
      error 9
    }

    * extract values and labels from value labels
    tempname val_lbls
    frame copy default `val_lbls'
    frame `val_lbls' {

      uselabel `val_lbl_name', clear

      levelsof value, local(lbl_vals)
      levelsof label, local(lbl_txts)

    }

    * check that user-provided names are same length as extraced label values
    local lbl_val_length : list sizeof lbl_vals
    local names_length : list sizeof names
    capture assert (`lbl_val_length' == `names_length')
    if (_rc != 0) {
      noi: di as error "The list in -names()- is a different size than the labels found."
      noi: di as error "Length of the user-provided names: `names_length'"
      noi: di as error "Lenght of the value labels for `varname': `lbl_val_length'"
      error 9
    }

    * construct variable names
    local constr_var_names ""

    local lbls `"`lbl_txts'"'
    local n : word count `vals'

    forvalues i = 1/`n' {

      * get ith element
      local val : word `i' of `vals'
      local txt : word `i' of `lbls'
      
      * construct suffix
      if !mi("`names'") {
        local suffix : word `i' of `names'
      }
      else if mi("`names'") {
        * use label
        local suffix `"`lbl'"'
        * sanitize label
        // remove spaces, first dropping duplicates and then replacing w/ _
        local suffix = stritrim(`"`suffix'"')
        local suffix = ustrregexra(`"`suffix'"', "[:space:]", "_")
        // removing punctuation marks
        local suffix = ustrregexra("`suffix'", "[:punct:]", "")
        // putting in lower case
        local suffix = ustrtolower("`suffix'")
      }
        
      * compose variable name as prefix concatenated with the suffix
      local constr_var_name = "`prefix'" + "`suffix'"
      local constr_var_names = "`constr_var_names' `constr_var_name'"

    }

    * --------------------------------------------------------------------------
    * check that do not not generate variable names that are too long
    * --------------------------------------------------------------------------

    * initialize list containers
    local length_var_names ""
    local names_too_long ""

    * determine whether each variable is too long; record length
    foreach constr_var_name of local constr_var_names {

      * length
      local length_var_name = ustrlen("`constr_var_name'")
      local length_var_names "`length_var_names' `length_var_name'"

      * whether too long
      local name_too_long = `length_var_name' > 32
      local names_too_long "`names_too_long' `name_too_long'"

    }

    * determine whether any dummy variable has a name that is too long
    local any_too_long : list uniq names_too_long
    local not_too_long "0"
    local any_too_long : list any_too_long - not_too_long
    local any_too_long : list sizeof any_too_long
    local any_too_long = `any_too_long' > 0

    * if so, issue an informative error message, summarizing issue and
    * detailing which variables pose problem
    if (`any_too_long' == 1) {

      noi: di as error "Unfortunately, some dummy variables would have names that are too long"
      noi: di as error "See details below."
      noi: di as error "Use the -names()- option to provide shorter names instead."

      foreach constr_var_name of local constr_var_names {

        local is_too_long : word `i' of `names_too_long'
        local length_var_name : word `i' of `length_var_names'
        local val : word `i' of `vals'

        if (`is_too_long' == 1) {
          noi: di as error "For value `val': `constr_var_name' (`length_var_name' characters)"
        }
        
      }

      error 9

    }

    * for dry run, print out automatically generated names
    if (!mi("`dryrun'")) {
      noi: di as result "Dummy variable names generated for `varname':"

      local n_vals : world count `vals'

      forvalues i = 1/`n_vals' {
        
        local val: word `i' of `vals'
        local constr_var_name : word `i' of `constr_var_names'
        noi: di as result "For value `val': `constr_var_name'"

      }

    }

    * for regular run, create variables
    if mi("`dryrun'") {

      local n_vals : world count `vals'

      forvalues i = 1/`n_vals' {

        * extract ith element of inputs
        local val : word `i' of `vals'
        local lbl : word `i' of `lbls'
        local constr_var_name : word `i' of `constr_var_names'

        local condit = cond(!mi(`"`if'"'), "& `if'", "")
        gen `constr_var_name' = (`varname' == `val' `cond')
        lable variable `constr_var_name' "`lbl'"

      }


    }
    
  }

end
