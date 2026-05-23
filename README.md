<!--
SPDX-FileCopyrightText: 2026 Lin Jian <me@linj.tech>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# wonima

The public part of my Emacs configured with [nima][].

[nima]: https://github.com/jian-lin/nima

## Status

Currently, this project is not complete.
I am in the process of porting my Emacs configuration to this.
Expect force pushes.

## Usage

- Run an Emacs: `nix run github:jian-lin/wonima#emacs-pgtk`
- Show available Emacsen: `nix flake show github:jian-lin/wonima`
- Apply `overlays.packages` to your Nixpkgs
  to use [my Emacs lisp packages](/packages)

## Contributing

Fixes are welcome.

This is my *personal* Emacs configuration
so it does *not* accept "new features".

## License

This package is [REUSE][]-compliant.
To get the license and copyright of each file,
run `reuse lint --json` or `reuse spdx`.

As a best-effort summary,
this package is licensed under GPL-3.0-or-later.

[REUSE]: https://reuse.software
