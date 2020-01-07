%Wrapper function to hold analysis code for tracing program
%To begin, select folder which contains .mi files

dir1 = uigetdir;
dir1 = dir([dir1 filesep '*.mi']);
pixel = 600/256;

for i = 1:length(dir1)
    %image1 = importdata([dir1(i).folder filesep dir1(i).name], '\t', 1);
    [Xframe,Yframe] = ginput(2);
    Xframe = int(Xframe);
    Yframe = int(Yframe);
    matrix1 = image1(Yframe(1):Yframe(2),Xframe(1):Xframe(2));
    imshow(matrix1);
    [X0,Y0] = ginput(2);
    X1 = int(X0);
    Y1 = int(Y0);
    if X1(1)>X1(2)
        X1 = [X1(2) X1(1)];
    end
    if Y1(1)>Y1(2)
        Y1 = [Y1(2) Y1(1)];
    end
%     localCoordsY = min(1,Y1(1)-3):max(Y1(2)+3, size(matrix1,1));
%     localCoordsX = min(1,X1(1)-3):max(X1(2)+3, size(matrix1,2));
%     [localMeshX, localMeshY] = meshgrid(localCoordsX, localCoordsY);
%     localMatrix = matrix1(localCoordsY, localCoordsX);
    F = griddedInterpolant(localMatrix);
    figure(); plot(linspace(X0(1),X0(2),20), F(linspace(X0(1),X0(2),20), linspace(Y0(1),Y0(2),20)));
    [xTrace,~] = ginput(1);
    yTrace = (Y0(1)-Y0(2))/(X0(1)-X0(2))*(xTrace-X0(1))+Y0(1);
    [xTrace(2), yTrace(2)] = followChain([X0(1) xTrace], [Y0(1) yTrace], F, 2);
    
end