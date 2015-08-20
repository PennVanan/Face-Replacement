function [model_container] = init_model(size)
%Initialize a MODEL_CONTAINER struct, which holds references to the
%   following members:
%       1. model_container.model (from the 'face-release1.0-basic' package)
%       2. model_container.posemap
%       3. model_container.thresh

if strcmp(size, 'big') == 1
    load face_p146_small.mat
elseif strcmp(size, 'small') == 1
    load face_p99.mat
else
    disp('Invalid model size specified!')
    assert(1 == 0);
end

model.interval = 5;
model.thresh = -0.3;
% model.thresh = min(-0.65, model.thresh);
%model.thresh = -10;

if length(model.components)==13 
    posemap = 90:-15:-90;
elseif length(model.components)==18
    posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
else
    error('Can not recognize this model');
end

model_container.model = model;
model_container.posemap = posemap;
model_container.thresh = model.thresh;
end