function [ x ] = find_start_point( AE, be, AI, bi)
%UNTITLED Summary of this function goes here
%  This code formulate the linprog problem 
%  of finding the start point for active-set

% TODO: May need to provide active set will feasible x.

small = 0.001;
ne = size(AE,1);
ni = size(AI,1);
m = 0;
if (isempty(AE))
    m = size(AI,2);
elseif(isempty(AI))
    m = size(AE,2);
end
assert(m ~= 0, 'incorrect constraints');
AE1 = [AE eye(ne) zeros(ne, ni)];

AI1 = [AI zeros(ni, ne) -eye(ni)];
AI2 = [zeros(ne, m) -eye(ne) zeros(ne, ni);
    zeros(ni, m) zeros(ni, ne) -eye(ni)];

A = [AI1;
    AI2];
b = [bi;
    zeros(ne+ni,1)];
f = [zeros(1, m) ones(1, ni+ne)]';

result = linprog(f, A, b, AE1, be);

x = result(1:m);
assert(norm(result(m+1:end)) < small);
end

