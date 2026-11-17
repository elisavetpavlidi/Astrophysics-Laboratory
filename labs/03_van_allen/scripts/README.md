# MATLAB analysis

The entry points below contain the completed analysis settings used for the Van Allen project.

| Entry point | Purpose | Default output folder |
| --- | --- | --- |
| [Geomagnetic_Analysis.m](Geomagnetic_Analysis.m) | Dst and solar-wind profiles, magnetometer comparison, main-phase 2–100 mHz spectrum and hourly 2–7 mHz profile | `../generated/matlab/geomagnetic/` |
| [ElectronSpectrum_Analysis.m](ElectronSpectrum_Analysis.m) | Differential flux, orbital context, three final electron spectra and the pre-storm start-time comparison | `../generated/matlab/electrons/` |
| [Compare_Frequency_Bands.m](Compare_Frequency_Bands.m) | Controlled comparison of both frequency bands at 1000 s and 3600 s | `../generated/matlab/frequency_band_comparison/` |

Paths in the table are relative to this `scripts/` folder.

## Inputs and execution

Place `GEOMAG.mat`, `RBSP.mat` and `RBSPenergy.mat` in [the lab data folder](../data/README.md). Start MATLAB in the repository root:

```matlab
addpath(fullfile(pwd,'labs','03_van_allen','scripts'));
Geomagnetic_Analysis;
ElectronSpectrum_Analysis;
Compare_Frequency_Bands;
```

The first two entry points are functions. They also accept explicit input and output folders:

```matlab
R = ElectronSpectrum_Analysis('/path/to/input/files','/path/to/output');
G = Geomagnetic_Analysis('/path/to/input/files','/path/to/output');
```

`Compare_Frequency_Bands` is a script. It reads the shared lab data folder and also accepts a `GEOMAG.mat` file in the working directory when the shared input is absent.

All entry points add [matlab_helpers/](matlab_helpers/) to the MATLAB path. Figures are exported as PNG, vector PDF and FIG; numerical results are saved as CSV and MAT files. The default output folders are under the lab's ignored `generated/` directory.

## Completed electron settings

| Case | Interval (UT) |
| --- | --- |
| `Pre14` | 16 March 2013, 14:00 to 17 March, 00:00 |
| `Main` | 17 March 2013, 13:00–15:00 |
| `Recovery` | 18 March 2013, 16:00–20:00 |
| `Pre12` | 16 March 2013, 12:00 to 17 March, 00:00 |

The first three cases form the primary spectrum comparison. `Pre12` measures sensitivity to the pre-storm start time. Time selections exclude the exact endpoints. Fits use unweighted OLS in log10 space, with channels 1–6 and 7–10, matching the project's numerical summary. The returned structure also records the shared `5.1 <= Lstar <= 5.5` comparison.

## Sources and validation

The two new entry points adapt the supplied completed student worksheets. They retain the final selected intervals, flux conversion and Fourier conventions. The auxiliary functions derive from the course-provided MATLAB helpers; adaptations are documented in [the helper notes](matlab_helpers/README.md).

All thirteen MATLAB files passed MISS_HIT syntax analysis for MATLAB R2020a. A native MATLAB runtime was not available, so execution of these entry points has not been verified here. The Python reproduction was run on the supplied data and reproduced all fourteen reference CSV tables exactly. MATLAB reruns can differ in plot formatting and floating-point rounding.

