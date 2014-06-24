function [ xk ] = getmin( v, x0 )
%This function is intended for unconstrained optimisation.
%Optimisation by descent direction and armijo condition
%compute gradient of f.
%Modification would be to impose a condition for decreasing
vDash = diff(v);
%initial point
xk = x0;
grad = double(subs(vDash,xk));
count = 0;
points = [];
while (norm(grad) > 0.01)
    if(count > 500)
        break;
    end
    count = count + 1;
    %generate descent direction
    d = -grad;
    %line search
    gamma = 0.5;
    f = double(subs(v, xk));
    fStar = 0;
    a = -2*(f-fStar)/(grad'*d);
    xtemp = xk+a*d;
    %f(xk+ad) - f(xk) > gamma*a*grad*d
    while (double(subs(v, xtemp)) > f + a*gamma*grad'*d)
        a = a*.9;
        xtemp = xk+a*d;
    end
    xk  = xtemp;
    grad = double(subs(vDash, xk));
    points = horzcat(points,xk);
end
disp(points);

end

