function supertitle(stringTitle)
% Provides different fallbacks for a super title on a multi-subplot figure,
% depending on Matlab version and toolbox availability
%   sgtitle -> suptitle -> annotation('textbox');
%
%   supertitle(stringTitle)
%
% IN
%   stringTitle     one line string to be used as title
% OUT
%
% EXAMPLE
%   supertitle
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

if exist('sgtitle')
    sgtitle(stringTitle);
elseif exist('suptitle')
    suptitle(stringTitle);
else
    annotation('textbox',  [0.2, 0.9, 0.6, 0.1], ...
        'string', stringTitle, 'FitBoxToText', 'on', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 14);
end