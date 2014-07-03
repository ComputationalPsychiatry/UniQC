function this = finish_processing_step(this, module)
% finishes current processing step by deleting duplicate data and storing
% results of processing step
%
%   MrSeries = finish_processing_step(MrSeries, module)
%
% This is a method of class MrSeries.
%
% IN
%   module      'realign', 'smooth', ...
%
% OUT
%
% EXAMPLE
%   finish_processing_step
%
%   See also MrSeries
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
% $Id$

% delete additional, processed files...
fileUnprocessed = fullfile(this.data.parameters.save.path, ...
    this.data.parameters.save.fileUnprocessed);

delete(fileUnprocessed);
delete(regexprep(fileUnprocessed,'\.nii', '\.mat'));

% save files ...?!?