% Trajectory Generation.
q = [0.2 ,0.2, 0]';
% points = [ 0 0; 1 0; 1 1; 2 2; 1 3; 0 3 ].';
points = feasibletraj(q);
% Divide the curve into uniform splines. Very important!
curve = spcrv(points, 3, 2*size(points,2)); 
% curve = points;
xder = diff(curve(1,:));
yder = diff(curve(2,:));
xdder = diff(xder(1,:));
ydder = diff(yder(1,:));

% plot(curve(1,:),curve(2,:),'LineWidth',2);
% % axis([-.4 3 -.2 3]), axis equal
% title('A random feasible trajectory');
% hold on

tau = 1;

%Compute objective function.

T = .5;

N = 1;

datasize = size(curve,2)-2;

%important trajectories
xSeq = zeros(1, datasize);
ySeq = zeros(1, datasize);
thetaSeq = zeros(1, datasize);
vBar = zeros(1, datasize);
wBar = zeros(1, datasize);

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
xe = 0;
ye = 0;
index = 0;
time = 1;
timeLim = 300;
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
    
    Ac = [0 wr 0;
        -wr 0 vr; 
        0 0 0];
    Bc = [1 0; 0 0; 0 1];
    [ Ad, Bd, C ] = cont2discrete( Ac, Bc, eye(3), [], T );

    n = 3;
    M = sparse(eye(n*N)) - sparse([zeros(n,n*N); kron(eye(N-1),Ad) zeros((n*(N-1)),n)]);
    Phi = sparse(M\[Ad;zeros(n*(N-1), n)]);
    Gamma = sparse(M\(kron(eye(N),Bd)));

    Q = blkdiag(40, 400, 20);
    Q = Q.^0.5;
    R = blkdiag(0.01, 0.01);
    R = R.^.5;

    [P,L,G] = dare(Ad,Bd,Q,R);

    Qbar = kron(eye(N-1), Q);
    Qbar = blkdiag(Qbar,P);
    Rbar = kron(eye(N), R);
    
%     value = curve(:,tau);
%     xr = value(1);
%     yr = value(2);
%     thetar = atan2(yd,xd);
%     e0 = [xr-x;yr-y;thetar-theta];%theta?
    R = [cos(theta) sin(theta) 0;
        -sin(theta) cos(theta) 0;
        0 0 1];
    e = R*e0;

    A = [Qbar*(Gamma);
        Rbar];
    b = -[Qbar*(Phi*e);
        zeros(2*N, 1)];
    %TODO. Impose dynamic constraints on V and W.
    % for now umax = 0.42 vmax = 0.3 => Wmax = 1.7

    uh = [   0.2123;
         0.7];

    D = [-eye(2*N);
        eye(2*N);
%         ];
        kron(eye(N),[1 0; 0 0]);
        -kron(eye(N),[1 0; 0 0])];
    fof = kron(ones(N,1),[vr; abs(wr)]);
    
    f = [kron(ones(N,1), uh) - fof;
        -kron(ones(N,1), -uh) + fof;
%         ]; 
        fof + 0.01;
        fof + 0.01];


    g = -(b' * A)';
    H = A'*A;

    Ubar = active_set(H, g, [],[], D, f);
%     opts = optimset('Algorithm','interior-point-convex');
% Ubar = quadprog(H, g, D, f,[],[],[],[],[],opts);
    %Get control law
    u = Ubar(1:2);
    index = index+1;

    vBar(index) = vr*cos(e(3)) - u(1);

    wBar(index) = wr - u(2);
    etest = Ad*e + Bd*u;
    
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
    
    xSeq(index) = x;
    ySeq(index) = y;
    thetaSeq(index) = theta;
    
    
    if ye <abs(yr-y)
        ye = yr-y;
    end
    if xe <abs(xr-x)
        xe = xr-x;
    end
   disp('yerror');
   disp(ye);
   disp('xerror');
   disp(xe);
   disp('thetaerror');
   disp(thetar-theta);
end

figure;
hold on
scatter(xrSeq, yrSeq);
scatter(xSeq, ySeq);
str = sprintf('Trajectory Comparision');
title(str);
% title('Trajectory Comparison');
legend('ref traj','real traj');
ylabel('y(m)');
xlabel('x(m)');
hold off;

figure;
subplot(3,2,1)
hold on;
plot(xrSeq);
plot(xSeq, 'color', 'green');
title('Reference x vs real x');
legend('ref x','real x');
ylabel('x(m)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,2)
hold on;
plot(yrSeq);
plot(ySeq,'color', 'green');
title('Reference y and real y');
legend('ref y','real y');
ylabel('y(m)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,3)
hold on;
plot(thetarSeq);
plot(thetaSeq,'color', 'green');
title('Reference orientation vs actual orientation');
legend('ref theta','real theta');
ylabel('theta(rads)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,4)
hold on;
plot(vrSeq);
plot(vBar,'color', 'green');
title('Reference linear velocity vs Optimal linear velocity');
legend('ref v','real v');
ylabel('v(m/s)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,5)
hold on;
plot(wrSeq);
plot(wBar,'color', 'green');
title('Reference angular velocity vs Optimal angular velocity');
legend('ref w','real w');
ylabel('w(rads/s)');
xlabel('time (0.5s)');
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