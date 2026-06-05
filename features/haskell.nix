{
  epkgs = epkgs: [ epkgs.haskell-mode ];

  elisp = ''
    (with-eval-after-load 'eglot
      ;; hls can also handle .cabal file now
      (defvar eglot-server-programs)
      (cl-pushnew '((haskell-mode haskell-cabal-mode) "haskell-language-server-wrapper" "--lsp")
                  eglot-server-programs
                  :test #'equal))
  '';
}
