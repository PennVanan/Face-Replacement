im = imread('test_images/faces', 'jpg');
level = 5;

% create initial gaussian reduction
gauss_pyramid{level} = [];
gauss_pyramid{1} = im;
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

% recreate original image
for i = level-1:1
    gauss_pyramid{i} = lap_pyramid{i} + impyramid(gauss_pyramid{i + 1}, 'expand');
end
imshow(gauss_pyramid{1})