% This code is a straight Matlab port of CGMs Fortran code.
% Vicke Noren 2018


utility = @(c,gamma) (c.^(1 - gamma)) / (1 - gamma);
ntoi    = @(x,g) round((clamp(x,g(1),g(end)) - g(1)) / (g(2)-g(1)) + 1);


tb = 20;
tr = 65;
td = 100;
nqp = 3;
nalfa = 101;
ncash = 1601;
nc = 3001;
rf = 1.02;
sigma_r = 0.157^2;
exc = 0.04;
delta = 0.96;
gamma = 10;

ageprof = [-2.170042 + 2.700381, 0.16818, -0.0323371 / 10, 0.0019704 / 100];
sigt_y = 0.0738;
sigp_y = 0.01065;
ret_fac = 0.68212;
reg_coef = 0;

weig = [1/6 2/3 1/6]';
grid = [-sqrt(3) 0 sqrt(3)]';

% SURVIVAL PROBABILITIES
survprob = zeros(80,1);
survprob(1)  = 0.99845;
survprob(2)  = 0.99839;
survprob(3)  = 0.99833;
survprob(4)  = 0.9983;
survprob(5)  = 0.99827;
survprob(6)  = 0.99826;
survprob(7)  = 0.99824;
survprob(8)  = 0.9982;
survprob(9)  = 0.99813;
survprob(10) = 0.99804;
survprob(11) = 0.99795;
survprob(12) = 0.99785;
survprob(13) = 0.99776;
survprob(14) = 0.99766;
survprob(15) = 0.99755;
survprob(16) = 0.99743;
survprob(17) = 0.9973;
survprob(18) = 0.99718;
survprob(19) = 0.99707;
survprob(20) = 0.99696;
survprob(21) = 0.99685;
survprob(22) = 0.99672;
survprob(23) = 0.99656;
survprob(24) = 0.99635;
survprob(25) = 0.9961;
survprob(26) = 0.99579;
survprob(27) = 0.99543;
survprob(28) = 0.99504;
survprob(29) = 0.99463;
survprob(30) = 0.9942;
survprob(31) = 0.9937;
survprob(32) = 0.99311;
survprob(33) = 0.99245;
survprob(34) = 0.99172;
survprob(35) = 0.99091;
survprob(36) = 0.99005;
survprob(37) = 0.98911;
survprob(38) = 0.98803;
survprob(39) = 0.9868;
survprob(40) = 0.98545;
survprob(41) = 0.98409;
survprob(42) = 0.9827;
survprob(43) = 0.98123;
survprob(44) = 0.97961;
survprob(45) = 0.97786;
survprob(46) = 0.97603;
survprob(47) = 0.97414;
survprob(48) = 0.97207;
survprob(49) = 0.9697;
survprob(50) = 0.96699;
survprob(51) = 0.96393;
survprob(52) = 0.96055;
survprob(53) = 0.9569;
survprob(54) = 0.9531;
survprob(55) = 0.94921;
survprob(56) = 0.94508;
survprob(57) = 0.94057;
survprob(58) = 0.9357;
survprob(59) = 0.93031;
survprob(60) = 0.92424;
survprob(61) = 0.91717;
survprob(62) = 0.90922;
survprob(63) = 0.90089;
survprob(64) = 0.89282;
survprob(65) = 0.88503;
survprob(66) = 0.87622;
survprob(67) = 0.86576;
survprob(68) = 0.8544;
survprob(69) = 0.8423;
survprob(70) = 0.82942;
survprob(71) = 0.8154;
survprob(72) = 0.80002;
survprob(73) = 0.78404;
survprob(74) = 0.76842;
survprob(75) = 0.75382;
survprob(76) = 0.73996;
survprob(77) = 0.72464;
survprob(78) = 0.71057;
survprob(79) = 0.6961;
survprob(80) = 0.6809;

delta2 = delta * survprob;

tn = td - tb + 1;

gr = grid * sigma_r^0.5;
eyp = grid * sigp_y^0.5;
eyt = grid * sigt_y^0.5;
mu = exc + rf;

expeyp = exp(eyp);

galfa = [0 : 0.01 : 0 + 0.01 * (nalfa - 1)]';
galfa = linspace(0,1,nalfa)';
gret = mu + gr;
gcash = [4 : 0.25 : 4 + 0.25 * (ncash - 1)]';
gcash = linspace(4, 4 + 0.25 * (ncash-1), ncash)';
aux3 = gcash;
gc = [0 : 0.1 : 0.1 * (nc - 1)]';
gc = linspace(0, 0.1 * (nc-1), nc)';



