function imageSpherical = spherical_projection(image, K, DC)

%%***********************************************************************%
%*                   Image to spherical projection                      *%
%*              Projects normal image to a spherical warp               *%
%*                                                                      *%
%* Code author: Preetham Manjunatha                                     *%
%* Github link: https://github.com/preethamam
%* Date: 08/02/2021                                                     *%
%************************************************************************%
%
%************************************************************************%
%
% Usage: imageSpherical = image2spherical(image, K, DC)
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

% Initialize an array
imageSpherical = uint8(zeros(ydim, xdim, bypixs));

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

xyz_cap = cat(3, xcap, ycap, zcap);
xyz_cap = reshape(xyz_cap,[],3);

% Normalized coords
xyz_cap_norm = (K * xyz_cap')';
xn = xyz_cap_norm(:,1) ./ xyz_cap_norm(:,3);
yn = xyz_cap_norm(:,2) ./ xyz_cap_norm(:,3);

% Radial and tangential distortion
r = xn.^2 + yn.^2;
xd_r = xn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);
yd_r = yn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);

xd_t = 2 * p1 * xn .* yn + p2 * (r.^2 + 2 * xn.^2);
yd_t = p1 * (r.^2 + 2 * yn.^2) + 2 * p2 * xn .* yn;

xd = xd_r + xd_t;
yd = yd_r + yd_t;

% Get the clipped mask
xd = reshape(xd,[ydim, xdim]);
yd = reshape(yd,[ydim, xdim]);
mask = xd > 0 & xd <= xdim & yd > 0 & yd <= ydim;

% Get masked coordinates
xd = ceil(xd .* mask);
yd = ceil(yd .* mask);

% Get projections
for i = 1:ydim
    for j = 1:xdim
        if yd(i,j) ~= 0 || xd(i,j)~=0
            imageSpherical(i,j,:) = image(yd(i,j), xd(i,j),:);
        end
    end
end

end

