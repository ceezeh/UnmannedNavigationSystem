% Trajectory Generation.
q = [0.2 ,0.2, 0]';
% points = [ 0 0; 1 0; 1 1; 2 2; 1 3; 0 3 ].';
points = feasibletraj(q);
curve = spcrv(points, 3, 2*size(points,2)); 
% curve = points;
xder = diff(curve(1,:));
yder = diff(curve(2,:));
xdder = diff(xder(1,:));
ydder = diff(yder(1,:));

plot(curve(1,:),curve(2,:),'LineWidth',2);
% axis([-.4 3 -.2 3]), axis equal
title('A Spline Curve');
hold on

tau = 1;

%Compute objective function.

T = .5;

N = 1;

datasize = size(curve,2)-2;
vBar = zeros(1, datasize);
wBar = zeros(1, datasize);


%important trajectories
xrSeq = zeros(1, datasize);
yrSeq = zeros(1, datasize);
thetarSeq = zeros(1, datasize);

vrSeq = zeros(1, datasize);
wrSeq = zeros(1, datasize);

x = curve(1,1);
y = curve(2,1);
xd=xder(1);
yd=yder(1);
theta = atan2(yd,xd);

index = 0;
time = 1;
timeLim = 1000;
%why am I getting an increase in error?
while (1)
    %tau0 is obtained from line search.
    tau0 = getmin3(curve,[x;y], tau);
    tau = 1 + tau0;
    if (tau > datasize) || time == timeLim
        break
    end
    time = time + 1;
    xd=xder(tau);
    yd=yder(tau);
    xdd=xdder(tau);
    ydd=ydder(tau);
    vr = sqrt(xd^2 + yd^2);
    wr = (ydd*xd-xdd*yd)/(vr^2);
    
    value = curve(:,tau);
    xr = value(1);
    yr = value(2);
    thetar = atan2(yd,xd);
    e0 = [xr-x;yr-y;thetar-theta];%theta?
     while ((abs(vr) < 0.01) &&(abs(wr) < 0.01)) || (abs(vr)<0.00001) ||...
             (norm(e0(1:2)) < 0.01)
        tau = tau + 1;
        if (tau > datasize) || time == timeLim
            break
        end
         xd=xder(tau);
        yd=yder(tau);
        xdd=xdder(tau);
        ydd=ydder(tau);
        vr = sqrt(xd^2 + yd^2);
        wr = (ydd*xd-xdd*yd)/(vr^2);
        
        value = curve(:,tau);
        xr = value(1);
        yr = value(2);
        thetar = atan2(yd,xd);
        e0 = [xr-x;yr-y;thetar-theta];%theta?
     end
    
    if (tau > datasize) || time == timeLim
        break
    end

    %Get control law
    wrindex = find((abs(wr - wrs)<0.01), 1, 'first');
    num = 2*36;
    ethetaindex = 1 + ceil(num/2 + (num/2) * e0(3)/pi);
    lim = .15;
    num = 2*lim/0.01;
    e1index = 1 + ceil(num/2 + (num/2) * e0(1)/lim);
    e2index = 1 + ceil(num/2 + (num/2) * e0(2)/lim);
    u = hashMap(:, e1index, e2index, ethetaindex, wrindex);
    index = index+1;
    e =e0;
    vBar(index) = vr*cos(e(3)) - u(1);

    wBar(index) = wr - u(2);
%     etest = Ad*e + Bd*u;
    
    xrSeq(index) = xr;
    yrSeq(index) = yr;
    thetarSeq(index) = thetar;

    vrSeq(index) = vr;
    wrSeq(index) = wr;
    
% Update robot's movement.

    thetaDot = T*wBar(index);
    theta = theta + thetaDot;
    % theta wraparound
    if theta > pi
        theta = theta - 2*pi;
    else
        if theta < -pi
            theta = theta + 2*pi;
        end
    end
    xdot = vBar(index)*cos(theta);
    x = x + T*xdot; 
    ydot = vBar(index) * sin(theta);
    y = y + T*ydot;
    
   disp('yerror');
   disp(yr-y);
   disp('xerror');
   disp(xr-x);
   disp('thetaerror');
   disp(thetar-theta);
end

% Reconstruct trajectory
xSeq = zeros(1, datasize);
ySeq = zeros(1, datasize);
thetaSeq = zeros(1, datasize);
x = curve(1,1);
y = curve(2,1);
xd=xder(1);
yd=yder(1);
theta = atan2(yd,xd);
index = 0;
for i = 1:datasize
    thetaDot = T*wBar(i);
    theta = theta + thetaDot;
    xdot = vBar(i)*cos(theta);
    x = x + T*xdot; 
    ydot = vBar(i) * sin(theta);
    y = y + T*ydot;
%     R = [cos(thetaDot) sin(thetaDot);
%     -sin(thetaDot) cos(thetaDot)];
%     point = R*[x;y];
    % rotate clockwise by thetadot.
    xSeq(i) = x;
    ySeq(i) = y;
    thetaSeq(i) = theta;

end
scatter(xSeq, ySeq);
title('Trajectory Comparison');
hold off;

figure;
hold on;
plot(xSeq, 'color', 'green');
plot(xrSeq);
title('Reference x vs real x');
legend('real x','ref x');
hold off;

figure;
hold on;
plot(ySeq,'color', 'green');
plot(yrSeq);
title('Reference y and real y');
legend('real y','ref y');
hold off;

figure;
hold on;
plot(thetaSeq,'color', 'green');
plot(thetarSeq);
title('Reference orientation vs actual orientation');
legend('real theta','ref theta');
hold off;

figure;
hold on;
plot(vrSeq);
plot(vBar,'color', 'green');
title('Reference linear velocity vs Optimal linear velocity');
legend('ref v','real v');
hold off;

figure;
hold on;
plot(wrSeq);
plot(wBar,'color', 'green');
title('Reference angular velocity vs Optimal angular velocity');
legend('ref w','real w');
hold off;

% Trajectory Parameters
% knots = [1,1:9,9];
% curve = spmak( knots, [ 0 0; 1 0; 1 1; 2 2; 1 3; 0 2 ].' );

% % fnplt(spline(xSeq(1:end), ySeq(1:end)));
% The observation is that reducing parameter speed(v=0.04) stops the
% robot's motion prematurely
% The ref signals are small larger than
% the trajectory. This may imply we need to relax the constraints. However,
% tracking in y is excellent but poor in x. We need to investigate the weighting functions.

% These were observed for P = diag(40, 400, 20) and R = (0.1, 0.1)
% Using P = diag(200, 400, 20) x tracking performs better while it works. 
% However the overall path tracking performs poorly

% Using P as original and v = .1, we obtain better tracking and motion overall 
% but generated trajectory is a miniturised version of the reference. 
% This may imply that controller is to slow and trajectory is in feasible. 

% Thus we change the trajectory to a less curved on.
% 


% % Trajectory parameters
% Here we try to reduce the curvature.
% knots = [1,1:9,9];
% curve = spmak( knots, [ 0 0; 1 0; 1 1; 2 2; 1 3; 0 3 ].' );
% Interestingly, using 0.08< v <.1 does as usual(generate miniturise trajectory)
% However for v = 0.07, we get that the simulation robot turns around 
% at the end of the path and now follows the path in reverse. This situation can not come up in practice.
% However, it appear that the problem is not the curvature but the splines. 
% For a constant parameteric speed, the spline are not uniformly placed. 
% This causes overtaken of trajectory and inability to follow. This occur
% at different point on the path leading to the strange behaviors.


% Next we attempt to use uniform splines.