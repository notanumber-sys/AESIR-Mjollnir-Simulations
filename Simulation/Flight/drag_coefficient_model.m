
% http://www.diva-portal.org/smash/get/diva2:1241365/FULLTEXT02.pdf
% Calculate the drag coefficient as function of velocity and speed of sound
function Cd = drag_coefficient_model(velocity, speedOfSound)
    eps1 = 0.1;
    eps2 = 10;  
    
    edge = 1.1;
    
    leftSide = 0:eps1:edge;
    rightSide = edge+eps1:eps1:15;
    farSide = 15+eps2:eps2:1000;
    
    a = 0.9;
    b = -0.6;
    c = edge;
    d = edge;
    A = 0.7 - 0.2;
    B = A;
    
    MachVals = [ leftSide rightSide farSide ];
    CdVals = 0.2 + [ A*exp(a*(leftSide - c)) B*exp(b*(rightSide - d)) B*exp(b*(farSide - d)) ];
    
    Mach = velocity./speedOfSound;
    Cd = interp1(MachVals, CdVals, Mach, 'pchip');
end