% I dont know how to derive wrSeq for empc so I will use hardcoded values.
clear;
vr = 0.05;
wrs = [0, 0.0667, 0.0644, 0.1316, 0.1250];
wrs = [-wrs(2:end) wrs];
num = 2*36;
dtheta = pi/36;
ethetas = linspace(-pi, pi, num);
lim = .15;
num = 2*lim/0.01;
ps = linspace(-.5,.5,num);
T = 0.5;
N = 1;
hashMap = zeros([2 1]);
for l = 1:length(ps)
    for i = 1:length(ps)
        for j = 1:length(ethetas)
            for k = 1:length(wrs)
       %tau0 is obtained from line search.

                Ac = [0 wrs(k) 0;
                    -wrs(k) 0 vr; 
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
                e = [ps(i);
                    ps(l);
                    ethetas(j)];%theta?

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
                fof = kron(ones(N,1),[vr; abs(wrs(k))]);

                f = [kron(ones(N,1), uh) - fof;
                    -kron(ones(N,1), -uh) + fof;
            %         ]; 
                    fof + 0.01;
                    fof + 0.01];


                g = -(b' * A)';
                H = A'*A;
                try
                    Ubar = active_set(H, g, [],[], D, f);
                catch exception
                    Ubar =[ NaN;NaN];
                end

            %     opts = optimset('Algorithm','interior-point-convex');
            % Ubar = quadprog(H, g, D, f,[],[],[],[],[],opts);
                %Get control law

            u = Ubar(1:2);
            hashMap(:,i,l,j,k) = u;
            end
        end
    end
end
save('empcMap.mat', 'hashMap', 'ethetas', 'wrs', 'ps');