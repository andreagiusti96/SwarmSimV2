function [envInput,hist,u] = FF_PI(x,rho_d,Ctrl_pars,hist)

arguments
    x           double
    rho_d       double
    Ctrl_pars   struct
    hist        double=0
end

%Initialization of the parameters of the controller
pts     = Ctrl_pars.pars;
u_FF    = Ctrl_pars.u_FF;
k_p     = Ctrl_pars.k_p;
k_i     = Ctrl_pars.k_i;
arena   = Ctrl_pars.arena;
Est_grid= Ctrl_pars.Est_grid;
dt      = Ctrl_pars.dt;


%Get the agents currently in the frame
[~,indices_inWindow] = getInWindow(x, arena);
x_curr = x(indices_inWindow,:);


%Compute the feedforward action 
F = griddedInterpolant(pts,u_FF, 'linear', 'nearest');
envInput_FF = F(x_curr(:,1),x_curr(:,2));

%Estimate the density of the agents (and computation of the control error)
rho=density_agents(x_curr,[length(pts{1}),length(pts{2})],Est_grid,true);
% err=rho_d./(max(max(rho_d)))-rho./(max(max(rho)));
% err=rho_d-rho;
err=log((rho_d+1e-11)./(rho+1e-11));

%%%%%%%%%%%%%%%%%         PI CONTROLLER        %%%%%%%%%%%%%%%%%%%%%

%Proportional action

F_fb = griddedInterpolant(pts,err, 'linear', 'nearest');
envInput_FB = k_p .* F_fb(x_curr(:,1),x_curr(:,2));

%Integral action (with anti-windup)

hist_t=hist+err.*dt;
total_act = k_p .* err + k_i .* hist_t + u_FF;
hist_t(total_act<0|total_act>1)=hist(total_act<0|total_act>1);
hist=hist_t;

F_int = griddedInterpolant(pts,hist, 'linear', 'nearest');
envInput_int = k_i .* F_int(x_curr(:,1),x_curr(:,2)); 
envInput_FB=envInput_FB+envInput_int;



%Give a high input to all agents outside the arena
envInput=max(max(envInput_FF+envInput_FB)).*ones(size(x,1),1);
%Apply the input to all the agents in the arena
envInput(indices_inWindow)=envInput_FF+envInput_FB;

%SATURATION
envInput=max([envInput,zeros(size(envInput))],[],2);
envInput=min([envInput,ones(size(envInput))],[],2);

fprintf("Min u: %.3f, Max u: %.3f \n",min(min(envInput(indices_inWindow))),max(max(envInput(indices_inWindow))))

[x_m,y_m]=ndgrid(pts{1},pts{2});
Fu= griddedInterpolant(pts,k_p*err+k_i*hist+u_FF, 'linear', 'nearest');
x_mv = reshape(x_m,[size(x_m,1)*size(x_m,2),1]);
y_mv = reshape(y_m,[size(y_m,1)*size(y_m,2),1]);
u_finv = Fu(x_mv,y_mv);
u = reshape(u_finv,size(x_m));


    
end