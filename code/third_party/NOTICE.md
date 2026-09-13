# Third-Party Code Notice

This directory holds code that was present in the original thesis project folder but
was **not written by Aakarsh Dhariwal**. It is kept separate from `code/localization/`,
`code/spectrum_sensing/`, and `code/ofdm/` (the author's own thesis code) for clarity
and honest attribution.

## `ofdm_trx.m`

The file header reads:

```
% The mfile investigates the effects of high power amplifier and the
% channel noise on the ofdm signals.
% Written By     : Baher Mohamed
```

This is a generic, widely circulated introductory OFDM transmit/receive chain
demonstration (8-point FFT, QPSK, high-power-amplifier clipping, a simple multipath
channel) explicitly attributed to Baher Mohamed in its own header. It is unrelated to
the thesis's actual OFDM system model: it uses a toy 8-subcarrier setup, whereas the
thesis's own OFDM generator (`code/ofdm/ofdm.m`) implements a 128-subcarrier, 16-sample
cyclic-prefix, 4-QAM waveform built with MATLAB's `ofdmmod`/`ofdmdemod` functions to
match the 5G NR-style parameters described in Section 5.3.1 of the thesis. `ofdm_trx.m`
was most likely kept as a learning/reference script while `ofdm.m` was being developed,
not used to generate any of the thesis's reported results.

## `REMEstimate/`

See `REMEstimate/NOTICE.md` for a detailed breakdown of that folder's third-party
geostatistics (variogram/kriging) utilities.

## License / usage

No license file accompanied either piece of code in the original project. Both are
included here for non-commercial, academic, and portfolio purposes only, with
attribution to their original authors where known.
