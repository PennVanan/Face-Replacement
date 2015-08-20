addpath('project2/')
addpath('project3/')
addpath('face-release1.0-basic/')
close all
%% Face replacement attempt
mc = init_model;
im1 = imread('test_images/nick', 'jpg');
im2 = imread('test_images/easy/inception-shared-dreaming', 'jpg');

% normalize image sizes with padding
[im1, im2] = padToSameSize(im1, im2);
im1_feat_pts = get_feature_points(im1, mc);
im2_feat_pts = get_feature_points(im2, mc);

%% NMI
tmp = im1_feat_pts{1};
x1 = tmp(:, 1);
y1 = tmp(:, 2);
tmp = im2_feat_pts{1};
x2 = tmp(:, 1);
y2 = tmp(:, 2);

assert(numel(x1) == numel(y1));
assert(numel(x2) == numel(y2));
min_matches = min([numel(x1) numel(x2)]);
max_matches = max([numel(x1) numel(x2)]);

% make arrays the same size
if numel(x1) == min_matches
    x1 = [x1 ; zeros(max_matches - min_matches, 1)];
    y1 = [y1 ; zeros(max_matches - min_matches, 1)];
else
    x2 = [x2 ; zeros(max_matches - min_matches, 1)];
    y2 = [y2 ; zeros(max_matches - min_matches, 1)];
end
%%

[x1, y1, x2, y2] = get_feature_matches(im1, im2, ...
                                    [x1 y1], [x2 y2], 100);
                                
% mask = get_inhull_matrix(warp, [x1 y1]);
% mask_orig = mask;
% for px = 1:4
%     mask = max(mask, circshift(mask, [px px]));
%     mask = max(mask, circshift(mask, [px -px]));
%     mask = max(mask, circshift(mask, [-px px]));
%     mask = max(mask, circshift(mask, [-px -px]));
% end
% mask = mask - mask_orig;

% we can limit the feature points used for warping to the hull points. This
% produces a little less complex of a warp, making for a more natural face
% warp
im1_hull_pts = convhull(x2, y2); im1_hull_pts = im1_hull_pts(1:end-1);
im2_hull_pts = convhull(x2, y2); im2_hull_pts = im2_hull_pts(1:end-1);
x1 = x1(im1_hull_pts);
y1 = y1(im1_hull_pts);
x2 = x2(im2_hull_pts);
y2 = y2(im2_hull_pts);

warp = morph_tps_wrapper(im1, im2, [x1 y1], [x2 y2], 1, 0);
in_hull = get_inhull_matrix(warp, [x2 y2]);

% now we remove the face from im2, and extract just the face from warp
blended = laplacian_blend(warp, im2, in_hull);
%% visual guides for whats going on
% figure(1); clf;
% imshow(warp);
% 
% % compute if pixels are in hull or not
% figure(2); clf;
% imshow(in_hull);
% 
% im2_pts = im2_feat_pts{1};
% tri = delaunayn([x2, y2]);
% figure(3); clf;
% imshow(im2)
% hold on
% trimesh(tri, x2, y2)
% hold off
% 
% figure(4); clf;
% imshow(warp)
% hold on
% trimesh(tri, x2, y2)
% hold off
% 
% 
% figure(5); clf;
% imshow(blended);
% hold on
% trimesh(tri, x2, y2)
%%


