function out = smartNormalize(matrix)
maxX = prctile(matrix,99);
minN = prctile(matrix,1);
out = (matrix-minN)./(maxX-minN);

end