function create_video()
%Takes frames created by extract_frames and writes all of them to a video 
% file by explicitly setting the frame rate. Also records the intermediate 
% morphed frames into a folder ('target_faces/')
addpath('face-release1.0-basic/')
addpath('project2/')
addpath('project3/')

writerObj = VideoWriter('final_outputs/eternal_glory.avi');
writerObj.FrameRate = 6;
open(writerObj);
Files=dir(fullfile('frames','*.jpg'));
i = 0;

[source_faces, source_features, source_face_angles] = get_source_face_scores('source_faces/both/', '*.jpg');

for k=1:length(Files)
   f=Files(k).name;
   filename = strcat('frames/', f)
   I = imread(filename);
   disp('Processing image: ');
   disp(i);
   J = replace_all_faces(source_faces, source_features, source_face_angles, I, 1);
   filename = strcat('target_faces/video_morph_', int2str(k));
   filename = strcat(filename, '.jpg');
   imwrite(J,  filename);
   disp(size(J));
   writeVideo(writerObj,J);
   i=i+1;
end
close(writerObj);