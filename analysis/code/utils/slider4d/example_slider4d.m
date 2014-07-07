function varargout = example_slider4d()
%creates 4D dataset numerically and runs slider4d to show capability of it
%
%    example_slider4d()
%
% IN
%
% OUT
%
% EXAMPLE
%   example_slider4d
%
%   See also
%
% Author: Lars Kasper
% Created: 2013-05-15
% Copyright (C) 2013 Institute for Biomedical Engineering, ETH/Uni Zurich.
% $Id$

% parameter specs, create shepp logan phantom
nX = 64;
nY = nX;
nSli = 32;
nDyn = 20;

P = phantom('Modified Shepp-Logan',nX);


% create different slices via shift
Y = zeros(nX,nY,nSli,1);
for iSli = 1:nSli
    Y(:,:,iSli,1) = circshift(P, iSli*floor(nX/nSli));
end

% replicate over number of dynamics and add some noise to make them
% different
Y = repmat(Y, [1 1 1 nDyn]) + 0.05*max(Y(:))*randn(nX,nY,nSli,nDyn);

% perform 3D-trafo to get Y ... deprecated, now done automatically in
% slider4d
% Y = permute(Y, [1 2 4 3]); % 3rd dimension dynamics, 4th dimension slices
% Y = reshape(Y,[nX, nY, nSli*nDyn]);

slider4d(Y, @plot_image_diagnostics, nSli);

if nargout > 1
    varargout{1} = Y;
end