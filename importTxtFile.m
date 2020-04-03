function image1 = importTxtFile(filepath,imageDim)
    file1 = importdata(filepath,'\t',220); %NOTE: some of the files randomly have more or fewer
    %header lines.  So change 220 to 219, or 221, if an error occurs. 
    data1 = file1.data;
    image1 = reshape(data1(1:prod(imageDim)),imageDim);
end