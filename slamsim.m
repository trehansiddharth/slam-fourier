addpath('ekfukf');

pkg load statistics;

global r;
global s;
global a;
global P;
global Ars;
global Qrs;
global Rm;
global dr;
global gridShape;
global gridR;
global covC;
global covBlur;
global a0;
global N;
global G;
global I;
global figureShape;

% User modifiable parameters for SLAM
gridShape = [10 10];
dr = 10;
meanC = [0.7; 0.3; 0.3];
covC = [0.2^2, 0, 0; 0, 0.2^2, 0; 0, 0, 0.2^2];
covBlur = [10^2, 0; 0, 10^2];

% User modifiable parameters for visualization
drFigure = 5;

% Internal parameters
N = prod(gridShape);
vprev = 0;
figureShape = (dr / drFigure) * gridShape;

% Generate a random landscape
a0 = mvnrnd(meanC, covC, N)';
gridR = dr * genR(gridShape);
figureR = drFigure * genR(figureShape);

% Visualize the interpolated landscape
G = gaussianInterp(figureR, dr, gridR, 3, covBlur);
c = G * a0(:);
c(c < 0) = 0;
c(c > 1) = 1;
I = zeros([figureShape 3]);
I(:,:,1) = reshape(c(1:3:end), figureShape);
I(:,:,2) = reshape(c(2:3:end), figureShape);
I(:,:,3) = reshape(c(3:3:end), figureShape);
imshow(I);
drawnow;

% Calculate initial values
r0 = dr * (gridShape / 2)';
s0 = [0; 0; 0; 0];
sigr = dr;
Prs = zeros(6);
[r, s, a, P] = genInitial(r0, s0, Prs, gridShape, meanC, covC);

global state;
global xmin;
global xmax;
global ymin;
global ymax;
global xrange;
global yrange;

state = 0;
xmin = 0;
xmax = 0;
ymin = 0;
ymax = 0;
xrange = 0;
yrange = 0;

function mouseClickCallback(t, absX, absY, accX, accY)
  global state;
  global xmin;
  global xmax;
  global ymin;
  global ymax;
  global xrange;
  global yrange;
  global G;
  global I;
  global figureShape;
  global a;
  if (state == 0)
    disp("Click on the upper right pixel of the landscape.");
    fflush(stdout);
    xmin = absX;
    ymin = absY;
    state = 1;
  elseif (state == 1)
    disp("Capturing mouse trajectory statistics. Move the mouse as if you were probing.");
    disp("Click when you want to actually start probing.");
    fflush(stdout);
    xmax = absX;
    ymax = absY;
    xrange = double(xmax - xmin);
    yrange = double(ymax - ymin);
    state = 2;
  elseif (state == 2)
    disp("Probing started.");
    fflush(stdout);
    state = 3;
  elseif (state == 3)
    disp("Probing stopped.");
    fflush(stdout);
    c = G * a(:);
    c(c < 0) = 0;
    c(c > 1) = 1;
    I1 = zeros([figureShape 3]);
    I1(:,:,1) = reshape(c(1:3:end), figureShape);
    I1(:,:,2) = reshape(c(2:3:end), figureShape);
    I1(:,:,3) = reshape(c(3:3:end), figureShape);
    subplot(1, 2, 1);
    imshow(I);
    title('Original');
    subplot(1, 2, 2);
    imshow(I1);
    title('Reconstructed');
    drawnow;
    state = 4;
  end
end

global xs;
global ys;

tprev = tic();
xs = [];
vxs = [];
axs = [];
ys = [];
vys = [];
ays = [];

function mouseMoveCallback(t, absX, absY, accX, accY)
  global r;
  global s;
  global a;
  global P;
  global Ars;
  global Qrs;
  global Rm;
  global dr;
  global gridShape;
  global gridR;
  global covC;
  global covBlur;
  global a0;
  global N;
  
  global state;
  global xmin;
  global xmax;
  global ymin;
  global ymax;
  global xrange;
  global yrange;
  
  global ts;
  global xs;
  global ys;
  
  if (state == 2)
    rreal = dr * ([(absX - xmin) / xrange; (absY - ymin) / yrange] .* gridShape' + 1);
    
    ts = [ts; t];
    xs = [xs; rreal(1)];
    ys = [ys; rreal(2)];
  elseif (state == 3)
    dt = toc(t);
    Ars = imuUpdate(2, dt);
    Hrs = imuMeasure(2);
    Qrs = [dr * eye(2), zeros(2), zeros(2); ...
           zeros(2), zeros(2), zeros(2); ...
           zeros(2), zeros(2), dr * ones(2) / (dt^2)];
    Rm = dr * eye(2) / (dt^2);
    
    rreal = dr * ([(absX - xmin) / xrange; (absY - ymin) / yrange] .* gridShape' + 1);
    m = dr * ([accX; accY] ./ [xrange; yrange]) .* gridShape';
    G = gaussianInterp(rreal, dr, gridR, 3, covBlur);
    c = G * reshape(a0, [(3 * N) 1]);
    
    [r, s, a, P] = slamstep(r, s, a, P, m, c, Ars, Hrs, Qrs, Rm, gridShape, covC, covBlur, dr);
    
    disp("Estimated r:");
    disp(r);
    disp("Real r:");
    disp(rreal);
    fflush(stdout);
  end
end

disp("Pausing for 5 seconds, adjust your workspace in this time.");
fflush(stdout);
pause(5);
disp("Click on the lower left pixel of the landscape.");
fflush(stdout);
mread;
