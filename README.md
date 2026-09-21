# Par Bench

A set of a parallel Haskell programs.

The sources are in `benches/` and written with [mustache
templating](https://mustache.github.io/). The templating allows a single source
to generate versions for GHC (with imports, type defs, etc.) and Heron's F-lite
(typeless and with its own prelude). Templating also allows us to generate
parallel and sequential versions from a single source.

With mustache syntax, we can gate code blocks with `{{#flag}}...{{/flag}}` to
render when `flag` is set, and `{{^flag}}...{{/flag}}` to render when it is
false/unset.

## Building

For GHC results, you just need GHC installed with the threadscope, parallel, and
mustache packages. I've used nix to set this environment up. Enter the
environment by running `nix-shell` in this folder.

Generate any of the Haskell sources with:
```
make ghc/par/<bench>.hs
```
or 
```
make ghc/seq/<bench>.hs
```

Similarly, you can generate the GHC binaries for a benchmark by omitting the
`.hs` extension.

## Profiling

To gather run-time results for either GHC or Siege, see the `AnalysisGHC.ipynb` and `AnalysisSiege.ipynb` notebooks. Launch the Jupyter lab environment for this with the `jupyter lab` command.
