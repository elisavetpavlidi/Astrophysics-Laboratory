# Stellar spectroscopy

**Course-provided 2026 teaching notebook:** Georgios Vasilopoulos ([gevas-astro](https://github.com/gevas-astro)). **Completed student analysis and extensions:** Elisavet Pavlidi. The [public earlier teaching material](https://github.com/gevas-astro/ASTRO_Python_tutotial/tree/main/Spectral_Lines) credits M. Papachristou, G. Vasilopoulos and D. Hatzidimitriou. See [full source credits](../../ACKNOWLEDGEMENTS.md).

## Aim

Compare stellar spectra, measure the Hα equivalent width from O5 to M5 and estimate the F0 excitation temperature from Hδ and Paδ.

| File or folder | Contents |
| --- | --- |
| [analysis.ipynb](analysis.ipynb) | Runnable analysis assembled from the completed work and F0 addendum |
| [source/](source/) | Completed original notebook, F0 addendum and helper cells |
| [pyHammer_templates/](pyHammer_templates/) | The 13 original FITS spectra used for this analysis |
| [report/report.pdf](report/report.pdf) | Latest supplied final report; student number removed |
| [figures/](figures/) | Selected spectra and line measurements |
| [results/](results/) | Continuum windows, equivalent widths and exported F0 quantities |

## Reproduce

Install the root requirements, open `analysis.ipynb` and run all cells. The included FITS files avoid a network download. The notebook writes the Hα table and F0 summary to `results/`.

The original notebook contains exploratory cells and was not arranged for a clean restart. The runnable version puts definitions and measurements in dependency order and removes an exploratory call that overwrote the final Hδ measurement. The measurement functions, continuum windows and physical relations come from the supplied analysis.

The files in `source/` preserve the working record. The F0 addendum and `.py` helper cells expect variables from the main laboratory notebook; they are not standalone programs.

## Interpretation

Positive equivalent width denotes absorption; negative values denote emission. The excitation-temperature calculation assumes the linear part of the curve of growth. Its formal propagated error does not describe all continuum and line-formation uncertainties, and the excitation temperature need not equal the effective temperature.
