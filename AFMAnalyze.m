%Wrapper function to hold analysis code for tracing program
%To begin, select folder which contains .txt files

%NOTE: It's important to change these if the paramaters change.
%If they change within a dataset, guess you'll have to do some fancier
%coding to extract this data from an arbitrary file.

imageSize = [600 600];
imageDim = [256 256];
pixel = imageSize(1)/imageDim(1);
stepLength = 4;

AnS = questdlg(['Would you like to analyze a new dataset or re-analyze an old one by'...
    ' selecting its analysis package?'],'New or old?','New','Re-analyze','New');
retry = 0;
if AnS(1) == 'R'
    retry = 1;
    uiopen();
    dir1 = analysis(:).path;
    analysisO = analysis;
    analysis = struct([]);
    j = 1;
else
    if ~exist('j','var')
        j = 1;
    end
    
    if ~exist('dirName','var')
        dirName = uigetdir;
        dir1 = dir([dirName filesep '*.txt']);
    end
    
    if ~exist('analysis','var')
        analysis = struct([]);
    end
end
try
    save([dirName filesep 'zBackup ' mat2str(fix(clock))],'analysis','j');
catch
    warning('Unable to save backup');
end



% traces = {};
% hs = {};
% dirLists = {};
k = 5;

while j <= length(dir1)
    if retry
        filepath = analysisO(j).path;
    else
        filepath = [dir1(j).folder filesep dir1(j).name];
    end
    image1 = importTxtFile(filepath,imageDim);
    %     plane = griddedInterpolant([image1(1,1) image1(1,imageDim(2)); image1(imageDim(1),1) image1(imageDim(1),imageDim(2))]);
    %     [tempX, tempY] = meshgrid(linspace(1,2,imageDim(2)),linspace(1,2,imageDim(1)));
    %     subtractPlane = plane(tempX',tempY');
    %     image1 = image1-subtractPlane;
    [flat1,image1] = quadFlattenN(image1);
    figure(); imagesc(flat1);
    %image1 = image1./max(image1(:));
    currentAnalysis = length(analysis);
    if ~retry
        Answer = questdlg('Any things here you want to capture?','Analyze image?','Yes','No','Debug','Yes');
    else
        Answer = 'Yes';
    end
    if strcmp(Answer,'Yes')
        analysis(currentAnalysis+1).Xframe = 0;
        if ~retry
            [Xframe,Yframe] = ginput(2);
            Xframe = min(max(round(Xframe),[1 1]), [size(image1,2) size(image1,2)]);
            Yframe = min(max(round(Yframe), [1 1]), [size(image1,1) size(image1,1)]);
        else
            Xframe = analysisO(j).Xframe;
            Yframe = analysisO(j).Yframe;
        end
        analysis(end).Xframe = Xframe;
        analysis(end).Yframe = Yframe;
        [matrix1,image2] = quadFlattenN(flat1(Yframe(1):Yframe(2),Xframe(1):Xframe(2)));
        [surfX, surfY] = meshgrid(1:size(matrix1,2),1:size(matrix1,1));
        figure(4); surf(surfX,surfY,matrix1,'EdgeColor','none','FaceColor','interp'); hold on;
        figure(k); imagesc(matrix1); hold on;
        if ~retry
            [X0,Y0] = ginput(4);
        else
            X0 = analysisO(j).X0;
            Y0 = analysisO(j).Y0;
        end
        analysis(end).X0 = X0;
        analysis(end).Y0 = Y0;
        F = griddedInterpolant(matrix1);
        if ~retry
            figure(2); plot(linspace(X0(1),X0(2),20), F(linspace(Y0(1),Y0(2),20), linspace(X0(1),X0(2),20)));
            clear trace h
            [trace(1,1),~] = ginput(1);
            trace(1,2) = (Y0(1)-Y0(2))/(X0(1)-X0(2))*(trace(1)-X0(1))+Y0(1);
        else
            clear trace h
            trace(1,:) = analysisO(j).initPoint;
        end
            analysis(end).initPoint = trace(1,:);
        h(1) = F(trace(1,2),trace(1,1));
        [trace(2,:),h(2)] = followChain([X0(1) Y0(1)], [trace(1,1) trace(1,2)], F, stepLength/pixel);
        i = 3;
        %sideChain = (trace(2,2)>(Y0(3)+(Y0(4)-Y0(3))/(X0(4)-X0(3))*(trace(2,1)-X0(3))));
        onChain = 1;
        while onChain
            [trace(i,:),h(i)] = followChain(trace(i-2,:), trace(i-1,:), F, stepLength/pixel);
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
            %F = griddedInterpolant(matrix1);
        end
        figure(4); plot3(trace(:,1),trace(:,2),h);
        figure(k); plot(trace(:,1),trace(:,2));
        analysis(end).trace = trace;
        analysis(end).h = h;
        if retry
            analysis(end).path = analysisO(j).path;
            analysis(end).fileName =analysisO(j).fileName;
        else
            analysis(end).path = [dir1(j).folder filesep dir1(j).name];
            analysis(end).fileName = dir1(j).name;
        end
        if ~retry
            anS = questdlg('Do you approve of the fit?',...
            'Choose wisely', 'Yes', 'No','Debug','Yes');
        else
            close(4);
            figure(k);
            ignore = ginput(1);
            if ignore(1)>ignore(2)
                anS = 'No';
            else
                anS = 'Yes';
            end
            if ignore(1)<0
                anS = 'Debug';
            end
        end
        if strcmp(anS,'No')
            analysis(end) = [];
            close(k);
            k = k-1;
        end
        if strcmp(anS,'Debug')
            keyboard;
        end
        k = k+1;
        if retry
            j = j+1;
%             close(k-1);
        end
    elseif strcmp(Answer,'No')
        j = j+1;
        %         traces{length(traces)+1} = trace;
        %         hs{length(hs)+1} = h;
        %         dirList{length(dirList)+1} = [dir1(j).folder filesep dir1(j).name];
        %close all;
    else
        keyboard;
    end
    
    try
        close 4;
        close 2;
        close 3;
        
    catch
    end
end
try
    uisave('analysis','j');
catch
end
clear saveTraces
for i = 1:length(analysis)
    saveTraces(1:length(analysis(i).trace),(2*i-1):(2*i)) = analysis(i).trace;
end
saveTraces = saveTraces.*pixel;
