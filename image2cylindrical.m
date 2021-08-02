function imageCylindrical = image2cylindrical(image, f, k1, k2, k3)

%%***********************************************************************%
%*                   Image to cylindrical projection                    *%
%*           Projects normal image to a cylindrical warp                *%
%*                                                                      *%
%* Code author: Preetham Manjunatha                                     *%
%* Github link: https://github.com/preethamam
%* Date: 08/02/2021                                                     *%
%************************************************************************%
%
%************************************************************************%
%
% Usage: imageCylindrical = image2cylindrical(image, f, k1, k2, k3)
% Inputs: image - input image
%         f  - focal length in pixels (typically varies from 200 t0 800)
%              highly depends on the camera.
%         k1 - Radial distortion coefficient.
%         k2 - Radial distortion coefficient.
%         k3 - Radial distortion coefficient.
%
% Outputs: imageCylindrical - Warpped image to cylindrical coordinates

% Get image size
[ydim, xdim, bypixs] = size(image);

% Initialize an array
imageCylindrical = uint8(zeros(ydim, xdim, 3));

% Get the center of image
xc = round(xdim/2);
yc = round(ydim/2);

% Create X and Y coordinates grid
[X,Y] = meshgrid(1:xdim, 1:ydim);

% Perform the cylindrical projection
theta = (X - xc)/f;
h = (Y - yc)/f;

% Cylindrical coordinates to Cartesian
xcap = sin(theta);
ycap = h;
zcap = cos(theta);
xn = xcap ./ zcap;
yn = ycap ./ zcap;
r = xn.^2 + yn.^2;

% Lens distortion addition 
xd = xn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);
yd = yn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);

% Convert to floor
ximg = floor(f * xd + xc);
yimg = floor(f * yd + yc);

% Find boundary of the cylindrical projection
region = (ximg > 0 & ximg <= xdim & yimg > 0 & yimg <= ydim);

% Temporary variables
imtmp  = reshape(image,[], size(image,3));
outtmp = reshape(imageCylindrical, [], size(imageCylindrical,3));
outtmp(region,:) = imtmp(region,:);

% Get projections
imageCylindrical(:) = outtmp(:);

clear outtmp imtmp

end

