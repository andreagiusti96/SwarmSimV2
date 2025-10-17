function [p_traj] = plotTrajectory(xVec,thenDelete, color, window)
%
%
    last = find(isnan(xVec(:,1,1)),1);
    if last > window
        xVec = xVec(last-window:last,:,:);
    end
    
    if size(xVec,3) == 2
        p_traj = plot(xVec(:,:,1),xVec(:,:,2), 'color',color);
    else
        p_traj = plot3(xVec(:,:,1),xVec(:,:,2),xVec(:,:,3), 'color',color);
    end
    
    if thenDelete
        drawnow
        delete(p_traj)
    end
end

