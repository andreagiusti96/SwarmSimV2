function [xVec, uVec, vVec] = Simulator(x0, v0, Simulation, Dynamics, GlobalIntFunction, LocalIntFunction, Environment, Ctrl_pars)
%
%Simulator executes a complete simulation of the swarm.
%   This function is called by a launcher script (Launcher, SequentialLauncher...).
%
%   [xVec, uVec] = Simulator(x0, v0, Simulation, Dynamics, GlobalIntFunction, LocalIntFunction)
%
%   Inputs:
%       x0                  Initial positions of the agents     (NxD matrix)
%       v0                  Initial velocities of the agents    (NxD matrix)
%       Simulation          Simulation parameters               (struct)
%       Dynamics            Dynamics of the agents              (struct)
%       GlobalIntFunction   Long distance interaction           (struct = struct('function','None'))
%       LocalIntFunction    Shorts distance interaction         (struct = struct('function','None'))
%
%   Outputs:
%       xVec                Positions of the agents             (TIMExNxD matrix)
%       uVec                Virtual forces acting on the agents (TIMExNxD matrix)
%
%   See also: Simulator, Launcher
%
%   Authors:    Andrea Giusti
%   Date:       2023
%

%% Validate input arguments
arguments
    x0                  double
    v0                  double
    Simulation          struct
    Dynamics            struct
    GlobalIntFunction   struct = struct('function','None')
    LocalIntFunction    struct = struct('function','None')
    Environment         struct = struct()
    Ctrl_pars           struct = struct()
end

assert(ismember(size(x0,2), [2,3]), 'x0 must have second dimension equal to 2 or 3!')
assert(all(size(v0,2)==size(x0,2)), 'v0 must have same dimensions of x0!')

assert(Simulation.recordVideo <= Simulation.drawON, 'Simulation.recordVideo must be false if Simulation.drawON is false')

if ~isfield(Simulation, 'InteractionFactor')
    Simulation.InteractionFactor = 1; % fraction of agents to interact with ]0,1] 
end
%(if InteractionFactor<1 a subset of agents is randomly selected by each agent at each update step to interact with)
assert(Simulation.InteractionFactor <=1 & Simulation.InteractionFactor >0, 'Simulation.InteractionFactor must be in range ]0;1]')
if (Simulation.InteractionFactor~=1); warning("Simulation.InteractionFactor is NOT set to 1"); end

if ~isfield(GlobalIntFunction, 'SensingNumber')
    GlobalIntFunction.SensingNumber = inf; % fraction of agents to interact with ]0,1] 
end
assert(GlobalIntFunction.SensingNumber>0, 'GlobalIntFunction.SensingNumber must be positive')
if (GlobalIntFunction.SensingNumber~=inf); warning("SensingNumber is NOT set to inf"); end

if length(Simulation.arena)==1
    Simulation.arena = [Simulation.arena, Simulation.arena];
end

cmap = linspace2([1,1,1], [1,0.5,0.5], 100)';
if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
    x_vec = linspace(-Simulation.arena(1)/2,Simulation.arena(1)/2,1000);
    y_vec = linspace(-Simulation.arena(2)/2,Simulation.arena(2)/2,1000);
    [x_mesh, y_mesh] = meshgrid(x_vec, y_vec);
    %F=scatteredInterpolant(Environment.Inputs.Points, Environment.Inputs.Values, 'linear', 'nearest');
    F = griddedInterpolant(Environment.Inputs.Points,Environment.Inputs.Values{1}, 'linear', 'nearest');
end
    
%% Instantiate Simulation Window

if Simulation.drawON
    figure
    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
        imagesc(x_vec,y_vec,F(x_mesh',y_mesh')')
        colormap(cmap)
    end
    %     if isfield(LocalIntFunction, 'DistanceRange')
    %         plotSwarmInit(x0, 0, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), Simulation.arena, thenDelete=true);
    %     else
    %         plotSwarmInit(x0, 0, inf, inf, Simulation.arena, thenDelete=true);
    %     end
    if isfield(LocalIntFunction, 'DistanceRange')
        plotSwarmInit(x0, 0, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), Simulation.arena, Simulation.arena, false, false, true, Simulation.agentShape, Simulation.agentSize, x0-v0);
    else
        plotSwarmInit(x0, 0, inf, inf, Simulation.arena, Simulation.arena, false, false, true, Simulation.agentShape, Simulation.agentSize, x0-v0);
    end
end

%% Inizialization
epsilon = Simulation.dT/100;
x=x0;
N=size(x,1);
h = waitbar(0, 'Simulation in Progress'); % Create a waitbar


%% Preallocate variables
TSample = [0:Simulation.deltaT:Simulation.Tmax]';   % sampling time instants
xVec=nan([size(TSample,1),size(x0)]);               % positions of the swarm
vVec=nan([size(TSample,1),size(x0)]);               % velocities of the swarm
uVec=nan([size(TSample,1),size(x0)]);               % inputs of the swarm
forces=zeros(size(x0));
envInput = zeros(N,1);

% xVec(1,:,:)=x0;
v=v0;

if Simulation.recordVideo
    video = VideoWriter('.SwarmSimV2/Output/video','MPEG-4');
    video.FrameRate = 1/Simulation.deltaT;
    open(video);
%     currFrame = getframe(gcf);
%     writeVideo(video,currFrame);
end

