%% A script used to generate all images for the final project. 
%% The spiffify video is also created automatically with this script
addpath('face-release1.0-basic/')
cd face-release1.0-basic/
compile
cd ..

%% Generate all face swaps for the test set
img_fmt = {'OfficialTestSet/blending/*.jpg', ...
    'OfficialTestSet/more/*.jpg', ...
    'OfficialTestSet/pose/*.jpg'};
file_paths = {'OfficialTestSet/blending/', ...
    'OfficialTestSet/more/', ...
    'OfficialTestSet/pose/'};

delete('final_outputs/face_swaps/*.jpg')
[source_faces, source_features, source_face_angles] = ... 
    get_source_face_scores('source_faces/nick/', '*.jpg');

for i = 1:numel(file_paths)
    img_list = dir(img_fmt{i});
    file_path = file_paths{i};
    for j = 1:numel(img_list)
        [~, file_name, ~] = fileparts(img_list(j).name);

        path_to_img = strcat(file_path, file_name);
        im2 = imread(path_to_img, 'jpg');

        I = replace_all_faces(source_faces, source_features, source_face_angles, im2);
        filename = strcat('final_outputs/face_swaps/morph_', img_list(j).name);
        imwrite(I, filename);
        disp(['Wrote file ', filename, ' to disk']);
    end
end

%% Generate the spiffify video
extract_frames('OfficialTestSet/video/videoclip.mp4');
create_video();