% Script demo_recon2image - to be excluded
% Test recon2image for multi-coil data reconstruction (TE1-FFE)
%
%   output = demo_recon2image()
%
% IN
%
% OUT
%
% EXAMPLE
%   demo_recon2image
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-11-29
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_function2.m 354 2013-12-02 22:21:41Z kasperla $

%% Load Recon
fileRecon = '/usr/ibtnas02/data-05/kasperla/MatchedFilterSpiral/data/LK332_14_11_11_MFSShapeSpeedInvivo3_9/reconTE1.mat';
load(fileRecon);


%% Load single-coil images into slices
TE1 = recon2image(reconTE1, 'coils');


%% Various Plots

% plot real part of signal
TE1.plot(); set(gcf, 'Name', 'Real part of TE1');
TE1.plot('signalPart', 'abs'); 
set(gcf, 'Name', 'Absolute value of TE1');

TE1.image2k.plot('signalPart', 'abs', 'plotMode', 'log', ...
    'displayRange', [-5 1]); 
set(gcf, 'Name', 'k-space per coil of TE1');

TE1.image2k.k2image.plot('signalPart', 'abs'); 
set(gcf, 'Name', 'Consistency check abs coil data after image2k and k2image');
