function [I] = normalize_masked_area(a, b, mask)
%Normalizes the masked portion of A to match the exposure of the masked
%   portion of B

[row, col, ~] = find(mask);
face_width = max(col) - min(col);
face_height = max(row) - min(row);
krn_width = ceil((face_width + face_height) / 2 / 7);

filt = fspecial('gaussian', [krn_width krn_width], floor(krn_width/4));

for i = 1:3
    b_layer = b(:, :, i);
    b_layer = uint8(double(b_layer) .* mask);
    b_avg = mean(b_layer(b_layer > 0));
        
    
    a_layer_orig = a(:, :, i);
    a_layer = a_layer_orig;
    a_avg = mean(a_layer(a_layer > 0));
    % add point wise offsets, with some blur to make for more natural
    % transitions in the images
    b_layer = conv2(double(b_layer), filt, 'same');
    a_layer = conv2(double(a_layer), filt, 'same');
    
    b_layer_pt_diff = b_layer - b_avg;
    a_layer_pt_diff = a_layer - a_avg;
    localized_diff = b_layer_pt_diff - a_layer_pt_diff;
    a(:, :, i) = a(:, :, i) + uint8(localized_diff * .75);
    
    % now fix the average value of A to fit B
    a_layer = a(:, :, i);
    a_layer = uint8(double(a_layer) .* mask);
    a_avg = mean(a_layer(a_layer > 0));
    
    diff = b_avg - a_avg;    
    a(:, :, i) = a(:, :, i) + diff;
end

I = a;
figure(3)
imshow(I)
end