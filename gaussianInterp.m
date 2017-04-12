function [G, dGdr] = gaussianInterp(r, dr, R, n, covBlur)
  k = size(R, 1);
  G = zeros(n * size(r, 2), n * size(R, 2));
  for i = 1:size(r, 2)
    gi = dr^2 * mvnpdf((r(:,i) - R)', zeros(1, k), covBlur)';
    Gi = kron(gi, eye(n));
    G(((i-1)*n+1):(i*n), :) = Gi;
  end
  if size(r, 2) == 1
    dGdr = gi' .* ((r - R)' * inv(covBlur));
  end
end