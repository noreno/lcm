
% Expected value in working age
function ev_out = ev(cash,v,fy,grid,secondd,ret,eyp,prob,reg_coef)
   [nrow,ncol] = size(cash);
   nco = size(v,1);
   n = size(prob,1);
   prob_li = 0; % 0.005
   ev_out = zeros(nrow,ncol);
   for ind1=1:n
      for ind2=1:n
         inc = fy(ind1) * (eyp(ind2) + reg_coef * ret);
         inc2 = clamp(inc + cash,grid(1),grid(end));
         aux = splint(grid,v,secondd,inc2);
         v1 = prob(ind1) * prob(ind2) * (1 - prob_li) * aux;
         ev_out = ev_out + v1;
      end
   end
   aux = splint(grid,v,secondd,cash);
   v1 = prob_li * aux;
   ev_out = ev_out + v1;
end
