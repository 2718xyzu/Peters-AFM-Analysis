function [newPoint,h] = followChain(point1, point2, interpM, pixels)
%     vec1 = (point2-point1)/norm(point2-point1);
%     point2 = reshape(point2,[2 1]);
%     vec1 = reshape(vec1,[2 1]);
%     i = 1;
%     radList = -pi/3:.015:pi/3;
%     section = zeros([1 length(radList)]);
%     for rad = radList
%         additionVec = [cos(rad) -sin(rad); sin(rad) cos(rad)]*vec1*pixels;
%         section(i) = interpM(point2(2)+additionVec(2),point2(1)+additionVec(1));
%         i = i+1;
%     end
%     radFinal = sum((section).*radList/(sum(section)));
%     newPoint = point2 + [cos(radFinal) -sin(radFinal); sin(radFinal) cos(radFinal)]*vec1*pixels;
%     newPoint = newPoint';
%     h = interpM(newPoint(2),newPoint(1));


% Uncomment below to use linear section method
    vec1 = (point2-point1)/norm(point2-point1);
    testPoint = [point2(1)+pixels*vec1(1), point2(2)+pixels*vec1(2)];
    for i = 1:3
        curveParameter = 2;
        sectionX = linspace(testPoint(1)-curveParameter*pixels*vec1(2), testPoint(1)+curveParameter*pixels*vec1(2), 100);
        sectionY = linspace(testPoint(2)+curveParameter*pixels*vec1(1), testPoint(2)-curveParameter*pixels*vec1(1), 100);
        section = interpM(sectionY,sectionX);
        section = section-min(section);
        weightX = sum(sectionX.*section)/sum(section);
        weightY = sum(sectionY.*section)/sum(section);
%         [~,I] = max(section);
        testPoint = [weightX,weightY];
    end
vec2 = testPoint-point2;
vec2 = pixels*vec2./norm(vec2);
newPoint = point2+vec2;
h = interpM(newPoint(2),newPoint(1));

end

