# NGC 300 ULX-1

**Original teaching notebook:** Georgios Vasilopoulos ([gevas-astro](https://github.com/gevas-astro)), [*LAB_Xray_2026_GR.ipynb*](https://github.com/gevas-astro/EKPA_LAB2022W_XRay/blob/e3a7ab9b49ca4ae22becdcb2ff729af26fadd258/LAB_Xray_2026_GR.ipynb) (2026). **Completed student analysis and extensions:** Elisavet Pavlidi. See [source credits and permissions](../../ACKNOWLEDGEMENTS.md).

## Aim

Measure the pulsar spin frequency and its evolution from NuSTAR events, then estimate the accretion rate and surface magnetic field using the laboratory model.

| File or folder | Contents |
| --- | --- |
| [analysis.ipynb](analysis.ipynb) | Original timing analysis, saved outputs and portable data path |
| [scripts/NGC300_ULX1_recalculate.py](scripts/NGC300_ULX1_recalculate.py) | Physical parameters, propagated uncertainties and sensitivity checks |
| [report/report.pdf](report/report.pdf) | Latest supplied final report; student number removed |
| [figures/](figures/) | Source selection, light curve, pulse profiles, periodograms and spin-up fit |
| [results/](results/) | Recovered physical-parameter calculations and sensitivity tables |

## Reproduce

For timing, put the corrected event file named in [data/README.md](data/README.md) inside `data/`, then run the notebook from top to bottom. Its original saved outputs are retained for inspection.

For the physical-parameter calculations, run from the repository root:

```bash
python labs/01_xray_pulsar/scripts/NGC300_ULX1_recalculate.py
```

The script writes its JSON, CSV and sensitivity figure beside itself. The `results/` folder holds the recovered outputs. The input spin frequency and its derivative are taken from the completed timing notebook; the script does not refit the event data.

## Interpretation

The final report separates statistical and systematic contributions and compares two distance calibrations. The mass, radius and magnetospheric factor are model assumptions. The broad-band flux is a literature-based bolometric proxy.

The retained timing notebook includes an unfilled uncertainty-template cell. Use the recalculation script and final report for the completed uncertainty analysis. Its period-search ordinate is the RMS dispersion of folded counts; it should be read as a detection statistic, rather than a calibrated significance.
