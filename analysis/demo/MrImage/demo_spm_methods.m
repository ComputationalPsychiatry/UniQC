% Script demo_spm_methods
% Demonstrates interfacing of SPM methods via splitting MrImage into ...
% array of MrImageSpm4Ds internally (e.g., for realign,coregister,segment,smooth)
%
%  demo_spm_methods
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
%
% $Id$
%
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load high dim data from workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSamples = [48, 48, 9, 10, 3, 8];
data = randn(nSamples);
data = create_image_with_index_imprint(data);
I = MrImage(data, ...
    'dimLabels', {'x', 'y', 'z', 't', 'echo', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', 'ms', 'nil'}, ...
    'resolutions', [1.5 1.5 1 0.5 17 1]);

I.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Split data into MrImageSpm4D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[splitI, selectionArray] = I.split_into_MrImageSpm4D();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Split data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
splitDims = {'echo', 'coil'};

dimInfo = I.dimInfo;

[dimInfoArray, sfxArray, selectionArray] = split(dimInfo, splitDims);


dimInfoCombined = combine(dimInfoArray, selectionArray);
% or: sfxArray -> dimInfoExtra via dimInfo.set_from_filenames(sfxArray)
dimInfoCombined = combine(dimInfoArray, sfxArray);
