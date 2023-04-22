%% Plots the animation of the tank emptying and the fuel being consumed


r_fuel = r_cc;
x_fill = m_ox_total./(opts.V_tank*opts.rho_ox);

for i=1:100:length(x_fill)
    
    x_fill(i) = min(1,max(0,x_fill(i)));
    Global_system(x_fill(i),r_fuel(i));
    
end