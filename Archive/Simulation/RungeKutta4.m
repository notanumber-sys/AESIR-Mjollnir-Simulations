function [t, X] = RungeKutta4(f, t_span, dt, x0)
%RUNGEKUNTA4 t_span = [t0 t_end]; dt = timestep; 
    
    dt2 = 0.5;
    t1 = t_span(1):dt:30;
    t2 = 30:dt2:t_span(end);
    t = [t1 t2(2:end)];

%     t = t_span(1):dt:t_span(end);
    N = length(t);
    N1 = length(t1);
    p = length(x0);
    
    X = zeros(p, N);
    X(:, 1) = x0;
    
    for i = 1:N-1
        if i > N1
            dt = dt2;
        end
        k1 = f(t(i), X(:, i));
        k2 = f(t(i) + dt / 2, X(:, i) + dt * k1 / 2);
        k3 = f(t(i) + dt / 2, X(:, i) + dt * k2 / 2);
        k4 = f(t(i) + dt, X(:, i) + dt * k3);
        
        X(:, i + 1) = X(:, i) + dt / 6 * (k1 + 2 * k2 + 2 * k3 + k4);
        
    end
end

