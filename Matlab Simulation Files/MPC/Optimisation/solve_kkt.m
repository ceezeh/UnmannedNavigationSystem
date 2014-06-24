function [ p , lambda ] = solve_kkt( x, G, d, A, b )
%QMR_METHOD Summary of this function goes here
%   Detailed explanation goes here

% Assertions are needed here.
assert(nargin > 2,'insert the right number of arguments');

if (nargin > 2)
% assert(nargin == 5,'insert the right number of arguments');

assert(size(G,2) == size(d,1), ...
'The no of columns in %s must match the number of rows in %s,', 'G','d');
end
if (nargin > 4)
assert(size(d,1) == size(A,2), ...
'The no of columns in %s must match the number of rows in %s,', 'A','d');

assert(size(A,1) == size(b,1), ...
'The no of row in %s must match the number of rows in %s,', 'b','d');
end
%construct the KKT.
K = [G -A';
    A zeros(size(A,1), size(A,1))]; 
% assume initial guess of p is zero.
d = G*x + d;

c = zeros(size(b));

const = [-d;
        c];
result = K\const;
% result = qmr(K,const,[],30);
% result = lsqr(K,const,[],30);
% result = quadprog(G,d,[],[],A,c);
p = result(1:size(G,2), 1);
lambda = result(size(G,2)+1:end, 1);
end

