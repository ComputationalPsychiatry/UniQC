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
        data    = MrImage; % contains nX*nY*nZ*nT data matrix (also called data)
        
        mean    = MrImage; % mean image over volumes of time series
        sd      = MrImage; % standard deviation image over volumes of time series
        snr     = MrImage; % signal-to-noise ratio (snr) image over volumes of time series
        coeffVar = MrImage; % coefficient of variation
        % difference image between first and last volume of time series
        diffLastFirst = MrImage; 
        
        anatomy = MrImage;  % anatomical image for reference
        tpms    = {} %cell of MrImages, tissue probability maps
        masks   = {}; % cell of MrImages
        rois    = {}; % cell of MrRois
        processing_log = {};
        svnVersion = '$Rev$'; % code version
        nProcessingSteps = 0;
        
        % General linear model
        glm     = MrGlm;
        
        % parameters for all complicated methods
        parameters = ...
            struct(...
            'trSeconds', 2.5, ... 
            'compute_stat_images', ...
            struct( ...
            'selectedVolumes', Inf ...
            ), ...
            'realign', ...
            struct( ...
            'quality', 0.9 ...
            ), ...
            'smooth', struct('fwhmMillimeter', 8), ...
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
            'cutoffSeconds', 10 ...
            ), ...
            'save', ...
            struct( ...
            'path', pwd, ...
            'format', 'nii', ...
            'items', 'all' ...
            ) ...
            );
        
    end % properties
    
    
    methods
        
        % Constructor of class
        function this = MrSeries(fileName, varargin)
            if exist('spm_jobman')
                %TODO: how to check whether initcfg has already been
                %performed?
                spm_jobman('initcfg');
            else
                error(sprintf(['SPM (Statistical Parametric Mapping) Software not found.\n\n', ...
                    'Please add to Matlab path or install from http://www.fil.ion.ucl.ac.uk/spm/']));
            end
            
            % create default names for statistical images as properties 
            imageArray = {'data', 'mean', 'sd', 'snr', 'coeffVar', ...
                'diffLastFirst'};
            nImages = numel(imageArray);
            for k = 1:nImages
                img = imageArray{k};
                this.(img).name = img;
            end
            
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
