function [r, s, a, P] = slamstep(rprev, sprev, aprev, Pprev, m, c, Ars, Hrs, Qrs, Rm, rmax, dr)
  xprev = packx(rprev, sprev, aprev);
  z = vertcat(m, c);
  
  n = numel(rprev);
  
  o = numel(m);
  p = size(c);
  
  N = numel(xprev);
  J = numel(rprev);
  K = N - J;
  
  A = [Ars, zeros(J, K); zeros(K, J), eye(K)];
  
  Omega = genOmega(n, rmax, dr);
  R = genR(n, rmax, dr);
  expDotProduct = exp(1i * Omega' * (rprev - dr * R))
  dcdr = 1i * (aprev * Omega') .* expDotProduct;
  dcda = diag(ones(1, size(Omega, 2)) * expDotProduct);
  
  H = [Hrs, zeros(o, K); dcdr, zeros(p, J - n), dcda];
  
  Q = [Qrs, zeros(J, K); zeros(K, J), zeros(K, K)];
  
  [xpred, Ppred] = ekf_predict1(M=xprev, P=Pprev, A=A, Q=Q);
  
  [rpred, ~, apred] = unpackx(n, J-n, p, xpred);
  
  R = [Rm, zeros(o, p); zeros(p, o), zeros(p, p)];
  
  %h = ones(1, size(Omega, 2)) * expDotProduct;
  [xupdt, Pupdt] = ekf_update1(M=xpred, P=Ppred, Y=z, H=H, R=R);
  
  [r, s, a] = unpackx(xupdt);
  P = Pupdt;
end