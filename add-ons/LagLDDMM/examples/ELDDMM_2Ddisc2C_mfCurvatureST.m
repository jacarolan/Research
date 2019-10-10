% =========================================================================
% This code is part of the Matlab-based toolbox 
% LagLDDDM - A Lagrangian Gauss--Newton--Krylov Solver for Mass- and 
%                        Intensity-Preserving Diffeomorphic Image Registration
% 
% For details and license info see 
% - https://github.com/C4IR/FAIR.m/tree/master/add-ons/LagLDDMM
%
% For details and license info see 
% - https://github.com/C4IR/FAIR.m/tree/master/add-ons/LagLDDMM%
% 2D Multilevel LDDMM Example using nonstationary velocity field and
% cuvature regularizer as described in Sec. 4.2 of
%
% @article{MangRuthotto2017,
%   Title = {A {L}agrangian {G}auss--{N}ewton--{K}rylov solver for mass- and intensity-preserving diffeomorphic image registration},
%   Year = {2017},
%   Journal = {SIAM Journal on Scientific Computing},
%   Author = {A. Mang, L. Ruthotto},
% }
% =========================================================================
close all; clear all; clc;
setup2Ddisc2CData

imgModel('reset','imgModel','splineInterMex','regularizer','moments','theta',.1);
alpha = [4e2 0];
parametric = 0;
pad  = .5;
nt   = 2;
N    = 3;

mV     = @(m) ceil(1*m);

minLevel = 5;
maxLevel = 7;
%% run LDDMM registration

% 1) setup grid for velocities (padded)
omegaV = omega; omegaV(1:2:end) = omegaV(1:2:end)-pad;  omegaV(2:2:end) = omega(2:2:end)+pad;

% 2) setup regularizer (and decide for stationary or nonstationary velocity)
regularizer('reset','regularizer','mfCurvatureST','nt',nt,'alpha',2*alpha/1e2,'HessianShift',1e-4); % stationary velocity

NPIRpara    = optPara('NPIR-GN');
NPIRpara.maxIter = 40;
NPIRpara.scheme = @GaussNewtonLDDMM;
[vc,~,wc,his] = MLLDDMM(ML,'minLevel',minLevel,'maxLevel',maxLevel,...
    'omegaV',omegaV,'mV',mV,'N',N,'parametric',parametric,'NPIRpara',NPIRpara,'plots',1);

%%
yc = getTrafoFromInstationaryVelocityRK4(vc,getNodalGrid(omega,m),'omega',omegaV,'m',m,'nt',nt,'tspan',[1,0],'N',N);
Topt = linearInterMex(dataT,omega,center(yc,m));
Jac = geometry(yc,m,'Jac','omega',omega);
D0  = distance(dataT(:),dataR(:),omega,m);
DOpt = distance(Topt(:),dataR(:),omega,m);

fig = figure(); clf;
fig.Name = sprintf('LDDMM Results: %s',mfilename);

subplot(2,3,1);
viewImage(dataR,omega,m);
title('reference');

subplot(2,3,4);
viewImage(dataT,omega,m);
hold on;
plotGrid(yc,omega,m,'spacing',4)
title('template');

subplot(2,3,2);
viewImage(Topt,omega,m);
title('T(yc)')

subplot(2,3,3);
viewImage(dataT(:)-dataR(:),omega,m);
title('init. residual, SSD=100%');

subplot(2,3,5);
viewImage2Dsc(Jac,omega,m);
title(sprintf('Jac, min=%1.2f max=%1.2f',min(Jac(:)),max(Jac(:))));

subplot(2,3,6);
viewImage(Topt(:)-dataR(:),omega,m);
title(sprintf('opt residual, SSD=%1.2f%%',100*DOpt/D0));
