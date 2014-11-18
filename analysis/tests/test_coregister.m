
%% load data

Y = MrImage('data/meanfunct.nii');
Z = MrImage('data/struct.nii');

%% and plot 
Y.plot;
Z.plot;

%% spm check registration
spm_check_registration(char({'DMPAD_0071/meanfunct.nii,1'; 'DMPAD_0071/struct.nii'}));

%% Coregister, but only update geometry
affineCoregistrationGeometry = Z.coregister_to(Y, 'geometry')

Z.plot(); % looks the same as before
Z.save('processed_geom.nii');
spm_check_registration(char({'DMPAD_0071/meanfunct.nii,1'; ...
    'DMPAD_0071/struct.nii'; 'processed_geom.nii'}));

% but not in checkreg...


%% Coregister with reslicing of data
affineCoregistrationGeometry = Z.coregister_to(Y, 'data');

Z.plot();

%Y = MrSeries('DMPAD_0071/funct.nii');
%Y.anatomy.load('DMPAD_0071/struct.nii', 'updateProperties', 'none');

