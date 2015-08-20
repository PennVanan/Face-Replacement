function [I] = replace_all_faces(source_faces, source_features, ...
    source_face_angles, im2, unique_faces_only)
% Replaces all faces in IM2 with the best matched face from SOURCE_FACES.
% SOURCE_FEATURES{i} contains the detected points for SOURCE_FACES{i}.
% SOURCE_FACE_ANGLES{i} contiains the best estimate for the angle of
% SOURCE_FACES{i}. UNIQUE_FACES_ONLY can be used if each image in the
% output should be replaced with a unique face from SOURCE_FACES

addpath('project2/')
addpath('project3/')
addpath('face-release1.0-basic/')

if nargin < 5
    unique_faces_only = 0;
end

im1 = source_faces{1};
% the image size of im2 may change during this process, so we keep an
% original copy
im2_orig_size = size(im2);
im2_orig = im2;

% resizing image 2 to the same size as image 1 helps with consistency
im2_resize_scale = ((size(im1, 1) / size(im2, 1)) + (size(im1, 2) / size(im2, 2)))/2;
if im2_resize_scale < 1
    im2_resize_scale = 1;
end
im2 = imresize(im2, im2_resize_scale);

% normalize image sizes with padding
for i = 1:numel(source_faces)
    [source_faces{i}, im2] = padToSameSize(source_faces{i}, im2);
end
[im2_feat_pts, im2_angles] = get_feature_points(im2);

% if no faces detected, return the original image
if numel(im2_feat_pts) == 0
    I = im2_orig;
    return
end

nfaces = numel(im2_feat_pts);
for i = 1:nfaces
    % gets the best matching source face to replace in the destination
    % image
    im2_angle = im2_angles{i};
    best_source_match_diff = 100000;
    best_source_match_idx = -1;
    for j = 1:numel(source_face_angles)
        angle_diff = abs(im2_angle - source_face_angles{j});
        if  angle_diff < best_source_match_diff
            best_source_match_diff = angle_diff;
            best_source_match_idx = j;
        end
    end
    im1 = source_faces{best_source_match_idx};
    im1_feat_pts = source_features{best_source_match_idx};

    
    % the try catch is to prevent a false face detection from crashing the
    % program
    try
        x1y1 = im1_feat_pts;
        x1 = x1y1(:, 1);
        y1 = x1y1(:, 2);

        x2y2 = im2_feat_pts{i};
        x2 = x2y2(:, 1);
        y2 = x2y2(:, 2);

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

        [x1, y1, x2, y2] = get_feature_matches(im1, im2, ...
                                            [x1 y1], [x2 y2]);
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
        warp = normalize_masked_area(warp, im2, in_hull);
        im2_with_face = laplacian_blend(warp, im2, in_hull);
        % the size of im2 may have changed in laplacian_blend, so we need
        % to fix it here by copying back into the original im2
        to_copy = min(size(im2), size(im2_with_face));
        im2(1:to_copy(1), 1:to_copy(2), :) = im2_with_face(1:to_copy(1), 1:to_copy(2), :);
        
        if unique_faces_only == 1
            source_faces{best_source_match_idx} = -100000000;
        end
        
    catch
        disp('False face detected')
    end
end
% now, shrink to the original size again
im2 = imresize(im2, 1/im2_resize_scale);

% remove padding. note that, due to the laplacian pyramid, im2 may have
% shrunk. So we need to copy the blended image back into the source image,
% so we preserve the whole size
im2_new_size = size(im2);
to_copy = min(im2_new_size, im2_orig_size);
im2_orig(1:to_copy(1), 1:to_copy(2), :) = im2(1:to_copy(1), 1:to_copy(2), :);
I = im2_orig;
end