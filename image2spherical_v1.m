function imageSpherical = image2spherical_v1(image, K, DC)

%%***********************************************************************%
%*                   Image to spherical projection                      *%
%*              Projects normal image to a spherical warp               *%
%*                                                                      *%
%* Code author: Preetham Manjunatha                                     *%
%* Github link: https://github.com/preethamam
%* Date: 05/04/2024                                                     *%
%************************************************************************%
%
%************************************************************************%
%
% Usage: imageSpherical = image2spherical_v1(image, K, DC)
% Inputs: image - input image
%         K  - Camera intrinsic matrix (depends on the camera).
%         DC - Radial and tangential distortion coefficient.
%              [k1, k2, k3, p1, p2]
%
% Outputs: imageSpherical - Warpped image to spherical coordinates

% Get distrotion coefficients
fx = K(1,1);
fy = K(2,2);
k1 = DC(1);
k2 = DC(2);
k3 = DC(3);
p1 = DC(4);
p2 = DC(5);

% Get image size
[ydim, xdim, bypixs] = size(image);

% Get the center of image
xc = round(xdim/2);
yc = round(ydim/2);

% Create X and Y coordinates grid
[X,Y] = meshgrid(1:xdim, 1:ydim);

% Perform the cylindrical projection
theta = (X - xc)/fx;
phi   = (Y - yc)/fy;

% Spherical coordinates to Cartesian
xcap = sin(theta) .* cos(phi);
ycap = sin(phi);
zcap = cos(theta) .* cos(phi);

xn = xcap ./ zcap;
yn = ycap ./ zcap;

% Radial and tangential distortion
r = xn.^2 + yn.^2;
xd_r = xn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);
yd_r = yn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);

xd_t = 2 * p1 * xn .* yn + p2 * (r.^2 + 2 * xn.^2);
yd_t = p1 * (r.^2 + 2 * yn.^2) + 2 * p2 * xn .* yn;

xd = xd_r + xd_t;
yd = yd_r + yd_t;

% Convert to floor
xd = floor(fx * xd + xc);
yd = floor(fy * yd + yc);

% Reshape and clip coordinates
xd = reshape(ceil(xd),[ydim, xdim]);
yd = reshape(ceil(yd),[ydim, xdim]);
mask = xd > 0 & xd <= xdim & yd > 0 & yd <= ydim;

% Get masked coordinates
xd = xd .* mask;
yd = yd .* mask;

% Get projections
ind = sub2ind(size(image), yd(mask), xd(mask), ones(size(xd(mask))));
IC1 = zeros(ydim, xdim, 'uint8');
IC1(mask) = image(ind + 0 * ydim * xdim);

if bypixs == 1
    imageSpherical  = IC1;
else
    IC2 = zeros(ydim, xdim, 'uint8');
    IC3 = zeros(ydim, xdim, 'uint8');
    IC2(mask) = image(ind + 1 * ydim * xdim);
    IC3(mask) = image(ind + 2 * ydim * xdim);
    imageSpherical = cat(3, IC1, IC2, IC3);
end

end

