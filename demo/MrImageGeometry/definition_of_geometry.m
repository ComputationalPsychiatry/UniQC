% Script definition_of_geometry
% Overview of how the image geomtry is represented in uniQC
%
%  definition_of_geometry
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-09-11
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Illustration of A = T * R * Z * S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resolution_mm = [3 2 0.5];
nVoxels = [30 110 180];
FOV_mm = resolution_mm.*nVoxels;
offcentre_mm = [110 80 -40];
%rotation_deg = [0 0 15]/180*pi;
shear_mm = [0 0 0];
rotation_deg = [25 -12 5]/180*pi;
% shear_mm = [1.1 0.8 1.5];
P = [offcentre_mm rotation_deg resolution_mm shear_mm];

T  =    [1   0   0   P(1);
    0   1   0   P(2);
    0   0   1   P(3);
    0   0   0   1];

R1  =   [1   0           0           0;
    0   cos(P(4))   sin(P(4))   0;
    0  -sin(P(4))   cos(P(4))   0;
    0   0           0           1];

R2  =   [cos(P(5))   0   sin(P(5))   0;
    0           1   0           0;
    -sin(P(5))   0   cos(P(5))   0;
    0           0   0           1];

R3  =   [cos(P(6))   sin(P(6))   0   0;
    -sin(P(6))   cos(P(6))   0   0;
    0           0           1   0;
    0           0           0   1];

R   = R1*R2*R3;

Z   =   [P(7)   0       0       0;
    0      P(8)    0       0;
    0      0       P(9)    0;
    0      0       0       1];

S   =   [1      P(10)   P(11)   0;
    0      1       P(12)   0;
    0      0       1       0;
    0      0       0       1];

A = T*R*Z*S;
% origin of A
invA = inv(A);
orig = invA(1:3,4)
A * [orig;1]

p1 = [1 1 1 1]';
p2 = [12 12 12 1]';

% shear only
S*p1
S*p2

% zoom only
Z*p1
Z*p2

% rotation only
R*p1
R*p2

% translation only
T*p1
T*p2

% translation and zoom
T*Z*p1
T*Z*p2

% affine transformation
A*p1
A*p2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2) Within dimInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% only has zoom and translation
% by default, centre of block is centre of FOV
D = MrDimInfo('resolutions', resolution_mm, 'nSamples', nVoxels, ...
    'arrayIndex', [1 1 1], 'samplingPoint', -FOV_mm/2+resolution_mm/2);
DSP = [D.samplingPoints{1}(1), D.samplingPoints{2}(1), D.samplingPoints{3}(1)];
DR = D.resolutions;

DT  =   [1   0   0   DSP(1);
    0   1   0   DSP(2);
    0   0   1   DSP(3);
    0   0   0   1];

DZ   =  [DR(1)   0       0       0;
    0      DR(2)    0       0;
    0      0       DR(3)    0;
    0      0       0       1];

% affine geometry
AD = DT*DZ
% origin of AD
invAD = inv(AD);
origD = invAD(1:3,4)
% centre of block is in origin
AD*[nVoxels/2-0.5, 1]'

AD * [origD;1]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_prime = A*AD;
A * p1
A_prime / AD * p1


% changing resolution in dimInfo
D2 = D.copyobj;
D2.resolutions = D.resolutions*2;

% computing new affine geoemtry
DSP2 = [D2.samplingPoints{1}(1), D.samplingPoints{2}(1), D.samplingPoints{3}(1)];
DR2 = D2.resolutions;

DT2  =   [1   0   0   DSP2(1);
    0   1   0   DSP2(2);
    0   0   1   DSP2(3);
    0   0   0   1];

DZ2   =  [DR2(1)   0       0       0;
    0      DR2(2)    0       0;
    0      0       DR2(3)    0;
    0      0       0       1];
AD2 = DT2*DZ2
Pprime = spm_imatrix(A_prime);
Pprime(7:9) = DR2;
A_prime * AD2 * p1
