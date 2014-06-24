q = [0.2 ,0.2, pi/2]';
% points = [ 0 0; 1 0; 1 1; 2 2; 1 3; 0 3 ].';
points = feasibletraj(q);
curve = spcrv(points, 3, 100); 
% values = spline(points);
% fnplot(values);

plot(curve(1,:),curve(2,:),'LineWidth',2);
axis equal;