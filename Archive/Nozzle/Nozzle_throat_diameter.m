
F = 4900;%N
g = 9.81;
Isp = 214;

mf_s = F/(Isp*g);
Tcc = 2100;
Pcc = 6e6;


R = 8.314;
% Mw = 15e-3;
gam = 1.4;
r = 287;%R/Mw;

Te = Tcc - (gam-1)/2*(Isp*g)^2/(gam*r);
Pe = 0.1e6;
Me = (Isp*g)/sqrt(gam*r*Te);
Pcc = Pe * (1+(gam-1)/2*Me^2)^(gam/(gam-1));

As = mf_s/(Pcc*(gam/(r*Tcc))^0.5*((gam+1)/2)^(-(gam+1)/(2*(gam-1))));
Ae_As = 1/Me*(2/(gam+1)*(1+(gam-1)/2*Me^2))^((gam+1)/(2*(gam-1)));
Ae = As*Ae_As;
Ds = sqrt(4*As/pi);
De = sqrt(4*Ae/pi);

