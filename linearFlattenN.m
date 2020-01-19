function [flattened, normalized] = linearFlattenN(matrix)
%Performs first-order flattening (remove linear components of tilt)
%and normalizes all values of a matrix to be between 0 and 1
flattened = matrix;
N = numel(matrix);
[X,Y] = meshgrid(1:size(matrix,2),1:size(matrix,1));
B = [ones(N,1) X(:) Y(:) ] \ matrix(:);
for i = 1:size(matrix,1)
    for j = 1:size(matrix,2)
        flattened(i,j) = matrix(i,j)-(B(2)*X(i,j)+B(3)*Y(i,j)+B(1));
    end
end
normalized = (flattened-min(flattened(:)))./(max(flattened(:))-min(flattened(:)));

end