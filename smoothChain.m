function smoothedChain = smoothChain(trace, F, stepLength, perStep)
    i = 3;
    onChain = 1;
    trace2 = [(trace(1,1)+trace(2,1))/2 (trace(1,2)+trace(2,2))/2 ; ...
        (trace(2,1)+trace(3,1))/2 (trace(2,2)+trace(3,2))/2];
    while onChain
        [trace2(i,:),~] = followChain(trace2(i-2,:), trace2(i-1,:), F, stepLength/pixel);
        onChain = norm([trace2(end,1)-trace(end,1) trace2(end,2)-trace(end,2)])>stepLength
    end
    
smoothedChain = trace2(1:perStep:length(trace2),:);
end