function [newPoint,h] = followChain(point1, point2, interpM, pixels)
    vec1 = (point2-point1)/norm(point2-point1);
    testPoint = [point2(1)+pixels*vec1(1), point2(2)+pixels*vec1(2)];
    for i = 1:3
        curveParameter = 2;
        sectionX = linspace(testPoint(1)-curveParameter*pixels*vec1(2), testPoint(1)+curveParameter*pixels*vec1(2), 100);
        sectionY = linspace(testPoint(2)+curveParameter*pixels*vec1(1), testPoint(2)-curveParameter*pixels*vec1(1), 100);
        section = interpM(sectionY,sectionX);
        weightX = sum(sectionX.*section)/sum(section);
        weightY = sum(sectionY.*section)/sum(section);
%         [~,I] = max(section);
        testPoint = [weightX,weightY];
    end
newPoint = testPoint;
h = interpM(testPoint(2),testPoint(1));
end