function [in_hull] = get_inhull_matrix(im, pts)
%Returns a binary mask of the convex hull of a set of points PTS on image
%   IM
pts_orig = pts;

warning off
% pts2 = zeros(size(pts));
% pts2(1, :) = pts(2, :);
% pts2(2, :) = pts(1, :);
% pts = pts2;

tri = delaunay(pts(:, 1), pts(:, 2)); 
[i, j] = ind2sub(size(im(:, :, 1)), 1:numel(im(:, :, 1)));
full_coords = [j' i'];
in_hull = ~isnan(tsearchn(pts, tri, full_coords))';
in_hull = reshape(in_hull, [size(im, 1), size(im, 2)]);
warning on

end

