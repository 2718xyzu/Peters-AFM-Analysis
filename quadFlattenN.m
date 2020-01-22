function [flattened, normalized] = quadFlattenN(matrix)
%Performs second-order flattening (remove quadratic components of tilt)
maxX = prctile(matrix(:),70);
minN = prctile(matrix(:),30);
N = numel(matrix);
[X,Y] = meshgrid(1:size(matrix,2),1:size(matrix,1));
normals = and(minN<matrix(:), maxX>matrix(:));
fit1 = fit([X(normals),Y(normals)],matrix(normals),'poly22');
flattened = matrix-fit1(X,Y);
normalized = smartNormalize(flattened);

end