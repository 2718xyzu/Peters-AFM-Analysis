function image1 = importTxtFile(filepath,imageDim)
for line = 218:221
    try
    file1 = importdata(filepath,'\t',line); %NOTE: some of the files randomly have more or fewer
    %header lines.  So change to a few different values, if an error occurs, until one works. 
    data1 = file1.data;
    image1 = reshape(data1(1:prod(imageDim)),imageDim);
    return
    catch
    end
end
assert(isfile(filepath)); %at this point the file itself probably doesn't exist
%I guess if you get past that last line, it's a real file, but it's not an
%mi file export (at least, not one I've run across before).  
end
