{
  epkgs = epkgs: [
    epkgs.haskell-mode
    epkgs.consult-hoogle
  ];

  elisp = ''
    (with-eval-after-load 'eglot
      ;; HLS can also handle .cabal file now
      (defvar eglot-server-programs)
      (cl-pushnew '((haskell-mode haskell-cabal-mode) "haskell-language-server-wrapper" "--lsp")
                  eglot-server-programs
                  :test #'equal))

    (keymap-global-set "M-s M-h" #'consult-hoogle)
  '';
}
