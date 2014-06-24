%this script attempts to generate paths as to be used by robot.
clear;
points = [0.05 0.05; 0.15 0.15; 0.25 0.15; 0.25 0.25; 0.25 0.35; 0.25 0.45; 0.15 0.55].';
scatter(points(1,:), points(2,:));
axis equal
hold on
q = [0.05 ,0.05, 0]';

alpha = atan2((points(2,2)-q(2)), (points(1,2)-q(1)));

beta = (pi/2) - (q(3) + alpha);
Phi = pi - 2*beta;
dist = norm(q(1:2) - points(:,2));
radius = sin(beta) * dist / sin(Phi);
start =  (beta + alpha) - pi;
centre = [q(1) - radius *cos(start); q(2) - radius *sin(start)]';
% we see that we can't always divide Phi into uniform parts.
% this means that our trajectory is not guaranteed to end at the center of
% a grid but if we can divide the grid into small enough parts, we can
% ensure the trajectory ends very close to a grid. However, this implies
% slow angular and linear speeds. Hence it may be sufficient to just ensure
% that trajectory ending inside a grid allowing more flexibility to choose
% speeds.
wmax = 1.5843;
v = 0.1;
w  = 0.1;
datasize = ceil(Phi/w);
xSeq = zeros(1, datasize);
ySeq = zeros(1, datasize);
index = 1;
for tau = start :w: start+Phi
    x = centre(1) + radius * cos(tau);
    y =  centre(2) + radius * sin(tau);
   xSeq(index) = x;
   ySeq(index) = y;
   % Check if (x,y) is close to grid centre.
   point = [x, y]';
   % this does not guarantee end trajectory is close to grid. With high
   % speed, point may never come close to grid centre at all. Thus we
   % define resolution of angular change to be around 5 degrees or 0.1
   % rads.
   if norm(point- points(:,2)) < 0.001
       break;
   end
   index = index + 1;
   
end
theta = pi/2 + tau;
 % theta wraparound
    if theta > pi
        theta = theta - 2*pi;
    else
        if theta < -pi
            theta = theta + 2*pi;
        end
    end
q = [x , y, theta]'; 
scatter(xSeq, ySeq);
hold off;