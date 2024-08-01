%
%SimulateDOMEexp Set the parameters and launch a simulation of the swarm.
%
%   See also: Launcher
%
%   Authors:    Andrea Giusti
%   Date:       2024
%

%% Clear environment
close all
clear

%% Parameters

defaultParamMicroorg;               % load default parameters to simulate microorganisms

% experiments_folder="C:\Users\david\OneDrive - Università di Napoli Federico II\Research\Data\DOME\";    % DAVIDE
experiments_folder="/Volumes/DOMEPEN/Experiments";                                          % ANDREA

% EUGLENA
% tag='E_switch_10';    experiment_name = fullfile("comparisons","Euglena_switch_10","combo5");  % switch10s combo 5
% tag='E_switch_10';    experiment_name = fullfile("comparisons","Euglena_switch_10","combo3");  % switch10s combo
% tag='E_switch_5';     experiment_name = fullfile("comparisons","Euglena_switch_5","combo");  % switch5s combo
% tag='E_switch_1';     experiment_name = fullfile("comparisons","Euglena_switch_1","combo");  % switch1s combo
% tag='E_75_ON';        experiment_name = fullfile("comparisons","Euglena_75_ON","combo");  % OFF-ON-OFF 75 combo
% tag='E_150_ON';       experiment_name = fullfile("comparisons","Euglena_150_ON","combo");  % OFF-ON-OFF 150 combo
% tag='E_255_ON';       experiment_name = fullfile("comparisons","Euglena_255_ON","combo");  % OFF-ON-OFF 255 combo
% tag='E_OFF';          experiment_name = fullfile("comparisons","Euglena_off","combo");  % OFF combo
% tag='E_ramp';         experiment_name = fullfile("comparisons","Euglena_ramp","combo");  % ramp combo

% tag='E_half_half';          experiment_name = "2023_06_14_E_6";    Environment.boundary = Simulation.arena * 2;
% tag='E_grad_centr_light';   experiment_name = "2023_06_12_E_3";    Environment.boundary = Simulation.arena * 2;
% tag='E_grad_centr_dark';    experiment_name = "2023_06_14_E_10";   Environment.boundary = Simulation.arena * 2;
% tag='E_grad_lateral';       experiment_name = "2023_06_13_E_16";   Environment.boundary = Simulation.arena * 2;
% tag='E_circle_light';       experiment_name = "2023_07_10_E_26";   Environment.boundary = Simulation.arena * 2;
% tag='E_circle_dark';        experiment_name = "2023_06_13_E_15";   Environment.boundary = Simulation.arena * 2;
% tag='E_circle_dark';        experiment_name = "2023_06_13_E_15";   Environment.boundary = Simulation.arena * 2;
% tag='E_BCLx36';             experiment_name = "2023_07_10_E_34";   N=N*2; Simulation.arena=Simulation.arena*2.5; Environment.boundary = Simulation.arena * 2; x0=randRect(N, Simulation.arena*2, D);

% VOLVOX
% tag='V_switch_10';        experiment_name = fullfile("comparisons","Volvox_switch_10","combo5");  % switch10s combo
% tag='V_switch_5';         experiment_name = fullfile("comparisons","Volvox_switch_5","combo");  % switch 5s
% tag='V_switch_1';         experiment_name = fullfile("comparisons","Volvox_switch_1","combo");  % switch 1s
% tag='V_255_ON';           experiment_name = fullfile("comparisons","Volvox_255_ON","combo");  % OFF-ON-OFF 255 combo
% tag='V_150_ON';           experiment_name = fullfile("comparisons","Volvox_150_ON","combo");  % OFF-ON-OFF 150 combo
% tag='V_75_ON';            experiment_name = fullfile("comparisons","Volvox_75_ON","combo");  % OFF-ON-OFF 150 combo
% tag='V_ramp';             experiment_name = fullfile("comparisons","Volvox_ramp","combo");  % ramp combo
% tag='V_OFF';              experiment_name = fullfile("comparisons","Volvox_OFF","combo");  % OFF combo

