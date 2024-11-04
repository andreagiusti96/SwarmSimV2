function [x, v, out_agents] = boundaryInteraction(x, v, boundary)
    out_agents = false(size(x));
    for dim = 1:length(boundary)
        out_agents_u(:,dim) = x(:,dim) >  boundary(dim)/2;
        out_agents_d(:,dim) = x(:,dim) < -boundary(dim)/2;
    end

    
    for dim = 1:length(boundary)
        x(out_agents_u(:,dim),dim) = min(x(out_agents_u(:,dim),dim), boundary(dim)/2);
        x(out_agents_d(:,dim),dim) = max(x(out_agents_d(:,dim),dim), -boundary(dim)/2);
        
        v(out_agents_u(:,dim),dim) = v(out_agents_u(:,dim),dim) .* -sign(v(out_agents_u(:,dim),dim));
        v(out_agents_d(:,dim),dim) = v(out_agents_d(:,dim),dim) .* sign(v(out_agents_d(:,dim),dim));

        
    end
    
    
%     for dim = 1:length(boundary)
%         x(:,dim) = min(x(:,dim), boundary(dim)/2);
%         x(:,dim) = max(x(:,dim), -boundary(dim)/2);
%     end
end

