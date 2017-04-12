function A = imuUpdate(n, dt)
  % Constant velocity model
  A = [eye(n), dt * eye(n), zeros(n); zeros(n), eye(n), zeros(n); zeros(n), zeros(n), -eye(n)];
end