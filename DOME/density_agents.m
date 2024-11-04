function [rho_im] = density_agents(x_cur,grid_dim,n_bins,kest)

arguments
    x_cur       (:,2) double
    grid_dim    (1,2) double
    n_bins      double=-1;
    kest        double=0;
end
%

if kest
    as_rat=grid_dim(2)/grid_dim(1);
    x_vec = linspace(-grid_dim(1)/2,grid_dim(1)/2,n_bins);
    y_vec = linspace(-grid_dim(2)/2,grid_dim(2)/2,round(as_rat*n_bins));
    [x_mesh, y_mesh] = meshgrid(x_vec, y_vec);
    x_mesh=reshape(x_mesh',[size(x_mesh,1)*size(x_mesh,2),1]);
    y_mesh=reshape(y_mesh',[size(y_mesh,1)*size(y_mesh,2),1]);
    rho=ksdensity(x_cur,[x_mesh, y_mesh]);
    rho=reshape(rho,[length(x_vec),length(y_vec)]);
    % rho=rho';
else
    if n_bins>0
        rho=histcounts2(x_cur(:,1),x_cur(:,2),n_bins)';
    else
        rho=histcounts2(x_cur(:,1),x_cur(:,2))';
    end
end


[x_mesh, y_mesh] = ndgrid(x_vec, y_vec);
rho_int=griddedInterpolant(x_mesh,y_mesh,rho);
x_im=linspace(-grid_dim(1)/2,grid_dim(1)/2,grid_dim(1));
y_im=linspace(-grid_dim(2)/2,grid_dim(2)/2,grid_dim(2));
[x_mesh,y_mesh]=ndgrid(x_im,y_im);
rho_im=rho_int(x_mesh,y_mesh);



end