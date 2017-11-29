function d = matRad_backProjection(w,dij,options)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad back projection function to calculate the current dose-,effect- or
% RBExDose- vector based on the dij struct.
% 
% call
%   d = matRad_backProjection(w,dij,options)
%
% input
%   w:       bixel weight vector
%   dij:     dose influence matrix
%   options: option struct defining the type of optimization
%
% output
%   d:       dose vector, effect vector or RBExDose vector 
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2016 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global matRad_global_x;
global matRad_global_d;

if isequal(w,matRad_global_x)
    
    % get dose from global variable
    d = matRad_global_d;
    
else
    
    matRad_global_x = w;
    
    % pre-allocation
    d = cell(options.numOfScen,1);
    
    % Calculate dose vector
    
    if ~options.bioOpt
       if isequal(options.model,'none')

           for i = 1:length(options.ixForOpt)
               d{i} = dij.physicalDose{options.ixForOpt(i)} * w;
           end

       elseif  isequal(options.model,'constRBE')

           for i = 1:length(options.ixForOpt)
                d{i} =  dij.physicalDose{options.ixForOpt(i)} * (w * dij.RBE);
           end
       end
    else
        
        for i = 1:length(options.ixForOpt)
            
            % calculate effect
            linTerm  = dij.mAlphaDose{options.ixForOpt(i)} * w;
            quadTerm = dij.mSqrtBetaDose{options.ixForOpt(i)} * w;
            e        = linTerm + quadTerm.^2;   

            if isequal(options.quantityOpt,'effect')
                d{i} = e;
            elseif isequal(options.quantityOpt,'RBExD')
                % calculate RBX x dose
                d{i}             = zeros(dij.numOfVoxels,1);
                d{i}(dij.ixDose) = sqrt((e(dij.ixDose)./dij.betaX(dij.ixDose))+(dij.gamma(dij.ixDose).^2)) ...
                                    - dij.gamma(dij.ixDose);
            else
               error('matRad: Cannot optimze this quantity')
            end
            
        end       
       
    end   
    
    matRad_global_d = d;
    
end

end

