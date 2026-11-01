# Timing input

Required for the selected FPMA analysis:

```text
nu30202035002A01_cl_bary.evt.gz
```

Place this file in this directory. Observation ID: `30202035002`. The supplied report identifies the NuSTAR observation of 16 December 2016.

The original event file was not among the recovered or supplied files. It has not been replaced with synthetic data. The timing notebook contains saved results, and the separate recalculation script runs from those fitted values.

Use the same processed, barycentrically corrected event file to reproduce the saved analysis. A newly downloaded uncorrected event file requires its own extraction, calibration and barycentric correction; renaming it is insufficient.
