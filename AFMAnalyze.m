%Wrapper function to hold analysis code for tracing program
%To begin, select folder which contains .txt files

%Initial parameters (must be constant for a whole dataset)

imageSize = [600 600]; %in nm
imageDim = [256 256]; %in pixels
pixel = imageSize(1)/imageDim(1); %the pixel variable is the conversion factor, in nm/pixels; 
%the structures this code saves have all position and length data stored in
%units of pixels; in order to convert to nm, you have to multiply by
%"pixel".  See the line of the code that creates saveTraces for an example.
%For all data created in the spring of 2020, pixel = 600/256.  Pixel will
%now be saved to each structure for future reference, but old structures
%may not contain that field.  
stepLength = 6;

AnS = questdlg(['Would you like to analyze a new dataset or re-analyze an old one by'...
    ' selecting its analysis package?'],'New or old?','New','Re-analyze','New');

%The 'retry' variable allows you to base new chain estimates on old ones;
%in essence, the first time you analyze a set of images, 'retry' should be
%zero.  Then you select the location of each molecule manually.  However,
%if you want to re-analyze the same dataset, just at a different
%stepLength, you don't need to tell it where the molecules are again, it
%can extract that information from the analysis you already did.  That
%makes re-analyses go faster while containing the same molecules as the
%original analysis.

%When you are re-analyzing, clicking in the lower left corner of an image
%is equivalent to accepting the trace; the top right corner rejects the
%trace; any click to the left of the x=0 line results in the debug command
%(but the trace will be accepted if you don't delete it)
%The green curve shows the result of smoothChain.  If you don't think
%you're going to do the Fourier analysis on a dataset, you don't have to
%worry about what the green curve looks like.

retry = 0;
if AnS(1) == 'R'
    retry = 1;
     anS = questdlg('Please Select the analysis package which contains the dataset to re-analyze',...
        'Select package', 'Ok', 'Ok');
    uiopen(); %select a completed analysisPackage from before
    dir1 = 1:length(analysis);
    analysisO = analysis;
    analysis = struct([]);
    if isfield(analysisO,'pixel')
        analysis(1).pixel = analysisO(1).pixel;
        pixel = analysisO(1).pixel;
    else
        analysis(1).pixel = pixel;
    end
    j = 1;
   
    if ~exist('dirName','var')
        anS = questdlg('Please Select the directory which contains all txt files from this dataset',...
        'Select search directory', 'Ok', 'Ok');
        dirName = uigetdir;
        dir1 = dir([dirName filesep '*.txt']);
    else
        disp('Using last-selected directory.  Hope that"s okay. If not, clear dirName.');
    end
else
    if ~exist('j','var')
        j = 1;
    end
    %select your directory with all the images
    if ~exist('dirName','var')
         anS = questdlg('Please Select the directory which contains all txt files from this dataset',...
        'Select search directory', 'Ok', 'Ok');
        dirName = uigetdir;
        dir1 = dir([dirName filesep '*.txt']);
    else
        disp('Using last-selected directory.  Hope that"s okay. If not, clear dirName.');
    end
    
    if ~exist('analysis','var')
        analysis = struct([]);
        analysis(1).pixel = pixel;
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
        filepath = [dir1(1).folder filesep analysisO(j).fileName];
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
            if i>10
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
        [smoothedChain,L] = smoothChain(trace, F, stepLength/pixel, X0, Y0);
        [a_n,E_n] = fourier_power_chain(smoothedChain);
        figure(4); plot3(trace(:,1),trace(:,2),h);
        figure(k); plot(trace(:,1),trace(:,2),'r');
        hold on; plot(smoothedChain(:,1),smoothedChain(:,2),'g');
        analysis(end).smoothed = smoothedChain;
        analysis(end).trace = trace;
        analysis(end).h = h;
        analysis(end).smoothedChain = smoothedChain;
        analysis(end).a_n = a_n;
        analysis(end).E_n = E_n;
        analysis(end).L = L*pixel;
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
saveTraces(saveTraces==0) = NaN;
saveTraces = saveTraces.*pixel; %put in the correct nm units; copy and paste this variable into excel
