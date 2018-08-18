% Script demo_split_combine
% Demonstrates interfacing of SPM methods via splitting MrImage into ...
% array of MrImageSpm4Ds internally and combining afterwards again
% (e.g., for realign,coregister,segment,smooth)
%
%  demo_split_combine
%
%
%   See also
%
% Author:   Lars Kasper
% Created:  2018-05-04
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load high dim data from workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSamples = [48, 48, 9, 10, 3, 8];
data = randn(nSamples);
data = create_image_with_index_imprint(data);
I = MrImage(data, ...
    'dimLabels', {'x', 'y', 'z', 't', 'echo', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', 'ms', 'nil'}, ...
    'resolutions', [1.5 1.5 1 0.5 17 1], 'nSamples', nSamples);

I.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Split data into MrImageSpm4D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[splitImageArray, selectionArray] = I.split_into_MrImageSpm4D();

% pseudo-code
% % some operation on split 4D images, e.g. realgin
% rp = splitI{1}.realign();
% for iSplit=1:nSplits
%     splitImageArray{iSplit}.apply_realignmnent(rp);
% end
% 
% MrImage.combine(splitI)
% Icombined  = I.combine(splitI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Split/Combine Inversion Test dimInfo and MrImage(or DataNd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% split 
splitDims = {'echo', 'coil'};
dimInfo = I.dimInfo;
[dimInfoArray, sfxArray, selectionArray] = split(dimInfo, splitDims);

% combine
[dimInfoCombined, indSamplingPointCombined] = dimInfoArray{1}.combine(dimInfoArray);
imageCombined = splitImageArray{1}.combine(splitImageArray);