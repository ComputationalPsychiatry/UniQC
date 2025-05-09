clear; close all; clc;
doPlotRoi = true;
arraySize = [51,51,1,200];
% percentage of temporal noise in relation to the signal value (spatial
% noise is fixed at 1 %) 
percentTemporalNoise = [0.01, 0.1, 1];
%% create ROI image
% Note: This is a slightly more complicated version, because we distinguish
% in dimInfo an image with [51 51] and [51 51 1] samples, whereas matlab
% doesn't. However, we can enforce this by manually defining the dimInfo
% object using 'nSamples' (see the issued warning). Usually, it is 
% sufficient to just input the data and the dimInfo is automatically 
% deducted from there.

% empyt (0) image
roi_data = zeros(arraySize(1:3));
% dimInfo with [51 51 1] samples
roi_dimInfo = MrDimInfo('nSamples', arraySize(1:3));
% create first roi image (using the dimInfo as a second object)
roi{1} = MrImage(roi_data, 'dimInfo', roi_dimInfo);
% set centre voxel to 1
roi{1}.data(26, 26, 1) = 1;
n_voxel(1) = sum(roi{1}.data(:));
roi{1}.plot;
% make ROIs
for n = 2:20
    roi{n} = roi{1}.imdilate(strel('disk', n-1));
    n_voxel(n) = sum(roi{n}.data(:));
    if doPlotRoi
        roi{n}.plot;
    end
end

%% generate image time series (200 volume) filled with 1's
m = MrImage(100 * ones(arraySize));
m.plot('sliceDimension', 't');

%% add 1% spatial noise (i.e. the same noise per time point)
m = m + 1 * randn(m.dimInfo.nSamples);
m.plot('sliceDimension', 't', 't', 1:200);

% add spatial noise
for s = 1:numel(percentTemporalNoise)
mNoisy{s} = m + percentTemporalNoise(s) * randn(1,1,1,200);
mNoisy{s}.name = [num2str(percentTemporalNoise(s)), '% temporal noise added'];
mNoisy{s}.plot('sliceDimension', 't', 't', 1:200);

% extract ROI information
mNoisy{s}.extract_rois(roi);
mNoisy{s}.compute_roi_stats();
end

%% compute coefficient of variation (CV)
clear n s
for s = 1:3
    for n = 1:20
        CV(s,n) = std(mNoisy{s}.rois{n}.perVolume.mean)/mean(mNoisy{s}.rois{n}.perVolume.mean);
    end
end
%% plot results
figure; plot(n_voxel, CV);
legend(strcat(string(num2cell(percentTemporalNoise)), '% temporal noise'))
figure; plot(log(n_voxel), log(CV));
legend(strcat(string(num2cell(percentTemporalNoise)), '% temporal noise'));
