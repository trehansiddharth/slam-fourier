function [r, dr, ddr, a, P] = scalpstep(rprev, drprev, ddrprev, aprev, m, c, omega, U, M, n, Pprev, W, Q)
  xprev = packx(rprev, drprev, ddrprev, aprev);
  z = vertcat(m, c);
  N = numel(xprev);
  M = numel(z);
  J = 3 * n;
  K = N - 3 * n;
  
  A = [U, zeros(J, K); zeros(K, J), eye(K)];
  
  dzdr = -aprev * diag(sin(omega' * rprev)) * omega';
  H = [M, zeros(n, K); dzdr, zeros(n), zeros(n), zeros(n, K)];
  for i = 1:(K/n)
    H((n+1):M,(J+i*n):(J+i*n+n-1)) = cos(dot(omega(:,i), rprev)) * eye(n);
  end
  
  [xpred, Ppred] = ekf_predict1(M=xprev, P=Pprev, A=A, Q=Q, W=W);
  
  [rpred, ~, ~, apred] = unpackx(n, xpred);
  
  [xupdt, Pupdt] = ekf_update1(M=xpred, P=Ppred, Y=z, H=H, R=Q, h=interp(apred, omega, xpred));
  
  [r, dr, ddr, a] = unpackx(xupdt);
  P = Pupdt;
end