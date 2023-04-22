global opts

%% Exhaust Flow

Me = ExhaustMach(opts);
Pe = ExhaustPressure(P_cc,Me,opts);


%% Thrust
Patm = opts.P_atm_sl;

Cs = ThrustCoefficient(Pe,P_cc,Patm,opts);
Tr = Thrust_using_Cs(mf_throat,Cs,OF,opts);