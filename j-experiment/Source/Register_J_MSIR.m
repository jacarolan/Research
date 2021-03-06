% Basic Registration Test
% Loads an image of a J, takes it as the reference image.
% Rotates the image, registers the rotated image to reference J
% This program uses multi-layer, which helps accuracy but not stability

dataR = -flipud(double(imread('J.png'))) + 255; %Finagle the J to look right, have 0 as background
dataR = transpose(dataR(:, :, 1)); %Image is black and white, just use the first dimension
m = size(dataR); %The dimensions of our input space
omega = [0, m(1), 0, m(2)]; %The lower/upper bounds on input by dimension
disp(m); %print Image dimensions

% setup image viewer
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');

subplot(1,2,1);
% view raw data
viewImage(dataR,omega,m,'title','Template');
dataT = imrotate(dataR, 60, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(1,2,2);
viewImage(dataT, omega, m, 'title', 'Rotated 60 degrees');

ML = getMultilevel({dataT,dataR},omega,m,'fig',2);
% % % % % % % % % % Data Loaded % % % % % % % % % % % 

level = 7; omega = ML{level}.omega; m = ML{level}.m; 
distance('set','distance','SSD');       
regularizer('reset','regularizer','mbCurvature','alpha',1e4,'mu',1,'lambda',0);
trafo('reset','trafo','affine2D'); w0 = trafo('w0');

% the y's are used for:  y0/initial guess, yRef/regularization, yStop/stopping
y0   = getCellCenteredGrid(omega,m); yRef = y0; yStop = y0;

% discretization of scale space
theta = [logspace(3,0,4),0]; 

% initialize the interpolation scheme and coefficients
imgModel('set','imgModel','splineInter','regularizer','moments'); 
[T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega,'theta',theta(1));
xc    = getCellCenteredGrid(omega,m); 
Rc    = imgModel(R,omega,xc);

% - initialize FAIR plots
FAIRplots('set','mode','multiscale registration','fig',1);
FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

% -- the PIR pre-registration -------------------------
PIRpara = FAIRcell2struct(optPara('GN','solver','backslash','maxIter',500));
beta = 0; M = []; wRef = []; xc = getCellCenteredGrid(omega,m);
fctn = @(wc) PIRobjFctn(T,Rc,omega,m,beta,M,wRef,xc,wc); 

[wc,his] = GaussNewton(fctn,w0,PIRpara{:});
reduction = fctn(wc)/fctn(w0);
yc   = trafo(wc,getCellCenteredGrid(omega,m)); 
%yc    = grid2grid(trafo(wc,getNodalGrid(omega,m)),m,'nodal','staggered'); 
Yc = {yc}; ITER = max(his.his(:,1)); REDUCTION = reduction;
% parameter for NPIR
NPIRpara = FAIRcell2struct(optPara('NPIR-GN','maxIter',500,'Plots',@FAIRplots,'yStop',yStop));

% loop over scales
for j=1:length(theta),
  % compute representation of data on j'th scale
  [T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega,'theta',theta(j));
  xc    = getCellCenteredGrid(omega,m); 
  Rc    = imgModel(R,omega,xc);

  % build objective function and regularizer
  yRef = yc;
  fctn = @(yc) NPIRobjFctn(T,Rc,omega,m,yRef,yc);
  
  % -- solve the optimization problem -------------------------------------------
  FAIRplots('set','mode','NPIR-GN-elastic','omega',omega,'m',m,'fig',j+3,'plots',1);
  FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m));
  [yc,his]  = GaussNewton(fctn,yc,NPIRpara{:});  
  reduction = fctn(yc)/fctn(yStop);
  Yc{end+1} = yc; ITER(end+1) = max(his.his(:,1)); REDUCTION(end+1) = reduction;
end;
%==============================================================================
