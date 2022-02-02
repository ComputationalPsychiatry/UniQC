function this = compute_stats(this, nanflag)
% Compute statistical values for ROI per slice and in total volume
%
%   Y = MrRoi()
%   Y.compute_stats(nanflag)
%
% This is a method of class MrRoi.
%
% IN
%   nanflag     'omitnan' (default) or 'includenan'
%               if 'includenan' is chosen, most operations (mean, sd,
%               median) will return nan, if one value in the arrray is NaN
% OUT
%
% EXAMPLE
%   compute_stats
%
%   See also MrRoi

% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-18
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 2
    nanflag = 'omitnan';
end

% other dims = not x,y,z; e.g. volumes, coils...
nSamplesOtherDims = max(cell2mat(cellfun(@size, this.data, 'UniformOutput', false)));
nSamplesOtherDims = nSamplesOtherDims(2:end);
nOtherDims = numel(nSamplesOtherDims);
selectionStringOtherDims = repmat({':'}, 1, nOtherDims);

this.perSlice.mean = cell2mat(cellfun(@(x) mean(x,1, nanflag), this.data, ...
    'UniformOutput', false));
this.perSlice.sd = cell2mat(cellfun(@(x) std(x, [], 1, nanflag), this.data, ...
    'UniformOutput', false));
this.perSlice.snr = this.perSlice.mean./this.perSlice.sd;
this.perSlice.coeffVar = this.perSlice.sd./this.perSlice.mean;
this.perSlice.diffLastFirst = cellfun(@(x) x(:,end) - x(:,1), this.data, ...
    'UniformOutput', false);

this.perSlice.min = NaN([this.nSlices, nSamplesOtherDims]);
this.perSlice.median = NaN([this.nSlices, nSamplesOtherDims]);
this.perSlice.max = NaN([this.nSlices, nSamplesOtherDims]);
indSliceWithVoxels = cellfun(@(x) ~isempty(x), this.data);

this.perSlice.min(indSliceWithVoxels,selectionStringOtherDims{:}) = ...
    cell2mat(cellfun(@(x) min(x, [], 1), this.data, ...
    'UniformOutput', false));
this.perSlice.max(indSliceWithVoxels,selectionStringOtherDims{:}) = ...
    cell2mat(cellfun(@(x) max(x, [], 1), this.data, ...
    'UniformOutput', false));

dataVol = cell2mat(this.data);

this.perVolume.mean = mean(dataVol, nanflag);
this.perVolume.sd = std(dataVol, nanflag);
this.perVolume.snr = this.perVolume.mean./this.perVolume.sd;
this.perVolume.coeffVar = this.perVolume.sd./this.perVolume.mean;
this.perVolume.diffLastFirst = dataVol(:,end)-dataVol(:,1);
this.perVolume.min = min(dataVol);
this.perVolume.max = max(dataVol);

% Median: Matlab <= 2014a does not know the no-NaN option :-(
matlabInfo = ver('Matlab');
hasNewMedian = str2num(matlabInfo.Version) >= 8.5;

if hasNewMedian
    % does not have to be indexed, new median takes care itself
    this.perSlice.median = cell2mat(cellfun(@(x) median(x, 1, nanflag), ...
        this.data, 'UniformOutput', false));
    this.perVolume.median = median(dataVol, 1, nanflag);
    
else
    if ~ispc
        matlab_version = version('-release');
        with_output = ~strcmp(matlab_version, '2014b');
    end
    if ispc || with_output
        this.perSlice.median(indSliceWithVoxels,:) = ...
            cell2mat(cellfun(@(x) median(x, 1),...
            this.data(indSliceWithVoxels), ...
            'UniformOutput', false));
    else
        this.perSlice.median = ...
            cell2mat(cellfun(@(x) median(x, 1),...
            this.data(indSliceWithVoxels), ...
            'UniformOutput', false));
    end
    
    this.perVolume.median = median(dataVol, 1);
end

