function [] = plotEnvField(points, values, window, cmap)
    arguments
        points  (1,2)   cell
        values          double
        window  (1,4)   double
        cmap    (:,3)   double = linspace2([1,1,1], [1,0.5,0.5], 100)'
    end
    x_vec = linspace(window(1),window(2),500);
    y_vec = linspace(window(3),window(4),500);
    [x_mesh, y_mesh] = meshgrid(x_vec, y_vec);

    F = griddedInterpolant(points,values, 'linear', 'nearest');
    
%     ax=gca();
%     hold on
    %axis(ax, 'xy')
    imagesc(x_vec,y_vec,F(x_mesh',y_mesh')')
    colormap(cmap)
    axis xy
%     axis(ax,'equal',[-window(1)/2 window(1)/2 -window(2)/2 window(2)/2])
end

