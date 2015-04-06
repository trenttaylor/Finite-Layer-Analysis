%% FINITE LAYER ANALYSIS
% FiniteLayerAnalysis.m

% 3 Mar 2015
% Trent Taylor

%% DESCRIPTION
% This script is the main script for the finite layer analysis. Function
% calls will be handled and outputs received.

%% WORKSPACE PREPARATION
close all
clear
clc
fprintf([fileread('license'),'\n\n']);
disp('FINITE LAYER ANALYSIS');
%% INPUT PARAMETERS
disp('Getting Cross Sectional Data');
load('defaults.mat');

disp('Cross sections are stored and can be retrieved.');
sectionName = input('Input Cross Section Name:');

if (exist([sectionName,'.mat'],'file') ~= 2)
    
    % Concrete Layers
    layers_conc = getConcreteLayers(defaults.compressiveStrength);

    % Steel Layers
    layers_ps = getSteelLayers(defaults.prestressGrade);
    layers_r = getSteelLayers(defaults.steelGrade);
    
    save([sectionName,'.mat'],'layers_conc','layers_ps','layers_r');
else
    load([sectionName,'.mat']);
end

% numerical tolerances
sub_layers = 100; % number of layers to divide each layer
tolerance = .001; % tolerance factor for numerical calculations (should be less than or equal to .001)
max_iterations = 1e9; % maximum number of iterations

%% CALCULATIONS
%% Section Properties
% gross moment of inertia
% Ig = calculateMomentOfInertia(layers_conc);

temp = [layers_conc{:}];
b = max(temp.width);
d = layers_conc{1,end}.distanceToBot;
dt_ps = getSteelCentroid(layers_ps);

Mn_all = [];
phi_all = [];

%% set up test cases
test_cases{1}.eps = -.0001;
test_cases{2}.eps = 0;
test_cases{3}.eps = .0005;
test_cases{4}.eps = .001;
test_cases{5}.eps = .0015;
test_cases{6}.eps = .002;
test_cases{7}.eps = .0025;
test_cases{8}.eps = .003;

temp = [test_cases{:}];
eps_all = [temp(:).eps];

%%
i = 0;

for eps = eps_all

    %% initilization
    i = i+1;
    diff = 1;
    j = 0;
    
    %% guess c
    c = dt_ps / 2;

    h_wait = waitbar(0,'Name');
    set(h_wait,'Name',['Test Case ', num2str(i), ' eps = ',num2str(test_cases{i}.eps)]);
    
    diff_max = diff;
    
    while (diff > tolerance)
        j = j+1;
        F_conc_subLayers = [];
        F_ps_subLayers = [];
        h_subLayers = [];
        
        %% re-estimate c after first iteration
        if (j~=1 && F_conc > F_ps + F_r)
            % F_conc is too big, decrease c
            c = c - c*tolerance;
            %disp(['Re-estimating c: ',num2str(c)]);
            
            diff_max = max(diff_max,diff);
            waitbar((1-abs(diff/diff_max)),h_wait,['Current c = ', sprintf('%12.9f',c)])
            
        elseif (j~=1 && F_conc < F_ps + F_r)
            % F_conc is too small, increase c
            c = c + c*tolerance;
            %disp(['Re-estimating c: ',num2str(c)]);
        end
        
        %% curvature
        phi = eps/c;
        
        %% calculate stress & force in concrete
        for layer_c = layers_conc(1:end)
            % height of each sub layer
            h = layer_c{1}.distanceToBot - layer_c{1}.distanceToTop;
            dh = h/sub_layers;
            b = layer_c{1}.width;
            
            for subLayer = layer_c{1}.distanceToBot:-dh:layer_c{1}.distanceToTop+dh
                %% calculate stress at top & bottom using hognestead, assuming cracked behavior
                                
                strain_top = getStrainAtDepth(c-subLayer+dh,phi);
                if (strain_top < 0)
                    strain_top = 0;
                end 
                f_top = getHognestad(layer_c{1}.compressiveStrength,strain_top,eps);
                
                strain_bot = getStrainAtDepth(c-subLayer,phi);
                if (strain_bot < 0)
                    strain_bot = 0;
                end
                f_bot = getHognestad(layer_c{1}.compressiveStrength,strain_bot,eps);
                
                %% calculate force at sub layer
                F_conc_subLayers(size(F_conc_subLayers,2)+1) = dh*(f_top + f_bot)/2;
                h_subLayers(size(h_subLayers,2)+1) = c-(subLayer+dh/2);
            end
        end
        
        % sum forces
        F_conc = sum(F_conc_subLayers);
        
        %% calculate stress & force in prestress
        
        for layer_ps = layers_ps(1:end)
            
            dp = layer_ps{1}.centroid - c;
            eps_s = getStrainAtDepth(dh,phi);
            Q = .031;
            R = 7.36;
            K = 1.04;
            
            fps = getPowerFormula(eps_s, layer_ps{1}.yeildStress, layer_ps{1}.ultimateStrength, layer_ps{1}.modulus, Q, R, K);
            
            Aps = layer_ps{1}.area;
            F_ps_subLayers(size(F_ps_subLayers,2)+1) = Aps*fps;
            
        end
        F_ps = sum(F_ps_subLayers);
        
        %% calculate stress & force in passive steel
        % TODO: Implmement passive reinforcement
        F_r = 0;
        
        %% sum forces
        diff = F_conc + F_ps + F_r;
        %disp(['Error: ',num2str(diff)]);
        
        if (j > max_iterations)
            delete(h_wait);
            error('Non-converging solution. Exceeded maximum number of iterations');
        end
        
        
        
    end
    
    
    delete(h_wait);
    
    %% Calculate Moment Capacity
    Mn = dp*F_ps;
    test_cases{i}.moment = Mn;
    test_cases{i}.curvature = phi;
    
    Mn_all(size(Mn_all,2)+1) = -Mn;
    phi_all(size(phi_all,2)+1) = phi;
    
    disp(['TEST CASE COMPLETE']);
    disp(['Nominal Moment Capacity: ', num2str(test_cases{i}.moment),' kip-in']);
    disp(['Neutral Axis Depth: ', num2str(c), ' in']);
    
end 

%% RESULTS
    
    %%
    figure;
    plot(eps_all,Mn_all);
    
    figure;
    plot(phi_all,Mn_all);
    
    %%
       

disp('FINISHED!')


%% LICENSE
%{
    The MIT License (MIT)

    Copyright (c) 2015 trenttaylor

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
%}