# Reddy example: unresolved motion-metric discrepancy

Tracking issue: https://github.com/ComputationalPsychiatry/UniQC/issues/18
Related implementation issue: https://github.com/ComputationalPsychiatry/UniQC/issues/2

The example has a reported mismatch between its motion-related annotations
and the corresponding example in the paper. The exact affected subject/run,
figure panel, paper value, and observed value still need to be recorded.
Do not interpret the current example as an exact numerical reproduction.

## References and baseline

- Paper: https://doi.org/10.1162/imag_a_00057
- Author code: https://github.com/BrightLab-ANVIL/Reddy_MotorMEICA/blob/main/MotionCalc.m
- Dataset: https://doi.org/10.18112/openneuro.ds004662.v1.1.0
- UniQC baseline: commit `99b5b2f`, branch `2-implement-me-example-from-reddy-et-al`.
- Local follow-up fixes adjust plotting and recompute unconvolved grip traces
  when using downloaded regressors; record the final commit when reproducing.

## What is currently computed

These are two distinct metrics, not a correlation with FD:

1. Mean FD: `mean(quality_measures.FD, 'omitnan')`, where PhysIO computes
   `quality_measures` from SPM realignment parameters.
2. Task-motion correlation: absolute Pearson correlation between the sum of
   the normalized, unconvolved right/left grip traces and
   `realignmentParameters(:,1)` (SPM X translation), using finite pairs.

The console currently labels this as `corr(right grip, X motion)`, although
both hands are used. The figure labels mean FD and absolute correlation.
The default pipeline uses recomputed physiology, sampled at 20 Hz, with
linear interpolation to scan times and the first ten volumes removed.
The physiology trigger column is not used to align the traces.

## Reproduce and capture evidence

Configure UniQC, SPM, and PhysIO on the MATLAB path. From the repository root:

```matlab
addpath(fullfile(pwd, 'demo', 'Paper'));
tapas_uniqc_download_example_data('openneuro_ds004662');
workspaceRoot = fullfile(tempdir, 'uniqc_reddy_motion_reproduction');
if ~isfolder(workspaceRoot), mkdir(workspaceRoot); end
diary(fullfile(workspaceRoot, 'reproduction.log'));
version
ver
which spm -all
which tapas_physio_get_movement_quality_measures -all
system('git rev-parse HEAD');
system('git status --short');
try
    % Candidate from the wrapper; not yet confirmed as the reported panel.
    tapas_uniqc_Reddy_ME_example_func(3, 1, 1, workspaceRoot);
catch exception
    disp(getReport(exception, 'extended'));
    diary off
    rethrow(exception);
end
diary off
```

The wrapper's candidate pairs are `(3,1)`, `(4,1)`, `(8,2)`, and `(1,2)`.
Match the paper panel to its exact pair before comparing numbers. Run the
single-subject function for that pair; a full wrapper run is not necessary.
Use a new scratch directory for a fresh realignment: the example reuses
`echoes/` and `rp.mat` if both exist, without validating their provenance.

Keep the log, final figures, `rp.mat`, and software versions. Record the
paper panel, subject/run, expected mean FD and correlation, observed values,
and whether realignment was fresh or cached. These generated files should
remain outside Git.

## Investigation and completion criteria

- Confirm whether the reported difference concerns mean FD, correlation,
  or both, and transcribe the paper's values with their figure/panel source.
- Compare the author's motion column/coordinate convention and preprocessing
  with SPM X translation; do not assume AFNI/SPM parameter columns coincide.
- Check time alignment, discarded volumes, use of one/both hands, raw versus
  HRF-convolved grip traces, and signed versus absolute correlation.
- If FD also differs, compare FD definition, rotational conversion/head
  radius, first-sample handling, and realignment method.
- Preserve before/after numeric evidence and add a focused regression check
  if a computation bug is found. Otherwise document the methodological
  difference and why exact agreement is not expected.

The discrepancy is deliberately deferred; its cause has not been established.
