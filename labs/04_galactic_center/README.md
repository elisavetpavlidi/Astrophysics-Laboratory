# The orbit of S2 and the mass of Sagittarius A*

Laboratory exercises 5–6, Department of Physics, National and Kapodistrian University of Athens. Student analysis by **Elisavet Pavlidi**, based on the laboratory exercise prepared by **Theocharis Apostolatos** and **Kosmas Gazeas**.

The orbit of S2 was used to estimate the mass of the Milky Way's central black hole. Twelve epochs of FITS images (1992–2002.9) were measured in SAOImage DS9. Synthetic ellipses were used to test projection and position noise. The measured positions were then used to fit the projected orbit, reconstruct it in its orbital plane and estimate the enclosed mass from the rate at which the star sweeps out area. A final regression tested whether the astrometry could resolve Schwarzschild precession.

| Quantity | Laboratory result |
| --- | ---: |
| Central mass | 3.18 million solar masses |
| Eccentricity | 0.687 |
| Inclination from the projected shape | 50.15° (acute-angle convention) |
| Periapsis distance | ≈259 AU, about 4,100 Schwarzschild radii |
| Schwarzschild radius | ≈0.063 AU |
| Precession regression slope | 0.84756 ± 0.17692 (95% confidence interval half-width) |

The interval for the recorded MATLAB Online slope includes the Newtonian value of 1. The lab mass is approximately 26% below the estimate from the 2024 GRAVITY study, which combined the orbits of four stars with higher-precision interferometric observations. [GRAVITY Collaboration (2024)](https://doi.org/10.1051/0004-6361/202452274)

## Files and execution

- [Lab report (Greek)](report/report.pdf), [measured positions](data/astrometry.csv), [synthetic trials](results/mat1_trials.csv), [orbit-fit trials](results/mat2_trials.csv) and [reported results](results/matlab_results.csv).
- [MAT0 and MAT2 diagnostics](figures/), [MAT3 mass-fit plot](figures/mat3_swept_area.png) and [recorded MAT4 plot](figures/mat4_matlab.png).
- Run `addpath('scripts/matlab')` from this lab folder in MATLAB, followed by `analyze_s2` for the trial fits, mass calculation and precession check, or `plot_synthetic_trials` to visualize the six MAT1 setups. These public scripts are student-side implementations of the teaching workflow. The synthetic plot uses a fixed seed, and the published worksheet records the original MAT1 outputs. The recalculation of MAT4 from the rounded astrometric table yields approximately 0.8670 ± 0.1142. The archived MATLAB Online run (0.84756 ± 0.17692) supplies the reported value and figure. The cause of the difference between the two runs has not been established.
- A separate [FITS sensitivity analysis](results/fits_check/) explores centroiding, the chosen black-hole position, the 1999 epoch and the impact of fitting the projected orbit directly. To rerun it, install NumPy, SciPy, Matplotlib and Pillow, then run `python scripts/python/analyze_s2.py /path/to/blackholeimages.zip --output results/fits_check` from this folder. The input FITS archive is distributed with the course. `replay_fits_check` repeats the mass and angle fits on this separate data set in MATLAB.

## References

- Theocharis Apostolatos and Kosmas Gazeas, *Estimation of the Mass of the Black Hole at the Centre of the Galaxy*, NKUA astrophysics laboratory handout, exercises 5–6.
- Gillessen et al. (2009), *The Astrophysical Journal* 692, 1075–1109. [DOI](https://doi.org/10.1088/0004-637X/692/2/1075)
- GRAVITY Collaboration (2024), *Astronomy & Astrophysics* 692, A242. [DOI](https://doi.org/10.1051/0004-6361/202452274)
