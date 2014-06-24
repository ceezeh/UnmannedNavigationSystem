function [path] = feasibletraj(q)
gds = 0.4; %gridsize
% q = [0.15 ,0.15, 0]';
p0 = q(1:2);
%use a rule that say if difference between orientation and alpha is more
%than pi/2, that path is infeasible.

npaths = [gds 0.00; gds gds; 0.00 gds; -gds gds; -gds 0.00; -gds -gds;...
    0.0 -gds; gds -gds].';
cmplxpaths = (npaths(1,:) + 1i* npaths(2,:));
alphas = angle(cmplxpaths);
N = 10;
path =[];
index = 1;
while (index < N)
    index = index + 1;
    % scatter(npaths(1,:), npaths(2,:));
    % next = npaths + repmat(q(1:2), [1 8]);
    
    change = q(3) - alphas;
    mask = change > pi;
%     wraparound
     if any(mask)
        change(mask) = change(mask) - 2*pi;
     else
        mask = change < -pi;
        if any(mask)
            change(mask) = change(mask) + 2*pi;
        end
     end
    
    mask = abs(change) < pi/4 + 0.1;

    %select next path
    feasiblePaths = npaths(:,mask);
    len = size(feasiblePaths,2);
    feasiblePaths = repmat(p0, [1 len]) + feasiblePaths;
    mask = feasiblePaths > 0;
    tmask = mask(1,:) & mask(2,:);
    if (~any(tmask)) 
        break;
    end
    feasiblePaths = feasiblePaths(:,tmask);
    %select randomly
    len = size(feasiblePaths,2);
    num = randi([1 len],1,1);
    point = feasiblePaths(:,num);
%     path = feasiblePaths(:,3);
%     point = p0 + path;
    [ traj, q ] = myspline_t( q, point );
    path = horzcat(path, traj(:,1:end-1));
    %map current point to a grid.
    p0(1) = q(1)- floor(mod(q(1), gds/2));
    p0(2) = q(2)- floor(mod(q(2), gds/2));
end
 scatter(path(1,:), path(2,:));
end