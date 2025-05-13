% Script tapas_uniqc_Reddy_ME_example
% ONE_LINE_DESCRIPTION
%
%  tapas_uniqc_Reddy_ME_example
%
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2025-05-02
% Copyright (C) 2025 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD MULTI-ECHO EPI DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% asssuming the data is stored in BIDS 
dataFolder = 'C:\Users\uqsboll2\Desktop\Reddy_ME_data';
subID = '03';

meFilenames = dir(fullfile(dataFolder, ['sub-', subID], 'func', '*.nii.gz'));

for f = 1:numel(meFilenames)

    % get nifti filename
    thisFilename = fullfile(meFilenames(f).folder, meFilenames(f).name);
    
    % get json filename (call fileparts twice in case of .nii.gz)
    [~, tmpFilename] = fileparts(thisFilename);
    [~, rawMeFilename] = fileparts(tmpFilename);

    % load data
    % nifti image
    tmp{f} = MrImage(thisFilename);
    % json file
    text = fileread(fullfile(meFilenames(f).folder, [rawMeFilename, '.json']));
    tmpJson = jsondecode(text);
    tmp{f}.dimInfo.add_dims(5, 'dimLabels', 'echoTime', ...
        'samplingPoints', tmpJson.EchoTime*1000, 'units', 'ms');

end

% combine tmp 4D-images in one 5D-image
data = tmp{1}.combine(tmp);
data.name = 'Multi-echo EPI';
clear tmp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT RAW QUALITY METRICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot mean across time for each echo
data.mean('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), ...
    'rotate90', 1);

% plot tSNR across time for each echo
data.snr('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), ...
    'rotate90', 1, 'colorBar', 'on');

close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REALIGN IMAGES AND OPTIMALLY COMBINE ECHOES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove first 10 volumes
data = data.select('t', 11:data.dimInfo.nSamples('t'));
% plot tSNR of middle echo for comparison
data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
    'displayRange', [0 data.snr('t').prctile(99)]);

% estimate realignment parameters based on the first echo and apply to all
% echoes
[rData, realignmentParameters] = data.realign(...
    'representationIndexArray', data.select('echoTime', 1), ...
    'applicationIndexArray', {'echoTime', 1:data.dimInfo.nSamples('echoTime')});

% confirm increase in SNR after realignment
rData.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
    'displayRange', [0 data.snr('t').prctile(99)]);

% this took a long time - let's save the results
rData.parameters.save.path = 'C:\Users\uqsboll2\Desktop\Reddy_ME_results';
rData.parameters.save.fileName = [strrep(rawMeFilename, 'echo-5_', ''), '.nii'];
disp(['Saving ', rData.get_filename]);
rData.save();
% for loading, use rData = MrImage('C:\Users\uqsboll2\Desktop\Reddy_ME_results')

% estimate T2*-based weights based on Poser et al., MRM, 2006 using a
% general linear model
% created using chatgpt

% extract TEs
TE = rData.dimInfo.samplingPoints{'echoTime'};

% Ensure TE is a column vector
TE = TE(:);
nTE = length(TE);

% compute mean across time
meanRData = rData.mean('t');
meanRData.plot('rotate90', 1, 'echoTime', 1:meanRData.dimInfo.nSamples('echoTime'));
% remove unnecessary dimensions
meanRData = meanRData.remove_dims('t');

snrThresh = 10;
T2range = [1, 5000]; % ms

S_size = size(meanRData.data);
spatialSize = S_size(1:end-1);
nVoxels = prod(spatialSize);

% Reshape to [nTE x nVoxels]
S_reshaped = reshape(meanRData.data, [nVoxels, nTE])';  % [nTE x nVoxels]

% Compute masks
isPositive = all(S_reshaped > 0, 1);
meanSignal = mean(S_reshaped, 1);
goodSNR = meanSignal > snrThresh;
validMask = isPositive & goodSNR;

% Log-transform only valid voxels
logS = zeros(size(S_reshaped));
logS(:, validMask) = log(S_reshaped(:, validMask));

% Design matrix
X = [ones(nTE, 1), TE];
X_pinv = pinv(X);

% Solve
beta = X_pinv * logS(:, validMask);
lnS0_valid = beta(1, :);
slope_valid = beta(2, :);

% Filter out non-decaying voxels (slope ≥ 0)
decayMask = slope_valid < 0;
validMaskIdx = find(validMask);
keepIdx = validMaskIdx(decayMask);

% Prepare output
T2map = NaN(nVoxels, 1);
S0map = NaN(nVoxels, 1);

% Compute S0 and T2
T2_valid = -1 ./ slope_valid(decayMask);
S0_valid = exp(lnS0_valid(decayMask));

% Clamp T2 to valid physiological range
T2_valid(T2_valid < T2range(1) | T2_valid > T2range(2)) = NaN;

% Assign to map
T2map(keepIdx) = T2_valid;
S0map(keepIdx) = S0_valid;

% Reshape to original dimensions
T2mapData = reshape(T2map, spatialSize);
S0mapData = reshape(S0map, spatialSize);

% recast as MrImages
T2map = meanRData.copyobj();
T2map = T2map.remove_dims('echoTime');
T2map.data = T2mapData;

S0map = meanRData.copyobj();
S0map = S0map.remove_dims('echoTime');
S0map.data = S0mapData;

% compute T2* weights
% create TE images
TEImage = meanRData.copyobj();
TEImage.data = permute(repmat(TE, [1, TEImage.dimInfo.nSamples(1:3)]), [2 3 4 1]);

exp(T2map.*(-1));











 
