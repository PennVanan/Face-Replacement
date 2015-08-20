%%
addpath('face-release1.0-basic/')
addpath('project2/')
addpath('project3/')

%% control variables
t1 = 0;     % run 'basic face detection'
t2 = 0;     % run 'facial matching with CascadeObjectDetector'
t3 = 1;     % run 'facial matching with face-release1.0-basic'
t3_homography = 1;  % run ransac option for t3
t3_tps = 0;     % run tps option for t3

%% basic face detection
if t1 == 1
    im = imread('test_images/easy/bc', 'jpg');
    fdect = vision.CascadeObjectDetector('ProfileFace');
    bboxes = step(fdect, im);
    ifaces = insertObjectAnnotation(im, 'rectangle', bboxes, 'Mouth');
    figure(2), imshow(ifaces), title('Detected faces');
end
%% facial matching with CascadeObjectDetector
%   Playing around with using RANSAC with detection results to try to find
%   feature matches between images. The general algorithm is as follows:
%       1. Build lots of detectors that recognizes faces and facial
%           features
%       2. Agregate the detection results
%       3. Run RANSAC on the proposed feature points
%       4. Calculate Transform
%
if t2 == 1
    im1 = imread('test_images/faces', 'jpg');
    im2 = imread('test_images/face2', 'jpg');
    
    face_detector = vision.CascadeObjectDetector('FrontalFaceCART');
    bboxes1 = step(face_detector, im1);
    bboxes2 = step(face_detector, im2);
    im1 = imcrop(im1, bboxes1(1, :));
    im2 = imcrop(im2, bboxes2(1, :));
    
    detectors = {vision.CascadeObjectDetector('FrontalFaceCART'), ...
        vision.CascadeObjectDetector('LeftEyeCART'), ...
        vision.CascadeObjectDetector('RightEyeCART'), ...
        vision.CascadeObjectDetector('Nose')};
    n = numel(detectors);
    
    % Build up a set of control points corresponding to each detector
    % output, to be used for RANSAC. This is not a very efeceient way to do
    % this, but for prototyping, I think its OK
    x1 = [];
    x2 = [];
    y1 = [];
    y2 = [];
    for i = 1:n
        bboxes1 = step(detectors{i}, im1);
        bboxes2 = step(detectors{i}, im2);
        
        % not all detectors find a match, so we need to check that both did
        least_matches = min([size(bboxes1, 1), size(bboxes2, 1)]);
        if least_matches > 0
            %for j = 1:size(bboxes1, 1)
            for j = 1:least_matches
                x1 = [x1 ; bboxes1(j, 1)];
                y1 = [y1 ; bboxes1(j, 2)];
                x1 = [x1 ; bboxes1(j, 1) + bboxes1(j, 3)];
                y1 = [y1 ; bboxes1(j, 2) + bboxes1(j, 4)];
            end
            %for j = 1:size(bboxes2, 1)
            for j = 1:least_matches
                x2 = [x2 ; bboxes2(j, 1)];
                y2 = [y2 ; bboxes2(j, 2)];
                x2 = [x2 ; bboxes2(j, 1) + bboxes2(j, 3)];
                y2 = [y2 ; bboxes2(j, 2) + bboxes2(j, 4)];
            end
        end
    end
%     
    thresh = 10;
    sep_thresh = 2;
    [H, inliers] = ransac_est_homography(y1, x1, y2, x2, thresh, sep_thresh);
%     y1 = [y1 ; size(im1, 1)];
%     x1 = [x1 ; size(im1, 2)];
%     y2 = [y2 ; size(im2, 1)];
%     x2 = [x2 ; size(im2, 2)];
    figure(1); clf;
    face_warped = get_warped_face(im1, im2, H);
    imshow(face_warped);
    
    figure(2); clf;
    imshow(im2);

    %display ransac
    figure(3); clf;
    showMatchedFeatures(im1, im2, [x1(inliers) y1(inliers)], ...
                                        [x2(inliers) y2(inliers)], ...
                                        'montage');
    title('showMatchedFeatures output');
    
    
    addpath('../project2/');
    figure(2); clf;
    warped_face = morph_tps_wrapper(im1, im2, [x1(inliers) y1(inliers)], [x2(inliers) y2(inliers)], 5/5, 5/5);
    imshow(warped_face);
%     figure(1); clf; hold on;
%     imshow([im1 im2]);
%     plot(x1, y1, 'b+');
%     plot(size(im1, 2) + x2, size(im1, 1) + y2, 'y+');
    
end

%% facial matching with face-release1.0-basic
% some code taken from 
if t3 == 1
    % mc is a struct that holds the model & params
    mc = init_model;
    im1 = imread('test_images/faces', 'jpg');
    im2 = imread('test_images/face2', 'jpg');
    
    im1_feat_pts = get_feature_points(im1, mc);
    im1_feat_pts = im1_feat_pts{1};
    x1 = im1_feat_pts(:, 1);
    y1 = im1_feat_pts(:, 2);
    
    im2_feat_pts = get_feature_points(im2, mc);
    im2_feat_pts = im2_feat_pts{1};
    x2 = im2_feat_pts(:, 1);
    y2 = im2_feat_pts(:, 2);

    thresh = 10;
    [H, inliers] = ransac_est_homography(y1, x1, y2, x2, thresh);
    x1 = x1(inliers);
    y1 = y1(inliers);
	x2 = x2(inliers);
    y2 = y2(inliers);
    
    % use project 3, homography techniques, to warp
    if t3_homography == 1
        figure(3); clf;
        warp = get_warped_face(im1, im2, H);
        imshow(warp);

        figure(4); clf;
        imshow(im2);

        %display ransac matchings
        figure(5); clf;
        showMatchedFeatures(im1, im2, [x1 y1], [x2 y2], 'montage');
    end
    
    % use project 2, tps technique, to warp
    if t3_tps == 1
        % add corner points as correspondences
        y1 = [y1 ; size(im1, 1)];
        x1 = [x1 ; size(im1, 2)];
        y2 = [y2 ; size(im2, 1)];
        x2 = [x2 ; size(im2, 2)];
        
        figure(4); clf;
        warp = morph_tps_wrapper(im1, im2, [x1 y1], [x2 y2], 1, 0);
        imshow(warp);
    end
    
    % get face boundary for original image
%     minX = min([x1 x2]);
%     maxX = max(x
end