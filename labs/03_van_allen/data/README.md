# Input data for the Python reproduction

Place the original course input files in this folder, using these exact names:

| File | Variables used by the script |
| --- | --- |
| `GEOMAG.mat` | `Bgr_time`, `Bgr`, `Dst_time`, `Dst` |
| `RBSP.mat` | `T`, `CountRate`, `Lstar` |
| `RBSPenergy.mat` | `E`, `Emin`, `Emax`, `G` |

If a downloaded filename contains a suffix such as `(1)`, rename the local copy to the canonical name above. The three files can also remain in another folder; pass that folder with `--data-dir`.

Timestamps are MATLAB serial date numbers interpreted as UT. The Fourier calculation requires a continuous magnetic-field series sampled once per second. The energy-channel arrays must correspond to the columns of `CountRate`.

Expected hashes for the supplied inputs are recorded in [the source validation record](../results/validation.json).

## Run from the repository root

Use the environment described in the [laboratory README](../README.md#run-in-python), then run:

```bash
python labs/03_van_allen/scripts/reproduce_analysis.py --data-dir labs/03_van_allen/data
```

The default output folder is `labs/03_van_allen/generated/`. Use `--output-dir` to select another destination.

Local `.mat` inputs in this folder and the default generated outputs are ignored by Git.

