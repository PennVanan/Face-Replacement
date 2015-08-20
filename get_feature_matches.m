function [x1, y1, x2, y2] = get_feature_matches(im1, im2, ...
    im1_pts, im2_pts)
%Calculates matching features using RANSAC. THRESH is the threshold used to
%   determine whether or not a face is close enough to be considered a
%   match

x1 = im1_pts(:, 1);
y1 = im1_pts(:, 2);
x2 = im2_pts(:, 1);
y2 = im2_pts(:, 2);

thresh = ceil((max(y2) - min(y2) + max(x2) - min(x2))/2/3);

if 1 == 1
    figure(1)
    showMatchedFeatures(im1, im2, [x1 y1], [x2 y2], 'montage');
end

[H, inliers] = ransac_est_homography(y1, x1, y2, x2, thresh);
x1 = x1(inliers);
y1 = y1(inliers);
x2 = x2(inliers);
y2 = y2(inliers);

if 1 == 1
    figure(2)
    showMatchedFeatures(im1, im2, [x1 y1], [x2 y2], 'montage');
end

end