% tag='V_half_half';          experiment_name = "2023_07_05_V_33";    Environment.boundary = Simulation.arena * 2;
% tag='V_grad_centr_light';   experiment_name = "2023_07_05_Volvox_29";    Environment.boundary = Simulation.arena * 2;
% tag='V_grad_centr_dark';    experiment_name = "2023_07_05_Volvox_26";   Environment.boundary = Simulation.arena * 2;
tag='V_grad_lateral';       experiment_name = "2023_07_05_Volvox_30";   Environment.boundary = Simulation.arena * 2;
% tag='V_circle_light';        experiment_name = "2023_07_05_Volvox_22";   Environment.boundary = Simulation.arena * 2;
% tag='V_circle_dark';        experiment_name = "2023_07_05_Volvox_24";   Environment.boundary = Simulation.arena * 2;


% EUGLENA
% id_folder = 'C:\Users\david\OneDrive - Università di Napoli Federico II\Research\Data\DOME\identifications\2024_06_17_GB_absw_noalpha_narrow';  % folder with identification data
% id_folder = '/Volumes/DOMEPEN/Experiments/comparisons/Euglena_switch_10/combo5'; % switch10s
% identification_file_name = 'identification_GB_absw_noalpha_narrow.txt';

%VOLVOX
id_folder = '/Volumes/DOMEPEN/Experiments/comparisons/Volvox_switch_10/combo5'; % switch10s
identification_file_name = 'identification_GB_60s.txt';

% tag = 'test';

% outputDir = 'C:\Users\david\OneDrive - Università di Napoli Federico II\Research\Data\DOME\Simulations';
outputDir = '/Users/andrea/Library/CloudStorage/OneDrive-UniversitàdiNapoliFedericoII/Andrea_Giusti/Projects/DOME/simulations';
% outputDir = '/Users/andrea/Library/CloudStorage/OneDrive-UniversitàdiNapoliFedericoII/Andrea_Giusti/Projects/DOME/simulations/comparison/Identifications';
% [~,simulation_name,~]=fileparts(identification_file_name);

%% Loads experiment data

% load identification data and instantiate simulated agents
data_folder=fullfile(experiments_folder,experiment_name);
data_folder = strrep(data_folder,'_E_','_Euglena_');
data_folder = strrep(data_folder,'_V_','_Volvox_');

identification=readtable(fullfile(id_folder,identification_file_name));
ids=randsample(length(identification.agents),N, true, ones(length(identification.agents),1));
agents = identification(ids,:);

Dynamics=struct('model','PTWwithSignedInput', ...
    'avgSpeed',agents.mu_s, 'rateSpeed', agents.theta_s, 'sigmaSpeed', agents.sigma_s, 'gainSpeed', agents.alpha_s, 'gainDerSpeed', agents.beta_s,...
    'avgOmega',agents.mu_w, 'rateOmega', agents.theta_w, 'sigmaOmega', agents.sigma_w, 'gainOmega', agents.alpha_w, 'gainDerOmega', agents.beta_w,...
    'omega', normrnd(0,agents.std_w,N,1), 'oldInput', zeros(N,1));

% % median of the parameters
% Dynamics=struct('model','PTWwithSignedInput', ...
%     'avgSpeed',median(agents.mu_s), 'rateSpeed', median(agents.theta_s), 'sigmaSpeed', median(agents.sigma_s), 'gainSpeed', median(agents.alpha_s), 'gainDerSpeed', median(agents.beta_s),...
%     'avgOmega',median(agents.mu_w), 'rateOmega', median(agents.theta_w), 'sigmaOmega', median(agents.sigma_w), 'gainOmega', median(agents.alpha_w), 'gainDerOmega', median(agents.beta_w),...
%     'omega', normrnd(0,agents.std_w,N,1), 'oldInput', zeros(N,1));

