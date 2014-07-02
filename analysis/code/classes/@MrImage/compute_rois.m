function rois = compute_rois(this, mask)
%computes rois for this MrImage given a cell of binary masks
%
%   output = compute_rois(input)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   compute_rois
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-01
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
    disp('gimme some masks, dude!');
end