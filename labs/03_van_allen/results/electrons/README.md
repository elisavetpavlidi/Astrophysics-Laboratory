# Saved electron energy spectra

The three CSV files contain time-averaged differential electron flux in the ten supplied RBSP energy channels. They are preserved from the numerical outputs in `VanAllen_Pavlidi_Complete.zip`, produced by the supplied Python reproduction using `RBSP.mat` and `RBSPenergy.mat`.

## Intervals and figures

| Phase | Interval (UT) | Numerical table | Original figure |
| --- | --- | --- | --- |
| Before the storm | 16 March 2013, 14:00 to 17 March, 00:00 | [electron_Pre14.csv](electron_Pre14.csv) | [Spectrum](../../figures/PreStorm_Spectrum.jpg) |
| Main phase | 17 March 2013, 13:00–15:00 | [electron_Main.csv](electron_Main.csv) | [Spectrum](../../figures/MainPhase_Spectrum.jpg) |
| Recovery | 18 March 2013, 16:00–20:00 | [electron_Recovery.csv](electron_Recovery.csv) | [Spectrum](../../figures/RecoveryPhase_Spectrum.jpg) |

The pre-storm table uses the 14:00 start shown in the figure. A 12:00 start used in another supplied driver defines a different average. The numerical selection excludes the exact interval endpoints.

## Columns and interpretation

| Column | Meaning | Unit |
| --- | --- | --- |
| `energy_keV` | Supplied representative channel energy | keV |
| `mean_differential_flux` | Differential flux averaged over the selected time samples | cm⁻² sr⁻¹ s⁻¹ keV⁻¹ |

The supplied calculation converts count rate to differential flux using `I = CountRate / (G * (Emax - Emin))`, then averages each energy channel over time.

These tables average along the sampled orbit; they do not impose a shared `Lstar` range across phases. Orbital position therefore matters when interpreting differences.

The original JPEG figures and their green fit lines are retained unchanged. The CSV files contain the mean flux values, rather than the fitted green curves. All three images also appear in the [written report](../../report/report.pdf).

The imported tables were checked for finite positive values, ten matching energy channels and agreement with the source archive's saved flux arrays.
