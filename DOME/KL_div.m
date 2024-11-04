function D_kl = KL_div(x_D,y_D,rho_des,rho)

D_kl = trapz(x_D, trapz(y_D, rho_des.*log((rho_des+1e-10)./(rho+1e-10)), 2));
% D_kl = 1 - exp(-D_kl);

end