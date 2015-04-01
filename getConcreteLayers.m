%% FINITE LAYER ANALYSIS
% getConcreteLayers.m

% 3 Mar 2015
% Trent Taylor

function [ layers ] = getConcreteLayers(compressiveStrength_default)
%GETCONCRETELAYERS Assembles a struct of concrete layers

%% Get number of layers
layerCount = inputdlg('Input number of layers: ');

layers{str2num(layerCount{1})} = {};
lastDistance = 0;

uiwait(msgbox('Define layers from top to bottom.'))

%% Get Layer Dimensions & Properties
for i = 1:str2num(layerCount{1})
    
    % Section Dimensions
    
    prompt = {  'Input layer width [in]: ',...
                'Input layer height [in]: ',...
                'Input distance from top of beam to top of layer [in]: ',...
                'Input compressive strength [psi]: '};
    answer = inputdlg(prompt,'CONCRETE INPUT - Concrete Layer Properties',1,{'','',num2str(lastDistance),num2str(compressiveStrength_default)});

    layers{i}.width = str2num(answer{1});
    layers{i}.height = str2num(answer{2});
    layers{i}.distanceToTop = str2num(answer{3});
    layers{i}.distanceToMid = layers{i}.distanceToTop + layers{i}.height / 2;
    layers{i}.distanceToBot = layers{i}.distanceToTop + layers{i}.height;
    lastDistance = layers{i}.distanceToBot;
    
    % physical properties
    layers{i}.compressiveStrength = str2num(answer{4});
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