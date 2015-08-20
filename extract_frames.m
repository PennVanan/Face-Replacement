function extract_frames(movie)
% Extracts images from the given Video as .jpg files and stores them in a 
% folder('frames/') which is assumed to be already created.
clc;
close all;
 
mov = VideoReader(movie);
opFolder = fullfile(cd, 'frames');
numFrames = mov.NumberOfFrames;
numFramesWritten = 0;
 
for t = 1 : numFrames
currFrame = read(mov, t);    
opBaseFileName = sprintf('%3.3d.jpg', t);
opFullFileName = fullfile(opFolder, opBaseFileName);
imwrite(currFrame, opFullFileName, 'jpg');   
progIndication = sprintf('Wrote frame %4d of %d.', t, numFrames);
disp(progIndication);
numFramesWritten = numFramesWritten + 1;
end     
progIndication = sprintf('Wrote %d frames to folder "%s"',numFramesWritten, opFolder);
disp(progIndication); 
 