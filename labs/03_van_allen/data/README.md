# Input data for the Van Allen analyses

Place the original course input files in this folder, using these exact names:

| File | Variables used by the analyses |
| --- | --- |
| `GEOMAG.mat` | `Bgr_time`, `Bgr`, `Dst_time`, `Dst`; the geomagnetic entry point also uses `Bz_time`, `Bz`, `Vsw_time`, `Vsw`, `Psw_time`, `Psw`, and optionally `Bca_time`, `Bca` |
| `RBSP.mat` | `T`, `CountRate`, `Lstar`, `MLT` |
| `RBSPenergy.mat` | `E`, `Emin`, `Emax`, `G` |

If a downloaded filename contains a suffix such as `(1)`, rename the local copy to the canonical name above. The three files can also remain in another folder; use Python's `--data-dir` argument or the MATLAB functions' first input argument.

Timestamps are MATLAB serial date numbers interpreted as UT. The Fourier calculation requires a continuous magnetic-field series sampled once per second. The energy-channel arrays must correspond to the columns of `CountRate`.

Expected hashes for the supplied inputs are recorded in [the source validation record](../results/validation.json).

## Run in Python from the repository root

Use the environment described in the [laboratory README](../README.md#run-in-python), then run:

```bash
python labs/03_van_allen/scripts/reproduce_analysis.py --data-dir labs/03_van_allen/data
```

The default output folder is `labs/03_van_allen/generated/`. Use `--output-dir` to select another destination.

## Run in MATLAB

The [MATLAB entry points](../scripts/README.md) read this data folder by default. Start MATLAB in the repository root:

```matlab
addpath(fullfile(pwd,'labs','03_van_allen','scripts'));
Geomagnetic_Analysis;
ElectronSpectrum_Analysis;
Compare_Frequency_Bands;
```

Their default outputs are under `generated/matlab/` in the lab folder. The two function entry points also accept explicit input and output folder arguments.

Local `.mat` inputs in this folder and the default generated outputs are ignored by Git.


