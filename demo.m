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
if add_grid == 1
    image(1:25:ydim,:,:) = 255;       %# Change every tenth row to white
    image(:,1:25:xdim,:) = 255;       %# Change every tenth column to white
end

% Warpping
imageCylindrical_v1 = image2cylindrical_v1(image, K, distortions);
imageCylindrical_v2 = image2cylindrical_v2(image, K, distortions);
imageCylindrical_ccv = image2cylindricalConcave(image, K, distortions, 1);
imageSpherical_v1   = image2spherical_v1(image, K, distortions);
imageSpherical_v2   = image2spherical_v2(image, K, distortions);


% Show plots
figure;
subplot(2,4,1); imshow(image); title('Input image')
subplot(2,4,2); imshow(imageCylindrical_v1); title('Cylindrical projection version 1')
subplot(2,4,3); imshow(imageCylindrical_ccv); title('Cylindrical projection (concave)')
subplot(2,4,4); imshow(imageSpherical_v1); title('Spherical projection version 1')

subplot(2,4,5); imshow(image); title('Input image')
subplot(2,4,6); imshow(imageCylindrical_v2); title('Cylindrical projection version 2')
subplot(2,4,7); imshow(imageCylindrical_ccv); title('Cylindrical projection (concave)')
subplot(2,4,8); imshow(imageSpherical_v2); title('Spherical projection version 2')
