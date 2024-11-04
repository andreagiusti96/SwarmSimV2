function [] = density_plot(x_cur,smooth,color_grad,grid_dim,n_bins,kest,alpha)

arguments 
    x_cur       (:,2) double
    smooth      double
    color_grad  (2,3)double
    grid_dim    (1,2) double
    n_bins      double=-1
    kest        double=0;
    alpha       double=0.6;
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
else
    if n_bins>0
        rho=histcounts2(x_cur(:,1),x_cur(:,2),n_bins);
    else
        rho=histcounts2(x_cur(:,1),x_cur(:,2));
    end
end



r_x=size(rho,1);
r_y=size(rho,2);

s_x=round(grid_dim(1)/r_x);
s_y=round(grid_dim(2)/r_y);

bl=ones(s_x,s_y);

rho_im=kron(rho, bl)'/max(max(rho));
rho_im=blur(rho_im,smooth);
c1=color_grad(1,:);%[0 0 1];
c2=color_grad(2,:);%[1 1 1];

image([-grid_dim(1)/2,grid_dim(1)/2],[-grid_dim(2)/2,grid_dim(2)/2],cat(3,rho_im*c1(1)+(1-rho_im)*c2(1),rho_im*c1(2)+(1-rho_im)*c2(2),rho_im*c1(3)+(1-rho_im)*c2(3)),'AlphaData',alpha);

end