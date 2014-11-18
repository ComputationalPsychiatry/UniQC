pathExamples = get_paths('examples');

% TODO:...make this work in other test directory...

%% load data into time series
S = MrSeries('data/funct_short.nii');
S.parameters.save.path = prefix_files(S.parameters.save.path, 'results');
S.anatomy.load('data/struct.nii', 'updateProperties', 'none');

%% compute statistical images (mean, snr, sd, etc.)
S.compute_stat_images();
% S.plot_stat_images();


%% compute tissue probability maps of anatomical image
S.parameters.compute_tissue_probability_maps.nameInputImage = 'anatomy';

S.compute_tissue_probability_maps();


%% Coregister anatomy to mean functional and take tissue probability maps ...
%  with it
S.parameters.coregister.nameStationaryImage = 'mean';
S.parameters.coregister.nameTransformedImage = 'anatomy';
S.parameters.coregister.nameEquallyTransformedImages = 'tissueProbabilityMap';

S.coregister();


%% Compute masks from co-registered tissue probability maps via thresholding
S.parameters.compute_masks.nameInputImages = 'tissueProbabilityMap';
S.parameters.compute_masks.nameTargetGeometry = 'mean';
S.parameters.compute_masks.threshold = 0.5;
S.parameters.compute_masks.keepExistingMasks = false;


S.compute_masks();


%% Extract region of interest data for masks from time series data

S.parameters.analyze_rois.nameInputImages = {'mean', 'sd', 'snr', ...
    'coeffVar', 'diffLastFirst'};
S.parameters.analyze_rois.nameInputMasks = '.*mask';
S.parameters.analyze_rois.keepCreatedRois = false;
S.analyze_rois();


%% Do some fancy preprocessing to the time series to see how SNR increases

S.realign();
S.compute_stat_images();
% S.plot_stat_images();

% maybe necessary if geometry changed too much through realignment
% S.coregister();
% S.compute_masks();
S.analyze_rois();


%% Do some fancy preprocessing to the time series to see how SNR increases

S.smooth();
S.compute_stat_images();
% S.plot_stat_images();
S.analyze_rois();
