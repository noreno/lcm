
function y = splint(xa,ya,y2a,x)
    nrow = size(x,1);
    ncol = size(x,2);
    n = size(xa,1);
    y = x;
    klo = 1;
    khi = n;
    for indr=1:nrow
        for indc=1:ncol
            klo = 1;
            khi = n;
            while (khi - klo) > 1
                k = fix((khi + klo) / 2);
                if xa(k) > x(indr,indc)
                    khi = k;
                else
                    klo = k;
                end
            end
            h = xa(khi) - xa(klo);
            a = (xa(khi) - x(indr,indc))/h;
            b = (x(indr,indc) - xa(klo))/h;
            y(indr,indc) = a * ya(klo) + b * ya(khi) + ((a^3 - a) * y2a(klo) + (b^3 - b) * y2a(khi)) * (h^2) / 6;
        end
    end
end
