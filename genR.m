function R = genR(gridShape)
  n = numel(gridShape);
  N = prod(gridShape);
  c = cell(1, n);
  [c{:}] = ind2sub(gridShape, 1:N);
  R = vertcat(c{end:-1:1});
end