function [x, wmask, lambda] = active_set(G, d, AE, BE, AI, BI)
%function can not detect linearly dependent constraints.
assert(nargin > 1,'insert the right number of arguments');

assert(size(G,2) == size(d,1), ...
'The no of columns in %s must match the number of rows in %s,', 'G','d');
if (nargin > 3)
    if ~(isempty(AE) && isempty(BE))
    assert(size(d,1) == size(AE,2), ...
    'The no of columns in %s must match the number of rows in %s,', 'AE','d');
    assert(size(AE,1) == size(BE,1), ...
    'The no of row in %s must match the number of rows in %s,', 'BE','d');

    %remove linear dependencies
%     E = lirows([AE BE]);
%     AE = E(:,1:end-1);
%     BE = E(:, end);
    end
end
if (nargin > 5)
    if ~(isempty(AI) && isempty(BI))
    assert(size(d,1) == size(AI,2), ...
    'The no of columns in %s must match the number of rows in %s,', 'AI','d');
    assert(size(AI,1) == size(BI,1), ...
    'The no of row in %s must match the number of rows in %s,', 'BI','d');
    %remove linear dependencies
%     I = lirows([AI BI]);
%     AI = I(:,1:end-1);
%     BI = I(:,end);
    end
end


A = [AE;-AI];  % whole set is [AE;AI}
B = [BE;-BI];
x = find_start_point(AE, BE, AI, BI);
offset = size(AE,1);
wmask_0 = [ true(1, offset) false(1, size(AI,1))];

small = 0.001;
count = 0;


%find initial working mask
wmask = (abs(B - A*x) < small);
wmask = wmask';

%21 is an arbitrary number to stop the iteration. Since active set is
%performing a quadratic program, it should converge very fast in about 5
%iterations typically. So 21 is an upper bound after which we can assume
%the problem is ill conditioned.
while(count ~= 21) 
    count = count + 1;
    % solve the quadratic problem
%     [p, lambda] = sif(x, G, d, A(wmask,:), B(wmask));
   
    [p, lambda] = solve_kkt(x, G, d, A(wmask,:), B(wmask));
    if (all(abs(p) < small)) % approx zero
        % go through the lagrangians.
        % check they satisfy the first order optimality condition where the
        % gradient of the lagrangian is zero.
        g = G*x + d;
        
        assert(all(abs(A(wmask,:)'*lambda - g) < 0.9) );
        % select only inequalities
%         neg_mask = ~wmask_0&wmask;
        % find indices of negative values
        neg_mask = find(lambda < 0);
        if (~any(neg_mask))
            break;
        else
            % Need to remove most negative
            minimum = min(lambda(neg_mask));
            % remove from working set
            j = find(lambda == minimum,1,'first');
            % most negative is removed.
            neg_mask = true(size(lambda));
            neg_mask(j) = false;
            wmask(wmask) = wmask(wmask)&neg_mask';
            % use same x
        end
    else %p ~= 0
        % find the mask for the non-working set constraints.
        % find the step length.
        nwmask = ~wmask_0&~wmask;
        tempmask = (A*p) < 0;
        % find the non working constraints that satisfy Ap < 0
        tempmask = tempmask' & nwmask;       
        
        minstep = (B(tempmask) - A(tempmask,:)*x)./(A(tempmask,:)*p);
        minstep = min(minstep);
        ak =  min([1 minstep]);
        x = x + ak*p;
        %check for blocking constraints
        if (ak ~= 1)
            % Add the blocking constraint(s) to active set
            % select only inequalities
            nwmask = ~wmask_0&~wmask;
            tempmask = (abs(B - A*x) < small);
            tempmask = nwmask&tempmask';
            tempmask = find(tempmask, 1, 'first');
            wmask(tempmask) = true;
        end
        
    end
end
assert(~any(isnan(x)));
end