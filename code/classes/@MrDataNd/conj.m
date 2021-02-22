function outputImage = conj(this, varargin)
% Computes complex conjugate value per image pixel
%
%   Y = MrImage();
%   conjY = Y.conj()
%   conjY = conj(Y);
%   
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%   outputImage             complex conjugate value image   
%
% EXAMPLE
%   conjY = conj(Y)
%
%   See also MrImage MrImage.perform_unary_operation

% Author:   Saskia Klein & Lars Kasper
% Created:  2014-11-29
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%


outputImage = this.perform_unary_operation(@conj, varargin{:});