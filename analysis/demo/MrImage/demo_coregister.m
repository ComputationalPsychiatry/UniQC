
%% load data

pathData        = get_path('examples');

fileFunctional      = fullfile(pathData, 'nifti', 'rest', 'fmri_short.nii');
fileFunctionalMean  = fullfile(pathData, 'nifti', 'rest', 'meanfmri.nii');
fileStructural      = fullfile(pathData, 'nifti', 'rest', 'struct.nii');

Y = MrImageSpm4D(fileFunctionalMean);
Z = MrImageSpm4D(fileStructural);

%% and plot 
Y.plot;
Z.plot;

%% spm check registration
spm_check_registration(char({fileFunctionalMean; fileStructural}));

%% Coregister, but only update geometry
affineCoregistrationGeometry = Z.coregister_to(Y, 'geometry');

Z.plot(); % looks the same as before
Z.save('fileName', 'processed_geom.nii');
spm_check_registration(char({fileFunctionalMean; fileStructural; ...
    'processed_geom.nii'}));

% but not in checkreg...

%% Coregister with reslicing of data
affineCoregistrationGeometry = Z.coregister_to(Y, 'data');

Z.plot();

Y = MrSeries(fileFunctionalSeries);
Y.anatomy.load(fileStructural, 'updateProperties', 'none');

