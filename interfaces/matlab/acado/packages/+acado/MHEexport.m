%Short one line introduction
% Longer multiline
% text explaining all features
%
% Usage:
% >> class(obj1, obj2); Explain...
% >> class(obj1); Explain...
%
% Parameters:
% obj1 explain.... [NUMERIC]
% obj2 explain.... [NUMERIC/PARAMETER]
%
% Example:
% >> an example...
%
% See also:
% acado.class.method1
% acado.class.method2
%
% Licence:
% This file is part of ACADO Toolkit  (http://www.acadotoolkit.org/)
%
% ACADO Toolkit, toolkit for Automatic Control and Dynamic Optimization.
% Copyright (C) 20082009 by Boris Houska and Hans Joachim Ferreau,
% K.U.Leuven. Developed within the Optimization in Engineering Center
% (OPTEC) under supervision of Moritz Diehl. All rights reserved.
%
% ACADO Toolkit is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 3 of the License, or (at your option) any later version.
%
% ACADO Toolkit is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with ACADO Toolkit; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 021101301 USA
%
% Author: Rien Quirynen
% Date: 2012

classdef MHEexport < acado.ExportOCP
    properties (GetAccess = 'public', SetAccess = 'protected')
        % Weighting matrices
        Q;
        Qend;
    end
    properties (SetAccess='protected')
        
        ocp;
        
        printDimQP = 0;
    end
    
    methods
        
        function obj = MHEexport(varargin)
            checkActiveModel;
            
            global ACADO_;
            ACADO_.count_other = ACADO_.count_other+1;
            obj.name = strcat(obj.name, num2str(ACADO_.count_other));
            
            if nargin == 1      % MHEexport( ocp )
                obj.ocp = varargin{1};
            else
                error('Unsupported use of the MHEexport constructor.')
            end
            
        end
        
        function printDimensionsQP(obj)
            obj.printDimQP = 1;
        end
        
        
        function getInstructions(obj, cppobj, get)
            
            if (get == 'H') % TEMPORARY FIX UNTIL MHE EXPORT IS PUBLIC
                fprintf(cppobj.fileMEX, '#include <mhe_export.hpp>\n');
                
            elseif (get == 'B')
                
                % HEADER
                if ~isempty(obj.ocp)
                    if ~acadoDefined(obj.ocp)
                        obj.ocp.getInstructions(cppobj, get);
                    end
                    fprintf(cppobj.fileMEX,sprintf('    MHEexport %s( %s );\n', obj.name, obj.ocp.name));
                else
                    error('Unable to export a MHE algorithm without an OCP formulation.');
                end
                
                % OPTIONS
                fprintf(cppobj.fileMEX,sprintf('    %s.set( GENERATE_MATLAB_INTERFACE, 1 );\n', obj.name));
                getOptions(obj, cppobj);
                
                % EXPORT
                if ~isempty(obj.dir)
                    fprintf(cppobj.fileMEX,sprintf('    %s.exportCode( "%s" );\n', obj.name, obj.dir));
                end
                
                % PRINT DIMENSIONS QP
                if obj.printDimQP
                    fprintf(cppobj.fileMEX,sprintf('    %s.printDimensionsQP( );\n', obj.name));
                end
                    
                fprintf(cppobj.fileMEX,'\n');
            end
        end
        
        
        function setMEXFiles(obj, dir)
            global ACADO_;
            if ~ischar(dir)
                error('Invalid directory name.');
            end
            ACADO_.helper.addMEX(dir, 'MHEstep.c')
        end
        
        
        function setMainFiles(obj, dir)
            global ACADO_;
            if ~ischar(dir)
                error('Invalid directory name.');
            end
            ACADO_.helper.addMain(dir, 'test.c', 'auxiliary_functions.c')
        end
        
        function setWeights(obj, varargin) % obj.setWeights(Q, S)
            if nargin ~= 3
                error('Unsupported use of the setWeights function.');
            end
            obj.Q = varargin{1};
            obj.Qend = varargin{2};
        end
        
    end
    
end
