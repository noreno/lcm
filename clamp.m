
function c = clamp(x,lo,hi)
%CLAMP returns endpoint if x is not inside interval, otherwise returns x.   
%
%   c = CLAMP(x,lo,hi) returns a scalar if x is a scalar.
%   If x is a scalar, c is also a scalar. lo and hi are scalars.
%   Returns x if lo <= x <= hi.
%   If x < lo, returns lo.
%   If x > hi, returns hi
%   If x is a vector 
%   This function is a replication of the clamp function in Julia.
%
%   Example:
%   Vector case: clamp(-10:20,0,10)
%   Matrix case: clamp(magic(3),2,7)

%   Vicke Noren 2018-04-20

%{
nrow = size(x,1);
ncol = size(x,2);
c = zeros(nrow,ncol);
for i=1:nrow
    for j=1:ncol
        if lo <= x(i,j) && x(i,j) <= hi
            c(i,j) = x(i,j);
        elseif x(i,j) < lo
            c(i,j) = lo;
        elseif x(i,j) > hi
            c(i,j) = hi;
        end
    end
end
%}

% Vectorized version:
c = x;
c(x < lo) = lo;
c(x > hi) = hi;

end
