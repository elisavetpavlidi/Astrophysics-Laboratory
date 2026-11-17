# MATLAB helper functions

These functions derive from the course-provided MATLAB material. They are included as dependencies of the completed student analyses; their teaching origin is retained.

| Function | Role |
| --- | --- |
| [fourierSpectrum.m](fourierSpectrum.m) | Squared Fourier amplitudes over a selected interval and frequency band |
| [fourierPower.m](fourierPower.m) | Mean squared Fourier amplitude in consecutive windows |
| [plotTimeSeries.m](plotTimeSeries.m) | Linked time-series plots with date axes |
| [plotfluxes.m](plotfluxes.m) | Channels 2 and 9, Lstar and magnetic local time |
| [plotfluxesL.m](plotfluxesL.m) | Orbit-segment mean flux in a selected Lstar range |
| [plotmeanspectrum.m](plotmeanspectrum.m) | Time-averaged differential electron spectrum |
| [fitPowerLaw.m](fitPowerLaw.m) | Log-space OLS power-law fit and optional fit statistics |
| [avgInSegments.m](avgInSegments.m) | Averages of samples separated by time gaps |
| [optional_nanmean.m](optional_nanmean.m) | Mean excluding NaNs, using base MATLAB |
| [plotindices.m](plotindices.m) | Dst and AL plots for matching caller-supplied time/index arrays |

The two Fourier helpers retain the supplied numerical implementation unchanged. The remaining helpers have been prepared for the completed workflow:

- Function descriptions, channel labels, steradian units and font settings were corrected.
- Plotting helpers retain their current figure handle for subsequent export.
- Time-series graphics use axes handles and two-argument zoom/pan callbacks.
- Segment averaging returns one average for a continuous series.
- NaN-aware averaging uses base MATLAB and a function name matching its filename.
- `fitPowerLaw` preserves the supplied log-space OLS method and returns `[A, gamma]` for `I(E) = A * E^(-gamma)`, with energy in keV. An optional second output provides sample count, channels, mean flux and log-space R².

`plotindices` is an auxiliary plotting function. Its AL array is supplied by the caller; the primary analyses use Dst from `GEOMAG.mat`.

See the [MATLAB guide](../README.md) for entry points, input files and validation limits.

