function A = imuUpdate(n, dt)
  A = [eye(n), dt * eye(n), 0.5 * (dt^2) * eye(n); zeros(n), eye(n), dt * eye(n); zeros(n), zeros(n), eye(n)];
end