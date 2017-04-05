function [G, dGdr] = gaussianInterp(r, dr, n, gridShape, covBlur)
  k = numel(gridShape);
  R = dr * genR(gridShape);
  g = mvnpdf((r - R)', zeros(1, k), covBlur)';
  g = g / sum(g);
  G = kron(g, eye(n));
  dgdr = g' .* ((r - R)' * inv(covBlur));
  dGdr = dgdr;
end