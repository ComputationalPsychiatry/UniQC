% Script demo_concat
% Concatenates two 4D image time series along chosen dimension (time)
%
%  demo_concat
%
%
%   See also
 
% Author:   Lars Kasper
% Created:  2019-04-14
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create two image time series with imprint of their sample indices in 
% image matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSamples = [48, 48, 9, 32];
data = randn(nSamples);
data = create_image_with_index_imprint(data);
I = MrImage(data, ...
    'dimLabels', {'x', 'y', 'z', 't'}, ...
    'units', {'mm', 'mm', 'mm', 's',}, ...
    'resolutions', [6 6 12 3], 'nSamples', nSamples);
I.dimInfo.set_dims('t', 'firstSamplingPoint', 0); % starting at t = 0;

I.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);

I1 = I.select('t', 1:17);
I2 = I.select('t', 18:32);

I3 = I.select('t', 1:17, 'z', 1:4);
I4 = I.select('t', 18:32, 'z', 5:9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pedestrian example: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Split in image array along a) time ( b) and slice) dimension

% a) split along time
I1Array = I1.split('splitDims', 't');
I2Array = I2.split('splitDims', 't');

% b) 2D split
I3Array = I3.split('splitDims', {'z','t'});
I4Array = I4.split('splitDims', {'z','t'});

% Combine all image arrays and reconcatenate!
% Note that not the order here will be important, but the actual value of
% the slice position in dimInfo

% a) concat along time 
IArray = [I2Array;I1Array]; 

IConcat = IArray{1}.combine(IArray, 't');
IConcat.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);

% b) 2D example: time and slices
IArray = [I3Array(:);I4Array(:)]; 

IConcat = IArray{1}.combine(IArray, {'t', 'z'});
IConcat.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Using inbuilt concat function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IConcat = I1.concat(I2, 't');
IConcat.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);

IConcat = I3.concat(I4, {'t', 'z'});
IConcat.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);