% parameters for strong photodispersion
% Dynamics=struct('model','PTWwithSignedInput', ...
%     'avgSpeed',agents.mu_s, 'rateSpeed', agents.theta_s, 'sigmaSpeed', agents.sigma_s, 'gainSpeed',    5, 'gainDerSpeed', -25,...
%     'avgOmega',agents.mu_w, 'rateOmega', agents.theta_w, 'sigmaOmega', agents.sigma_w, 'gainOmega', -0.5, 'gainDerOmega', 2,...
%     'omega', normrnd(0,agents.std_w,N,1), 'oldInput', zeros(N,1));

% load inputs data
if isfile(fullfile(data_folder,'inputs.txt'))   % time varying inputs
    inputs=load(fullfile(data_folder,'inputs.txt'));
    u=inputs(:,1)/255;              %select blue channel and scale in [0,1]
    Environment.Inputs.Times  = Simulation.timeInstants;
    Environment.Inputs.Values = u(1:length(Simulation.timeInstants));
else                                            % spatial inputs
    u = loadInputPattern(data_folder, pattern_blurring);
    Environment.Inputs.Points = {linspace(-Simulation.arena(1),Simulation.arena(1),size(u,1))/2, linspace(-Simulation.arena(2),Simulation.arena(2),size(u,2))/2};
    Environment.Inputs.Values = flip(u,2);
end

%% Create Initial Conditions
%rng(1,'twister'); % set the randomn seed to have reproducible results

speeds0 = abs(normrnd(median(identification.mean_s),median(identification.std_s),N,1));
theta0 = 2*pi*rand(N,1)-pi;
v0 = speeds0 .* [cos(theta0), sin(theta0)];
%v0 = zeros(size(x0));

%% Run Simulation
[xVec, uVec, ~] = Simulator(x0, v0, Simulation, Dynamics, Render, GlobalIntFunction, LocalIntFunction, Environment);

%% Analysis
if smoothing
    xVec = movmean(xVec,3);
    %xVec = movmean(xVec,3);
end

% derivate quantities
[~, vVec_grad] = gradient(xVec, 1, Simulation.deltaT, 1);
vVec_fe = [diff(xVec); xVec(end,:,:)-xVec(end-1,:,:)]/Simulation.deltaT;
vVec_be = [xVec(2,:,:)-xVec(1,:,:); diff(xVec)]/Simulation.deltaT;
speed_grad = vecnorm(vVec_grad,2,3);
speed_fe = vecnorm(vVec_fe,2,3);
speed_be = vecnorm(vVec_be,2,3);
speed = speed_be;

theta = atan2(vVec_grad(:,:,2), vVec_grad(:,:,1));
% angular velocity - gradient
for i=1:length(Simulation.timeInstants)-1
    omega_grad(i,:) = angleBetweenVectors(squeeze(vVec_grad(i,:,:)),squeeze(vVec_grad(i+1,:,:)))';
end
omega_grad(length(Simulation.timeInstants),:) = angleBetweenVectors(squeeze(vVec_grad(length(Simulation.timeInstants)-1,:,:)),squeeze(vVec_grad(length(Simulation.timeInstants),:,:)))';
omega_grad=omega_grad/Simulation.deltaT;

% angular velocity - Forward Euler
for i=1:length(Simulation.timeInstants)-1
    omega_fe(i,:) = angleBetweenVectors(squeeze(vVec_fe(i,:,:)),squeeze(vVec_fe(i+1,:,:)))';
end
omega_fe(length(Simulation.timeInstants),:) = angleBetweenVectors(squeeze(vVec_fe(length(Simulation.timeInstants)-1,:,:)),squeeze(vVec_fe(length(Simulation.timeInstants),:,:)))';
omega_fe=omega_fe/Simulation.deltaT;

% angular velocity - Backward Euler
omega_be(1,:) = angleBetweenVectors(squeeze(xVec(2,:,:)-xVec(1,:,:)),squeeze(xVec(3,:,:)-xVec(2,:,:)))';
omega_be(2,:) = angleBetweenVectors(squeeze(xVec(2,:,:)-xVec(1,:,:)),squeeze(xVec(3,:,:)-xVec(2,:,:)))';
for i=3:length(Simulation.timeInstants)
    omega_be(i,:) = angleBetweenVectors(squeeze(vVec_be(i-1,:,:)),squeeze(vVec_be(i,:,:)))';
