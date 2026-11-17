# Final numerical results

Processed Fourier and electron-spectrum results from the completed Van Allen analysis. The fourteen CSV tables and numerical summary were reproduced with the project's Python calculation and matched the completed source package byte for byte.

The Fourier figures correspond to the processed comparisons in the final report. The course-provided MATLAB functions define the underlying Fourier convention.

## Phase spectra

The six `fft_phase*_band*.csv` files correspond to the panels in [Bands_FFT_Phases.png](../figures/Bands_FFT_Phases.png).

| Phase | Interval (UT, March 2013) | 2–7 mHz | 2–100 mHz |
| --- | --- | --- | --- |
| Before the storm | 16 March, 14:00–15:00 | [CSV](fft_phase1_band1.csv) | [CSV](fft_phase1_band2.csv) |
| Main phase | 17 March, 14:00–15:00 | [CSV](fft_phase2_band1.csv) | [CSV](fft_phase2_band2.csv) |
| Recovery | 18 March, 18:00–19:00 | [CSV](fft_phase3_band1.csv) | [CSV](fft_phase3_band2.csv) |

| Column | Meaning |
| --- | --- |
| `frequency_Hz` | Discrete Fourier frequency in Hz |
| `amplitude_squared_nT2` | Squared Fourier amplitude in nT² |
| `PSD_nT2_per_Hz` | One-sided power spectral density in nT²/Hz |

Each spectrum uses 3599 samples at one-second spacing: the original helper excludes the exact interval endpoints. Discrete bin frequencies are given in the CSV files; nominal band limits do not imply a bin at every boundary.

## Hourly profiles

| File | Frequency band | Time window |
| --- | --- | --- |
| [power_3600s_band1.csv](power_3600s_band1.csv) | 2–7 mHz | 3600 s |
| [power_3600s_band2.csv](power_3600s_band2.csv) | 2–100 mHz | 3600 s |

Each profile contains 1464 non-overlapping windows covering March–April 2013. [Bands_HourlyPhysical.png](../figures/Bands_HourlyPhysical.png) shows the 16–21 March interval alongside Dst.

| Column | Meaning |
| --- | --- |
| `matlab_datenum` | Window-centre timestamp as a MATLAB serial date number, interpreted as UT |
| `mean_amplitude_squared_nT2` | Squared Fourier amplitude averaged over the selected bins |
| `mean_PSD_nT2_per_Hz` | Power spectral density averaged over those bins |
| `integrated_power_nT2` | Power spectral density summed over the selected bins and multiplied by the bin width |

Mean spectral density and integrated band power are different quantities. For the positive, non-Nyquist bins used here, PSD equals squared amplitude multiplied by `N * dt / 2`, where `N` is the sample count and `dt = 1 s`.

## 1000-second profiles

| File | Frequency band | Time window |
| --- | --- | --- |
| [power_1000s_band1.csv](power_1000s_band1.csv) | 2–7 mHz | 1000 s |
| [power_1000s_band2.csv](power_1000s_band2.csv) | 2–100 mHz | 1000 s |

Each table contains 5270 non-overlapping windows covering March–April 2013. The columns have the same meanings as in the hourly tables above.

The final comparisons show:

- [Mean squared amplitude for both bands and both window lengths](../figures/Bands_OriginalNormalization.png), Figure 4 of the report.
- [Mean PSD at 1000 s and 3600 s within each band](../figures/Bands_WindowSensitivity.png), Figure 6 of the report.

For the 1000-second profiles, the selected bands contain 6 and 99 frequency bins. Mean PSD equals mean squared amplitude multiplied by 500; integrated band power equals mean squared amplitude multiplied by half the bin count.

## Electron spectra

The [electron results](electrons/README.md) contain the three storm-phase spectra and the completed comparison of pre-storm start times, 12:00 and 14:00 UT.

## Numerical summary

[summary.json](summary.json) records the final calculation:

| Field | Contents |
| --- | --- |
| `sampling_seconds` | One-second magnetic-field sampling |
| `profiles` | Bin counts, actual frequency limits and peak values for both bands and both window lengths |
| `fits` | Electron mean fluxes, log-space power-law indices, fit R² values, sampled `Lstar` ranges and shared-`Lstar` comparisons |
| `fft_cases` | The three selected Fourier intervals and their sample counts |
| `validation` | Analytical sinusoid and Parseval check result |

Profile peak values refer to the 16–21 March storm interval; the CSV profiles cover the full March–April input series. Peak timestamps are window-centre times in UT.

## Source record and checks

[validation.json](validation.json) preserves the source archive's validation record, software versions and input hashes. It also identifies RBSP inputs used elsewhere in the source project.

The processed tables were checked for finite values, ordered frequencies, matching timestamps, the PSD conversion, and integrated 2–100 mHz power at least as large as integrated 2–7 mHz power in every shared window. The 1000-second tables, 12:00 electron spectrum and summary also match the verified project run exactly.
