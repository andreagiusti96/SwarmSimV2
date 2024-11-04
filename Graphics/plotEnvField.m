function [] = plotEnvField(points, values, window, cmap)
    arguments
        points  (1,2)   cell
        values          double
        window  (1,2)   double
        cmap    (2,3)   double = [0 0 1;1 1 1]
    end
    x_vec = linspace(-window(1)/2,window(1)/2,window(1));
    y_vec = linspace(-window(2)/2,window(2)/2,window(2));
    [x_mesh, y_mesh] = meshgrid(x_vec, y_vec);

    F = griddedInterpolant(points,values, 'linear', 'nearest');
    
    ax=gca();
    hold on
    axis(ax, 'xy')
    c1=cmap(1,:);
    c2=cmap(2,:);
    u=F(x_mesh',y_mesh')';


    image([-window(1)/2,window(1)/2],[-window(2)/2,window(2)/2],cat(3,u*c1(1)+(1-u)*c2(1),u*c1(2)+(1-u)*c2(2),u*c1(3)+(1-u)*c2(3)),'AlphaData',1)
    
    axis(ax,'equal',[-window(1)/2 window(1)/2 -window(2)/2 window(2)/2])
end

