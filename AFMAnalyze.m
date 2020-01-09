%Wrapper function to hold analysis code for tracing program
%To begin, select folder which contains .mi files

% dir1 = uigetdir;
% dir1 = dir([dir1 filesep '*.mi']);
pixel = 600/256;
retry = 0;
for i = 1:length(dir1)
    if retry == 0
    %image1 = importdata([dir1(i).folder filesep dir1(i).name], '\t', 1);
    %image1 = image1./max(image1(:));
    [Xframe,Yframe] = ginput(2);
    Xframe = round(Xframe);
    Yframe = round(Yframe);
    matrix1 = image1(Yframe(1):Yframe(2),Xframe(1):Xframe(2));
    figure(3); imshow(matrix1); hold on;
    [surfX, surfY] = meshgrid(1:size(matrix1,2),1:size(matrix1,1));
    figure(4); surf(surfX,surfY,matrix1,'EdgeColor','none','FaceColor','interp'); hold on;
    [X0,Y0] = ginput(2);
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
    end
    figure(); plot(linspace(X0(1),X0(2),20), F(linspace(Y0(1),Y0(2),20), linspace(X0(1),X0(2),20)));
    clear trace h
    [trace(1,1),~] = ginput(1);
    trace(1,2) = (Y0(1)-Y0(2))/(X0(1)-X0(2))*(trace(1)-X0(1))+Y0(1);
    h(1) = F(trace(1,2),trace(1,1));
    [trace(2,:),h(2)] = followChain([X0(1) Y0(1)], [trace(1,1) trace(1,2)], F, 2.5/pixel);
    onChain = 1;
    i = 3;
    while onChain
        [trace(i,:),h(i)] = followChain(trace(i-2,:), trace(i-1,:), F, 2);
        if i>20
            onChain = mean(h(1:end-1))<2*h(i);
        end
        i = i+1;
        
        F = griddedInterpolant(matrix1);
    end
    figure(3); plot(trace(:,1),trace(:,2));
    figure(4); plot3(trace(:,1),trace(:,2),h);
    
    
end