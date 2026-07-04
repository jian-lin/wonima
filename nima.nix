# SPDX-FileCopyrightText: 2026 Lin Jian <me@linj.tech>
# SPDX-License-Identifier: GPL-3.0-or-later

emacs:

{ lib, config, ... }:

{
  package = emacs;
  earlyDefaultEl.elisp = lib.readFile ./early-init.el;
  pedantic = true;

  overlay =
    final: _prev:
    let
      wonimaPackages = lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = ./packages;
      };
      mkWonimaPackage =
        let
          # return parsed version, or null if failed
          tryParseVersion =
            let
              parse =
                file:
                file
                |> lib.readFile
                |> lib.match versionRegex
                |> (parsed: if parsed == null then null else lib.head parsed);
              # this simple regex does not match all valid versions
              # but it is good enough for our use cases
              # a better regex is not easy because nix does not support non-greedy regexp
              versionRegex = ".*;; Version: ([[:digit:]]+(.[[:digit:]]+)*)\n.*";
              mainFileName = pname: "${pname}.el";
            in
            pname: src: parse <| lib.path.append src (mainFileName pname);
          testFileExists = pname: src: (lib.readDir src).${testFileName pname} or null == "regular";
          testFileName = pname: "${pname}-tests.el";
        in
        {
          # path to a dir named pname
          #   the dir must have a pname.el file
          #   the dir can have other optional .el files, such as pname-tests.el
          src,
          packageRequires ? [ ],
        }@args:
        lib.throwIfNot (lib.pathIsDirectory src) "mkWonimaPackage: src isn't a dir path: ${src}"
          final.melpaBuild
          (finalAttrs: {
            pname = lib.baseNameOf src;
            version =
              let
                parsed = tryParseVersion finalAttrs.pname src;
              in
              lib.throwIf (parsed == null) "mkWonimaPackage: fail to parse version" parsed;

            src = lib.fileset.toSource {
              root = src;
              fileset = lib.fileset.fileFilter (file: file.hasExt "el") src;
            };

            inherit packageRequires;

            # By default, elisp test files are not included.
            # We include them to ensure they are buildable and to run tests in the nix build.
            files = ''("*.el")'';

            turnCompilationWarningToError = config.pedantic;

            doInstallCheck = testFileExists finalAttrs.pname src;
            postInstallCheck = lib.optionalString finalAttrs.doInstallCheck ''
              emacs --batch \
                --eval "
                  (let ((default-directory \"$out/share/emacs/site-lisp\"))
                    (normal-top-level-add-subdirs-to-load-path))" \
                --load=${testFileName finalAttrs.pname} \
                --funcall=ert-run-tests-batch-and-exit
            '';

            pos = lib.unsafeGetAttrPos "src" args; # for meta.position
          });
    in
    lib.attrsets.unionOfDisjoint { inherit mkWonimaPackage wonimaPackages; } wonimaPackages;
}
