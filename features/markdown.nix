{
  epkgs = epkgs: [ epkgs.markdown-mode ];

  elisp = ''
    (setopt markdown-fontify-code-blocks-natively t)
  '';
}
