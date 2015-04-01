%% FINITE LAYER ANALYSIS
% getSteelCentroid.m

% 16 Mar 2015
% Trent Taylor

function [ centroid ] = getSteelCentroid( layers_steel )
%GETSTEELCENTROID calculates the centroid of steel layers
%   getSteelCentroid calculates the centroid of the steel layers based off
%   of the steel structure that is input by the user.

%% Determine the total area
% cell array addressing overcomplicates accessing data, converting to
% simple matrices
temp =  [layers_steel{:}];
As_layers = [temp.area];
centroid_layers = [temp.centroid];

% sum(A*ybar)/sum(A)
centroid = sum((As_layers.*centroid_layers))/sum(As_layers);

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