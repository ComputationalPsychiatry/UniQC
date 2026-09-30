# Echo combination for sequence and methods development

This example adapts the comparisons in Poser and Norris (2009),
[Investigating the benefits of multi-echo EPI for fMRI at 7 T](https://doi.org/10.1016/j.neuroimage.2009.01.007),
to the publicly downloadable Reddy handgrasp data, OpenNeuro ds004662,
snapshot 1.1.0. The Reddy acquisitions are **3 T**, not 7 T. This is a
methodological demonstration; neither the original numerical results nor
the original anatomical panels should be expected.

Tracking issue: [UniQC #20](https://github.com/ComputationalPsychiatry/UniQC/issues/20).

## Run

Set up UniQC, SPM and the Image Processing Toolbox as for the Reddy example.
The optional handgrasp model uses the existing Reddy physiological-regressor
helper and its dependencies.

```matlab
tapas_uniqc_download_example_data('openneuro_ds004662');
scratchFolder = fullfile(tempdir, 'uniqc-poser');
% One subject; omit runGLM=false to include handgrasp PSC and t-maps:
results = tapas_uniqc_Poser_ME_example_func(3, 1, 1, scratchFolder, ...
    'runGLM', false);
% All four downloaded subject/run pairs, including the handgrasp models:
results = tapas_uniqc_Poser_ME_example(1, scratchFolder);
```

The wrapper follows the Reddy wrapper's subject/run list and first two
arguments. The per-run function follows its four positional arguments:
subject, run, verbosity and scratch folder. Verbosity is 0 for no explicit
demo figures, 1 for final comparisons, 2 for tSNR maps, and 3 for weight and
physiology diagnostics. SPM may display its own processing windows.
Outputs are isolated under `derivatives/openneuro/ds004662/Poser/sub-XX/run-X`.
Rerunning a run replaces its outputs and recomputes preprocessing; no Reddy
cache is silently reused. A run with GLM disabled does not remove old GLM
outputs: consult `comparison_summary.mat` for the current run options.

## Comparisons and interpretation

All echoes share one motion correction estimated from echo 1. The first ten
volumes are discarded, matching the Reddy analysis. Echo times are read from
JSON and sorted; no Poser-specific echo count, TE, slice or task timing is
used. The following methods use `MrImage.combine_multi_echo`:

| Method | Normalized weights |
| --- | --- |
| Each individual echo | One-hot selection |
| Equal | 1 / number of echoes |
| T2star | TE exp(-TE/T2*) |
| CNR | TE times temporal SNR |

Equal averaging has the same tSNR and percent signal change as simple
summation, but a different absolute signal scale. T2* uses UniQC's
log-linear fit, not the original paper's nonlinear fit.

By default weights use the first 24 **retained** volumes (original 11:34),
and quality metrics use the remaining volumes (original 35:end). Supply
`weightVolumes` and `evaluationVolumes` to change these disjoint windows.
The default calibration is not claimed to be a verified rest period;
task effects, drift and motion contribute to its variance. Select validated
rest intervals for a closer analogue of the paper's rest-based estimator.

The legacy script's sensitivity proxy is retained explicitly:
`tSNR(combined) * sum(weights .* TE)`, in ms. It assumes an effective TE
given by the weight average. With differing echo signal levels this is an
approximation, not an exact BOLD contrast prediction or a measured task
CNR. Both the proxy and tSNR are reported so that an apparent improvement
can be inspected. A higher tSNR alone does not establish optimal BOLD
sensitivity. No method is declared universally optimal.

The reference is echo 2 of the *same* ME acquisition, following the Reddy
comparison. It is not an independently acquired conventional single-echo
scan. Consequently this example cannot assess acceleration-related
distortion improvements between different acquisition protocols.

Sensitivity gains are voxelwise percentages relative to echo 2, averaged
over the same finite, positive-sensitivity voxels for every method. Empty
tissue ROIs return NaN; voxel counts are saved. Brain, GM and WM masks from
SPM segmentation replace hand-drawn Poser ROIs. Inspect segmentation before
interpreting regional results. The optional GLMs use the full retained run,
the same six motion parameters and right/left grip and CO2 regressors for
every method; calibration weights stay fixed. PSC and unthresholded SPM
right-grip t-maps are shown with common colour limits. They are descriptive
task-response comparisons, not a held-out validation of activation or
multiple-comparison-corrected inference.

## Relationship to the original figures

| Paper / historical script | Adaptation |
| --- | --- |
| Fig. 1 manual anatomical ROIs | Reproducible tissue ROIs and saved brain/comparison masks |
| Fig. 2 separate ME/SE image quality | Saved mean images for each echo and combination; no claim about separate acquisitions |
| Fig. 3 relative CNR | Regional sensitivity-proxy gain and tSNR plot plus CSVs; T2* comparison added |
| Figs. 4–5 activation comparisons | Optional per-echo and per-combination right-grip PSC and t-maps with common colour limits; no Stroop or group t-map reproduction |
| Figs. 6–7 trial averages and noise analysis | Not reproduced by the historical script or this adaptation |

Method numbers in output filenames follow the rows of `echo_comparison.csv`:
echoes in increasing TE, then Equal, T2star and CNR. Maps include normalized
weights, mean, tSNR, sensitivity proxy and gain percentages. The MAT summary
records source filenames, field strength, TE, windows, ROI counts and options.

## Historical source audit

`results/example1_ME_data.m` is preserved byte-for-byte from branch
`137-fix-demos-that-were-excluded-from-release`, originally added by commit
`4e2dcee`. Only that file is imported: the original commit also changes 80
unrelated files. It is an archival script requiring private data, not the
entry point for this public-data example.

It does implement simple and practical CNR-weighted combinations, estimates
weights from volumes 3:26, computes the effective-TE sensitivity proxy and
ROI differences, and begins an SPM model. It does not implement T2* weighting,
a complete all-method activation comparison, or all figures from the paper.
Its private paths, four-echo assumptions, manually drawn masks, separate SE
scan at a hardcoded 25 ms and Stroop onsets cannot be transferred to Reddy.
The new entry points replace those dataset-specific assumptions.

## Validation status

MATLAB R2025b numerical checks passed for normalized weights, masking,
agreement of echo-2 tSNR with direct mean/std calculation, and zero gain for
the reference echo. MATLAB's static analyzer reports no issues for the three
new functions. A full sub-03/run-1 validation was started, but the tool call
was cancelled during lengthy SPM preprocessing; end-to-end real-data outputs
and the optional GLM/contrast path have not yet been verified.
