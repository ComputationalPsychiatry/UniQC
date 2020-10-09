function formatString = get_format_string(maxValue)
% create right printf for value range, e.g., %1.0f if values 0...10, but
% %0.1f if values 0...0.9
%
%  formatString = get_format_string(maxValue)
%
% IN
%
% OUT
%
% EXAMPLE
%   get_format_string
%
%   See also sprintf fprintf
 
% Author:   Lars Kasper
% Created:  2020-10-09
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

nDecimalsBeforePoint= max(0, 1 + floor(log10(maxValue)));
nDecimalsAfterPoint = max(0, - floor(log10(maxValue)));
formatString = sprintf('%%%d.%df', nDecimalsBeforePoint, nDecimalsAfterPoint);

