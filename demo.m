clc; close all; clear;

% Inputs
fileName = 'checker.jpg';

% Add grid line
add_grid = 0;

% Focal lengths
fx = 50;
fy = 50;

% Read image
image = (imread(fileName));

% Get image size
[ydim, xdim, bypixs] = size(image);

% Camera intrinsics
K = [fx, 0, xdim/2; 0, fy, ydim/2; 0, 0, 1];

% Distortion coefficients [k1, k2, k3, p1, p2]
distortions = [0, 0, 0, 0, 0];

% Add grid line 
if add_grid
    image(1:25:ydim,:,:) = 255;       %# Change every tenth row to white
    image(:,1:25:xdim,:) = 255;       %# Change every tenth column to white
end

% Warpping
imageCylindrical    = cylindrical_projection(image, K, distortions) ;
imageSpherical      = spherical_projection(image, K, distortions);

% Show plots
figure;
subplot(1,3,1); imshow(image); title('Input image')
subplot(1,3,2); imshow(imageCylindrical); title('Cylindrical projection')
subplot(1,3,3); imshow(imageSpherical); title('Spherical projection')
