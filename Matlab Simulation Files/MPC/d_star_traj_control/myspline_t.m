function [ traj, q ] = myspline_t( q, point )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
v = 0.2;
gridsize = 0.4;
change = 1i*(point(2)-q(2)) + (point(1)-q(1));
alpha = angle(change);

%check if curve or straight path
if (abs(alpha-q(3)) < 0.1)
    spacing = gridsize/v + 1;
    xSeq = linspace(q(1), point(1), spacing);
    ySeq = linspace(q(2), point(2), spacing);
    traj = [xSeq;ySeq];
    q(1:2) = point; 
else
    % determine direction.
    dir = 1;
    if (q(3) - alpha >  0) &&(q(3) - alpha < pi)
        dir = -1; %anticlockwise
    end
    
    %determine beta
    l = -q(3);
    Rot = [cos(l) -sin(l);
                sin(l) cos(l)];
    q_t = Rot * q(1:2);
    point_t = Rot * point;
    a = atan2(abs(q_t(2) - point_t(2)), abs(q_t(1) - point_t(1)));  
    Phi = 2 * a;
    beta = pi/2 - a;
    dist = norm(q(1:2) - point);
    radius = abs(sin(beta) * dist / sin(Phi));
    if (dir < 0) 
        start = (pi/2 + q(3));
    else
        start =  (beta + alpha) - pi;
    end
    centre = [q(1) - radius *cos(start); q(2) - radius *sin(start)]';
    % we see that we can't always divide Phi into uniform parts.
    % this means that our trajectory is not guaranteed to end at the center of
    % a grid but if we can divide the grid into small enough parts, we can
    % ensure the trajectory ends very close to a grid. However, this implies
    % slow angular and linear speeds. Hence it may be sufficient to just ensure
    % that trajectory ending inside a grid allowing more flexibility to choose
    % speeds.
    % wmax = 1.5843;
    % v = 0.1;
    w  = dir*pi/6;

    datasize = ceil(Phi/abs(w));
    xSeq = [];
    ySeq = [];
    index = 1;
    for tau = start :w: start+(dir*Phi)
        x = centre(1) + radius * cos(tau);
        y =  centre(2) + radius * sin(tau);
       xSeq = horzcat(xSeq,x);
       ySeq = horzcat(ySeq,y);
       % Check if (x,y) is close to grid centre.
       currpos = [x, y]';
       % this does not guarantee end trajectory is close to grid. With high
       % speed, point may never come close to grid centre at all. Thus we
       % define resolution of angular change to be around 5 degrees or 0.1
       % rads.
       if norm(currpos - point) < 0.001
           break;
       end
       index = index + 1;

    end
    theta = (dir*pi/2) + tau;
     % theta wraparound
        if theta > pi
            theta = theta - 2*pi;
        else
            if theta < -pi
                theta = theta + 2*pi;
            end
        end
    q = [x , y, theta]'; 
    traj = [xSeq;ySeq];
end
end