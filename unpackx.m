function [r, s, a] = unpackx(n, d, p, x)
  N = numel(x);
  K = N - d;
  r = x(1:n);
  s = x((n+1):(n+d));
  a = reshape(x((n+d+1):end), [p, K/p]);
end