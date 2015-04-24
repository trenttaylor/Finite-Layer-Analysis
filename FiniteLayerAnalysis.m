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
% graph limits
eps_c_min = .0005;
eps_c_max = .004;
eps_c_inc = .0001;

plot_graphs = 'yes';

% numerical tolerances
sub_layers = 100; % number of layers to divide each layer
tolerance = .001; % tolerance factor for numerical calculations (should be less than or equal to .001)
max_iterations = 500; % maximum number of iterations

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

%% CALCULATIONS
%% Section Properties
temp = [layers_conc{:}];

b=0;

for i = 1:size(layers_conc,2)
    b = max(b,layers_conc{i}.width);
end

d = layers_conc{1,end}.distanceToBot;
dt_ps = getSteelCentroid(layers_ps);

Mn_all = [];
phi_all = [];

%% SET UP TEST CASES
test_cases{1}.eps = eps_c_min;

for eps = test_cases{1}.eps:eps_c_inc:eps_c_max
    test_cases{end+1}.eps = eps;
end

temp = [test_cases{:}];
eps_all = [temp(:).eps];

i = 0;

%% RUN ANALYSIS

for eps = eps_all

    %% Initialization
    i = i+1;
    diff = 1;
    j = 0;
    
    %% Guess c
    c = dt_ps / 2;
    % set limits for bisection
    c_toplimit = 0;
    c_botlimit = layers_conc{end}.distanceToBot;

    h_wait = waitbar(0,'Name');
    set(h_wait,'Name',['Test Case ', num2str(i), ' eps = ',num2str(test_cases{i}.eps)]);
    
    diff_max = diff;
    %diff
    %tolerance
    
    while (abs(diff) > tolerance)
        j = j+1;
        F_conc_subLayers = [];
        F_ps_subLayers = [];
        h_subLayers = [];
        f_mid = [];
        
        %% Re-estimate c after first iteration
        if (j~=1 && -F_conc > F_ps + F_r)
            % F_conc is too big, decrease c
            c_botlimit = c;
            c = .5 * (c_toplimit + c_botlimit);
            
            diff_max = max(diff_max,diff);
            waitbar((1-abs(diff/diff_max)),h_wait,['Current c = ', sprintf('%12.2f',c),' diff = ',sprintf('%12.2f',diff)])
            
        elseif (j~=1 && -F_conc < F_ps + F_r)
            % F_conc is too small, increase c
            c_toplimit = c;
            c = .5 * (c_toplimit + c_botlimit);
            
            diff_max = max(diff_max,diff);
            waitbar((1-abs(diff/diff_max)),h_wait,['Current c = ', sprintf('%12.2f',c),' diff = ',sprintf('%12.2f',diff)])
        end
        
        %% Curvature
        phi = eps/c;
        
        %% Calculate stress & force in concrete
        for layer_c = layers_conc(1:end)
            % height of each sub layer
            h = layer_c{1}.distanceToBot - layer_c{1}.distanceToTop;
            dh = h/sub_layers;
            b = layer_c{1}.width;
            
            for subLayer = layer_c{1}.distanceToTop:dh:layer_c{1}.distanceToBot-dh
                %% calculate stress at top & bottom using hognestead, assuming cracked behavior
                Ec = 57000*sqrt(layer_c{1}.compressiveStrength);
                
                strain_top = getStrainAtDepth(subLayer-c,phi);
                f_top = getHognestad(-layer_c{1}.compressiveStrength,strain_top,Ec,defaults.eps_0);
                
                strain_bot = getStrainAtDepth(subLayer+dh-c,phi);
                f_bot = getHognestad(-layer_c{1}.compressiveStrength,strain_bot,Ec,defaults.eps_0);
                
                f_mid(end+1) = .5*(f_bot+f_top);
                
                %% calculate force at sub layer             
                F_conc_subLayers(size(F_conc_subLayers,2)+1) = abs(dh)*b*(f_top + f_bot)/2;
                h_subLayers(end+1) = -subLayer-dh/2;
            end
        end
        
        % sum forces
        F_conc = sum(F_conc_subLayers);
        
        %% Calculate stress & force in prestress
        d_ps_subLayers = [];
        f_ps_subLayers = [];
        
        for layer_ps = layers_ps(1:end)
            
            e = layer_ps{1}.centroid - c;
            
            % Strain from jacking
            eps_1 = layer_ps{1}.prestressForce / (layer_ps{1}.area * layer_ps{1}.modulus);
            % Strain from concrete
            eps_2 = 0;
            
            % Elastic Shortening
            eps_c = getStrainAtDepth(e,phi);
            
            eps_s = eps_1 + eps_2 +eps_c;
            Q = .031;
            R = 7.36;
            K = 1.04;
            
            fps = getPowerFormula(eps_s, layer_ps{1}.yeildStress, layer_ps{1}.ultimateStrength, layer_ps{1}.modulus, Q, R, K);
            
            Aps = layer_ps{1}.area;
            F_ps_subLayers(end+1) = Aps*fps;
            f_ps_subLayers(end+1) = fps;
            d_ps_subLayers(end+1) = layer_ps{1}.centroid;
            
        end
        F_ps = sum(F_ps_subLayers);
        
        %% calculate stress & force in passive steel
        % TODO: Implmement passive reinforcement
        F_r = 0;
        
        %% Sum forces
        diff = F_conc + F_ps + F_r;
        %disp(['Error: ',num2str(diff)]);
        %disp(num2str(j));
        
        if (j > max_iterations)
            delete(h_wait);
            error('Non-converging solution. Exceeded maximum number of iterations');
        end
    end
    
    delete(h_wait);
    
    %% Calculate Moment Capacity
    Mn = dt_ps*F_ps;
    test_cases{i}.moment = Mn;
    test_cases{i}.curvature = phi;
    
    Mn_all(size(Mn_all,2)+1) = Mn;
    phi_all(size(phi_all,2)+1) = phi;
    
    disp(['TEST CASE COMPLETE eps = ', num2str(eps)]);
    disp(['Curvature: ', num2str(phi)]);
    disp(['Nominal Moment Capacity: ', num2str(test_cases{i}.moment),' lbf-in, ',num2str(test_cases{i}.moment/12000),' kip-ft']);
    disp(['Neutral Axis Depth: ', num2str(c), ' in']);
    disp(['Iterations Required: ', num2str(j)]);
    
    if (strcmp(plot_graphs,'yes') || strcmp(plot_graphs, 'Yes'))
        figure;
        suptitle(['Eps = ', num2str(eps)]);
        subplot(2,2,1);
        scatter(F_conc_subLayers,h_subLayers,'.');
        title('Total Force in Each Layer');

        subplot(2,2,2);
        scatter(f_mid,h_subLayers,'.');
        title('Stress');

        subplot(2,2,3);
        hold on
        scatter(F_conc_subLayers,h_subLayers,'.');   
        barh(-d_ps_subLayers,f_ps_subLayers);
        title('Force Diagram');
        hold off

        subplot(2,2,4);
        xcoords = [0,-eps,getStrainAtDepth(layers_conc{end}.distanceToBot,phi),0,0];
        ycoords = [0,0,-layers_conc{end}.distanceToBot,-layers_conc{end}.distanceToBot,0];
        line(xcoords,ycoords);
        text(0,-c,['c = ', num2str(c)]);
    end
    
end 

%% RESULTS
        
figure;
plot(phi_all,Mn_all);
title('Moment Curvature Diagram');
xlabel('Curvature [in/in]');
ylabel('Moment [lbf-in]');
ylim = get(gca,'ylim');
set(gca,'ylim',[0,ylim(2)]);
    
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