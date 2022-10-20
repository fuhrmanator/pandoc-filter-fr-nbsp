`fr-nbsp`, a Pandoc Lua Filter for no-break spaces used in French typography
(adapted by C. Fuhrman to work more like [babel-french](https://www.ctan.org/pkg/babel-french))
==================================================================

[![GitHub build status][CI badge]][CI workflow]

`fr-nbsp` is a [Pandoc Lua filter][Lua filter] for French documents
that replaces spaces with no-break spaces (or narrow no-break spaces)
when needed.

[Lua filter]: https://pandoc.org/MANUAL.html#option--lua-filter

[CI badge]: https://img.shields.io/github/workflow/status/fuhrmanator/pandoc-filter-fr-nbsp/CI?logo=github

[CI workflow]: https://github.com/fuhrmanator/pandoc-filter-fr-nbsp/actions/workflows/ci.yaml

Usage
------------------------------------------------------------------

1. Download the file [fr-nbsp.lua](./fr-nbsp.lua)
2. Use it with `pandoc -L fr-nbsp.lua`

License
------------------------------------------------------------------

This pandoc Lua filter is published under the MIT license, see
file `LICENSE` for details.
