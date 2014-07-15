classdef MrSeries < CopyData
    %Class of MR Time Series (4D = spatial coordinates:x,y,z, and time)
    %
    %
    % EXAMPLE
    %   MrSeries
    %
    %   See also
    %
    % Author:   Saskia Klein & Lars Kasper
    % Created:  2014-06-06
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
    
    properties
        % COMMENT_BEFORE_PROPERTY
        name    = 'MrSeries';
        data    = []; % MrImage(); % contains nX*nY*nZ*nT data matrix (also called data)
        
        mean    = []; % MrImage(); % mean image over volumes of time series
        sd      = []; % MrImage(); % standard deviation image over volumes of time series
        snr     = []; % MrImage(); % signal-to-noise ratio (snr) image over volumes of time series
        coeffVar = []; % MrImage(); % coefficient of variation
        % difference image between first and last volume of time series
        diffLastFirst = []; % MrImage();
        
        anatomy = []; % MrImage();  % anatomical image for reference
        tpms    = {} %cell of MrImages, tissue probability maps
        masks   = {}; % cell of MrImages
        rois    = {}; % cell of MrRois
        processing_log = {};
        svnVersion = '$Rev$'; % code version
        nProcessingSteps = 0;
        
        % General linear model
        glm     = []; % MrGlm();
        
        % parameters for all complicated methods
        parameters = ...
            struct(...
            'compute_stat_images', ...
            struct( ...
            'selectedVolumes', Inf ...
            ), ...
            'realign', ...
            struct( ...
            'quality', 0.9 ...
            ), ...
            'smooth', struct('fwhmMillimeters', 8), ...
            'create_masks', ...
            struct( ...
            'source', {}, ...
            'threshold', 0.9 ...
            ), ...
            'extract_rois', ...
            struct( ...
            'mode',  'statImages' ... % 'statImages', 'timeseries4d'
            ), ...
            't_filter', ...
            struct( ...
            'cutoffSeconds', 128 ...
            ), ...
            'save', ...
            struct( ...
            'path', '', ...
            'format', 'nii', ...
            'items', 'all' ... % items to save: 'none', 'all', 'object'
            ) ...
            );
        
    end % properties
    
    
    methods
        
        % Constructor of class
        function this = MrSeries(fileName, varargin)
            if exist('spm_jobman')
                % spm_jobman runs this automatically, does not have to be
                % done again here! ...only warning is generated
                % spm_jobman('initcfg');
            else
                error(sprintf(['SPM (Statistical Parametric Mapping) Software not found.\n\n', ...
                    'Please add to Matlab path or install from http://www.fil.ion.ucl.ac.uk/spm/']));
            end
            
            % object initialization before value are altered
            %this = this@CopyData();
            
            % construct all objects that are properties of MrSeries within
            % this constructor to to avoid weird pointer Matlab bug
            % that set default values to first created object
            
            this.glm = MrGlm();
            
            % create MrImages in constructor
            % also: set default names for statistical images as properties
            [~, nameImageArray] = this.get_all_image_objects();
            for iImage = 1:numel(nameImageArray)
                this.(nameImageArray{iImage}) = MrImage();
                img =  this.(nameImageArray{iImage});
                img.name = nameImageArray{iImage};
                img.parameters.save.fileUnprocessed = ...
                    [nameImageArray{iImage} '.nii'];
            end
            
            % save path
            stringTime = datestr(now, 'yymmdd_HHMMSS');
            pathSave = fullfile(pwd, ['MrSeries_' stringTime]);
            this.set_save_path(pathSave);
          
            
            switch nargin
                case 0
                    
                otherwise
                    %somehow, all variable parameters are converted
                    %into a cell, if varargin is given directly...
                    this.load(fileName,varargin{:})
            end
        end
        
    end % methods
    
end
