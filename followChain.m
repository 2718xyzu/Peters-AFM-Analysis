function [newX, newY] = followChain(point1, point2, interpM, pixels)
    vec1 = point2-point1;
    testPoint = [point2(1)+pixels/norm(vec1)*vec1(1), point2(2)+pixels/norm(vec1)*vec1(2)];
    section = interpM(testPoint);

newX = point1(1)+max(section);
newY = point2(2);
end