clc; close all; clear;

% Inputs
fileName = 'checker.jpg';
image = (imread(fileName));
f = 50;
k1 = 0.0;
k2 = 0.0;
k3 = 0.0;

% Warpping
imageCylindrical = image2cylindrical(image, f, k1, k2, k3);
imageSpherical = image2spherical(image, f, k1, k2, k3);

% Show plots
figure;
subplot(1,3,1); imshow(image); title('Input image')
subplot(1,3,2); imshow(imageCylindrical); title('Cylindrical projection')
subplot(1,3,3); imshow(imageSpherical); title('Spherical projection')
