# Van Allen laboratory

**Elisavet Pavlidi · Department of Physics, NKUA · 2026–2027**

Fourier analysis of geomagnetic variability around the March 2013 storm, comparing the 2–7 mHz and 2–100 mHz frequency bands.

## Files

| File | Purpose |
| --- | --- |
| [Compare_Frequency_Bands.m](scripts/Compare_Frequency_Bands.m) | Compare frequency bands, time windows and storm phases; export figures and numerical results |
| [fourierSpectrum.m](scripts/matlab_helpers/fourierSpectrum.m) | Calculate squared Fourier amplitudes over a selected time interval and frequency range |
| [fourierPower.m](scripts/matlab_helpers/fourierPower.m) | Calculate mean squared Fourier amplitude in consecutive, non-overlapping windows |

The two Fourier helper functions are preserved unchanged from the course-provided MATLAB material.

## Input data

Use the original course file `GEOMAG.mat`, supplied separately, and place it inside `scripts/`. It must contain:

| Variable | Contents |
| --- | --- |
| `Bgr_time` | Magnetic-field timestamps as MATLAB datenums |
| `Bgr` | Magnetic-field series in nT, sampled once per second |
| `Dst_time` | Dst timestamps as MATLAB datenums |
| `Dst` | Dst index in nT |

The calculation assumes continuous one-second magnetic-field sampling. The selected time intervals are in UT.

## Run in MATLAB

Start MATLAB in the repository root, then run:

```matlab
cd('labs/03_van_allen/scripts')
Compare_Frequency_Bands
```

The driver adds `matlab_helpers/` to the MATLAB path automatically. MATLAB must support local functions in scripts and `exportgraphics`.

## Analysis settings

Both frequency bands use identical time intervals and processing. The time profiles use windows of 3600 s and 1000 s over March–April 2013, with a separate view of 16–21 March alongside Dst.

The individual Fourier spectra use three equal one-hour intervals:

| Interval | Date | Time (UT) |
| --- | --- | --- |
| Before the storm | 16 March 2013 | 14:00–15:00 |
| Main phase | 17 March 2013 | 14:00–15:00 |
| Recovery phase | 18 March 2013 | 18:00–19:00 |

The original helper output is squared Fourier amplitude in nT², averaged over the selected frequency bins for the windowed profiles. It is distinct from a power spectral density in nT²/Hz and from integrated band power. The driver exports these quantities in separate columns. A wider frequency band need not have a larger **mean** squared amplitude.

## Outputs

The script creates `scripts/frequency_band_comparison/` containing:

- Fourier spectra for each interval and frequency band as CSV files.
- Time-profile tables with mean squared amplitude, mean power spectral density and integrated band power.
- Figures in PNG, vector PDF and MATLAB FIG formats.
- `Frequency_Band_Comparison_Results.mat` with the result structure.

Native MATLAB execution has not been verified in this environment.
