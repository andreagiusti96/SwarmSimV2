%
%SimulateDOMEexp Set the parameters and launch a simulation of the swarm.
%
%   See also: Launcher
%
%   Authors:    Davide Salzano
%   Date:       2024
%

%% Clear environment
% close all
clear all

%% Parameters
defaultParamMicroorg;               % load default parameters to simulate microorganisms


tag='CircleStatic';

%Folder with the parameters of the agents identified from experiments
id_folder = 'C:\Users\david\OneDrive - Università di Napoli Federico II\Research\Data\DOME\identifications\2024_06_17_GB_absw_noalpha_narrow';  % folder with identification data
identification_file_name = 'identification_GB_absw_noalpha_narrow.txt';

%Output directory
outputDir = 'C:\Users\david\OneDrive - Università di Napoli Federico II\Research\Data\DOME\Simulations';
% outputDir = '/Users/andrea/Library/CloudStorage/OneDrive-UniversitàdiNapoliFedericoII/Andrea_Giusti/Projects/DOME/simulations/comparison/Identifications';
% [~,simulation_name,~]=fileparts(identification_file_name);

%% Loads experiment data

% load identification data and instantiate simulated agents
identification=readtable(fullfile(id_folder,identification_file_name));
ids=randsample(length(identification.agents),N, true, ones(length(identification.agents),1));
agents = identification(ids,:); 

Dynamics=struct('model','PTWwithSignedInput', ...
    'avgSpeed',agents.mu_s, 'rateSpeed', agents.theta_s, 'sigmaSpeed', agents.sigma_s, 'gainSpeed', agents.alpha_s, 'gainDerSpeed', agents.beta_s,...
    'avgOmega',agents.mu_w, 'rateOmega', agents.theta_w, 'sigmaOmega', agents.sigma_w, 'gainOmega', agents.alpha_w, 'gainDerOmega', agents.beta_w,...
    'omega', normrnd(0,agents.std_w,N,1), 'oldInput', zeros(N,1));


%% %%%%%%%%%%%%% DEFINITION OF THE CONTROL GOAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define a grid over the arena
Environment.Inputs.Points = {linspace(-Simulation.arena(1),Simulation.arena(1),1920)/2, linspace(-Simulation.arena(2),Simulation.arena(2),1080)/2};

%Define a spatial pattern

% ----------Circular Pattern (of a given radius)--------------
% radii = 700;
% Environment.Inputs.Values={};
% 
% %Create the circle adjusting with the aspect ratio
% for i=1:length(radii)
%     as_rat=(Simulation.arena(1)/Simulation.arena(2))^2;
%     [X,Y]= meshgrid(Environment.Inputs.Points{1},Environment.Inputs.Points{2});
%     Environment.Inputs.Values{i}= 0.5*double(((X).^2 + (Y.*as_rat).^2 >= radii(i)^2)) + 0.5*double(((X).^2 + (Y.*as_rat).^2 >= (0.5*radii(i))^2)); 
% end
% 
% Environment.Inputs.Times = linspace(0,160,3);
% Environment.Inputs.Times = 0;

% --------Inverse of a Gaussian Distribution -----------------

mu=[0 0];
Sigma=[200^2 0;0 200^2];
ag_d=mvnrnd(mu,Sigma,N);
rho_d=density_agents(ag_d,[length(Environment.Inputs.Points{1}),length(Environment.Inputs.Points{2})],40,true);
u=1 - rho_d;
u=1*(u-min(min(u)))./(max(max(u))-min(min(u)));
Environment.Inputs.Values = {u};
Environment.Inputs.Times = 0;

%% DEFINITION OF THE CONTROL FUNCTION

% % ---------------- PI Controller ---------------------
% %Controller parameters
% Ctrl_pars.pars          = Environment.Inputs.Points;
% Ctrl_pars.u_FF          = u;
% Ctrl_pars.k_p           = -0.003;%-0.03;      %-100000        %-1
% Ctrl_pars.k_i           = -.1;%-50;        %-1000          %-0.01;
% Ctrl_pars.arena         = Simulation.arena;
% Ctrl_pars.Est_grid      = 40;
% Ctrl_pars.dt            = 100*Simulation.dT;
% Ctrl_pars.hist          = true;
% Ctrl_pars.hist_0        = zeros([length(Environment.Inputs.Points{1}),length(Environment.Inputs.Points{2})]);
% 
% 
% %Control Function
% Environment.Inputs.Input_function = @(x,z)FF_PI(x,rho_d,Ctrl_pars,z);


%------------- Intermittent Feed-Forward Action -------------------------

%Controller parameters
Ctrl_pars.pars          = Environment.Inputs.Points;
Ctrl_pars.u_FF          = u;
Ctrl_pars.arena         = Simulation.arena;
Ctrl_pars.dt            = 100*Simulation.dT;
Ctrl_pars.hist          = true;
Ctrl_pars.hist_0        = [0;0;1];
Ctrl_pars.t_on          = 50;
Ctrl_pars.t_off         = 5;


%Control Function
Environment.Inputs.Input_function = @(x,z)FF_Intermittent(x,Ctrl_pars,z);


 
%% Create Initial Conditions
speeds0 = abs(normrnd(median(identification.mean_s),median(identification.std_s),N,1));
theta0 = 2*pi*rand(N,1)-pi;
v0 = speeds0 .* [cos(theta0), sin(theta0)];



%% Run Simulation
[xVec, uVec, ~] = Simulator(x0, v0, Simulation, Dynamics, GlobalIntFunction, LocalIntFunction, Environment, Ctrl_pars);
                    
%% Plot and save the data
Spatial_plots2;
