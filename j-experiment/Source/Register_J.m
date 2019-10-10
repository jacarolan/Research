% Basic Registration Test
% Loads an image of a J, takes it as the reference image.
% Rotates the image, registers the rotated image to reference J

dataT = -flipud(double(imread('J.png'))) + 255; %Finagle the J to look right, have 0 as background
dataT = transpose(dataT(:, :, 1)); %Image is black and white, just use the first dimension
m = size(dataT); %The dimensions of our input space
omega = [0, m(1), 0, m(2)]; %The lower/upper bounds on input by dimension
disp(m); %print Image dimensions

% setup image viewer
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');

subplot(2,3,1);
% view raw data
viewImage(dataT,omega,m,'title','Template');

dataT_rot30 = imrotate(dataT, 30, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(2,3,2);
viewImage(dataT_rot30, omega, m, 'title', 'Rotated 30 degrees');

dataT_rot60 = imrotate(dataT, 60, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(2,3,3);
viewImage(dataT_rot60, omega, m, 'title', 'Rotated 60 degrees');

dataT_rot90 = imrotate(dataT, 90, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(2,3,4);
viewImage(dataT_rot90, omega, m, 'title', 'Rotated 90 degrees');

dataT_rot120 = imrotate(dataT, 120, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(2,3,5);
viewImage(dataT_rot120, omega, m, 'title', 'Rotated 120 degrees');

dataT_rot150 = imrotate(dataT, 150, 'bicubic', 'crop');
viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
subplot(2,3,6);
viewImage(dataT_rot150, omega, m, 'title', 'Rotated 150 degrees');

% % % % % % % % % % Data Loaded % % % % % % % % % % % 

