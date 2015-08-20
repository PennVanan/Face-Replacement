function [face_img_warped] = get_warped_face(face, scene, h)

face_tform = projective2d(h');
scene_tform = projective2d(eye(3));

% find the maximum/minimum dimensions. initialized with dummy values to
% ensure good values replace them in the for loop
x_world_lim = [100000000.0, 0.0];
y_world_lim = [100000000.0, 0.0];


% outputLimits returns the max/min x/y location taken up by an image
% after being put through a transformation. the locations are based off
% of the coordinate system it is being transformed into

% output limits of face
[limx limy] = outputLimits(face_tform, ...
                        [1 size(face, 2)], ...
                        [1 size(face, 1)]);
x_world_lim(1) = min(x_world_lim(1), limx(1));
x_world_lim(2) = max(x_world_lim(2), limx(2));
y_world_lim(1) = min(y_world_lim(1), limy(1));
y_world_lim(2) = max(y_world_lim(2), limy(2));

% output limits of scene
[limx limy] = outputLimits(scene_tform, ...
                        [1 size(scene, 2)], ...
                        [1 size(scene, 1)]);
x_world_lim(1) = min(x_world_lim(1), limx(1));
x_world_lim(2) = max(x_world_lim(2), limx(2));
y_world_lim(1) = min(y_world_lim(1), limy(1));
y_world_lim(2) = max(y_world_lim(2), limy(2));

% begin constructing the destination space
w = ceil(x_world_lim(2) - x_world_lim(1));
h = ceil(y_world_lim(2) - y_world_lim(1));
mosaicImRef = imref2d([h w], x_world_lim, y_world_lim);

% warp into destination space
face_img_warped = imwarp(face, face_tform, 'OutputView', mosaicImRef);
end

