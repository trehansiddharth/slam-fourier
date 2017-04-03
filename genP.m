function P = genP(Prs, gridShape, covC, covBlur)
% genP  Generate a covariance matrix for the state.
%   P = genP()
  k = size(Prs, 1);
  m = size(covC, 1);
  n = size(gridShape, 1);
  N = prod(gridShape);
  
  G = zeros(N * m, N * m);
  for i = 1:(N * m)
    for j = 1:(N * m)
      if (mod(i, m) == mod(j, m))
        c = cell(1, n + 1);
        [c{:}] = ind2sub([m; gridShape], i);
        ri = cell2mat(c);
        
        c = cell(1, n + 1);
        [c{:}] = ind2sub([m; gridShape], j);
        rj = cell2mat(c);
        
        G(i, j) = mvnpdf(ri(2:end) - rj(2:end), zeros(1, n), covBlur);
      else
        G(i, j) = 0;
      end
    end
  end
  
  covCs = repmat({covC}, 1, N);
  S = blkdiag(covCs{:})
  
  P = [Prs, zeros(k, N * m); zeros(N * m, k), G * S * G'];
end