function newPosition = convert_montage_position_to_selection(montagePosition, ...
    montageSize, dimInfoSelection)
% Converts (mouse) position in montage into x,y,z selection of plotted data
%
%    newPosition = convert_montage_position_to_selection(montagePosition, ...
%                   montageSize, dimInfoSelection))
%
% IN
%
%   dimInfoSelection    dimInfo of selected image part for montage plot
% OUT
%
% EXAMPLE
%   convert_montage_position_to_selection
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-03-28
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

nX = dimInfoSelection.nSamples('x');
nY = dimInfoSelection.nSamples('y');

montageX = montagePosition(1);
montageY = montagePosition(2);

% montageX and montageY have to be the swapped here, because 1st and second
% dimension of matlab array and displayed image are swapped as well
x = mod(round(montageY), nX);
y = mod(round(montageX), nY);

% final sample has to be set manually, because mod is between 0 and nX-1
if ~x, x = nX; end
if ~y, y = nY; end

nRows = montageSize(1);
nCols = montageSize(2);

iRow = min(max(1, ceil(montageY/nX)), nRows);
iCol = min(max(1, ceil(montageX/nY)), nCols);

iZ = (iRow-1)*nCols+iCol;

%z = dimInfoSelection.samplingPoints{'z'}(iZ);
z = iZ;
newPosition = [x y z]
