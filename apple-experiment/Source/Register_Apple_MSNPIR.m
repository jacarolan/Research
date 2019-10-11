% Basic Registration Test
% Loads an image of a J, takes it as the reference image.
% Rotates the image, registers the rotated image to reference J
% This program uses multi-layer, which helps accuracy but not stability

dataR = -flipud(double(imread('Apple.png'))) + 255; %Finagle the Apple to look right, have 0 as background
dataR = transpose(dataR(:, :, 1)); %Image is black and white, just use the first dimension
m = size(dataR); %The dimensions of our input space
omega = [0, m(1), 0, m(2)]; %The lower/upper bounds on input by dimension
disp(m); %print Image dimensions

% setup image viewer
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');

subplot(1,2,1);
% view raw data
viewImage(dataR,omega,m,'title','Template');
dataT = -flipud(double(imread('Apple_def.png'))) + 255; %Finagle the deformed apple to look right, have 0 as background
dataT = transpose(dataT(:, :, 1));
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(1,2,2);
viewImage(dataT, omega, m, 'title', 'Rotated 60 degrees');

ML = getMultilevel({dataT,dataR},omega,m,'fig',2);
% % % % % % % % % % Data Loaded % % % % % % % % % % % 

level = 6; omega = ML{level}.omega; m = ML{level}.m; 

% initialize the interpolation scheme and coefficients
imgModel('reset','imgModel','splineInter'); 
[T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega,'out',0);
xc    = getCellCenteredGrid(omega,m); 
Tc    = imgModel(T,omega,xc);
Rc    = imgModel(R,omega,xc);

% initialize distance measure
distance('set','distance','SSD');       

% initialize regularization, note: yc-yRef is regularized, elastic is staggered 
regularizer('reset','regularizer','mbElastic','alpha',1e4,'mu',1,'lambda',0);
y0   = getStaggeredGrid(omega,m); yRef = y0; yStop = y0;


% setup and initialize plots 
FAIRplots('reset','mode','NPIR-Gauss-Newton','omega',omega,'m',m,'fig',1,'plots',1);
FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

% build objective function, note: T coefficients of template, Rc sampled reference
fctn = @(yc) NPIRobjFctn(T,Rc,omega,m,yRef,yc); fctn([]); % report status

% -- solve the optimization problem -------------------------------------------
[yc,his] = GaussNewton(fctn,y0,'maxIter',500,'Plots',@FAIRplots,'yStop',yStop,'solver','backslash');
% report results
iter = size(his.his,1)-2; reduction = 100*fctn(yc)/fctn(y0);
fprintf('reduction = %s%% after %d iterations\n',num2str(reduction),iter);

%==============================================================================
