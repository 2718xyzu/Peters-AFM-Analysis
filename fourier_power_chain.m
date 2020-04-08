function [a_n,E_n] = fourier_power_chain(smoothedChain)
    dsc = diff(smoothedChain);
    ds_k = (dsc(:,1).^2+dsc(:,2).^2).^1/2;
    theta_k = atan(dsc(:,2)./dsc(:,1));
    N = length(smoothedChain)-1;
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