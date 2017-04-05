function [r, s, a, P] = slamstep(rprev, sprev, aprev, Pprev, m, c, Ars, Hrs, Qrs, Rm, gridShape, covC, covBlur, dr)
  % Pack the state and mesurement vectors
  xprev = packx(rprev, sprev, aprev);
  z = vertcat(m, c);
  
  % Compute number of dimensions of other vectors for convenience
  n = numel(rprev); % Number of dimensions to position  
  o = numel(m); % Number of dimensions to measurement m
  p = numel(c); % Number of dimensions to color
  N = numel(xprev); % Total number of dimensions to state
  K = numel(aprev); % Total number of dimensions to map coefficients
  J = N - K; % Total number of other dimensions to state
  
  % Compute state transition matrix (perform Ars on r and s, preserve map)
  A = [Ars, zeros(J, K); zeros(K, J), eye(K)];
  
  % Compute measurement matrix (perform Hrs on r and s, do fancy stuff on map)
  R = genR(gridShape); % Compute coordinates of grid points
  [G, dGdr] = gaussianInterp(rprev, dr, p, gridShape, covBlur); % Compute matrices for Gaussian interpolation and its derivative
  dcdr = aprev * dGdr; % Compute derivative of color with respect to position
  dcda = G; % Compute derivative of color with respect to map coefficients
  H = [Hrs, zeros(o, K); dcdr, zeros(p, J - n), dcda]; % Combine into measurement matrix
  
  % Compute process noise covariance matrix (Qrs for noise on r and s, zero noise for map coefficients)
  Q = [Qrs, zeros(J, K); zeros(K, J), zeros(K, K)];
  
  % Run EKF prediction step and unpack result
  [xpred, Ppred] = ekf_predict1(M=xprev, P=Pprev, A=A, Q=Q);
  [rpred, spred, apred] = unpackx(n, J-n, p, xpred);
  
  % Compute measurement noise covariance matrix (Rm for noise on measurement m from r and s, zero noise for map coefficients)
  R = [Rm, zeros(o, p); zeros(p, o), zeros(p, p)];
  
  % Compute measurement from predicted state and run EKF update step
  h = [Hrs, zeros(o, K); zeros(p, J), G] * xpred;
  [xupdt, Pupdt] = ekf_update1(M=xpred, P=Ppred, Y=z, H=H, R=R);
  
  % Unpack the result and return
  [r, s, a] = unpackx(n, J-n, p, xupdt);
  P = Pupdt;
end