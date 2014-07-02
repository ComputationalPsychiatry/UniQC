classdef MrImage < CopyData
%An MR image (3D, 3D)
% is this shown too?
%
%   output = MrImage(input)
%
% IN
%
% OUT
%
% EXAMPLE
%   MrImage
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-04-15
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Analysis Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
properties
    n       = struct('x', 0, 'y', 0, 'z', 0); % counter structure of x,y,z dimension of data
    data    = []; % nX*nY*nZ data matrix
    rois    = []; % see also MrRoi
end
methods
 % NOTE: Most of the methods are saved in separate function.m-files in this folder;
 %       except: constructor, delete, set/get methods for properties.

 % Constructor of MrImage class. Accepts fileName input for different
    % file type
    % .nii
    % .img/.hdr
    % .mat
    % MrImage-Folder
    %
    function this = MrImage(fileName)
        
        if nargin < 1
            fileName = 'bla.nii'; % maybe default SPM canonical?
        end
        
        isMatrix = ~isstr(fileName);
        
        if isMatrix
            this.data = fileName;
        else
            [p,f,ext] = fileparts(fileName);
            switch ext
                case {'.nii', '.img','.hdr'}
                    this.load_nifti_analyze(fileName);
                case {'.mat'} % assumes mat-file contains one variable with 3D image data
                    this.data = load(fileName);
                case ''
                    if isdir(fileName) % previously saved object, load
                    else
                        error('File with unsupported extension or non-existing');
                    end
            end
                    end
           this.n.x = size(this.data,1);             
           this.n.y = size(this.data,2);             
           this.n.z = size(this.data,3);             
    
    % loads matrix into .data from nifti or analyze file using spm_read_vols 
    load_nifti_analyze(this, fileName);
    end
    
  end
end