f = fopen('mevent', 'r');
t = tic();
prevMouseDown = 0;
while 1
  line = fgetl(f);
  [timestamp, mouseDown, absX, absY, accX, accY] = strread(line, "%f %f %f %f %f %f");
  if timestamp * 1e6 >= t
    if (mouseDown == 0) && (prevMouseDown == 1)
      fflush(stdout);
      mouseClickCallback(t, absX, absY, accX, accY);
      t = tic();
    else
      mouseMoveCallback(t, absX, absY, accX, accY);
      t = tic();
    end
    prevMouseDown = mouseDown;
  end
end