end
omega_be=omega_be/Simulation.deltaT;

% angular velocity - Central Derivative
omega_ce(1,:) = angleBetweenVectors(squeeze(xVec(2,:,:)-xVec(1,:,:)),squeeze(xVec(3,:,:)-xVec(2,:,:)))';
for i=2:length(Simulation.timeInstants)-1
    omega_ce(i,:) = angleBetweenVectors(squeeze(xVec(i,:,:)-xVec(i-1,:,:)),squeeze(xVec(i+1,:,:)-xVec(i,:,:)))';
end
omega_ce(length(Simulation.timeInstants),:) = angleBetweenVectors(squeeze(xVec(end-1,:,:)-xVec(end-2,:,:)),squeeze(xVec(end,:,:)-xVec(end-1,:,:)))';
omega_ce=omega_ce/Simulation.deltaT;

omega = omega_be;

%% PLOTS




[~,indices_inWindow] = getInWindow(squeeze(xVec(end,:,:)), Render.window);
xFinal_inWindow = squeeze(xVec(end,indices_inWindow,:));
xSemiFinal_inWindow = squeeze(xVec(end-1,indices_inWindow,:));

% create output folder, save data and parameters

if outputDir
    if ~exist('simulation_name','var') || isempty(simulation_name)
        counter=1;
        if ~tag
            tag=Dynamics.model;
        end
        while exist(fullfile(outputDir,[datestr(now, 'yyyy_mm_dd_'),tag,'_',num2str(counter)]),'dir')
            counter=counter+1;
        end
        simulation_name = [datestr(now, 'yyyy_mm_dd_'),tag,'_',num2str(counter)];
    end
    output_path=fullfile(outputDir, simulation_name);
    mkdir(output_path)
    disp('Saving data in ' + string(output_path))
    save(fullfile(output_path, 'data'))
    
    fileID = fopen(fullfile(output_path, 'parameters.txt'),'wt');
    fprintf(fileID,'SimulateDOMEexp\n\n');
    fprintf(fileID,'Experiment: %s\n',data_folder);
    fprintf(fileID,'Identification: %s\n\n',fullfile(id_folder,identification_file_name));
    fprintf(fileID,'Date: %s\n',datestr(now, 'dd/mm/yy'));
    fprintf(fileID,'Time: %s\n\n',datestr(now, 'HH:MM'));
    fprintf(fileID,'Parameters:\n\n');
    fprintf(fileID,'N= %d\n',N);
    fprintf(fileID,'D= %d\n',D);
    fprintStruct(fileID,Simulation)
    fprintf(fileID,'Dynamics:\n');
    fprintStruct(fileID,Dynamics)
    fprintf(fileID,'GlobalIntFunction:\n');
    fprintStruct(fileID,GlobalIntFunction)
    fprintf(fileID,'LocalIntFunction:\n');
    fprintStruct(fileID,LocalIntFunction)
    fprintf(fileID,'Environment:\n');
    fprintStruct(fileID,Environment)
    fprintf(fileID,'Render:\n');
    fprintStruct(fileID,Render)
    fprintf(fileID,'smoothing= %s\n',mat2str(smoothing));
    fprintf(fileID,'delta= %.2f\n',delta);
    fclose(fileID);
end

