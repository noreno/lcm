
function y2 = spline(x,y,gam)
    n  = length(x);
    y2 = zeros(n,1);
    u  = zeros(n,1);
    yp1 = x(1)^(-gam);
    y2(1) = -0.5;
    u(1) = (3 / (x(2) - x(1))) * ((y(2) - y(1)) / (x(2) - x(1)) - yp1);
    for i=2:(n-1)
        sig = (x(i) - x(i-1)) / (x(i+1) - x(i-1));
        p = sig * y2(i-1) + 2;
        y2(i) = (sig - 1) / p;
        u(i) = (6 * ((y(i+1) - y(i)) / (x(i+1) - x(i)) - ((y(i) - y(i-1)) / (x(i) - x(i-1)))) / (x(i+1) - x(i-1)) - sig * u(i-1)) / p;
    end
    y2(end) = 0;
    for k=(n-1):-1:1
        y2(k) = y2(k) * y2(k+1) + u(k);
    end
end
