# Saved electron energy spectra

The four CSV files contain the completed time-averaged differential electron-flux calculations in the ten supplied RBSP energy channels: three storm-phase spectra and a pre-storm start-time comparison. They are processed outputs of the project's Python reproduction using `RBSP.mat` and `RBSPenergy.mat`.

## Intervals and figures

| Phase | Interval (UT) | Numerical table | Report figure |
| --- | --- | --- | --- |
| Before the storm | 16 March 2013, 14:00 to 17 March, 00:00 | [electron_Pre14.csv](electron_Pre14.csv) | [Spectrum](../../figures/PreStorm_Spectrum.jpg) |
| Main phase | 17 March 2013, 13:00–15:00 | [electron_Main.csv](electron_Main.csv) | [Spectrum](../../figures/MainPhase_Spectrum.jpg) |
| Recovery | 18 March 2013, 16:00–20:00 | [electron_Recovery.csv](electron_Recovery.csv) | [Spectrum](../../figures/RecoveryPhase_Spectrum.jpg) |

The pre-storm table uses the 14:00 start shown in the figure. A 12:00 start used in another supplied driver defines a different average. The numerical selection excludes the exact interval endpoints.

## Pre-storm start-time comparison

[electron_Pre12.csv](electron_Pre12.csv) gives the completed average from 16 March 2013, 12:00 UT to 17 March, 00:00 UT. It can be compared with [electron_Pre14.csv](electron_Pre14.csv), which starts at 14:00 UT and is used for the primary pre-storm comparison.

The numerical summary retains both `Pre12` and `Pre14` results. [summary.json](../summary.json) also records the log-space, unweighted power-law fits to channels 1–6 and 7–10 for all four intervals, together with R² and shared-`Lstar` checks. These fit parameters describe the project's numerical refit; the green curves in the report figures are retained as plotted.

## Columns and interpretation

| Column | Meaning | Unit |
| --- | --- | --- |
| `energy_keV` | Supplied representative channel energy | keV |
| `mean_differential_flux` | Differential flux averaged over the selected time samples | cm⁻² sr⁻¹ s⁻¹ keV⁻¹ |

The supplied calculation converts count rate to differential flux using `I = CountRate / (G * (Emax - Emin))`, then averages each energy channel over time.

These tables average along the sampled orbit; they do not impose a shared `Lstar` range across phases. Orbital position therefore matters when interpreting differences.

The original JPEG figures and their green fit lines are retained unchanged. The CSV files contain the mean flux values, rather than the fitted green curves. All three images also appear in the [written report](../../report/report.pdf).

The imported tables were checked for finite positive values, ten matching energy channels and agreement with the source archive's saved flux arrays.
