clear;
% Trajectory Generation.
degree = 7;

taus = sym('taus',[1 1]);
xs = sin(taus/10);
xds = diff(xs,taus);
xdds = diff(xds, taus);
ys = sin(taus/20);
yds = diff(ys,taus);
ydds = diff(yds,taus);
Td = 38*pi;
tau = 0;
v = 0.3;

%Compute objective function.

T = .5;

N = 5;


%Important trajectories
datasize = ceil(Td/v);

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



x = double(subs(xs, taus, 0));
y = double(subs(ys, taus, 0));
theta = double(atan2(subs(yds, taus, 0), subs(xds, taus, 0)));

index = 0;
time = 1;

while (time < floor(Td/v)-50)
    
    %tau0 is obtained from line search.
    fn = ((ys-y)^2 + (xs-x)^2);
    tau0 = getmin(fn,tau);
    tau = v + tau0;
    time = time + 1;
    vr = double(sqrt(subs(xds^2 + yds^2, taus, tau)));
    wr = double(subs((ydds*xds-xdds*yds)/(vr^2),taus,tau));
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

    xr = double(subs(xs, taus, tau));
    yr = double(subs(ys, taus, tau));
    thetar = atan2(double(subs(yds, taus, tau)),...
        double(subs(xds, taus, tau)));
    e0 = [xr-x;yr-y;thetar-theta];%theta?
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
        1.5843];

     D = [-eye(2*N);
        eye(2*N);
%         ];
        kron(eye(N),[1 0; 0 0]);
        -kron(eye(N),[1 0; 0 0])];
    fof = kron(ones(N,1),[vr; abs(wr)]);
    
    f = [kron(ones(N,1), uh) - fof;
        -kron(ones(N,1), -uh) + fof;
%         ];
        fof+0.01;
        fof+0.01];


    g = -(b' * A)';
    H = A'*A;

    Ubar = active_set(H, g, [],[], D, f);

    %Get control law
    u = Ubar(1:2);
    
    index = index + 1;
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
    theta = theta+  thetaDot;
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
end


figure;
hold on
scatter(xSeq, ySeq);
scatter(xrSeq, yrSeq);
str = sprintf('Trajectory Comparision');
title(str);
% title('Trajectory Comparison');
legend('real traj','ref traj');
ylabel('y(m)');
xlabel('x(m)');
hold off;

figure;
subplot(3,2,1)
hold on;
plot(xSeq, 'color', 'green');
plot(xrSeq);
title('Reference x vs real x');
legend('real x','ref x');
ylabel('x(m)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,2)
hold on;
plot(ySeq,'color', 'green');
plot(yrSeq);
title('Reference y and real y');
legend('real y','ref y');
ylabel('y(m)');
xlabel('time (0.5s)');
hold off;

subplot(3,2,3)
hold on;
plot(thetaSeq,'color', 'green');
plot(thetarSeq);
title('Reference orientation vs actual orientation');
legend('real theta','ref theta');
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