
function capinc = fci(sav,galfa,ret,rf)
    nrow   = length(sav);
    n      = length(galfa);
    capinc = zeros(nrow,n);
    for ind1=1:nrow	% Loop over invested wealth
        if sav(ind1) >= 0
            rp = ret .* galfa + rf * (1 - galfa);
        else
            rp = ones(n,1) * rf;
        end
        for ind2=1:n % Loop over risky shares
            capinc(ind1,ind2) = sav(ind1) * rp(ind2);
        end
    end
end
