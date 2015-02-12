
%% load data

pathExamples        = get_path('examples');
pathData            = fullfile(pathExamples, 'resting_state_ingenia_3T', 'data');

fileFunctional      = fullfile(pathData, 'funct_short.nii');
fileFunctionalMean  = fullfile(pathData, 'meanfunct.nii');
fileStructural      = fullfile(pathData, 'struct.nii');

Y = MrImage(fileFunctionalMean);
Z = MrImage(fileStructural);

%% and plot 
Y.plot;
Z.plot;

%% spm check registration
spm_check_registration(char({fileFunctionalMean; fileStructural}));

%% Coregister, but only update geometry
affineCoregistrationGeometry = Z.coregister_to(Y, 'geometry');

Z.plot(); % looks the same as before
Z.save('processed_geom.nii');
spm_check_registration(char({fileFunctionalMean; fileStructural; ...
    'processed_geom.nii'}));

% but not in checkreg...

%% Coregister with reslicing of data
affineCoregistrationGeometry = Z.coregister_to(Y, 'data');

Z.plot();

Y = MrSeries(fileFunctionalSeries);
Y.anatomy.load(fileStructural, 'updateProperties', 'none');

