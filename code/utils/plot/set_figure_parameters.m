function fh = set_figure_parameters(fh, convfac)
% Improves default figure parameters of Matlab figure for saving and
% printing figures
%
%   fh = set_figure_parameters(fh, convfac)
%
% IN
%   fh          figure handle
%   convfac     conversion factor for figure element sizes (scaling)
%               higher means larger font size, thicker lines etc.
%               default: 2 (twice the Matlab default)
% OUT
%
% EXAMPLE
%   set_figure_parameters
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2020-10-02
% Copyright (C) 2020 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

if nargin < 2
    convfac = 2;
end

xscale = 0.5; 
yscale = 0.5;
out_width = 21*xscale;
out_height = 30*yscale;
FontName = 'Helvetica';
FontSizeText = 8;
FontSizeAxes = 8;
LineWidth = 3;
set(fh,'DefaultLineLineWidth', LineWidth*convfac/2);
set(fh,'DefaultAxesLineWidth', LineWidth*convfac/2);
set(fh,'DefaultAxesFontName', FontName);
set(fh,'DefaultAxesFontSize', FontSizeAxes*convfac);
set(fh, 'DefaultTextFontSize', FontSizeText*convfac);
set(fh, 'PaperUnits', 'centimeter');
set(fh, 'PaperPosition', [0 0 out_width out_height]*convfac);
set(fh, 'PaperSize', [out_width out_height]*convfac);