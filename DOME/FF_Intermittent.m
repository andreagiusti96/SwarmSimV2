function [envInput,hist,u] = FF_Intermittent(x,Ctrl_pars,hist)

arguments
    x           double
    Ctrl_pars   struct
    hist        double=0
end

%Initialization of the parameters of the controller
pts     = Ctrl_pars.pars;
u_FF    = Ctrl_pars.u_FF;
arena   = Ctrl_pars.arena;
dt      = Ctrl_pars.dt;
t_on    = Ctrl_pars.t_on;
t_off   = Ctrl_pars.t_off;

%Get the agents currently in the frame
[~,indices_inWindow] = getInWindow(x, arena);
x_curr = x(indices_inWindow,:);


%% FEED FORWARD ACTION 

if hist(3)>0
    if (hist(1)-hist(2)-t_on>0)
        hist(3)=-1*hist(3);
        hist(2)=hist(1);
    end
else
    if (hist(1)-hist(2)-t_off>0)
        hist(3)=-1*hist(3);
        hist(2)=hist(1);
    end
end

hist(1)=hist(1)+dt;

if hist(3)>0
    F = griddedInterpolant(pts,u_FF, 'linear', 'nearest');
    envInput_FF = F(x_curr(:,1),x_curr(:,2));
else
    F = griddedInterpolant(pts,zeros(size(u_FF)), 'linear', 'nearest');
    envInput_FF = F(x_curr(:,1),x_curr(:,2));
end




%Give a high input to all agents outside the arena
envInput=max(max(envInput_FF)).*ones(size(x,1),1);
%Apply the input to all the agents in the arena
envInput(indices_inWindow)=envInput_FF;

%SATURATION
envInput=max([envInput,zeros(size(envInput))],[],2);
envInput=min([envInput,ones(size(envInput))],[],2);

fprintf("Min u: %.3f, Max u: %.3f \n",min(min(envInput(indices_inWindow))),max(max(envInput(indices_inWindow))))

[x_m,y_m]=ndgrid(pts{1},pts{2});
if hist(3)>0
    Fu = griddedInterpolant(pts,u_FF, 'linear', 'nearest');
else
    Fu = griddedInterpolant(pts,zeros(size(u_FF)), 'linear', 'nearest');
end
x_mv = reshape(x_m,[size(x_m,1)*size(x_m,2),1]);
y_mv = reshape(y_m,[size(y_m,1)*size(y_m,2),1]);
u_finv = Fu(x_mv,y_mv);
u = reshape(u_finv,size(x_m));


    
end