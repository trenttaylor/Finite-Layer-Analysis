%% FINITE LAYER ANALYSIS
% getSteelLayers.m

% 3 Mar 2015
% Trent Taylor

function [ output_args ] = calculateMomentOfInertia( layers )
%CALCULATEMOMENTOFINERTIA Summary of this function goes here
%   Detailed explanation goes here

%% Extract Data
A_total = 0;
Ay_total = 0;

for i = 1:size(layers,2)
    
    b(i) = layers{i}.width;
    h(i) = layers{i}.height;
    y_bar(i) = layers{i}.distanceToMid;
    
end

%% Find Neutral Axis

A = b.*h;
Ay = A.*y_bar;

y_bar_gross = Ay/A;

%% Find Ig
bh3 = b.*(h).^3;
Ad2 = A.*(y_bar).^2;

Ig_sec = bh3+Ad2;

Ig = sum(Ig_sec);
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