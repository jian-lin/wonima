<!--
SPDX-FileCopyrightText: 2026 Lin Jian <me@linj.tech>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# wonima

The public part of my Emacs
configured with [nima](https://github.com/jian-lin/nima).

## Status

Currently, this project is not complete.
I am in the process of porting my Emacs configuration to this.
Expect force pushes.

## Usage

- Run it like this `nix run github:jian-lin/wonima#emacs-pgtk`
- Available Emacsen can be shown by `nix flake show github:jian-lin/wonima`
- Can be extended via `extendModules`.

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
