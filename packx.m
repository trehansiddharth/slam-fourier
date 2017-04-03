function x = packx(r, s, a)
  x = vertcat(r, s, reshape(a, [numel(a), 1]))
end