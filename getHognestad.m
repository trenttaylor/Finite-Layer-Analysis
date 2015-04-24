%% FINITE LAYER ANALYSIS
% getHognestad.m

% 3 Apr 2015
% Trent Taylor

%% DESCRIPTION
% This function is the Hognestead equation for determining the stress at a
% given strain.

function [ value ] = getHognestad( fc, eps, Ec, eps_0 )
%GETHOGNESTAD gets stress at a given strain


%% Hognestad equation
fr = 7.5*sqrt(abs(fc));

eps_r = fr/Ec;

fcc = fc.*((2.*-.003)./eps_0 - (-.003./eps_0).^2);

if eps > 2*eps_r
    value = 0;
elseif eps > eps_r
    value = fr*(1-((eps-eps_r)/eps_r));
elseif eps > 0
    value = fr*(eps/eps_r);
elseif eps > eps_0
    value = fc.*((2.*eps)./eps_0 - (eps./eps_0).^2); 
elseif eps > -.04
    
    eps_50u = (3+.002*abs(fc))/(abs(fc)-1000);
    eps_c0 = .002;
    z = .5/(eps_50u-eps_c0);
    
    value = fc*(1-z*(abs(eps)-eps_c0)); % Kent & Park
    if value > 0
        value = 0;
        return
    end
else
    value = 0;
end

% Hognestad, E., Hanson, N. W., & McHenry, D. (1955, December). 
% Concrete stress distribution in ultimate strength design. In ACI 
% Journal Proceedings (Vol. 52, No. 12). ACI.


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