function this = MrDataNd_remove_dims(this)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   run(Y,'MrDimInfo_remove_dims')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDataNd_remove_dims
%
%   See also MrUnitTest
 
% Author:   Matthias Mueller-Schrader
% Created:  2023-01-03
% Copyright (C) 2023 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

sizes = [11,12,1,1,13];
samples = 1:prod(sizes);
dimLabels = {'a','b','c','d','e'};
units = repmat({'mm'},[1,numel(sizes)]);
iRemove = 3; % Index to remove.

mri = MrImage(reshape(samples,sizes),'dimLabels',dimLabels,'units',units);

% Adapt ranges (because of defaults):
singletonDims = mri.dimInfo.get_singleton_dimensions();
ranges = mri.dimInfo.ranges;
ranges(:,singletonDims) = 1; % So that they are all the same.
mri.dimInfo.ranges = ranges;

mri_rem_name = mri.remove_dims(dimLabels{iRemove});
mri_rem_ind = mri.remove_dims(iRemove);

% Now compare these removed dims with a new one - created with reduced dims
sizes(iRemove) = [];
dimLabels(iRemove) = [];
units(iRemove) = [];
mri_reduced = MrImage(reshape(samples,sizes),'dimLabels',dimLabels,'units',units);
% Adapt ranges (because of defaults):
singletonDims = mri_reduced.dimInfo.get_singleton_dimensions();
ranges = mri_reduced.dimInfo.ranges;
ranges(:,singletonDims) = 1; % So that they are all the same.
mri_reduced.dimInfo.ranges = ranges;


warning('off', 'MATLAB:structOnObject');
this.verifyEqual(struct(mri_rem_name),struct(mri_rem_ind),'Numeric and alphabetic index differ.');
this.verifyEqual(struct(mri_rem_name),struct(mri_reduced));
warning('on', 'MATLAB:structOnObject');

