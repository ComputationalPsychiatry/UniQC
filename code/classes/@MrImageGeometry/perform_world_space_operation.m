function [dimInfo, NewAffineTrafo] = ...
    perform_world_space_operation(this, operation, parameters, dimInfo)
% Computes new dimInfo and affineTrafo
%
%   Y = MrImageGeometry()
%   Y.shift(inputs)
%
% This is a method of class MrImageGeometry.
%
% IN
%
% OUT
%
% EXAMPLE
%   shift
%
%   See also MrImageGeometry

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-12-12
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


%% compute affine transformation matrix

switch operation
    % shift
    case 'shift'
        P = [parameters, 0, 0, 0, 1, 1, 1, 0, 0, 0];
        operationMatrix = uniqc_spm_matrix(P);
        
        % rotation
    case 'rotation'
        P = [0, 0, 0, parameters*180/pi, 1, 1, 1, 0, 0, 0];
        operationMatrix = uniqc_spm_matrix(P);
        
        % zoom
    case 'zoom'
        % set all zoom parameters to 1 if no change in resolution is
        % required
        parameters(parameters == 0) = 1;
        P = [0, 0, 0, 0, 0, 0, parameters, 0, 0, 0];
        operationMatrix = uniqc_spm_matrix(P);
        
    otherwise
        error('Unknown operation.')
end

% compute new affine Matrix
affineMatrix = operationMatrix * this.get_affine_matrix();
%% add changes to dimInfo
switch operation
    % zoom
    case 'zoom'
        % in case of zoom we want to change the dimInfo, not the affine trafo
        dimInfo.x.resolutions = parameters(1);
        dimInfo.y.resolutions = parameters(2);
        dimInfo.z.resolutions = parameters(3);
end
%% compute new dimInfo and affine trafo

NewAffineTrafo = MrAffineTransformation(affineMatrix, dimInfo);

end




