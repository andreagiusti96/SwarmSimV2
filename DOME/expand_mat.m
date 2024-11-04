function A_e = expand_mat(A,sz)

r_x=size(A,1);
r_y=size(A,2);

s_x=round(sz(1)/r_x);
s_y=round(sz(2)/r_y);

bl=ones(s_x,s_y);

A_e=kron(A, bl);


end

