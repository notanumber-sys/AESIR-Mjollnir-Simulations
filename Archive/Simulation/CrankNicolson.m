function [t, Y] = CrankNicolson(f, t_span, h, x0)
    t = t_span(1):h:t_span(end);
    N = length(t);
    p = length(x0);
    
    Y = zeros(p, N);
    Y(:, 1) = x0;
    
    for i = 1:N-1
        % y_{n+1} = y_n + h * \sum_{i=1}^s b_i * k_i,      for i \in {1, 2},
        %
        % k_i = f(t_n + c_i * h, y_n + h * \sum_{j=1}^s a_{ij} * k_j),
        %
        % c_1 = 0, c_2 = 1,
        % a_11 = 0, a_12 = 0, a_21 = 1/2, a_22 = 1/2,
        % b_1 = 1/2, b_2 = 1/2,
        %
        % y_{n+1} = y_n + h * (k_1 + k_2) / 2,
        %
        % k_1 = f(t_n, y_n),
        % k_2 = f(t_n + h, y_n + h * (k_1 + k_2) / 2).

        k1 = f(t(i), Y(:, i));
        k2 = f(t(i) + h, Y(:, i) + h * (k1 / 2));

        % Solve system of equations.
        
        Y(:, i + 1) = Y(:, i) + h * (k1 + k2) / 2;
    end
end