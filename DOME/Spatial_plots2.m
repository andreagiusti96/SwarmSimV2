%% Get the position of all the agents (Final position)

[~,indices_inWindow] = getInWindow(squeeze(xVec(end,:,:)), Simulation.arena);
xFinal_inWindow = squeeze(xVec(end,indices_inWindow,:));
xSemiFinal_inWindow = squeeze(xVec(end-1,indices_inWindow,:));

%% Plot the swarm (Starting position vs Final position)

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


figure (9);
surf(rho_d-rho);
shading interp;
view(2);
colorbar;
