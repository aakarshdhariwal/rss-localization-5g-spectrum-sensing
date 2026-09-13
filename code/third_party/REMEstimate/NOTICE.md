# Third-Party Code Notice — REMEstimate

The MATLAB files in this directory are **not original work produced for this thesis**.
They were bundled in the source project as `RemEstimateMATLAB.zip` and used as
reference/utility material while exploring radio environment map (REM) construction
techniques (inverse-distance weighting and ordinary kriging). They are kept here,
clearly separated from the author's own thesis code in `code/`, for transparency and
reproducibility, and are not presented as Aakarsh Dhariwal's original contribution.

## Confirmed third-party authorship

The following files carry explicit author headers identifying them as classic MATLAB
File Exchange (FEX) utilities, unrelated to this thesis:

| File | Author | Notes (from in-file header) |
|---|---|---|
| `variogram.m` | Wolfgang Schwanghart (`w.schwanghart[at]unibas.ch`) | Dated 21 July 2011. Isotropic/anisotropic experimental variogram calculation. |
| `variogramfit.m` | Wolfgang Schwanghart (`w.schwanghart[at]unibas.ch`) | Dated 7 October 2010. Least-squares fit of a theoretical variogram model; references `fminsearchbnd` (FEX File ID #8277) as a companion utility. |
| `kriging.m` | Wolfgang Schwanghart (`w.schwanghart[at]unibas.ch`) | Dated 13 October 2010. Ordinary kriging interpolation in two dimensions. |
| `fminsearchbnd.m` | John D'Errico | Well-known FEX utility (`fminsearchbnd`, FEX File ID #8277): bound-constrained wrapper around `fminsearch`. |

## Remaining files in this folder — third-party in origin, specific authorship unclear

`estimate_power.m`, `estimate_power_ext.m`, `eval_RvsRMSE.m`, `eval_dist2locations.m`,
`findMask4Fazr.m`, `prepareROC.m`, `run_RvsRMSE.m`, `run_exampleKrig.m`,
`run_exampleVari.m`, `run_rem_constructor.m`, `smoothRmse.m`, and `smoothXY_overRuns.m`
carry no explicit author header, but there is strong circumstantial evidence that they
are part of the same pre-existing, third-party REM-estimation package rather than code
written for this thesis:

- Every one of these files, together with the four attributed files above, is bundled
  inside the original `RemEstimateMATLAB.zip`, whose internal file timestamps range
  from **23 December 2011 to 8 May 2013** — a full decade before this 2023 thesis.
- `run_rem_constructor.m` itself opens with the in-file comment `%% 2011 12 26
  PREPARING`, and its example scenario (a 1000 m × 1000 m area, transmitter at
  (670, 471), generic `channel.name = 'URBAN'` structure, "FAZR"/"CDZR" ROC
  terminology) does not match the parameters used anywhere in the author's own
  thesis code (100 m × 100 m grid, transmitter at (18, 37)).
- None of the author's own scripts in `code/` (`calculate_rss.m`,
  `rss_measurements.m`, `LIvE_algorithm.m`, `Corrected_mse_code.m`, `mse_test.m`,
  `test_grid.m`, etc.) call any function defined in this folder — the package does
  not appear to have been wired into the thesis's actual simulation pipeline.
- The accompanying `.mat`/`.fig`/`.png` example data that shipped in the original zip
  (also dated 2011–2013) has been left out of this repository as non-essential,
  pre-existing demo output; only the reusable `.m` utility files are kept here.

Per the thesis bibliography, `Practical_Radio_Environment_Mapping_with_Geostatis.pdf`
(Phillips, Ton, Sicker, and Grunwald, "Practical Radio Environment Mapping with
Geostatistics," IEEE DySPAN 2012 — see `references/rem/`) is the most likely
conceptual source for this kriging/IDW-based REM-estimation toolkit, given the
matching subject matter and overlapping timeframe, though this repository does not
assert that link as confirmed.

## Why these files are kept

They are included only for transparency about what was in the original project
folder and to avoid silently deleting historical research material. They are **not**
required to run any of the author's own localization or REM-construction code in
`code/localization/`, `code/spectrum_sensing/`, or `code/ofdm/`, which implement REM
reconstruction via direct RSS interpolation rather than by calling into this package.

## License / usage

No license file accompanied the original bundle. These files are included here for
non-commercial, academic, and portfolio purposes only, with attribution to the
original authors identified above. If you intend to reuse `variogram.m`,
`variogramfit.m`, or `kriging.m`, please obtain them directly from MATLAB Central
File Exchange under their original terms, and `fminsearchbnd.m` from John D'Errico's
original FEX submission.
