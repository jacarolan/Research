% Basic Registration Test
% Loads an image of a J, takes it as the reference image.
% Rotates the image, registers the rotated image to reference J

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

% Register image with affine linear transformations
imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-1);
level = 4; omega = ML{level}.omega; m = ML{level}.m;
[T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega,'out',0);
distance('reset','distance','SSD');
center = (omega(2:2:end)-omega(1:2:end))'/2;
trafo('reset','trafo','affine2D'); 
w0 = trafo('w0'); beta = 0; M =[]; wRef = []; % disable regularization

% initialize plots
FAIRplots('reset','mode','PIR-GN','fig',1);
FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

xc = getCellCenteredGrid(omega,m); 
Rc = imgModel(R,omega,xc);
fctn = @(wc) PIRobjFctn(T,Rc,omega,m,beta,M,wRef,xc,wc);

% optimize
[wc,his] = GaussNewton(fctn,w0,'Plots',@FAIRplots,'solver','backslash','maxIter',10);
%==============================================================================


