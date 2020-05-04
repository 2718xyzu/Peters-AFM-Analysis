function errorbounds = make_errrorbar_plot(L_p, M, a_n, mean_L, e_k2, segment_length, mode_numbers,xoffset)
    %handles one dataset at a time (unpack them from their cells before
    %putting them in here); L_p, e_k2 and segment_length in nm.
    %L_p should be the mean persistence length estimate for each mode
    N = mean_L/segment_length;
    mode_numbers = reshape(mode_numbers,[1 numel(mode_numbers)]);
    errorbounds = zeros([3 length(mode_numbers)]);
    errpos = zeros([length(mode_numbers) 1]);
    errneg = zeros([length(mode_numbers) 1]);
    errorbounds(1,:) = mode_numbers;
    j = 1;
    for i = errorbounds(1,:)
        a_n_noise(i) = 4/mean_L*e_k2*(1+(N-1)*sin(i*pi/(2*N)).^2);
        var_an_measured = var(a_n(:,i));
        delta_log_P = sqrt(2/(M-1)*var_an_measured^2+a_n_noise(i)^2)/(var_an_measured-a_n_noise(i));
        errpos(j) = exp(log(L_p(i))+delta_log_P)-L_p(i);
        errneg(j) = exp(log(L_p(i))-delta_log_P)-L_p(i);
        errorbounds([2 3],j) = [exp(log(L_p(i))-delta_log_P); exp(log(L_p(i))+delta_log_P)];
        j = j+1;
    end
    errorbar(xoffset+mode_numbers,L_p(mode_numbers),errneg, errpos,'.');
end