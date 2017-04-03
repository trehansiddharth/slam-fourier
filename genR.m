function R = genR(n, xmax, dx)
  N = floor(xmax / dx);
  R = zeros(n, N^n);  
  for j = 1:N^n
    for i = 1:n
      R(i, j) = 1 + mod(floor(j / (N^(i-1))), N);
    end
  end
end