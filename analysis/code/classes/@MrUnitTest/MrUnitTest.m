classdef MrUnitTest < matlab.unittest.TestCase
    % Implements unit testing for MrClasses
    %
    % EXAMPLE
    %   MrUnitTest
    %
    %   See also
    %
    % Author:   Saskia Bollmann & Lars Kasper
    % Created:  2017-07-07
    % Copyright (C) 2017 Institute for Biomedical Engineering
    %                    University of Zurich and ETH Zurich
    %
    % This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
    % under the terms of the GNU General Public License (GPL), version 3.
    % You can redistribute it and/or modify it under the terms of the GPL
    % (either version 3 or, at your option, any later version).
    % For further details, see the file COPYING or
    %  <http://www.gnu.org/licenses/>.
    %
    % $Id: new_class2.m 354 2013-12-02 22:21:41Z kasperla $
    
    properties (TestParameter)
        dimInfoVariants = {'1', '2', '3', '4', '5'};
        
    end
    
    methods
        dimInfo = make_dimInfo_reference(this, do_save)
    end
    
    methods (Test, TestTags = {'Constructor', 'MrDimInfo'})
        
        this = MrDimInfo_constructor(this, dimInfoVariants)
        
    end % methods 'Constructor'
    
end
