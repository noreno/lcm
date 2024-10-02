
% Expected value in retirement age
function ev_out = evr(cash,v,fy,grid,secondd)
    [nrow,ncol] = size(cash);
    nro = size(v,1);
    inc = fy + cash; % Add return on wealth (=cash) to income
    inc = clamp(inc,grid(1),grid(end)); % Make sure income is within grid points
    ev_out = splint(grid,v,secondd,inc); % Create grid
    prob_li = 0; % 0.005
    aux = splint(grid,v,secondd,cash);
    ev_out = (1 - prob_li) * ev_out + prob_li * aux;
end
