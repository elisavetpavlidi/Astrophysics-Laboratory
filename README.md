# Astrophysics Laboratory

**Elisavet Pavlidi · Department of Physics, NKUA · 2026–2027**

A collection of laboratory work in astrophysics and space physics, combining observational data, numerical methods and physical interpretation.

The repository brings together Python and MATLAB code, Jupyter notebooks, figures, numerical results and written reports, organised by laboratory exercise.

## Laboratory exercises

| Laboratory | Scientific focus | Analysis and material |
| --- | --- | --- |
| [X-ray pulsar timing](labs/01_xray_pulsar/) | Period searches, spin-frequency evolution and physical parameters of NGC 300 ULX-1 | [Notebook](labs/01_xray_pulsar/analysis.ipynb) · [Parameter calculations](labs/01_xray_pulsar/scripts/NGC300_ULX1_recalculate.py) · [Report](labs/01_xray_pulsar/report/report.pdf) |
| [Stellar spectroscopy](labs/02_stellar_spectroscopy/) | Stellar spectra, equivalent widths and an excitation-temperature estimate | [Notebook](labs/02_stellar_spectroscopy/analysis.ipynb) · [Source files](labs/02_stellar_spectroscopy/source/) · [Report](labs/02_stellar_spectroscopy/report/report.pdf) |
| [Van Allen laboratory](labs/03_van_allen/) | Geomagnetic variability, ULF frequency bands and energetic electron spectra | [MATLAB comparison](labs/03_van_allen/scripts/Compare_Frequency_Bands.m) · [MATLAB guide](labs/03_van_allen/scripts/README.md) · [Report](labs/03_van_allen/report/report.pdf) |
| [S2 and Sagittarius A*](labs/04_galactic_center/) | Astrometry in SAOImage DS9, orbital reconstruction, central mass and a test for Schwarzschild precession | [Analysis and results](labs/04_galactic_center/) · [MATLAB scripts](labs/04_galactic_center/scripts/matlab/) · [Report](labs/04_galactic_center/report/report.pdf) |

## Organisation

Each folder under `labs/` corresponds to one exercise. Depending on the exercise, it contains analysis notebooks or scripts, data notes, figures, numerical results and a report. The laboratory folders and script headers describe the relevant inputs, parameters and methods.

The reports are in Greek; repository documentation is in English.

## Running the analyses

Software and data requirements depend on the exercise. Some observational inputs must be supplied separately; consult the laboratory notes and script headers before running an analysis.

### Python and Jupyter

Use Python 3.12 and create an environment from the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m jupyterlab
```

Open the relevant `analysis.ipynb` notebook and follow its laboratory instructions. Python dependencies are listed in [requirements.txt](requirements.txt).

### MATLAB

Use MATLAB for the `.m` files and follow the data-path instructions for the relevant entry point.

The [Van Allen MATLAB guide](labs/03_van_allen/scripts/README.md) covers geomagnetic analysis, electron spectra and frequency-band comparisons. The entry points load the shared `labs/03_van_allen/data/` inputs and add their helper folder automatically.

## Credits and provenance

Student analyses, parameter choices, extensions, interpretation and reports are by **Elisavet Pavlidi**.

The X-ray timing and stellar spectroscopy exercises build on teaching notebooks by **Georgios Vasilopoulos ([gevas-astro](https://github.com/gevas-astro))**. Additional teaching contributors, original sources and permissions notes are listed in [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md). The Van Allen MATLAB workflow builds on course-provided helpers; their adaptations are documented in the [helper notes](labs/03_van_allen/scripts/matlab_helpers/README.md).

The Galactic Centre exercise is based on laboratory material prepared by **Theocharis Apostolatos** and **Kosmas Gazeas**. [S2 exercise and references](labs/04_galactic_center/)

See [provenance](docs/PROVENANCE.md) and [validation](docs/VALIDATION.md) for source preparation and documented checks.