log_txt = ['- Simulating ',num2str(N),' ',Dynamics.model, ' agents in ', num2str(size(x0,2)),'D space'];
if ~strcmp(GlobalIntFunction.function, 'None'); log_txt = [log_txt,' with ',GlobalIntFunction.function,' interaction']; end
if isfield(Environment,'Inputs')
    if isfield(Environment.Inputs,'Points')
        log_txt = [log_txt,' with spatial inputs'];
    else
        log_txt = [log_txt,' with temporal inputs'];
    end
end
disp(log_txt);

%% ----------------- Run Simulation ---------------------

%Initialization
t=0;
count=1;                                        % sampling iteration


if isfield(Ctrl_pars,"hist")
    hist=Ctrl_pars.hist_0;
end
[envInput,~,u_a] = Environment.Inputs.Input_function(x,hist);

while t<Simulation.Tmax
    % Compute inputs from interactions
    if ~strcmp(GlobalIntFunction.function, 'None') || ~strcmp(LocalIntFunction.function, 'None')
        forces = VFcontroller(x, GlobalIntFunction, LocalIntFunction, Simulation.dT, Simulation.InteractionFactor);
    end
    
    % Compute environmental inputs
    if isfield(Environment,'Inputs')
        
        if isfield(Environment.Inputs,'Input_function')
            if mod(t,Ctrl_pars.dt)==0
                if isfield(Ctrl_pars,'hist')
                    [envInput,hist,u] = Environment.Inputs.Input_function(x,hist);
                    u_a = (u + u_a)/2;
                else
                    envInput = Environment.Inputs.Input_function(x);
                end
            end
        elseif isfield(Environment.Inputs,'Points')
            envInput = F(x(:,1),x(:,2));
        elseif isfield(Environment.Inputs,'Times')
            envInput = ones(N,1) * interp1(Environment.Inputs.Times, Environment.Inputs.Values, t, Environment.Inputs.InterpMethod);
        end

    end

    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points') && isfield(Environment.Inputs,'Times')
        time = find(Environment.Inputs.Times<=t,1,'last');
        F = griddedInterpolant(Environment.Inputs.Points,Environment.Inputs.Values{time}, 'linear', 'nearest');
    end
    
    % Acquire data
    if t>=TSample(count)-epsilon
        t=Simulation.deltaT*round(t/Simulation.deltaT);
        
        xVec(count,:,:)=x;
        vVec(count,:,:)=v;
        uVec(count,:,:)=forces;
        
        count= count+1;
        
        % plot swarm
        if Simulation.drawON
            cla
            hold on
            if isfield(Environment,'Inputs') 
                if isfield(Environment.Inputs,'Points')
                imagesc(x_vec,y_vec,F(x_mesh',y_mesh')')
                elseif isfield(Environment.Inputs,'Times')
                set(gca,'Color',interp1(linspace(0,1,100),cmap,interp1(Environment.Inputs.Times, Environment.Inputs.Values, t, Environment.Inputs.InterpMethod)))
                end
            end
            if Simulation.drawTraj; plotTrajectory(xVec, false, [0,0.7,0.9], Simulation.drawTraj); end
            if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
            if isfield(LocalIntFunction, 'DistanceRange')
                plotSwarm(x, t, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), ~Simulation.recordVideo, ones(size(x,1), 1), false, Simulation.agentShape, Simulation.agentSize, x-v);
            else
                plotSwarm(x, t, inf, inf, ~Simulation.recordVideo, ones(size(x,1), 1), false, Simulation.agentShape, Simulation.agentSize, x-v);
            end
            
            if Simulation.recordVideo
                currFrame = getframe(gcf);
                writeVideo(video,currFrame);
            end
        end
    end
    
    % Integrate Agents' Dynamics
    [x, v, Dynamics] = integrateAgents(x, v, forces, Dynamics, Simulation.dT, envInput);
    
    % Compute boundaries interaction
    if isfield(Environment,'boundary')
    [x, v, out_agents] = boundaryInteraction(x, v, Environment.boundary);
    end
    
    % Update time
    t=t+Simulation.dT;
    t=Simulation.dT*round(t/Simulation.dT);
    
    if mod(t,100*Simulation.dT)==0
        waitbar(t / Simulation.Tmax, h);
    end
    

end

xVec(count,:,:)=x;
vVec(count,:,:)=v;
uVec(count,:,:)=forces;

if Simulation.recordVideo
    close(video);
    %disp(['Video saved in ', video.Path])
end

%% PLOTS

figure (20);
[x_m,y_m]=ndgrid(Environment.Inputs.Points{1},Environment.Inputs.Points{2});
surf(x_m,y_m,u_a);
shading interp
view(2)
colorbar;
clim([0 1])

% plot swarm
if Simulation.drawON
    cla
    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
        imagesc(x_vec,y_vec,F(x_mesh',y_mesh')')
        %colormap(cmap)
    end
    if Simulation.drawTraj; plotTrajectory(xVec, false, [0,0.7,0.9], Simulation.drawTraj); end
    if isfield(LocalIntFunction, 'DistanceRange')
        plotSwarm(squeeze(xVec(end,:,:)), t, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), flase, ones(size(x,1), 1), false, Simulation.agentShape, Simulation.agentSize, x-v);
    else
        plotSwarm(squeeze(xVec(end,:,:)), t, inf, inf, false, ones(size(x,1), 1), false, Simulation.agentShape, Simulation.agentSize, x-v);
    end
    if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
end

close(h); % Close the waitbar when done


end






