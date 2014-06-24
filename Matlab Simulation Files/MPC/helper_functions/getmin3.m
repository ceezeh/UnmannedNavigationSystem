function [ result ] = getmin3( ref, traj, tau0 )
%This function is intended for unconstrained optimisation.
%Optimisation by descent direction and armijo condition
%compute gradient of f.
%Modification would be to impose a condition for decreasing

spacing = 100;
if (tau0 - spacing < 1)
    start = 1;
else
    start = tau0-spacing;
end
last = min(size(ref,2),tau0+spacing);
values = ref(:,start:last) - repmat(traj, [1 last-start+1]);

a = arrayfun(@(x) x^2, values);
a = a(1,1:end)+a(2,1:end);
result = start + find(a==min(a), 1, 'first' );
assert(~isempty(result));
end