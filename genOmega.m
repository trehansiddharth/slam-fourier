function Omega = genOmega(n, xmax, dx)
  Omega = (genR(n, xmax, dx) - 1) * 2*pi / xmax;
end