if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
    % SWARM initial
    figure
    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
        plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values, Render.window)
    end
    if Render.drawTraj; plotTrajectory(xVec, false, [0,0.7,0.9], Render.drawTraj); end
    if isfield(LocalIntFunction, 'DistanceRange')
        plotSwarmInit(x0, 0, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), Render.window, [Render.window(2)-Render.window(1), Render.window(4)-Render.window(3)]/2, false, false, false, Render.agentShape, Render.agentSize, Render.agentsColor, squeeze(xVec(2,:,:)));
    else
        plotSwarmInit(x0, 0, inf, inf, Render.window, [Render.window(2)-Render.window(1), Render.window(4)-Render.window(3)]/2, false, false, false, Render.agentShape, Render.agentSize, Render.agentsColor, squeeze(xVec(2,:,:)));
    end
    if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
    if outputDir
        saveas(gcf, fullfile(output_path, 'x_0'))
        saveas(gcf, fullfile(output_path, 'x_0'),'png')
    end
    
    % SWARM final
    figure
    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
        plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values, Render.window)
    end
    if Render.drawTraj; plotTrajectory(xVec, false, [0,0.7,0.9], Render.drawTraj); end
    if isfield(LocalIntFunction, 'DistanceRange')
        plotSwarmInit(xFinal_inWindow, Simulation.Tmax, LocalIntFunction.DistanceRange(1), LocalIntFunction.DistanceRange(2), Render.window, [Render.window(2)-Render.window(1), Render.window(4)-Render.window(3)]/2, false, false, false, Render.agentShape, Render.agentSize, Render.agentsColor, xSemiFinal_inWindow);
    else
        plotSwarmInit(xFinal_inWindow, Simulation.Tmax, inf, inf, Render.window, [Render.window(2)-Render.window(1), Render.window(4)-Render.window(3)]/2, false, false, false, Render.agentShape, Render.agentSize, Render.agentsColor, xSemiFinal_inWindow);
    end
    if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
    if outputDir
        saveas(gcf, fullfile(output_path, 'x_final'))
        saveas(gcf, fullfile(output_path, 'x_final'),'png')
    end
end

% figure % colored trajectories
% hold on
% colors = get(gca, 'ColorOrder');
% final = Simulation.Tmax;
% x_inWindow = xVec(:,indices_inWindow,:);
% for i=1:size(x_inWindow,2)
%     c = colors(mod(i-1,7)+1,:);
%     plot(x_inWindow(1:final,i,1),x_inWindow(1:final,i,2), 'color', c, 'LineWidth',1.25);
%     ang = atan2(x_inWindow(final,i,2)-x_inWindow(final-1,i,2),x_inWindow(final,i,1)-x_inWindow(final-1,i,1));
%     plot_singleRod(x_inWindow(final,i,:), ang, Render.agentSize, Render.agentSize/2, c);
%     %plot(x_inWindow(final,i,1),x_inWindow(final,i,2),'o', 'color', c, 'MarkerFaceColor', c);
% end
% xticks([])
% yticks([])
% axis('equal')
% axis(Render.window)
% box on
% set(gca,'Color',[0.05, 0.05, 0.05]); set(gcf, 'InvertHardCopy', 'off'); % dark background
% if outputDir
%     fig=gcf; fig.Units = fig.PaperUnits; fig.PaperSize = fig.Position(3:4); % set correct pdf size
%     saveas(fig,fullfile(output_path, 'trajectories_colored'))
%     saveas(fig,fullfile(output_path, 'trajectories_colored'),'pdf')
%     saveas(fig,fullfile(output_path, 'trajectories_colored'),'png')
% end

