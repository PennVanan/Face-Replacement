function [imgs, feat_pts, angles] = get_source_face_scores(path, spec)
%Given a file path, and spec for getting images, returns a cell array of
%   images as well as a cell array of image angles, where ANGLES{i} is the
%   angle of the face from IMGS{i}. All images are assumed to have the SAME
%   size!
    addpath('face-release1.0-basic/')

    files = dir(strcat(path, spec));
    n = numel(files);
    imgs{n} = [];
    angles{n} = [];
    feat_pts{n} = [];
    
    for i = 1:n
        [~, file_name, ~] = fileparts(files(i).name);
        imgs{i} =  imread(strcat(path, file_name), 'jpg');
        [features, detected_angle] = get_feature_points(imgs{i});
        feat_pts{i} = features{1};
        angles{i} = detected_angle{1};
    end
end
