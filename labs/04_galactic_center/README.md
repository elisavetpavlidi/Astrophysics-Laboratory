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
- [Twelve-epoch image animation](figures/animation.gif) used for the DS9 astrometry.

### Running the MATLAB scripts

Open [`scripts/matlab/`](scripts/matlab/) as the current folder in MATLAB. The orbit and precession fits use Curve Fitting Toolbox.

1. Run `MAT1_26` for the synthetic projection and noise test. Use the input parameters in the [MAT1 trial table](results/mat1_trials.csv).
2. Run `MAT0_26` to process the measured DS9 positions and write `DATAfile.mat`.
3. Run `MAT2_26` to fit the orbit and write `MAT_DATA_phys.mat`.
4. Run `MAT3_26` with `J.m` in the same folder to estimate the mass. Enter the scales `1.177366744e13` metres per pixel and `3.168808781e-8` inverse seconds.
5. Run `MAT4_26` for the precession regression. The [recorded MATLAB result](results/matlab_results.csv) corresponds to the run presented in the report. MAT1 and MAT2 use random draws, so a new run can return a different fit.

The [FITS sensitivity-check outputs](results/fits_check/) document a supplementary comparison with the image-based centroiding analysis.

## References

- Theocharis Apostolatos and Kosmas Gazeas, *Estimation of the Mass of the Black Hole at the Centre of the Galaxy*, NKUA astrophysics laboratory handout, exercises 5–6.
- Gillessen et al. (2009), *The Astrophysical Journal* 692, 1075–1109. [DOI](https://doi.org/10.1088/0004-637X/692/2/1075)
- GRAVITY Collaboration (2024), *Astronomy & Astrophysics* 692, A242. [DOI](https://doi.org/10.1051/0004-6361/202452274)
