pixel = 600/256;

close all;
nmax = 10;
reopen = 1;
if reopen
    clear summary
    a_n = cell([1 4]);
    %the four items in each cell correspond to the 
    E_n = cell([1 4]);
    L = cell([1 4]);
    L_p = cell([1 4]);
    meanL = [0 0 0 0 ];
end


for j = 1:4
%     switch j
%         case 1
%             a_n = a_ns_c;
%             E_n = E_ns_c;
%         case 2
%             a_n = a_ns_x;
%             E_n = E_ns_x;
%         case 3
%             a_n = a_ns_e;
%             E_n = E_ns_e;
%         case 4
%             a_n = a_ns_a;
%             E_n = E_ns_a;
%     end
    if reopen
        uiopen;
        for i = 1:length(analysis)
            [a_n1,E_n1,L1] = fourier_power_chain(analysis(i).smoothedChain*pixel);
            a_n{j}(i,:) = a_n1(1:nmax);
            E_n{j}(i,:) = E_n1(1:nmax);
            L{j}(i) = L1;
        end
    end
    clear summary;
    summary(1,:) = mean(a_n{j});
    summary(2,:) = mean(abs(a_n{j}));
    summary(3,:) = var(abs(a_n{j}));
    summary(4,:) = mean(E_n{j});
    %the ensemble mean of the Energy terms is not a statistically useful
    %quantity for determining L_p, but it should be more or less a constant
    %across the modes
    %E_n is the energy of the mode divided by the bending modulus B
    summary(5,:) = var(E_n{j});
    meanL(j) = mean(L{j});

    for i = 1:5
        figure(i); hold on;
        plot(summary(i,:));
    end

end
for i = 1:5
    figure(i); legend({'Control', 'Chloroquine', 'EtBr', 'Acridine'});
end

for j = 1:4
    for i = 1:length(L{j})
        L_p{j}(i,:) = L{j}(i)^2./(((1:nmax).^2).*pi^2.*var(a_n{j}));
    end
end

figure; hold on; 
for j = 1:4
    plot(mean(L_p{j}));
    meanLp(j) = mean(mean(L_p{j}));
    stdLp2(j) = std(mean(L_p{j}));
end

legend({'Control', 'Chloroquine', 'EtBr', 'Acridine'});