% SPATIAL INPUTS
if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
    [density_by_input_sim, bins] = agentsDensityByInput(Environment.Inputs.Points, Environment.Inputs.Values, xFinal_inWindow, Render.window, n_bins);
    [c_coeff_sim, norm_slope_sim, coefficents] = linearDependence((bins(1:end-1)+bins(2:end))'/2, density_by_input_sim');
    
    figure % simulation light distribution
    bar((bins(1:end-1)+bins(2:end))/2,density_by_input_sim, 1)
    hold on
    plot(bins,coefficents(1)+coefficents(2)*bins,LineWidth=2);
    xlabel('Input intensity')
    ylabel('Density of agents')
    yticks([0:0.25:1]);
    text(max(bins),max(density_by_input_sim)*1.1,['\rho=',num2str(c_coeff_sim,'%.2f')],'HorizontalAlignment','right','FontSize',14)
    text(max(bins),max(density_by_input_sim)*1.05,['norm slope=',num2str(norm_slope_sim,'%.2f')],'HorizontalAlignment','right','FontSize',14)
    ylim([0,max(density_by_input_sim)*1.15])
    xlim([-0.1,1.1])
    xticks(round(bins,2))
    title('Simulated light distribution')
    if outputDir
        saveas(gcf, fullfile(output_path, 'light_distribution'))
        saveas(gcf, fullfile(output_path, 'light_distribution'),'png')
    end
    
    % experimental positions get distribution wrt light intensity
    mask = detectObjects(data_folder, background_sub, brightness_thresh);
    %[density_by_input_exp, bins, norm_slope_exp, c_coeff_exp, coefficents, ~,~, u_values_exp] = agentsDensityByInput(Environment.Inputs.Points, Environment.Inputs.Values, mask, Render.window);
    [density_by_input_exp, bins] = agentsDensityByInput(Environment.Inputs.Points, Environment.Inputs.Values, mask, Render.window, n_bins);
    [c_coeff_exp, norm_slope_exp, coefficents] = linearDependence((bins(1:end-1)+bins(2:end))'/2, density_by_input_exp');
    
    figure
    x_vec = linspace(Render.window(1),Render.window(2),size(mask,2));
    y_vec = linspace(Render.window(3),Render.window(4),size(mask,1));
    box on
    hold on
    cmap = linspace2([1,1,1], [1,0.5,0.5], 100)';
    colormap(cmap)
    imagesc(x_vec,y_vec,flip(u'))
    I=imagesc(x_vec,y_vec,cat(3,zeros(size(mask)),zeros(size(mask)),mask));
    set(I, 'AlphaData', mask);
    axis('equal')
    axis(Render.window)
    xticks([])
    yticks([])
    title('Experimental')
    if outputDir
        saveas(gcf, fullfile(output_path, 'exp_positions'))
        saveas(gcf, fullfile(output_path, 'exp_positions'),'png')
    end
    
    figure % experimental light distribution
    bar((bins(1:end-1)+bins(2:end))/2,density_by_input_exp, 1)
    hold on
    plot(bins,coefficents(1)+coefficents(2)*bins,LineWidth=2);
    xlabel('Input intensity')
    ylabel('Density of agents')
    yticks([0:0.25:1]);
    text(max(bins),max(density_by_input_exp)*1.1,['\rho=',num2str(c_coeff_exp,'%.2f')],'HorizontalAlignment','right','FontSize',14)
    text(max(bins),max(density_by_input_exp)*1.05,['norm slope=',num2str(norm_slope_exp,'%.2f')],'HorizontalAlignment','right','FontSize',14)
    ylim([0,max(density_by_input_exp)*1.15])
    xlim([-0.1,1.1])
    xticks(round(bins,2))
    title('Experimental light distribution')
    box
    if outputDir
        saveas(gcf, fullfile(output_path, 'exp_light_distribution'))
        saveas(gcf, fullfile(output_path, 'exp_light_distribution'),'png')
    end
    
    figure % difference between light distribution
    tvd = 0.5 * norm(density_by_input_exp-density_by_input_sim,1); % Total Variation Distance
    hold on
    b_exp = bar((bins(1:end-1)+bins(2:end))/2,density_by_input_exp, 1, FaceColor = 'b', FaceAlpha = 0.5);
    b_sim = bar((bins(1:end-1)+bins(2:end))/2,density_by_input_sim, 1, FaceColor = 'k', FaceAlpha = 0.4);
    %[f,xi] = ksdensity(u_values_exp, support=[-0.001,1.001], BoundaryCorrection='reflection');
    %f=f/sum(f);
    %plot(xi,f)
    legend({'REAL','SIMULATED'},'FontSize',14)
    xlabel('Input intensity','FontSize',14)
    ylabel('Density of agents','FontSize',14)
    yticks([0:0.25:1]);
    text(mean(bins),max(density_by_input_exp)*1.10,['TVD=',num2str(tvd,'%.2f')],'HorizontalAlignment','center','FontSize',14)
    ylim([0,max(density_by_input_exp)*1.15])
    xlim([-0.1,1.1])
    xticks(round(bins,2))
    box
    if outputDir
        saveas(gcf, fullfile(output_path, 'difference_light_distribution'))
        saveas(gcf, fullfile(output_path, 'difference_light_distribution'),'png')
    end
    
else % TEMPORAL INPUTS
    
    [metrics_of_interest] = compareResults({data_folder,output_path}, output_path, true, Render);
    
end

% figure % TIME PLOT - SPEED and ANGULAR VELOCITY
% subplot(2,4,[1 2 3])
% plotWithShade(Simulation.timeInstants, median(speed,2), min(speed, [], 2), max(speed, [], 2), 'b', 0.3);
% if isfield(Environment,'Inputs')
%     highlightInputs(Environment.Inputs.Times, Environment.Inputs.Values, 'r', 0.25)
% end
% xlabel('t [s]')
% ylabel('speed')
% rng=ylim;
% box on
% subplot(2,4,4)
% h=histogram(speed(:),'Orientation','horizontal');
% ylim(rng);
% set(gca,'xtick',[])
% subplot(2,4,[5 6 7])
% plotWithShade(Simulation.timeInstants, median(abs(omega),2), min(abs(omega), [], 2), max(abs(omega), [], 2), 'b', 0.3);
% %plotWithShade(Simulation.timeInstants, median(omega,2), min(omega, [], 2), max(omega, [], 2), 'b', 0.3);
% if isfield(Environment,'Inputs')
%     highlightInputs(Environment.Inputs.Times, Environment.Inputs.Values, 'r', 0.25)
% end
% xlabel('t [s]')
% ylabel('ang. vel. [rad/s]')
% rng=ylim;
% box on
% subplot(2,4,8)
% h=histogram(abs(omega(:)),'Orientation','horizontal');
% %h=histogram(omega(:),'Orientation','horizontal');
% ylim(rng);
% set(gca,'xtick',[])
% if outputDir
%     saveas(gcf,fullfile(output_path, 'time_plot'))
%     saveas(gcf,fullfile(output_path, 'time_plot'),'png')
% end
%
% figure % SCATTER PLOT - SPEED and ANGULAR VELOCITY
% s=scatterhist(speed(:),abs(omega(:)), 'Location','NorthEast','Direction','out');
% xlabel(s,'speed')
% ylabel(s,'ang. vel. [rad/s]')
% s(1).YAxisLocation = 'left';
% s(1).XAxisLocation = 'bottom';
% s(2).Position = [0.1    0.82   0.7    0.125];
% s(3).Position = [0.82   0.1    0.125    0.7];
% s(1).Position(3) = 0.7;
% s(1).Position(4) = 0.7;
% if outputDir
% saveas(gcf,fullfile(output_path, 'scatter_plot'))
% saveas(gcf,fullfile(output_path, 'scatter_plot'),'png')
% end
%
% figure % SCATTER PLOT - MEAN SPEED and ANGULAR VELOCITY
% s=scatterhist(mean(speed,1),mean(abs(omega),1), 'Location','NorthEast','Direction','out');
% xlabel(s,'mean speed [px/s]')
% ylabel(s,'mean ang. vel. [rad/s]')
% s(1).YAxisLocation = 'left';
% s(1).XAxisLocation = 'bottom';
% s(2).Position = [0.1    0.82   0.7    0.125];
% s(3).Position = [0.82   0.1    0.125    0.7];
% s(1).Position(3) = 0.7;
% s(1).Position(4) = 0.7;
% if outputDir
% saveas(gcf,fullfile(output_path, 'scatter_plot_mean'))
% saveas(gcf,fullfile(output_path, 'scatter_plot_mean'),'png')
% end

% figure % CORRELETION PLOT - SPEED and ANGULAR VELOCITY
% corrplot([speed(1:end-1,1),speed(2:end,1),omega(1:end-1,1),omega(2:end,1)],VarNames={"v_k", "v_{k+1}", "\omega_k", "\omega_{k+1}"})
% if outputDir
% saveas(gcf,fullfile(output_path, 'scatter_plot'))
% saveas(gcf,fullfile(output_path, 'scatter_plot'),'png')
% end

if Render.recordVideo
    SSdir = getSSfolder();
    copyfile(fullfile(SSdir,'Output','video.mp4'),output_path)
end

% pause
% close all
