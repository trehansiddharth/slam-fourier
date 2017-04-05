function [r, s, a, P] = genInitial(r0, s0, Prs, gridShape, meanC, covC)
  k = size(Prs, 1);
  m = size(covC, 1);
  n = size(gridShape, 1);
  N = prod(gridShape);
  
  r = r0;
  s = s0;
  a = meanC .* ones(1, N);
  P = [Prs, zeros(k, N * m); zeros(N * m, k), eye(N * m)];
end