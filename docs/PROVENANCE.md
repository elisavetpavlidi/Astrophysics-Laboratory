# Provenance and validation

## Included work

Two completed exercises are supported by the supplied reports and notebooks: X-ray pulsar timing and stellar spectroscopy. The uploaded reports take precedence over older working copies. The repository copies remove the student number while retaining the author's name and scientific content.

The original 2026 spectroscopy notebook and F0 addendum are retained in `source/`. Its runnable presentation uses those same measurement functions and selected windows, with definitions placed before their use. Exploratory duplicate calculations are excluded from that presentation. Generated result exports are labelled separately from the retained working files.

The recovered X-ray physical-parameter script is included without changes. Its inputs come from the timing fit and literature values; this is not a new fit to the event data. The raw corrected events remain missing, so end-to-end timing execution has not been verified.

## Material still needed for further exercises

The MATLAB material found so far contains instructions rather than the student's `.m` solutions. Further exercises will need their actual code and final reports before they can be added as completed work.

Older starter notebooks, duplicated draft PDFs, teaching slides and compilation by-products are not included as additional completed exercises.

## File record

`file_manifest.json` maps the prepared files to their supplied or recovered source filenames and records transformations. `checksums.sha256` records the prepared file bytes. Validation results are recorded in `VALIDATION.md`.

## Original teaching sources, checked 1 November 2026

The X-ray base notebook was identified as `gevas-astro/EKPA_LAB2022W_XRay/LAB_Xray_2026_GR.ipynb`, snapshot `e3a7ab9b49ca4ae22becdcb2ff729af26fadd258` (14 October 2026). Its author is Georgios Vasilopoulos.

The public spectroscopy teaching README in `gevas-astro/ASTRO_Python_tutotial/Spectral_Lines` credits M. Papachristou, G. Vasilopoulos and D. Hatzidimitriou. The public `LabSpectra_v4.ipynb` is an earlier teaching version; no claim of byte-for-byte identity to the separately supplied 2026 course notebook is made.

Attributions were added to both runnable notebook headers, their READMEs, the root README and citation metadata. Code cells and saved outputs were checked to remain unchanged. Full citations and licence observations are recorded in `ACKNOWLEDGEMENTS.md`.
