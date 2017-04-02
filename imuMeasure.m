function M = imuMeasure(n, R)
  M = [zeros(n), zeros(n), R * eye(n)];
end