%% Get the position of all the agents (Final position)

[~,indices_inWindow] = getInWindow(squeeze(xVec(end,:,:)), Simulation.arena);
xFinal_inWindow = squeeze(xVec(end,indices_inWindow,:));
xSemiFinal_inWindow = squeeze(xVec(end-1,indices_inWindow,:));
% 
% % create output folder, save data and parameters
% 
% if outputDir
%     if ~exist('simulation_name','var') || isempty(simulation_name)
%         counter=1;
%         if ~tag
%             tag=Dynamics.model;
%         end
%         while exist(fullfile(outputDir,[datestr(now, 'yyyy_mm_dd_'),tag,'_',num2str(counter)]),'dir')
%             counter=counter+1;
%         end
%         simulation_name = [datestr(now, 'yyyy_mm_dd_'),tag,'_',num2str(counter)];
%     end
%     output_path=fullfile(outputDir, simulation_name);
%     mkdir(output_path)
%     disp('Saving data in ' + string(output_path))
%     save(fullfile(output_path, 'data'))
% 
%     fileID = fopen(fullfile(output_path, 'parameters.txt'),'wt');
%     fprintf(fileID,'SimulateSpatialTV\n\n');
%     fprintf(fileID,'Identification: %s\n\n',fullfile(id_folder,identification_file_name));
%     fprintf(fileID,'Date: %s\n',datestr(now, 'dd/mm/yy'));
%     fprintf(fileID,'Time: %s\n\n',datestr(now, 'HH:MM'));
%     fprintf(fileID,'Parameters:\n\n');
%     fprintf(fileID,'N= %d\n',N);
%     fprintf(fileID,'D= %d\n',D);
%     fprintStruct(fileID,Simulation)
%     fprintf(fileID,'Dynamics:\n');
%     fprintStruct(fileID,Dynamics)
%     fprintf(fileID,'GlobalIntFunction:\n');
%     fprintStruct(fileID,GlobalIntFunction)
%     fprintf(fileID,'LocalIntFunction:\n');
%     fprintStruct(fileID,LocalIntFunction)
%     fprintf(fileID,'Environment:\n');
%     fprintStruct(fileID,Environment)
%     fprintf(fileID,'smoothing= %s\n',mat2str(smoothing));
%     fprintf(fileID,'delta= %.2f\n',delta);
%     fclose(fileID);
% end
%% Plot the swarm (Starting position vs Final position)

% if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
%     %Plot the swarm at the initial timestep
%     figure (1);
%     if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
%         plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values{1}, Simulation.arena)
%     end
%     plotSwarmInit(x0, 0, inf, inf, Simulation.arena, Simulation.arena, false, false, false, Simulation.agentShape, Simulation.agentSize, squeeze(xVec(2,:,:)));
%     if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
%     if outputDir
%         saveas(gcf, fullfile(output_path, 'x_0'))
%         saveas(gcf, fullfile(output_path, 'x_0'),'png')
%     end
% 
    % Plot the swarm at the final timestep
    figure(2);
    if isfield(Environment,'Inputs') && isfield(Environment.Inputs,'Points')
        plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values{end}, Simulation.arena)
    end
    plotSwarmInit(xFinal_inWindow, Simulation.Tmax, inf, inf, Simulation.arena, Simulation.arena, false, false, false, Simulation.agentShape, Simulation.agentSize, xSemiFinal_inWindow);
    if isfield(Environment,'boundary'); plotBoundary(Environment.boundary); end
    % if outputDir
    %     saveas(gcf, fullfile(output_path, 'x_final'))
    %     saveas(gcf, fullfile(output_path, 'x_final'),'png')
    % end
% end

%% Plot the Photoaccumulation Index evolution over time

window = [-Simulation.arena(1),Simulation.arena(1),-Simulation.arena(2),Simulation.arena(2)]/2;

% for i=1:length(Render.all_time)
%     %Compute PhI at every time instant
%     cur_ind = max([Render.all_time(i)/Simulation.deltaT,2]);
%     [~,indices_inWindow] = getInWindow(squeeze(xVec(cur_ind,:,:)), Simulation.arena);
%     x_cur = squeeze(xVec(cur_ind,indices_inWindow,:));
%     time = find(Environment.Inputs.Times<=Render.all_time(i),1,'last');
%     [~, ~, norm_slope_sim(i), ~, ~, ~,~, ~] = agentsDensityByInput(Environment.Inputs.Points, Environment.Inputs.Values{time}, x_cur, window);
% end
% 
% figure(3);
% hold on;
% plot(Render.all_time,movmean(norm_slope_sim,20),'LineWidth',2);
% hold on;
% xlabel('Time [s]','FontSize',14)
% ylabel('PhI','FontSize',14)
% xlim([0, Simulation.Tmax]);
% if outputDir
%     saveas(gcf, fullfile(output_path, 'PhI'))
%     saveas(gcf, fullfile(output_path, 'PhI'),'png')
% end


%% Plot the density of the agents (Final Instant)

% figure(4);
% plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values{end}, Simulation.arena);
% hold on
% density_plot(xFinal_inWindow,40,[255 214 0;255 255 255]/255,Simulation.arena,140,true,0.6);
% if outputDir
%     saveas(gcf, fullfile(output_path, 'rho_f'))
%     saveas(gcf, fullfile(output_path, 'rho_f'),'png')
% end
% 
% figure(5);
% plotEnvField(Environment.Inputs.Points, Environment.Inputs.Values{end}, Simulation.arena);
% hold on
% density_plot(x0,40,[255 214 0;255 255 255]/255,Simulation.arena,140,true,0.6);
% if outputDir
%     saveas(gcf, fullfile(output_path, 'rho_i'))
%     saveas(gcf, fullfile(output_path, 'rho_i'),'png')
% end


%% KL divergence between desired and real density 

jmp=50;
figure(6);
for i=1:jmp:length(Render.all_time)
    %Compute KL Divergence at all time instants
    cur_ind = max([Render.all_time(i)/Simulation.deltaT,2]);
    [~,indices_inWindow] = getInWindow(squeeze(xVec(cur_ind,:,:)), Simulation.arena);
    x_cur = squeeze(xVec(cur_ind,indices_inWindow,:));
    ag_den=density_agents(x_cur,size(Environment.Inputs.Values{1}),40,true);
    rho=ag_den;%.*sum(sum((rho_d)))./sum(sum(ag_den));%.*sum(sum(1-Environment.Inputs.Values{1}'))./sum(sum(ag_den));
    % Kl((i-1)/jmp+1)=norm((rho-rho_d),'fro');
    Kl((i-1)/jmp+1)=KL_div(Environment.Inputs.Points{1},Environment.Inputs.Points{2},rho_d,rho);
    clc;
    disp(i/length(Render.all_time));
end


plot(Render.all_time(1:jmp:end),Kl,'LineWidth',2);
hold on;
xlabel('Time [s]','FontSize',14)
ylabel('||\rho-\rho_d||','FontSize',14)
xlim([0, Simulation.Tmax]);
% if outputDir
%     saveas(gcf, fullfile(output_path, 'KL_Div'))
%     saveas(gcf, fullfile(output_path, 'KL_Div'),'png')
% end


figure
surf(rho_d-rho);
shading interp;
view(2);
figure;
subplot(2,1,1);
surf(rho_d);
shading interp;
view(2);
subplot(2,1,2);
surf(rho);
shading interp;
view(2);
