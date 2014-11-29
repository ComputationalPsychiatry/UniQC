function outputImage = k2image(this, varargin)
% Computes image representation (scaled/circshifted FFT) of k-space per slice
% by applying transformKspaceToImage;
%
%   Y = MrImage();
%   k2imageY = Y.k2image(applicationDimension)
%   k2imageY = k2image(Y, applicationDimension);
%
%
% This is a method of class MrImage.
%
% NOTE: transformKspaceToImage is a function of the Recon-Code of the IBT
%       Zurich, not part of this toolbox; if transformKspaceToImage is not available, fft2 is
%       performed
%
% IN
%
%   applicationDimension    1, 2, 3, 4 or '2D'
%                           default: '2D'
%
%                           1...4
%                           data is permuted to have applicationDimension
%                           as the 4th, then 3D-transformImage2kSpace is
%                           performed
%                           
%                           '2D'
%                           slice-wise image-to-k-space operation
%
% OUT
%   outputImage             k2image part image
%
% EXAMPLE
%   k2imageY = k2image(Y)
%
%   See also MrImage MrImage.perform_unary_operation
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
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

if nargin < 2
    varargin{1} = '2D';
end

if exist('transformKspaceToImage')
    functionHandle = @transformKspaceToImage;
else
    functionHandle = @(y) ifftshift(fftn(fftshift(y)))/sqrt(numel(y));
end
outputImage = this.perform_unary_operation(functionHandle, varargin{:});