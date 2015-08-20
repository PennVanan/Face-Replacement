function [feature_data, face_angles] = get_feature_points(im)
%Returns a CELL ARRAY. Each member of this array, feature_data{i}, contains
%   a vector [X Y]. The j'th element of this vector holds the j'th X and Y
%   feature coordinates in the i'th face detected. The length of 
%   feature_data is the number of faces detected
mc_big = init_model('big');
mc_small = init_model('small');

model_big = mc_big.model;
model_small = mc_small.model;
thresh = mc_small.thresh;


n = 0;
resize_cnt = 0;
resize_factor = 3;
while n == 0
    % the small face model is more robust, so use it first
    bs_small = detect(im, model_small, thresh);
    bs_small = clipboxes(im, bs_small);
    bs_small = nms_face(bs_small, 0.3);
    n_small = numel(bs_small);
    
    % try the big model if nothing is found
    bs_big = detect(im, model_big, thresh);
    bs_big = clipboxes(im, bs_big);
    bs_big = nms_face(bs_big, 0.3);
    n_big = numel(bs_big);

    if n_big > n_small
        n = n_big;
        bs = bs_big;
    else
        n = n_small;
        bs = bs_small;
    end
    
    if n == 0
        thresh = thresh - 0.05;
        im = imresize(im, resize_factor);
        
        if (resize_cnt * resize_factor) >= 3
            feature_data = [];
            face_angles = [];
            return
        end
        
        resize_cnt = resize_cnt + 1;
        disp(['raised model threshold to ', num2str(thresh)]);
    end
end

feature_data{n} = [];
face_angles{n} = [];

for i = 1:n
    x = (bs(i).xy(:, 1) + bs(i).xy(:, 3))/2;
    y = (bs(i).xy(:, 2) + bs(i).xy(:, 4))/2;
    
    feature_data{i} = [x y];
    resize_factor = max(1, (resize_cnt * resize_factor));
    feature_data{i} = feature_data{i} / resize_factor;
    face_angles{i} = mc_big.posemap(bs(i).c);
    disp(['face ', num2str(i), ' has angle of ', num2str(face_angles{i})]);
end