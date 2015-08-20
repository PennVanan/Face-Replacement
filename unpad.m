function [ im ] = unpad( im )
%Removes black borders from an image

r = im(:, :, 1);
g = im(:, :, 2);
b = im(:, :, 3);

mask = r > 0; % Mask is bright stuff.
% Fill in the body
% mask = imfill(mask, 'holes'); % Mask is whole solid body.
% % OR it in with the zeros
mask = mask | (r == 0); % Mask now includes pure zeros.
% Extract pixels that are not masked
im(:, :, 1) = r(~mask);
im(:, :, 2) = g(~mask);
im(:, :, 3) = b(~mask);

end

