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

subplot(2,3,1);
% view raw data
viewImage(dataR,omega,m,'title','Template');

dataTs = zeros(m(1), m(2), 5);
for i = 1:5
    next = imrotate(dataR, 60 * i, 'bicubic', 'crop');
    dataTs(:, :, i) = next;
    viewImage('reset','viewImage','viewImage2D','colormap','gray(256)','axis','off');
    subplot(2,3,i+1);
    dataT = dataTs(:, :, i);
    viewImage(dataT, omega, m, 'title', 'Rotated Image');
end

for i = 1:5
    dataT = dataTs(:, :, i);

    ML = getMultilevel({dataT,dataR},omega,m,'fig',2);
    % % % % % % % % % % Data Loaded % % % % % % % % % % % 

    % Register image with multi-layer affine linear transformations
    imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-1);
    distance('reset','distance','SSD');
    trafo('reset','trafo','affine2D');

    wc = MLPIR(ML,'plotIter',0,'plotMLiter',1);
end