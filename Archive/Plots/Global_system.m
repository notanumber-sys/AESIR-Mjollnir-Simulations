function [] = Global_system(x_fill,r_fuel)
%GLOBAL_SYSTEM plots the system according to the state given in parameters
%: fuel radius and tank filling (between 0 and 1)
disp(x_fill)

global opts

figure(4)



x_tank_ext_left=-opts.e_tank; y_tank_ext_left=-opts.e_tank; 
x_tank_ext_right=opts.L_tank+opts.e_tank; y_tank_ext_right=opts.D_tank_int+opts.e_tank;

x_tank_ext = [x_tank_ext_left, x_tank_ext_right, x_tank_ext_right, x_tank_ext_left, x_tank_ext_left];
y_tank_ext = [y_tank_ext_left, y_tank_ext_left, y_tank_ext_right, y_tank_ext_right, y_tank_ext_left];

%% Tank
%rectangle('Position','[x,y,width,length])
rectangle('Position',[0,0,opts.L_tank,opts.D_tank_int],'FaceColor','blue');
rectangle('Position',[x_tank_ext_left,y_tank_ext_left,opts.L_tank+2*opts.e_tank,opts.D_tank_ext]);

rectangle('Position',[0,0,(1-x_fill)*opts.L_tank,opts.D_tank_int],'FaceColor','white');

%% Kastrullen 

rectangle('Position',[opts.L_tank,0,opts.L_kastrullen,opts.D_tank_int],'FaceColor','k');
rectangle('Position',[opts.L_tank,y_tank_ext_left,opts.L_kastrullen,opts.D_tank_ext]);
axis('equal')

%% Combustion Chamber
%rectangle('Position','[x,y,width,length])

rectangle('Position',[opts.L_tank+opts.L_kastrullen,0,opts.L_cc,opts.D_tank_int]);

rectangle('Position',[opts.L_tank+opts.L_kastrullen+opts.L_pcc,0,opts.L_fuel,opts.D_tank_int],'FaceColor','#F7BE36');
rectangle('Position',[opts.L_tank+opts.L_kastrullen+opts.L_pcc,opts.D_tank_int/2-r_fuel,opts.L_fuel,2*r_fuel],'FaceColor','white');


rectangle('Position',[opts.L_tank+opts.L_kastrullen,-opts.e_tank,opts.L_cc,opts.D_tank_int+2*opts.e_tank]);
hold on
%% Nozzle
x_nozzle=opts.L_tank+opts.L_kastrullen+opts.L_cc;
h=opts.D_tank_int/2-opts.D_nozzle/2;                %length between tank radius and throat radius
H=(opts.D_exit/2-opts.D_nozzle/2);                  %length between throat radius and exit radius          
L_conv = h/tand(opts.beta_nozzle);
L_div = H/tand(opts.alpha_nozzle);


nozzle_x = x_nozzle+[0, L_conv, opts.L_nozzle-L_div, L_div];
nozzle_y_bottom = [0, h, h, h-H];
nozzle_y_top = opts.D_tank_int + [0, -h, -h, -h+H];

plot(nozzle_x,nozzle_y_bottom, 'k', 'LineWidth',2);
hold on
plot(nozzle_x,nozzle_y_top, 'k', 'LineWidth',2);
hold off



end

