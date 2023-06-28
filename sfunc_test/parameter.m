clear; clc;
pa = struct('A', 5, 'T', 20, 'k', 8, 'm', 1, 'epsilon', 5, 'p', 10, 'c', 15)

A = [0 1; -pa.k/pa.m 0];
B = [0; 1/pa.m];

Q = [10000 0; 0 100];
R = 1;
[K, ~] = lqr(A, B, Q, R);

%% 1-st level pendulum
clear; clc;
M = 3.5;
m = 1.5;
l = 1;
g = 9.80665;

step_time = 0;

theta = 5;                      % Initial pendulum angle, deg
theta_init = theta / 180 * pi;  % Angle in rad

b = 0;                          % Damping coefficient,  N/(m/s)
pos = 1;                        % Desired position

I = 1/3*m*l^2;      % Inertia of the pendulum

den = I*(M+m) + M*m*l^2;
a22 = -(I+m*l^2)*b/den;
a23 = -m^2*g*l^2/den;
a42 = -m*l*b/den;
a43 = m*g*l*(M+m)/den;

A = [0    1    0   0;
     0  a22  a23   0;
     0    0    0   1;
     0  a42  a43   0];
B = [0; (I+m*l^2)/den; 0; -m*l/den];

pa = struct('eta', 0.5, 'k', 20, 'a', 3, 'b', 5, 'c1', 5, 'c2', 10)