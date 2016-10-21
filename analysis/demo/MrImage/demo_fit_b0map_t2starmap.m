% Script demo_fit_b0map_t2starmap
% Exemplifies use of MrImage.fit to compute parameter maps for linear phase
% and exponential magnitude decay evolution
%
%  demo_fit_b0map_t2starmap
%
%
%   See also MrImage.fit
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-11-15
% Copyright (C) 2015 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
%
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Multi-echo data, extract phase and magnitude
% 4th dimension (time) is echo time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
multiEcho = MrImage;
multiEcho.geom.TR_s = 1/1026; % is actually different TEs of multi-echo data
phaseB0 = angle(multiEcho);
absT2star = abs(multiEcho);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exponential fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if you rather want t as name for the independent variable, you can write:
% functionT2star     = fittype('a*exp(-(t/T2star))+b', 'independent', 't');
functionT2star  = 'a*exp(-x/T2star)+b';
startPoint      = [1, 25e-3, 0];


functionT2star = @(t) = a*exp(-t/T2star)+b;


T2starMap = absT2star.fit('fitType', functionT2star, 'fitDimension', ...
    4, 'startPoint', startPoint);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Linear fit and coil-weighting of phase for B0 map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
