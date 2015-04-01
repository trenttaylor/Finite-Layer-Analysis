%% FINITE LAYER ANALYSIS
% getSteelLayers.m

% 3 Mar 2015
% Trent Taylor

function [ layers ] = getSteelLayers(defaultSteelGrade)
%GETSTEELLAYERS Assembles a struct of concrete layers

%% Get number of layers
layerCount = inputdlg('Input number of layers: ');

if (str2num(layerCount{1}) == 0)
    layers = {};
    return 
end

layers{str2num(layerCount{1})} = {};

%% Get Layer Dimensions & Properties
for i = 1:str2num(layerCount{1})
    
    %% Section Dimensions
    
    prompt = {  'Input layer area [in2]: ',...
                'Input distance from top of beam to centroid of layer [in]: ',...
                'Input ultimate strength [psi]: '};
    answer = inputdlg(prompt,'STEEL INPUT - Steel Layer Properties',1,{'','',num2str(defaultSteelGrade*1000)});

    layers{i}.area = str2num(answer{1});
    layers{i}.centroid = str2num(answer{2});
    
    %% physical properties
    layers{i}.ultimateStrength = str2num(answer{3});
    
    %% Pre-stress losses
    if (layers{i}.ultimateStrength > 120000)
        answer2 = inputdlg({'Ultimate Force','Prestress Losses (decimal)','Modulus of Elasticity'},'PRESTRESS PROPERTIES',1,{num2str(layers{i}.ultimateStrength),'','28500000'});
        layers{i}.ultimateStrength = str2num(answer2{1});
        layers{i}.yeildStress = .9 * layers{i}.ultimateStrength; 
        layers{i}.prestressForce = layers{i}.ultimateStrength * .75 * (1-str2num(answer2{2}));
        layers{i}.modulus = str2num(answer2{3});
    end
end

end

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