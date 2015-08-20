function [blended] = laplacian_blend(a, b, mask)
%Returns a blended version of images A and B, which are assumed to be of
%   type UINT8 with 3 color channels. A mask, of type DOUBLE, should have 
%   values close to 1 for any sections of BLENDED where image A will show
%
%   The general algorithm is:
%       1. Create gaussian and laplacian pyramids of images A and B
%       2. At each level of these pyramids, mix the images according to the
%           MASK
%       3. Reconstruct the image pyramid from the gaussians and laplacians

[M, N, ~] = size(a);
level = 5;
[gauss_pyr_a, laplace_pyr_a] = get_pyramids(double(a), level);
[gauss_pyr_b, laplace_pyr_b] = get_pyramids(double(b), level);


% filtering the mask can help create a smoother transition, expecially at
% corner points
hsize = [10 10]; sigma = 3;
filt = fspecial('gaussian', hsize, sigma);
mask = conv2(double(mask), filt, 'same');
[gauss_pyr_mask, ~] = get_pyramids(double(mask), level);

% construct a blend of each image for each level, according to the masks
% constructed above. Each *_blend{i} contains the masked portions of
% A and B
gauss_blend{level} = [];
laplacian_blend{level} = [];
for p = 1:level
	[Mp, Np, ~] = size(gauss_pyr_b{p});
    
    % the mask should be rescaled at each level, otherwise the blur becomes
    % less effective as sigma shrings in relation to the sigma in the image
    % pyramid
    scaled_mask = gauss_pyr_mask{p};
    mask_a = zeros(size(scaled_mask, 1), size(scaled_mask, 2), 3);
    mask_a(:, :, 1) = scaled_mask;
    mask_a(:, :, 2) = scaled_mask;
    mask_a(:, :, 3) = scaled_mask;
    mask_b = 1 - mask_a;
    
	mask_a_resized = imresize(mask_a,[Mp Np]);
	mask_b_resized = imresize(mask_b,[Mp Np]);
    
    gauss_a = gauss_pyr_a{p} .* mask_a_resized;
    gauss_b = gauss_pyr_b{p} .* mask_b_resized;
    new_gauss = gauss_a + gauss_b;
	gauss_blend{p} = new_gauss;
    
    lap_a = laplace_pyr_a{p} .* mask_a_resized;
    lap_b = laplace_pyr_b{p} .* mask_b_resized;
    new_lap = lap_a + lap_b;
    laplacian_blend{p} = new_lap;
end
blended = reconstruct_pyramids(gauss_blend, laplacian_blend);
blended = uint8(blended);
end

function [gauss_pyramid, lap_pyramid] = get_pyramids(im, level)
% create initial gaussian reduction
gauss_pyramid{level} = [];
gauss_pyramid{1} = im;
level = level + 1;

for i = 2:level
    gauss_pyramid{i} = impyramid(gauss_pyramid{i - 1}, 'reduce');
end

% create a pyramid of expansions, which will be used to create a laplacian
% pyramid
gauss_pyramid_exp{level - 1} = [];
for i = level-1:-1:1
    % expand gaussian from the next level smaller
    gauss_im_small = gauss_pyramid{i + 1};
    gauss_pyramid_exp{i} = impyramid(gauss_im_small, 'expand');
    size_exp = size(gauss_pyramid_exp{i});

    % the expanded gaussian may be smaller than the original image, so we
    % need to normalize it
    gauss_im_big = gauss_pyramid{i};
    gauss_im_big = gauss_im_big(1:size_exp(1), 1:size_exp(2), :);
    gauss_pyramid{i} = gauss_im_big;
end

% generate the actual laplacian pyramid
lap_pyramid{level - 1} = [];
for i = 1:level-1
    lap_pyramid{i} = gauss_pyramid{i} - gauss_pyramid_exp{i};
end
end


function [img] = reconstruct_pyramids(gauss_pyramid, lap_pyramid)
level = numel(lap_pyramid);
% recreate original image
for i = level-1:-1:1
    exp_gauss = impyramid(gauss_pyramid{i + 1}, 'expand');
    gauss_pyramid{i} = lap_pyramid{i} + exp_gauss;
end
img = gauss_pyramid{1};
end
