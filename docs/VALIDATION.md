# Validation

Prepared on 31 October 2026.

| Check | Result |
| --- | --- |
| Notebook structure | All included notebooks pass `nbformat` validation |
| Spectroscopy execution | All 17 code cells in `analysis.ipynb` executed sequentially in a fresh Python process with a noninteractive plotting backend |
| Hα results | All 13 equivalent widths reproduce the final report's rounded table |
| F0 results | Hδ = 15.552 Å, Paδ = 5.272 Å and excitation temperature = 5605 K, consistent with the supplied report |
| X-ray physical parameters | Recalculation script runs successfully and reproduces the recovered JSON results exactly |
| PDF reports | Both two-page reports rendered and visually checked after student-number redaction |
| Notebook privacy | Student number removed from code and saved outputs |
| Repository navigation | All local Markdown links and image references checked |

Scientific execution used Python 3.12.14, NumPy 2.3.5, SciPy 1.17.0, Matplotlib 3.10.8 and Astropy 8.0.2. These scientific dependencies are pinned in the root requirements. JupyterLab is the intended local interface; execution validation here used a sequential Python runner rather than a live browser session.

The X-ray event file was unavailable, so the timing fit has not been rerun from raw events. The optional Stingray comparison was not executed. The retained original spectroscopy notebook records the working session; use the separately prepared `analysis.ipynb` for execution from a clean state.
