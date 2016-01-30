function this = convert(this, newCoordinateSystem)
% Converts current geometry to new coordinate system
%
%   Y = MrImageGeometry()
%   Y.convert(newCoordinateSystem)
%
% This is a method of class MrImageGeometry.
%
% IN
%
% OUT
%
% EXAMPLE
%   Y.convert(CoordinateSystems.nifti) => overwrite current geometry values
%                                       (e.g. offcenter, rotation
%   Y.copyobj.convert(CoordinateSystems.nifti)
%   Y.convert(CoordinateSystems.scanner)
%
%   See also MrImageGeometry CoordinateSystems
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-12-09
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

switch this.coordinateSystem
    case CoordinateSystems.scanner
        switch newCoordinateSystem
            case CoordinateSystems.nifti
                this.offcenter_mm = this.offcenter_mm - ...
                    this.FOV_mm/2;
        end
    case CoordinateSystems.nifti
        switch newCoordinateSystem
            case CoordinateSystems.scanner
                this.offcenter_mm = this.offcenter_mm +...
                    + this.FOV_mm/2;
        end
end

this.coordinateSystem = newCoordinateSystem;