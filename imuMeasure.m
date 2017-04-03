function H = imuMeasure(n, K)
  H = [zeros(n), zeros(n), K * eye(n)];
end