function image1 = importTxtFile(filepath,imageDim)
    file1 = importdata(filepath,'\t',219);
    data1 = file1.data;
    image1 = reshape(data1(1:prod(imageDim)),imageDim);
end