f_y = zeros(nqp,tr-1);
for t=(tb+1):tr
   avg = exp(ageprof * [1 t t^2 t^3]');
   f_y(:,t-tb) = avg * exp(eyt);
end

ret_y = ret_fac * exp(ageprof * [1 tr tr^2 tr^3]');

ut = utility(gcash,gamma);
% "In the last period the policy functions are trivial (the agent consumes
% all available wealth) and the value function corresponds to the indirect
% utility function." (CGM 2005, p. 497)
v = ut; % Terminal value function
c = gcash;
alfa = zeros(size(c));

vpol = zeros(ncash,80);
cpol = ones(size(vpol));
alfapol = zeros(size(vpol));

u = utility(gc,gamma);
tt = 80;

% RETIREMENT PERIODS
for ind1=1:35
   t = tt - ind1 + 1;
   t
   secd = spline(aux3,v,gamma);
   % Loop over cash-on-hand grid
   for ind2=1:ncash
      if t == tn-1
         lowc = c(ind2) / 2;
         highc = c(ind2);
         if gcash(ind2) >= 50
            highc = c(ind2) / 1.5;
         end
      elseif t == tn-2
         lowc = c(ind2) / 2.5;
         highc = c(ind2);
         if gcash(ind2) >= 50
            highc = c(ind2) / 1.2;
         end
      elseif (t < tn-2) && (t > tn-5)
         lowc = c(ind2) / 3.5;
         highc = c(ind2);
         if gcash(ind2) >= 50
            highc = c(ind2) / 1.1;
         end
      else
         lowc = c(ind2) - 10;
         highc = c(ind2) + 10;
      end
      lowc2 = ntoi(lowc,gc);
      highc2 = ntoi(highc,gc);
      nc_r = highc2 - lowc2 + 1;
      gc_r = gc(lowc2:highc2);
      lowalfa2 = 1;
      highalfa2 = nalfa;
      if (gcash(ind2) > 40) && (t < tn-1)
         lowalfa = alfa(ind2) - 0.2;
         highalfa = alfa(ind2) + 0.2;
         lowalfa2 = ntoi(lowalfa,galfa);
         highalfa2 = ntoi(highalfa,galfa);
      end
      nalfa_r = highalfa2 - lowalfa2 + 1;
      galfa_r = galfa(lowalfa2:highalfa2);
      invest = gcash(ind2) - gc_r;
      u_r = u(lowc2:highc2);
      u2 = u_r;
      for ind4=1:nc_r
         if invest(ind4) < 0
            u2(ind4) = -1e10; % Assign large negative utility to avoid case of negative investment
         end
      end
      invest = max(invest,0); % Investment has to be positive
      u3 = max(u2,-1e10);
      v1 = zeros(nc_r,nalfa_r);
      for ind5=1:nqp
		 % Calculate capital income (= return on investment)
         nw = fci(invest,galfa_r,gret(ind5),rf);
		 % Calculate cash-on-hand variable (= retirement income + return on investments)
         nv = evr(nw,v,ret_y,aux3,secd);
         % Calculate next-period value across shocks
         v1 = v1 + nv * weig(ind5);
      end
      % Calculate this period value as reward plus next-period value
      % adjusted for delta2 (= survival probability times discount factor)
      vv = u3 + delta2(t) * v1;
      vv = max(vv,-1e10);
      % Solve maximization problem (Bellman equation)
      [v2,pt] = max(vv(:)); % Julia code: v2,pt = findmax(vec(vv))
      aux2 = fix((pt - 1) / nc_r); % Julia code: aux2 = fld(pt-1,nc_r)
      alfa2 = galfa(aux2 + lowalfa2);
      c2 = gc(pt + lowc2 - 1 - aux2 * nc_r);
      %[t gcash(ind2) alfa2 c2]
      % Store value and policy functions
      vpol(ind2,t) = v2;
      alfapol(ind2,t) = alfa2;
      cpol(ind2,t) = c2;
   end
   % Update value and policy functions for iteration for t-1
   v = vpol(:,t);
   alfa = alfapol(:,t);
   c = cpol(:,t);
end




% WORKING PERIODS
for ind1=1:(tt-35)
   t = 45 - ind1 + 1;
   t
   secd = spline(aux3,v,gamma);
   for ind2=1:ncash
      if (t < tr-29) && (t > tr-25)
         lowc = c(ind2) - 10;
         highc = c(ind2) + 10;
      else
         lowc = c(ind2) - 5;
         highc = c(ind2) + 5;
      end
      lowc2 = ntoi(lowc,gc);
      highc2 = ntoi(highc,gc);
      nc_r = highc2 - lowc2 + 1;
      gc_r = gc(lowc2:highc2);
      lowalfa2 = 1;
      highalfa2 = nalfa;
      if (gcash(ind2) > 40) && (t < tn-1)
         lowalfa = alfa(ind2) - 0.2;
         highalfa = alfa(ind2) + 0.2;
         lowalfa2 = ntoi(lowalfa,galfa);
         highalfa2 = ntoi(highalfa,galfa);
      end
      nalfa_r = highalfa2 - lowalfa2 + 1;
      galfa_r = galfa(lowalfa2:highalfa2);
      invest = gcash(ind2) - gc_r;
      u_r = u(lowc2:highc2);
      u2 = u_r;
      for ind4=1:nc_r
         if invest(ind4) < 0
            u2(ind4) = -1e10;
         end
      end
      invest = max(invest,0);
      u3 = max(u2, -1e10);
      
      v1 = zeros(nc_r,nalfa_r);
      for ind5=1:nqp
		 % Calculate capital income (= return on investment)
         nw = fci(invest,galfa_r,gret(ind5),rf);
		 % Calculate cash-on-hand variable (= labor income + return on investments)
         nv = ev(nw,v,f_y(:,t),aux3,secd,gret(ind5),expeyp,weig,reg_coef);
         v1 = v1 + nv * weig(ind5);
      end
      vv = u3 + delta2(t) * v1;
      vv = max(vv,-1e10);
      
      [v2,pt] = max(vv(:)); % Julia code: v2,pt = findmax(vec(vv))
      aux2 = fix((pt - 1) / nc_r); % Julia code: aux2 = fld(pt-1,nc_r)
      alfa2 = galfa(aux2 + lowalfa2);
      c2 = gc(pt + lowc2 - 1 - aux2 * nc_r);
      %[t gcash(ind2) alfa2 c2]
      % Store value and policy functions
      vpol(ind2,t) = v2;
      alfapol(ind2,t) = alfa2;
      cpol(ind2,t) = c2;
   end
   % Update value and policy functions for iteration for t-1
   v = vpol(:,t);
   alfa = alfapol(:,t);
   c = cpol(:,t);
end

save('outdata.mat')

csvwrite('testalfa.csv',alfapol)
csvwrite('testcons.csv',cpol)
csvwrite('testvfun.csv',vpol)
