# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.4.21] - 2026-09-10

### Added

- `FacetRegressionInfo` struct to cache computations for `facetregressionplot`, giving it the same interface as the other random-effect plotting types. ([#158])

## [0.4.20] - 2026-09-10

### Added

- Support for random-effect levels that aren't strings in `shrinkageplot`. ([#157])

## [0.4.19] - 2026-09-10

### Added

- Shrinkage dot plots. ([#156])

## [0.4.18] - 2026-08-28

### Added

- Faceted regression plot (`facetregressionplot`). ([#153])

## [0.4.17] - 2026-08-28

### Added

- Point labels for `shrinkageplot` (`labels`, `labelcolor`, `labelsize` kwargs). ([#152])

## [0.4.16] - 2026-08-27

### Added

- Distinguish union from intersection styling in UpSet plots. ([#150])

### Changed

- Docstrings are now merged across method definitions for each plot function. ([#151])

## [0.4.15] - 2026-08-26

### Added

- Ridge plots for parameters other than the fixed effects. ([#79])

## [0.4.14] - 2026-08-26

### Added

- UpSet plots (`upsetplot`, `upsettable`) for visualizing categorical predictor intersection structure. ([#120])

## [0.4.13] - 2026-08-25

### Fixed

- More informative error message in `shrinkageplot` when the model has only a single predictor. ([#149])

## [0.4.12] - 2026-05-18

### Added

- Support for plotting multiple models together in `coefplot` and `ridgeplot`. ([#121])

### Changed

- Repository ownership/CI hardening updates, including a zizmor security audit added to CI. ([#116])

## [0.4.11] - 2026-02-07

### Changed

- Updated documentation and repository links following a change in repository ownership. ([#112])

## [0.4.10] - 2025-08-27

### Changed

- Bumped compatibility to support MixedModels.jl v5. ([#109])

## [0.4.9] - 2025-06-24

### Changed

- Bumped compatibility to support Makie v0.24. ([#107])

## [0.4.8] - 2025-06-18

### Changed

- Bumped compatibility to support Makie v0.23. ([#106])

## [0.4.7] - 2025-04-08

### Changed

- Bumped compatibility to support BSplineKit v0.19. ([#105])

## [0.4.6] - 2025-02-09

### Changed

- Bumped compatibility to support BSplineKit v0.18. ([#104])

## [0.4.5] - 2025-01-15

### Changed

- Bumped compatibility to support Makie v0.22. ([#103])

## [0.4.4] - 2024-08-01

### Added

- Additional tests around rank-deficient model support. ([#98])

### Changed

- Updated attribute forwarding for Makie v0.21. ([#99])

## [0.4.3] - 2024-05-29

### Changed

- Unified plotting functions to accept the `Indexable` union (`Figure`, `GridLayout`, `GridPosition`) across all active plot types. ([#97])

## [0.4.2] - 2024-05-28

### Fixed

- Forwarding of the `show_intercept` keyword argument. ([#96])

## [0.4.1] - 2024-05-14

### Fixed

- A misplaced `xlabel` setting. ([#95])

### Changed

- Bumped compatibility to support Makie v0.21. ([#94])
- Switched documentation build to Documenter 1.3. ([#87])

## [0.4.0] - 2024-03-22

### Added

- Support for rank-deficient models. ([#86])

### Changed

- Reduced reliance on Makie recipes in favor of direct plotting calls. ([#86])
- Reorganized and reworked the test suite. ([#85])

## [0.3.28] - 2024-01-10

### Changed

- Adjusted compat settings; added a `progress` keyword argument. ([#84])

## [0.3.27] - 2023-09-12

### Added

- 2D density plots (`ridge2d`) for bivariate bootstrap parameter distributions. ([#80])

### Changed

- Made the reference line in `zetaplot` visually distinct. ([#78])

## [0.3.26] - 2023-08-04

### Changed

- Added `PrecompileTools` support to reduce load/first-plot latency. ([#76])

## [0.3.25] - 2023-07-12

### Added

- `vline` option in caterpillar and QQ-caterpillar plots. ([#75])

## [0.3.24] - 2023-07-07

### Added

- Support for custom colors in caterpillar and shrinkage plots. ([#74])

## [0.3.23] - 2023-06-29

### Added

- `cols` keyword argument support in `shrinkageplot`. ([#72])

## [0.3.22] - 2023-06-28

### Added

- `cols` keyword argument support in caterpillar plots. ([#71])

### Changed

- Internal reorganization of the codebase. ([#69])

## [0.3.21] - 2023-05-28

### Added

- Support for plotting into generic `FigureLike` and `GridLayout` targets for multi-axis plots. ([#68])

## [0.3.20] - 2023-05-05

### Added

- Profile likelihood plots (ζ plots) with BSplineKit interpolation, and density plots of profile ζ values. ([#58])

## [0.3.19] - 2023-05-05

### Fixed

- A Makie-related workaround needed for the test suite. ([#65])

### Changed

- Bumped compatibility to support StatsBase v0.34. ([#66])

## [0.3.18] - 2023-02-04

### Changed

- Bumped compatibility to support Makie v0.19. ([#63])

## [0.3.17] - 2022-10-14

### Fixed

- Prevented correlation ellipses from changing axis limits in `shrinkageplot`. ([#61])

## [0.3.16] - 2022-10-13

### Added

- Correlation ellipses in `shrinkageplot`. ([#57])

### Changed

- Bumped compatibility to support Makie v0.18. ([#59])
- Reworked the test suite and set up Percy.io visual regression testing. ([#54], [#60])

## [0.3.15] - 2022-05-08

### Changed

- Bumped compatibility to support Makie v0.17. ([#52])

## [0.3.14] - 2022-05-05

### Changed

- General Makie compatibility fixes. ([#50], [#51])
- Adopted a formal style guide (YAS style via JuliaFormatter). ([#49])

## [0.3.13] - 2022-01-15

### Fixed

- Compatibility fixes for Makie v0.16. ([#47])

### Removed

- `CairoMakie` from package dependencies (now expected to be provided by the user).

## [0.3.12] - 2022-01-10

### Changed

- Bumped compatibility to support Makie v0.16. ([#46])

## [0.3.11] - 2021-11-24

### Changed

- Bumped compatibility to support SpecialFunctions v2. ([#44])

## [0.3.10] - 2021-09-27

### Added

- `ranefinfotable` function, plus additional tests. ([#42])

## [0.3.9] - 2021-09-11

### Added

- Shrinkage and caterpillar plots for generalized linear mixed models (GLMMs). ([#41])

## [0.3.8] - 2021-09-07

### Added

- Ridge plots (`ridgeplot`) of bootstrap parameter distributions. ([#40])

## [0.3.7] - 2021-08-31

### Fixed

- `QQNorm` recipe. ([#39])

## [0.3.6] - 2021-08-31

### Changed

- Keyword arguments are now passed through in QQ plot recipes. ([#38])

## [0.3.5] - 2021-08-29

### Changed

- `shrinkageplot!` now uses `splomaxes` and a panel function internally. ([#35])

## [0.3.4] - 2021-08-25

### Added

- Coefficient plots (`coefplot`) and QQ plots. ([#28])
- Support for the new `condVar(m, fname)` method for computing conditional variances. ([#28])

## [0.3.3] - 2021-08-23

### Changed

- Bumped compatibility to support Makie's newer release series. ([#31])

## [0.3.2] - 2021-07-13

### Added

- `shrinkageplot!` mutating method. ([#26])

## [0.3.1] - 2021-06-24

### Fixed

- Confidence interval computation now multiplies the standard deviation by 1.960. ([#23])

## [0.3.0] - 2021-06-21

### Changed

- Switched `shrinkageplot` away from using `θref` internally. ([#21])
- Bumped compatibility to support Makie v0.14. ([#20])

## [0.2.0] - 2021-06-02

### Changed

- `simplelinreg` now returns a `Tuple` instead of its previous return type. ([#16])

## [0.1.2] - 2021-05-20

### Fixed

- An integer overflow bug from accumulating large sums with small integer types. ([#13])

### Changed

- Migrated from AbstractPlotting to Makie v0.13. ([#14])

## [0.1.1] - 2021-05-17

### Added

- Option to disable sorting in `caterpillarplot!`. ([#12])

## [0.1.0] - 2021-05-16

Initial release.

### Added

- Shrinkage plots comparing unshrunken vs. shrunken random-effect estimates. ([#2])
- Caterpillar plots (horizontal error-bar plots of conditional means) and the `RanefInfo` struct. ([#4])
- Online documentation. ([#9])

<!-- Versions -->
[Unreleased]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.21...HEAD
[0.4.21]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.20...v0.4.21
[0.4.20]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.19...v0.4.20
[0.4.19]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.18...v0.4.19
[0.4.18]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.17...v0.4.18
[0.4.17]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.16...v0.4.17
[0.4.16]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.15...v0.4.16
[0.4.15]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.14...v0.4.15
[0.4.14]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.13...v0.4.14
[0.4.13]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.12...v0.4.13
[0.4.12]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.11...v0.4.12
[0.4.11]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.10...v0.4.11
[0.4.10]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.9...v0.4.10
[0.4.9]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.8...v0.4.9
[0.4.8]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.7...v0.4.8
[0.4.7]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.6...v0.4.7
[0.4.6]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.5...v0.4.6
[0.4.5]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.28...v0.4.0
[0.3.28]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.27...v0.3.28
[0.3.27]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.26...v0.3.27
[0.3.26]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.25...v0.3.26
[0.3.25]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.24...v0.3.25
[0.3.24]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.23...v0.3.24
[0.3.23]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.22...v0.3.23
[0.3.22]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.21...v0.3.22
[0.3.21]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.20...v0.3.21
[0.3.20]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.19...v0.3.20
[0.3.19]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.18...v0.3.19
[0.3.18]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.17...v0.3.18
[0.3.17]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.16...v0.3.17
[0.3.16]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.15...v0.3.16
[0.3.15]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.14...v0.3.15
[0.3.14]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.13...v0.3.14
[0.3.13]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.12...v0.3.13
[0.3.12]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.11...v0.3.12
[0.3.11]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.10...v0.3.11
[0.3.10]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.9...v0.3.10
[0.3.9]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.8...v0.3.9
[0.3.8]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/palday/MixedModelsMakie.jl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/palday/MixedModelsMakie.jl/releases/tag/v0.1.0

<!-- Pull requests -->
[#2]: https://github.com/palday/MixedModelsMakie.jl/pull/2
[#4]: https://github.com/palday/MixedModelsMakie.jl/pull/4
[#9]: https://github.com/palday/MixedModelsMakie.jl/pull/9
[#12]: https://github.com/palday/MixedModelsMakie.jl/pull/12
[#13]: https://github.com/palday/MixedModelsMakie.jl/pull/13
[#14]: https://github.com/palday/MixedModelsMakie.jl/pull/14
[#16]: https://github.com/palday/MixedModelsMakie.jl/pull/16
[#20]: https://github.com/palday/MixedModelsMakie.jl/pull/20
[#21]: https://github.com/palday/MixedModelsMakie.jl/pull/21
[#23]: https://github.com/palday/MixedModelsMakie.jl/pull/23
[#26]: https://github.com/palday/MixedModelsMakie.jl/pull/26
[#28]: https://github.com/palday/MixedModelsMakie.jl/pull/28
[#31]: https://github.com/palday/MixedModelsMakie.jl/pull/31
[#35]: https://github.com/palday/MixedModelsMakie.jl/pull/35
[#38]: https://github.com/palday/MixedModelsMakie.jl/pull/38
[#39]: https://github.com/palday/MixedModelsMakie.jl/pull/39
[#40]: https://github.com/palday/MixedModelsMakie.jl/pull/40
[#41]: https://github.com/palday/MixedModelsMakie.jl/pull/41
[#42]: https://github.com/palday/MixedModelsMakie.jl/pull/42
[#44]: https://github.com/palday/MixedModelsMakie.jl/pull/44
[#46]: https://github.com/palday/MixedModelsMakie.jl/pull/46
[#47]: https://github.com/palday/MixedModelsMakie.jl/pull/47
[#49]: https://github.com/palday/MixedModelsMakie.jl/pull/49
[#50]: https://github.com/palday/MixedModelsMakie.jl/pull/50
[#51]: https://github.com/palday/MixedModelsMakie.jl/pull/51
[#52]: https://github.com/palday/MixedModelsMakie.jl/pull/52
[#54]: https://github.com/palday/MixedModelsMakie.jl/pull/54
[#57]: https://github.com/palday/MixedModelsMakie.jl/pull/57
[#58]: https://github.com/palday/MixedModelsMakie.jl/pull/58
[#59]: https://github.com/palday/MixedModelsMakie.jl/pull/59
[#60]: https://github.com/palday/MixedModelsMakie.jl/pull/60
[#61]: https://github.com/palday/MixedModelsMakie.jl/pull/61
[#63]: https://github.com/palday/MixedModelsMakie.jl/pull/63
[#65]: https://github.com/palday/MixedModelsMakie.jl/pull/65
[#66]: https://github.com/palday/MixedModelsMakie.jl/pull/66
[#68]: https://github.com/palday/MixedModelsMakie.jl/pull/68
[#69]: https://github.com/palday/MixedModelsMakie.jl/pull/69
[#71]: https://github.com/palday/MixedModelsMakie.jl/pull/71
[#72]: https://github.com/palday/MixedModelsMakie.jl/pull/72
[#74]: https://github.com/palday/MixedModelsMakie.jl/pull/74
[#75]: https://github.com/palday/MixedModelsMakie.jl/pull/75
[#76]: https://github.com/palday/MixedModelsMakie.jl/pull/76
[#78]: https://github.com/palday/MixedModelsMakie.jl/pull/78
[#79]: https://github.com/palday/MixedModelsMakie.jl/pull/79
[#80]: https://github.com/palday/MixedModelsMakie.jl/pull/80
[#84]: https://github.com/palday/MixedModelsMakie.jl/pull/84
[#85]: https://github.com/palday/MixedModelsMakie.jl/pull/85
[#86]: https://github.com/palday/MixedModelsMakie.jl/pull/86
[#87]: https://github.com/palday/MixedModelsMakie.jl/pull/87
[#94]: https://github.com/palday/MixedModelsMakie.jl/pull/94
[#95]: https://github.com/palday/MixedModelsMakie.jl/pull/95
[#96]: https://github.com/palday/MixedModelsMakie.jl/pull/96
[#97]: https://github.com/palday/MixedModelsMakie.jl/pull/97
[#98]: https://github.com/palday/MixedModelsMakie.jl/pull/98
[#99]: https://github.com/palday/MixedModelsMakie.jl/pull/99
[#103]: https://github.com/palday/MixedModelsMakie.jl/pull/103
[#104]: https://github.com/palday/MixedModelsMakie.jl/pull/104
[#105]: https://github.com/palday/MixedModelsMakie.jl/pull/105
[#106]: https://github.com/palday/MixedModelsMakie.jl/pull/106
[#107]: https://github.com/palday/MixedModelsMakie.jl/pull/107
[#109]: https://github.com/palday/MixedModelsMakie.jl/pull/109
[#112]: https://github.com/palday/MixedModelsMakie.jl/pull/112
[#116]: https://github.com/palday/MixedModelsMakie.jl/pull/116
[#120]: https://github.com/palday/MixedModelsMakie.jl/pull/120
[#121]: https://github.com/palday/MixedModelsMakie.jl/pull/121
[#149]: https://github.com/palday/MixedModelsMakie.jl/pull/149
[#150]: https://github.com/palday/MixedModelsMakie.jl/pull/150
[#151]: https://github.com/palday/MixedModelsMakie.jl/pull/151
[#152]: https://github.com/palday/MixedModelsMakie.jl/pull/152
[#153]: https://github.com/palday/MixedModelsMakie.jl/pull/153
[#156]: https://github.com/palday/MixedModelsMakie.jl/pull/156
[#157]: https://github.com/palday/MixedModelsMakie.jl/pull/157
[#158]: https://github.com/palday/MixedModelsMakie.jl/pull/158
