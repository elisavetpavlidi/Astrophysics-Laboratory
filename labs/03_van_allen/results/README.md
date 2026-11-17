# Saved Fourier results

These figures and tables are preserved from `VanAllen_Pavlidi_Complete.zip`. They were produced by the supplied Python NumPy/SciPy reproduction of the course MATLAB helpers. They are saved numerical outputs, rather than a new native MATLAB run.

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

## Source record and checks

[validation.json](validation.json) preserves the source archive's validation record, software versions and input hashes. It also identifies RBSP inputs used elsewhere in the source project.

The repository import was checked for finite CSV values, ordered frequencies, matching timestamps, the PSD conversion, and integrated 2–100 mHz power at least as large as integrated 2–7 mHz power in every shared hourly window. Imported figures and numerical files retain their original bytes.
