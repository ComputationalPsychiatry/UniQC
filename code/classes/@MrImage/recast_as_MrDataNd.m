function recastMrDataNd = recast_as_MrDataNd(this)
% down-casts an MrImage as MrDataNd
%
%   Y = MrImage()
%   Yas4D = Y.recast_as_MrDataNd(inputs)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   recast_as_MrDataNd
%
%   See also MrImage

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2021-10-28
% Copyright (C) 2021 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.



recastMrDataNd = MrDataNd();
recastMrDataNd.update_properties_from(this);

% house keeping: rename, if default name was used before, add info
% about recast
if strcmp(recastMrDataNd.name, 'MrImage')
    recastMrDataNd.name = 'MrDataNd';
end
recastMrDataNd.info{end+1,1} = 'recast_as_MrDataNd';