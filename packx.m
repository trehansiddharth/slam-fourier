function x = packx(r, dr, ddr, a)
  x = vertcat(r, dr, ddr, reshape(a, [numel(a), 1]))
end