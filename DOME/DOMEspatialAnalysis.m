clear
close all

experiments_folder = '/Volumes/DOMEPEN/Experiments';

% EUGLENA
% tag='Euglena_half_half';        experiments = {'2023_06_12_E_2','2023_06_14_E_6','2023_06_15_E_12','2023_06_26_E_29','2023_06_26_E_30','2023_06_23_E_1','2023_06_23_E_2','2023_06_26_E_2'};
% tag='Euglena_grad_centr_light'; experiments = {'2023_06_12_E_4','2023_06_14_E_7','2023_06_15_E_14','2023_06_23_E_5','2023_06_23_E_6','2023_06_26_E_5','2023_06_26_E_6','2023_06_26_E_33'};
% tag='Euglena_grad_centr_dark';  experiments = {'2023_06_23_E_7','2023_06_23_E_8','2023_06_23_E_9','2023_06_26_E_7','2023_06_26_E_8','2023_06_26_E_34','2023_06_26_E_35','2023_07_10_E_23'};
% tag='Euglena_grad_lateral';     experiments = {'2023_06_13_E_16','2023_06_14_E_8','2023_06_15_E_13','2023_06_23_E_3','2023_06_26_E_3','2023_06_26_E_4','2023_06_26_E_31','2023_06_26_E_32'};
% tag='Euglena_circle_light';     experiments = {'2023_06_15_E_16','2023_06_23_E_10','2023_06_23_E_11','2023_06_26_E_9','2023_06_26_E_10','2023_06_26_E_36','2023_06_26_E_37','2023_07_10_E_26'};
% tag='Euglena_circle_dark';      experiments = {'2023_06_13_E_15','2023_06_15_E_17','2023_06_23_E_13','2023_06_26_E_11','2023_06_26_E_12','2023_06_26_E_39','2023_07_10_E_25','2023_07_10_E_22'};
% tag='Euglena_BCL_dark_x36';     experiments = {"2023_07_10_E_30","2023_07_10_E_34","2023_07_10_E_35"};
% tag='Euglena_BCL_light_x36';    experiments = {"2023_07_10_E_36","2023_07_10_E_37","2023_07_10_E_38"};
% tag='Euglena_spatial_mix';      experiments = {'2023_07_10_E_34','2023_06_26_E_11','2023_07_10_E_26','2023_06_23_E_9','2023_06_14_E_7','2023_06_14_E_6'};

% VOLVOX
tag='Volvox_half_half';        experiments = {'2023_07_04_V_19','2023_07_04_V_20','2023_07_05_V_11','2023_07_05_V_32','2023_07_05_V_33','2023_07_07_V_1','2023_07_07_V_2'};
% tag='Volvox_grad_lateral';     experiments = {'2023_06_08_V_14','2023_06_08_V_16','2023_07_04_V_21','2023_07_04_V_22','2023_07_05_V_12','2023_07_05_V_30','2023_07_05_V_31','2023_07_07_V_3'};
% tag='Volvox_grad_centr_light'; experiments = {'2023_06_08_V_17','2023_07_04_V_23','2023_07_04_V_24','2023_07_05_V_13','2023_07_05_V_28','2023_07_05_V_29','2023_07_06_V_6','2023_07_07_V_4'};
% tag='Volvox_grad_centr_dark';  experiments = {'2023_07_04_V_25','2023_07_04_V_26','2023_07_05_V_14','2023_07_05_V_26','2023_07_05_V_27','2023_07_06_V_7','2023_07_07_V_5'};
% tag='Volvox_circle_light';     experiments = {'2023_06_08_V_19','2023_06_08_V_20','2023_07_04_V_27','2023_07_04_V_28','2023_07_05_V_15','2023_07_05_V_16','2023_07_05_V_21','2023_07_05_V_22','2023_07_05_V_23','2023_07_05_V_34','2023_07_07_V_6'};
% tag='Volvox_circle_dark';      experiments = {'2023_07_04_V_29','2023_07_04_V_30','2023_07_05_V_17','2023_07_05_V_18','2023_07_05_V_19','2023_07_05_V_20','2023_07_05_V_24','2023_07_05_V_25','2023_07_05_V_35','2023_07_07_V_7'};


