%
%defaultParam Set the default values of the parameters.
%   It is called by launcher scripts such as Launcher.
%
%   See also: Launcher, SequentialLauncher
%   
%   Authors:    Andrea Giusti
%   Date:       2023
%

%% Add subfolders to the Matlab path
current_folder = fileparts(which('defaultParam'));
addpath(genpath(current_folder));

%% Default Parameters

% Directory to save the results of the simulations.
% Set outputDir='' to prevent automatic saving.
outputDir='./Output';
% outputDir='';

N=40;                      % number of agents
D=2;                        % number of dimensions [2 or 3]

LinkNumber=6*(D-1);         % number of links per agent in the lattice configuration (L)
                            % If D=2 then 6=triangular lattice, 4=square lattice, 3=hexagonal lattice
                            % If D=3 then 6=cubic lattice, 12=thetradic-octaedric lattice
                            
Rmax= (sqrt(5-D)+1)/2;      % maximum lenght of a link (R_a). Must be in [1; Rnext]
MaxSensingRadius=3;         % sensing radius of the agents (R_s)

smoothing = false;          % smooth temporal data with moving average

%% Simulation parameters
% All these fields are mandatory
Simulation=struct();
Simulation.Tmax =   5;     % maximum simulation time (simulation is stopped earlier if steady state is reached)
Simulation.deltaT = 0.1;    % sampling time step
Simulation.dT =     0.001;  % integration time step
Simulation.arena =  [10,10];% size of the simulation window
Simulation.timeInstants = [0:Simulation.deltaT:Simulation.Tmax];

%% Initial conditions
% Initial positions
delta=(Rmax-1) * 0.5;               % maximum displacement of the initial positions. delta<=(Rmax-1)/2 preserves all the links
x0=randCircle(N, 3, D);             % initial conditions drawn from a uniform disc
%x0 = normrnd(0,0.1*sqrt(N),N,D);    % initial conditions drawn from a normal distribution
%x0 = perfectLactice(N, LinkNumber, D, true, true, (floor(nthroot(N,D)+1))^D); % initial conditions on a correct lattice
%x0 = perfectLactice(N, LinkNumber, D) + randCircle(N, delta, D); % initial conditions on a deformed lattice
%x0 = perfectLactice(N, LinkNumber, D, true, true, (floor(nthroot(N,D)+1))^D ) + randCircle(N, delta, D); % initial conditions on a deformed lattice

% Initial velocities (only for SecondOrder, PersistentTurningWalker and LevyWalk)
avgSpeed0   = 0.1;
sigmaSpeed0 = 0.1;
speeds0 = abs(normrnd(avgSpeed0,sigmaSpeed0,N,1));
theta0 = 2*pi*rand(N,1)-pi;
v0 = speeds0 .* [cos(theta0), sin(theta0)];
% v0 = zeros(N,D);

%% Dynamic model of the agents
% These parameters are used in integrateAgents.

Dynamics=struct('model','FirstOrder', 'sigma',0, 'vMax',inf);
% Dynamics=struct('model','SecondOrder', 'sigma',0, 'vMax', inf);
%Dynamics=struct('model','PTW', 'avgSpeed',avgSpeed0, 'rateSpeed', 1, 'sigmaSpeed', sigmaSpeed0, 'rateOmega', 0.5, 'sigmaOmega', 3, 'omega', normrnd(0,0,N,1));
% Dynamics=struct('model','PTWwithInput', ...
%     'avgSpeed',avgSpeed0, 'rateSpeed', 1, 'sigmaSpeed', sigmaSpeed0, 'gainSpeed', -1, 'gainDerSpeed', -1,...
%     'rateOmega', 1, 'sigmaOmega', 0, 'gainOmega', 1, 'gainDerOmega', 1,'omega', normrnd(0,1,N,1), 'oldInput', zeros(N,1));
%Dynamics=struct('model','PTWcoupled', 'avgSpeed', avgSpeed0, 'rateSpeed', 1, 'sigmaSpeed', 1, 'rateOmega', 1, 'sigmaOmega', @(x)2*max(1-x/3,0), 'omega', zeros(N,1));
%Dynamics=struct('model','LevyWalk', 'alpha',0.005, 'sigma', 0);

%% Global interaction function for long distance interactions
% These parameters are used in globalInteractionForce.

GlobalIntFunction=struct('function','Lennard-Jones','parameters',[0.5, (D-1)*12], 'MaxSensingRadius', MaxSensingRadius, 'Gain', 20);
% GlobalIntFunction=struct('function','PowerLaw-FiniteCutoff','parameters',[1, Rmax], 'MaxSensingRadius', MaxSensingRadius, 'Gain', 0.5);
%GlobalIntFunction=struct('function','Spears','parameters', [2 35]);  %from Spears2004
%GlobalIntFunction=struct('function','Morse','parameters',[0.2, 2]);
%GlobalIntFunction=struct('function','Modified-LJ','parameters',[]);  %from Torquato2009 for hexagonal lattice
%GlobalIntFunction=struct('function','None');

%% Local interaction function for short distance interactions
% These parameters are used in localInteractionForce.
% If LocalIntFunction has a 'DistanceRange' field it is used to compute and 
% plot the links between the agents.

% LocalIntFunction=struct('function','Linear', 'LinkNumber',LinkNumber, 'DistanceRange', [0.6, 1.1], 'Gain', 1);
LocalIntFunction=struct('function','None', 'DistanceRange', [0, Rmax]);
% LocalIntFunction=struct('function','None');

% Set an optional rotation matrix to apply non-radial local forces.
% Normal intercations can be used to form square lattices (only in 2D).
% LocalIntFunction.Rotation = [0 1; -1 0];  % 90deg rotation matrix (optional)

%% Simulation Environment
Environment = struct();
% Time-varying inputs
% Environment.Inputs.InterpMethod = 'previous'; % Use previous input until switching to new input value
% Environment.Inputs.InterpMethod = 'linear';   % Gradually change from previous to next input value
% Environment.Inputs.Times  = [0, 5, 10]; 
% Environment.Inputs.Values = [0, 1, 1];

% Spatial inputs
% Environment.Inputs.Points = {[-3:3], [-5:5]};
% Environment.Inputs.Values = linspace(-1,1,length(Environment.Inputs.Points{1}))' * ones(1,length(Environment.Inputs.Points{2}));


%% Render parameters
Render.window = [-Simulation.arena(1),Simulation.arena(1),-Simulation.arena(2),Simulation.arena(2)]/2; % size of the simulation window
Render.drawON=false;                % draw swarm during simulation (if N is large slows down the simulation)
Render.drawTraj=0;                  % draw trajectories of the agents (if N is large slows down the simulation)
Render.recordVideo=false;           % record video of the simulation (if true drawON must be true)
Render.frameRate = 1/Simulation.deltaT * 6;
Render.time_plot = 0:45:Simulation.Tmax;
Render.all_time = 0:Simulation.deltaT:Simulation.Tmax;
Render.shaded = true;

% Light palette - red inputs
Render.agentsColor = [0 0 1]; % blue
Render.sim_c =      [0 0 0]; % black
Render.exp_c =      [0 0 1]; % blue
Render.cmap_inputs = linspace2([1,1,1], [1,0.5,0.5], 100)';  % light red

% Agents
Render.agentShape = ".";          % shape to plot the agents "rod" or any defualt marker key ('.','+','diamond',...)
Render.agentSize = 20; 
