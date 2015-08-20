function [x y] = get_cascade_features(im)

detectors = {%vision.CascadeObjectDetector('FrontalFaceCART'));, ...
vision.CascadeObjectDetector('LeftEyeCART'), ...
vision.CascadeObjectDetector('RightEyeCART'), ...
vision.CascadeObjectDetector('Nose')};
n = numel(detectors);

% Build up a set of control points corresponding to each detector
% output, to be used for RANSAC. This is not a very efeceient way to do
% this, but for prototyping, I think its OK
x = [];
y = [];

for i = 1:n
    bboxes = step(detectors{i}, im);
    % not all detectors find a match, so we need to check that both did
    num_matches = size(bboxes, 1);
    if num_matches > 0
        for j = 1:num_matches
            x = [x ; bboxes(j, 1)];
            y = [y ; bboxes(j, 2)];
            x = [x ; bboxes(j, 1) + bboxes(j, 3)];
            y = [y ; bboxes(j, 2) + bboxes(j, 4)];
        end
    end
end