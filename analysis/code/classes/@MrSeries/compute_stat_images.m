function this = compute_stat_images(this)
% computes mean, standard deviation (sd), signal-to-noise ratio (snr)
% and coefficient of variation (1/snr) images given a 4D time series
%
%   Y = MrSeries()
%   Y.compute_stat_images(inputs)
%
% This is a method of class MrSeries.
%
% IN
%   parameters.compute_stat_images
%
% OUT
%   this.mean
%   this.snr
%   this.sd
%   this.coeff_var
%
% EXAMPLE
%   compute_stat_images
%
%   See also MrSeries MrImage MrImage.compute_stat_image
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-06
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

this.init_processing_step('compute_stat_images');
selectedVolumes = this.parameters.compute_stat_images.selectedVolumes;

% compute statistical images via MrImage method and update save-parameters
[~, nameStatImageArray] = this.get_all_image_objects('stats');

for iImage = 1:numel(nameStatImageArray)
    img = nameStatImageArray{iImage};
    parameters = this.(img).parameters;
    this.(img) = this.data.compute_stat_image(img, ...
        'selectedVolumes', selectedVolumes);
    this.(img).name = sprintf('%s (%s)', img, this.name);
    this.(img).parameters.save = parameters.save;
end

this.finish_processing_step('compute_stat_images', this.data);
