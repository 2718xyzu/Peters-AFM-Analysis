function [smoothedChain,L] = smoothChain(trace, F, stepLengthInPixels, X0, Y0)
%     if diff(trace).^2
%     end
    trace2 = makeTraceFrom(trace, F, stepLengthInPixels, X0, Y0);
    perStep = 2;
    avgTrace1 = average2chainz(trace, trace2, perStep);
    trace4 = makeTraceFrom(trace, F, stepLengthInPixels, X0, Y0);
    trace5 = makeTraceFrom(trace, F, stepLengthInPixels, X0, Y0);
    avgTrace2 = average2chainz(trace4, trace5, perStep);
    smoothedChain1 = average2chainz(avgTrace1, avgTrace2, perStep);
    smoothedChainL = smoothdata(smoothedChain1, 1, 'loess', 7);
    dsc = diff(smoothedChainL);
    ds_k = (dsc(:,1).^2+dsc(:,2).^2).^1/2;
    L = sum(ds_k);
    l = length(smoothedChainL);
    smoothedChain(:,1) = spline(1:l,smoothedChainL(:,1),linspace(1,l,round(l*.8)));
    smoothedChain(:,2) = spline(1:l,smoothedChainL(:,2),linspace(1,l,round(l*.8)));
%     figure; hold on; plot(trace(:,1),trace(:,2));
%     plot(trace2(:,1),trace2(:,2));
%     plot(trace4(:,1),trace4(:,2));
%     plot(trace5(:,1),trace5(:,2));
%     plot(avgTrace1(:,1),avgTrace1(:,2));
%     plot(avgTrace2(:,1),avgTrace2(:,2));
%     plot(smoothedChain1(:,1),smoothedChain1(:,2));
%     plot(smoothedChain(:,1),smoothedChain(:,2));
    
    
    function trace3 = average2chainz(trace, trace2, perStep)
    trace3 = zeros([(length(trace)-1)*perStep 2]);
    p2 = zeros([length(trace2)-1 1])-1;
    k = 1;
    for i = 1:length(trace)-1
        split1(:,1) = linspace(trace(i,1),trace(i+1,1),perStep+1);
        split1(:,2) = linspace(trace(i,2),trace(i+1,2),perStep+1);
        for j = 1:perStep
            x1 = trace(i,1);
            y1 = trace(i,2);
            x2 = trace(i+1,1);
            y2 = trace(i+1,2);
            x3 = split1(j,1);
            y3 = split1(j,2);
            [~,Isort] = sort(sum([split1(j,1)-trace2(:,1) split1(j,2)-trace2(:,2)].^2,2));
            mIndexes = sort(Isort(1:2));
            x4 = trace2(mIndexes(1),1);
            y4 = trace2(mIndexes(1),2);
            x5 = trace2(mIndexes(2),1);
            y5 = trace2(mIndexes(2),2);
            v1 = [x2-x1 y2-y1];
            v2 = [x5-x4 y5-y4];
            n1 = norm(v1);
            n2 = norm(v2);
            u1 = v1/n1;
            u2 = v2/n2;
            p2(mIndexes(1)) = max(p2(mIndexes(1)), dot([x3-x4 y3-y4],(u1+u2))/dot(v2,(u1+u2)));
            trace3(k,:) = [x3+p2(mIndexes(1))*v2(1)+x4 y3+p2(mIndexes(1))*v2(2)+y4]/2;
            k = k+1;
        end
    end
    end


    function trace2 = makeTraceFrom(trace, F, stepLengthInPixels, X0, Y0)
        i = 3;
        onChain = 1;
        trace2 = [(trace(1,1)+trace(2,1))/2 (trace(1,2)+trace(2,2))/2 ; ...
            (trace(2,1)+trace(3,1))/2 (trace(2,2)+trace(3,2))/2]+randn(2)*stepLengthInPixels/5;
        while onChain
            [trace2(i,:),~] = followChain(trace2(i-2,:), trace2(i-1,:), F, stepLengthInPixels);
            try
            onChain = norm([trace2(end,1)-trace(end,1) trace2(end,2)-trace(end,2)])>stepLengthInPixels && norm([trace2(i,1)-X0(3), trace2(i,2)-Y0(3)])>norm([X0(3)-X0(4),Y0(3)-Y0(4)]) && i<length(trace)*10;
            catch
                onChain = 0;
            end
            i = i+1;
        end
        
    end



end