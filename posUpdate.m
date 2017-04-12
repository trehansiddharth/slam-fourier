function A = posUpdate(r)
  n = numel(r);
  A = [zeros(n), r; zeros(1, n), 1]; 
end