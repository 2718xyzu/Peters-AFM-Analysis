function [a_n,E_n,L] = fourier_power_chain(smoothedChain)
    %smoothedChain is an n-by-2 matrix; first column is x values, second is y values
    dsc = diff(smoothedChain);
    ds_k = (dsc(:,1).^2+dsc(:,2).^2).^1/2;
    theta_k = atan(dsc(:,2)./dsc(:,1));
    change = diff(theta_k);
    if nnz(abs(change)>pi/2) %when the angle of the segment goes past pi/2 or under -pi/2
                             %there is an artificial 'jump' in the angle
                             %data; this smooths that out
        k = find(abs(change)>pi/2);
        for i = 1:length(k)
            theta_k(k(i)+1:end) = theta_k(k(i)+1:end) - sign(change(k(i)))*pi;
        end
    end
    N = length(smoothedChain)-1; %from Gittes et al. 
    L = sum(ds_k);
    for n = 1:N-1
        for k = 1:N
            smid(k) = sum(ds_k(1:k-1))+1/2*ds_k(k);
            a_k(k) = theta_k(k)*ds_k(k)*cos(n*pi/L*smid(k));
        end
        a_n(n) = sqrt(2/L)*sum(a_k);
    end
    E_n = 1/2*((1:N-1*pi/L).^2).*(a_n.^2);
end