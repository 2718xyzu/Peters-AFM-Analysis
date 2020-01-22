%Wrapper function to hold analysis code for tracing program
%To begin, select folder which contains .txt files

dirName = uigetdir;
dir1 = dir([dirName filesep '*.txt']);
imageSize = [600 600];
imageDim = [256 256];
pixel = imageSize(1)/imageDim(1);
retry = 0;

if ~exist('j','var')
    j = 1;
end

save([dirName filesep 'Backup ' int2str(sum(fix(clock)))],'*s','j');

% traces = {};
% hs = {};
% dirLists = {};


while j <= length(dir1)
    file1 = importdata([dir1(j).folder filesep dir1(j).name],'\t',219);
    data1 = file1.data;
    image1 = reshape(data1(1:prod(imageDim)),imageDim);
%     plane = griddedInterpolant([image1(1,1) image1(1,imageDim(2)); image1(imageDim(1),1) image1(imageDim(1),imageDim(2))]);
%     [tempX, tempY] = meshgrid(linspace(1,2,imageDim(2)),linspace(1,2,imageDim(1)));
%     subtractPlane = plane(tempX',tempY');
%     image1 = image1-subtractPlane;
    [flat1,image1] = quadFlattenN(image1);
    figure(); imagesc(flat1);
    %image1 = image1./max(image1(:));
    Answer = questdlg('Any things here you want to capture?');
    if strcmp(Answer,'Yes')
        [Xframe,Yframe] = ginput(2);
        Xframe = min(max(round(Xframe),[1 1]), [size(image1,2) size(image1,2)]);
        Yframe = min(max(round(Yframe), [1 1]), [size(image1,1) size(image1,1)]);
        [matrix1,image2] = quadFlattenN(flat1(Yframe(1):Yframe(2),Xframe(1):Xframe(2)));
        [surfX, surfY] = meshgrid(1:size(matrix1,2),1:size(matrix1,1));
        figure(4); surf(surfX,surfY,matrix1,'EdgeColor','none','FaceColor','interp'); hold on;
        figure(3); imagesc(matrix1); hold on;
        [X0,Y0] = ginput(4);
    %     X1 = int(X0);
    %     Y1 = int(Y0);
    %     if X1(1)>X1(2)
    %         X1 = [X1(2) X1(1)];
    %     end
    %     if Y1(1)>Y1(2)
    %         Y1 = [Y1(2) Y1(1)];
    %     end
    %     localCoordsY = min(1,Y1(1)-3):max(Y1(2)+3, size(matrix1,1));
    %     localCoordsX = min(1,X1(1)-3):max(X1(2)+3, size(matrix1,2));
    %     [localMeshX, localMeshY] = meshgrid(localCoordsX, localCoordsY);
    %     localMatrix = matrix1(localCoordsY, localCoordsX);
        F = griddedInterpolant(matrix1);
        figure(); plot(linspace(X0(1),X0(2),20), F(linspace(Y0(1),Y0(2),20), linspace(X0(1),X0(2),20)));
        clear trace h
        [trace(1,1),~] = ginput(1);
        trace(1,2) = (Y0(1)-Y0(2))/(X0(1)-X0(2))*(trace(1)-X0(1))+Y0(1);
        h(1) = F(trace(1,2),trace(1,1));
        [trace(2,:),h(2)] = followChain([X0(1) Y0(1)], [trace(1,1) trace(1,2)], F, 2);
        i = 3;
        %sideChain = (trace(2,2)>(Y0(3)+(Y0(4)-Y0(3))/(X0(4)-X0(3))*(trace(2,1)-X0(3))));
        onChain = 1;
        while onChain
            [trace(i,:),h(i)] = followChain(trace(i-2,:), trace(i-1,:), F, 2);
            if i>20
                %onChain = (sideChain==(trace(i,2)>(Y0(3)+(Y0(4)-Y0(3))/(X0(4)-X0(3))*(trace(i,1)-X0(3)))));
                %sideChain = (trace(i,2)>(Y0(3)+(Y0(4)-Y0(3))/(X0(4)-X0(3))*(trace(i,1)-X0(3))));
                inBox = (trace(i,1)>0 && trace(i,1)<size(matrix1,2)+1 && trace(i,2)>0 && trace(i,2)<size(matrix1,1)+1);
                onChain = norm([trace(i,1)-X0(3), trace(i,2)-Y0(3)])>norm([X0(3)-X0(4),Y0(3)-Y0(4)]);
                onChain = onChain && inBox;
            end
            i = i+1;
            if mod(i,1000)==0
                keyboard;
            end
            F = griddedInterpolant(matrix1);
        end
        figure(3); plot(trace(:,1),trace(:,2));
        figure(4); plot3(trace(:,1),trace(:,2),h);
        traces{length(traces)+1} = trace;
        hs{length(hs)+1} = h;
        dirLists{length(dirLists)+1} = [dir1(j).folder filesep dir1(j).name];
    elseif strcmp(Answer,'No')
        j = j+1;
%         traces{length(traces)+1} = trace;
%         hs{length(hs)+1} = h;
%         dirList{length(dirList)+1} = [dir1(j).folder filesep dir1(j).name];
        close all;
    else
        j = 100000;
    end
    keyboard;
    try
        close 3;
        close 4;
    catch
    end
end