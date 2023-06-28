%% Initial angles
clear; clc;
syms M11 M21 M22 M31 M32 M41 M51 M52;
syms R mw m1 m2 l1 l2 g;
syms x(t) theta1(t) theta2(t) tau(t);

theta1_deg = 1;
theta2_deg = -1;
theta1_rad = theta1_deg * pi / 180;
theta2_rad = theta2_deg * pi / 180;

%% Lagrangian
T = M11 * diff(x, t)^2 ...
  + M21 * diff(theta1, t)^2 + M22 * diff(theta2, t)^2 ...
  + (M31*diff(theta1, t)*cos(theta1)+ M32*diff(theta2, t)*cos(theta2))*diff(x, t) ...
  + M41 * diff(theta1, t) * diff(theta2, t) * (sin(theta1)*sin(theta2)+cos(theta1)*cos(theta2));

V = M51 * cos(theta1) + M52 * cos(theta2);

L = T - V;

eqn = functionalDerivative(L, [x; theta1; theta2]) == [-tau; 2*tau; 0];

eqn = simplify(eqn);
%% Linear
M = [2*M11      M31     M32;
       M31    2*M21     M41;
       M32      M41   2*M22];

Maux = [0     0    0;
        0  -M51    0;
        0     0 -M52];

%inv(M)

denominator = 2*(M22*M31^2 - M31*M32*M41 + M21*M32^2 + M11*M41^2 - 4*M11*M21*M22);

Minv= [(M41^2 - 4*M21*M22), (2*M22*M31 - M32*M41), (2*M21*M32 - M31*M41);
       (2*M22*M31 - M32*M41), (M32^2 - 4*M11*M22), (2*M11*M41 - M31*M32); 
       (2*M21*M32 - M31*M41), (2*M11*M41 - M31*M32), (M31^2 - 4*M11*M21)];

Minv = Minv / denominator;

Mf = Minv * -Maux;

B_part = Minv * [1; -2; 0];

%% Substitution
Jw = 1/2 * mw * R^2;
J1 = 1/3 * m1 * (2*l1)^2;
J2 = 1/3 * m2 * (2*l2)^2;

% M11 = (1/2*(m1+m2) + (mw*R^2+Jw)/(R^2));
% M21 = 1/2 * (m1*l1^2 + J1 + 4*m2*l1^2);
% M22 = 1/2 * (m2*l2^2 + J2);
% M31 = m1*l1 + 2*m2*l1;
% M32 = m2*l2;
% M41 = 2*m2*l1*l2;
% M51 = (m1+2*m2)*g*l1;
% M52 = m2*g*l2;

Ms = [(1/2*(m1+m2) + (mw*R^2+Jw)/(R^2));
       1/2 * (m1*l1^2 + J1 + 4*m2*l1^2);
       1/2 * (m2*l2^2 + J2);
       m1*l1 + 2*m2*l1;
       m2*l2;
       2*m2*l1*l2;
       (m1+2*m2)*g*l1;
       m2*g*l2];

Ms = vpa(subs(Ms, [m1 m2 l1 l2 mw R g], [1 0.5 0.25 0.5 0.1 0.1 9.8]));

Mset = [M11; M21; M22; M31; M32; M41; M51; M52];

CoeF1 = [2*M22*M31 -M32*M41;
        2*M21*M32 -M31*M41;
        2*M11*M41 -M31*M32;
        M32^2 -4*M11*M22;
        M31^2 -4*M11*M21;
        M41^2 -4*M21*M22];

CoeF2 = [M22*M31^2 -M31*M32*M41 M21*M32^2 M11*M41^2 -4*M11*M21*M22];

CoeF3 = double( ...
        [Ms(4) Ms(6) Ms(5) Ms(6) Ms(7) Ms(8);
         Ms(4) Ms(6) Ms(6) Ms(5) Ms(8) Ms(7);
         Ms(5) Ms(6) Ms(6) Ms(4) Ms(7) Ms(8)]);

CoeF1 = double(subs(CoeF1, Mset, Ms));

CoeF2 = double(subs(CoeF2, Mset, Ms));

Mf_num = double(subs(Mf, Mset, Ms));

B_part_num = double(subs(B_part, Mset, Ms));
%% LQR
A = [0 0 0 1 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 1;
     0 Mf_num(1,2) Mf_num(1,3) 0 0 0;
     0 Mf_num(2,2) Mf_num(2,3) 0 0 0;
     0 Mf_num(3,2) Mf_num(3,3) 0 0 0];

B = [0; 0; 0; B_part_num(1); B_part_num(2); B_part_num(3)];

C = eye(6);

Q = [100 0 0 0 0 0;
     0 5000 0 0 0 0;
     0 0 100 0 0 0;
     0 0 0 1 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 1];

R = 1;

[K, ~] = lqr(A, B, Q, R);

Kr = sqrt(Q(1, 1)/R);

%% Disturbances
input_dis = 0;
input_dis_time = 10;

d1_mean = 0;
d1_variance = 0.1;

d2_mean = 0;
d2_variance = 1;

d3_mean = 0;
d3_variance = 1;

%% Passing through
para = struct( ...
    'c1', 4, ...
    'c2', 2, ...
    'c3', 4, ...
    'alpha', 2, ...
    'beta', 2.5, ...
    'gamma', 3.5, ...
    'eta', 0.1, ...
    'k', 40)

% coefs used in linear model
% para = struct( ...
%     'c1', 2, ...
%     'c2', 5, ...
%     'c3', 1.3, ...
%     'alpha', 1.5, ...
%     'beta', 4.4, ...
%     'gamma', 2.7, ...
%     'eta', 0.005, ...
%     'k', 30)