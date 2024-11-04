function [image_b] = blur(image,r)

%Initialize the blurred image
% image_b=NaN(size(image));
% d_x=size(image,1);
% d_y=size(image,2);

K = ones(r,r); % the convolution kernel, indicating a 3x3 moving mean
image_b = conv2(image,K,'same')./conv2(ones(size(image)),K,'same');


% for i=1:size(image,1)
%     for j=1:size(image,2)
%         ind_x=max([i-r,1]):min([i+r,d_x]);
%         ind_y=max([j-r,1]):min([j+r,d_y]);
%         image_b(i,j) = mean(mean(image(ind_x,ind_y)));
%     end
%     disp(i);
% end


end

