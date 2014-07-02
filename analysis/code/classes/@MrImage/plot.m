function fh = plot(this)
%plots an MR image per slice
%
%   fh = plot2(this)
%
% IN
%
% OUT
%
% EXAMPLE
%   plot2
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-05-21
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Analysis Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
fh = figure;imagesc(this.data(:,:,1)); axis square;colormap gray
end