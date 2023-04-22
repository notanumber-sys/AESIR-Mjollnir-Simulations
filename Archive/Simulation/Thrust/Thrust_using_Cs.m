function Tr = Thrust_using_Cs(mf_throat,Cs,OF,opts)
%THRUST

alpha = opts.alpha_nozzle;

lambda = (1+cosd(alpha))/2;
c_star = interp1(opts.OF_set,opts.C_star_set,OF);

Tr = lambda .* mf_throat .* Cs' .* c_star;

end

