(TeX-add-style-hook
 "ComplementarityConstraints"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art11"
    "fontspec"
    "fullpage"
    "listings"
    "booktabs"
    "amsmath"
    "hyperref")
   (TeX-add-symbols
    '("norm" 1))
   (LaTeX-add-labels
    "sec:ieee 9 bus system"
    "tab:res_vlim_nonenforced"
    "tab:res_vlim_enforced"
    "sec:questions"
    "sec:shad-pric-matp"
    "eq:muz"
    "eq:comp-cond"
    "sec:an-example"
    "eq:2"
    "eq:3")))