defaultParamMicroorg;
background_sub = true;      % use background subtraction for object detection (spatial experiments)

n_bins         = 3;      % number of bins for light distribution (set to 5 for BCL, 3 for other exp)

deltaT = 0.5;
dT = 0.01;
window = [0, 1920, 0, 1080];

%% LOAD
current_folder = fileparts(which('AnalyseDOMEspatial'));
addpath(genpath(current_folder));

main_fig = figure('Position',[100 100 1900 600]);
cmap = linspace2([1,1,1], [1,0.5,0.5], 100)';

for i = 1:length(experiments)
    experiments{i} = strrep(experiments{i},'_E_','_Euglena_');
    experiments{i} = strrep(experiments{i},'_V_','_Volvox_');
    data_folder = fullfile(experiments_folder,experiments{i});
    
    % get final agents positions and inputs
    mask = detectObjects(data_folder, background_sub, brightness_thresh);
    u = loadInputPattern(data_folder, pattern_blurring);
    Inputs.Points = {linspace(window(1),window(2),size(u,1)), linspace(window(3),window(4),size(u,2))};
    Inputs.Values = flip(u,2);
    
    % get distribution wrt light intensity
    [density_by_input(i,:), bins, agents_by_input(i,:), pixels_by_input(i,:)] = agentsDensityByInput(Inputs.Points, Inputs.Values, mask, window, n_bins);
    [c_coeff(i), norm_slope(i), coefficents] = linearDependence((bins(1:end-1)+bins(2:end))'/2, density_by_input(i,:)');

    
    
    %% PLOTS
    x_vec = linspace(window(1),window(2),size(mask,2));
    y_vec = linspace(window(3),window(4),size(mask,1));
    % figure; imagesc(x_vec,y_vec,img_grey); axis('equal'); axis(window); xticks([]); yticks([])
    % figure; imagesc(x_vec,y_vec,background); axis('equal'); axis(window); xticks([]); yticks([])
    % figure; imagesc(x_vec,y_vec,foreground); axis('equal'); axis(window); xticks([]); yticks([])
    %figure; imagesc(x_vec,y_vec,mask); axis('equal'); title(['mask=',num2str(brightness_thresh)])
    
    set(0, 'CurrentFigure', main_fig) % comparison final positions
    subplot(2,length(experiments),i)
    box on
    hold on
    colormap(cmap)
    imagesc(x_vec,y_vec,flip(u'))
    I=imagesc(x_vec,y_vec,cat(3,zeros(size(mask)),zeros(size(mask)),mask));
    set(I, 'AlphaData', mask);
    axis('equal')
    axis(window)
    xticks([])
    yticks([])
    title(experiments{i},'Interpreter','none')
    
    
    set(0, 'CurrentFigure', main_fig) % comparison light distribution
    subplot(2,length(experiments),i+length(experiments))
    bar((bins(1:end-1)+bins(2:end))/2,density_by_input(i,:), 1)
    hold on
    plot(bins,coefficents(1)+coefficents(2)*bins,LineWidth=2);
    xlabel('Input intensity')
    ylabel('Density of agents')
    yticks([0:0.25:1]);
    text(max(bins),0.7,['\rho=',num2str(c_coeff(i),'%.2f')],'HorizontalAlignment','right','FontSize',14)
    text(max(bins),0.65,['norm slope=',num2str(norm_slope(i),'%.2f')],'HorizontalAlignment','right','FontSize',14)
    ylim([0,0.75])
    xlim([-0.1,1.1])
    xticks(round(bins,2))
    
    if ~exist(fullfile(data_folder,'plots') , 'dir') % single exp data
        mkdir(fullfile(data_folder,'plots'))
        
        figure % single exp final positions
        box
        hold on
        colormap(cmap)
        imagesc(x_vec,y_vec,u')
        I=imagesc(x_vec,y_vec,cat(3,zeros(size(mask)),zeros(size(mask)),mask));
        set(I, 'AlphaData', mask);
        axis('equal')
        axis(window)
        xticks([])
        yticks([])
        saveas(gcf,fullfile(data_folder,'plots', 'final_positions'))
        saveas(gcf,fullfile(data_folder,'plots', 'final_positions'),'png')
        
        figure % single exp light distribution
        bar((bins(1:end-1)+bins(2:end))/2,density_by_input(i,:), 1)
        hold on
        plot(bins,coefficents(1)+coefficents(2)*bins,LineWidth=2);
        xlabel('Input intensity')
        ylabel('Density of agents')
        title('Final distribution w.r.t. light intensity')
        yticklabels([]);
        text(max(bins),max(density_by_input(i,:))*1.1,['\rho=',num2str(c_coeff(i),3)],'HorizontalAlignment','right','FontSize',14)
        text(max(bins),max(density_by_input(i,:))*1.05,['norm slope=',num2str(norm_slope(i),3)],'HorizontalAlignment','right','FontSize',14)
        ylim([0,max(density_by_input(i,:))*1.15])
        xlim([-0.1,1.1])
        xticks(round(bins,2))
        saveas(gcf,fullfile(data_folder,'plots', 'light_distribution'))
        saveas(gcf,fullfile(data_folder,'plots', 'light_distribution'),'png')
    end
end

% create output folder in 'comparisons'
comparison_output_folder = fullfile(experiments_folder,'comparisons', tag);
if ~exist(comparison_output_folder , 'dir'); mkdir(comparison_output_folder); end

% save comparison figure
set(0, 'CurrentFigure', main_fig)
saveas(gcf,fullfile(comparison_output_folder,'all'))
saveas(gcf,fullfile(comparison_output_folder,'all'),'png')

figure % mean light distribution
mean_dist = sum(agents_by_input./pixels_by_input,1);
mean_dist = mean_dist/sum(mean_dist);
[c_coeff_mean,norm_slope_mean,coefficents_mean] = linearDependence((bins(1:end-1)+bins(2:end))'/2, mean_dist');
bar((bins(1:end-1)+bins(2:end))/2,mean_dist, 1)
hold on
plot(bins,coefficents_mean(1)+coefficents_mean(2)*bins,LineWidth=2);
xlabel('Input intensity')
ylabel('Density of agents')
yticks([0:0.25:1]);
text(max(bins),max(mean_dist)*1.1,['\rho=',num2str(c_coeff_mean,'%.2f')],'HorizontalAlignment','right','FontSize',14)
text(max(bins),max(mean_dist)*1.05,['norm slope=',num2str(norm_slope_mean,'%.2f')],'HorizontalAlignment','right','FontSize',14)
ylim([0,max(mean_dist)*1.15])
xlim([-0.1,1.1])
xticks(round(bins,2))
title('Weighted mean distribution w.r.t. light intensity')
saveas(gcf,fullfile(comparison_output_folder,'mean_light_distribution'))
saveas(gcf,fullfile(comparison_output_folder,'mean_light_distribution'),'png')

% figure % mean light distribution
% mean_dist = mean(density_by_input,1);
% [c_coeff_mean,norm_slope_mean,coefficents_mean] = linearDependence((bins(1:end-1)+bins(2:end))'/2, mean_dist');
% bar((bins(1:end-1)+bins(2:end))/2,mean_dist, 1)
% hold on
% plot(bins,coefficents_mean(1)+coefficents_mean(2)*bins,LineWidth=2);
% xlabel('Input intensity')
% ylabel('Density of agents')
% yticklabels([]);
% text(max(bins),max(mean_dist),['\rho=',num2str(c_coeff_mean,3)],'HorizontalAlignment','right','FontSize',14)
% text(max(bins),max(mean_dist)*1.05,['norm slope=',num2str(norm_slope_mean,3)],'HorizontalAlignment','right','FontSize',14)
% ylim([0,max(mean_dist)*1.15])
% xlim([-0.1,1.1])
% xticks(round(bins,2))
% title('Mean distribution w.r.t. light intensity')

