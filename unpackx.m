function [r, dr, ddr, a] = unpackx(n, x)
  N = numel(x);
  K = N - 3 * n;
  r = x(1:n);
  dr = x((n+1):(2*n));
  ddr = x((2*n+1):(3*n));
  a = reshape(x((3*n+1):N), [n, K/n]);
end