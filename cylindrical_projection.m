function imageCylindrical = cylindrical_projection(image, K, DC)

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
% Usage: imageCylindrical = image2cylindrical(image, K, DC)
% Inputs: image - input image
%         K  - Camera intrinsic matrix (depends on the camera).
%         DC - Radial and tangential distortion coefficient.
%              [k1, k2, k3, p1, p2]
%
% Outputs: imageCylindrical - Warpped image to cylindrical coordinates

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
imageCylindrical = uint8(zeros(ydim, xdim, bypixs));

% Get the center of image
xc = xdim/2;
yc = ydim/2;

% Create X and Y coordinates grid
[X,Y] = meshgrid(1:xdim, 1:ydim);

% Perform the cylindrical projection
theta = (X - xc) / fx;
h = (Y - yc) / fy;

% Cylindrical coordinates to Cartesian
xcap = sin(theta);
ycap = h;
zcap = cos(theta);

xyz_cap = cat(3, xcap, ycap, zcap);
xyz_cap = reshape(xyz_cap,[],3);

% Normalized coords
xyz_cap_norm = (K * xyz_cap')';
xn = xyz_cap_norm(:,1) ./ xyz_cap_norm(:,3);
yn = xyz_cap_norm(:,2) ./ xyz_cap_norm(:,3);

% Radial and tangential distortion 
r = xn.^2 + yn.^2;
xd = xn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);
yd = yn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);

% Reshape and clip coordinates
xd = reshape(ceil(xd),[ydim, xdim]);
yd = reshape(ceil(yd),[ydim, xdim]);
mask = xd > 0 & xd <= xdim & yd > 0 & yd <= ydim;

% Get masked coordinates
xd = ceil(xd .* mask);
yd = ceil(yd .* mask);

% Get projections
for i = 1:ydim
    for j = 1:xdim
        if yd(i,j) ~= 0 || xd(i,j)~=0
            imageCylindrical(i,j,:) = image(yd(i,j), xd(i,j),:);
        end
    end
end

end