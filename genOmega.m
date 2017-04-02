function omega = genOmega(n, xmax, dx)
  k = xmax / dx;
  omegaMax = 2*pi/(dx);
  frequencies = (0:(k-1)) * omegaMax / k;
  omega = []
  allOmega = zeros(n, k^n);
  for j = 1:k^n
    for i = 1:n
      allOmega(i, j) = frequencies(1 + mod(floor(j / (k^(i-1))), k));
    end
    if norm(allOmega(:,j)) < omegaMax
      omega = [omega, allOmega(:,j)];
    end
  end
end