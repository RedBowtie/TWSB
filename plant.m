function [sys,x0,str,ts,simStateCompliance] = ...
    plant(t,x,u,flag, CoeF1, CoeF2, CoeF3, theta1_rad, theta2_rad)
%SFUNTMPL General MATLAB S-Function Template
%   With MATLAB S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an MATLAB S-function syntax is:
%       [SYS,X0,STR,TS,SIMSTATECOMPLIANCE] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying more than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].
%
%      SIMSTATECOMPLIANCE = Specifices how to handle this block when saving and
%                           restoring the complete simulation state of the
%                           model. The allowed values are: 'DefaultSimState',
%                           'HasNoSimState' or 'DisallowSimState'. If this value
%                           is not speficified, then the block's compliance with
%                           simState feature is set to 'UknownSimState'.


%   Copyright 1990-2010 The MathWorks, Inc.

%
% The following outlines the general structure of an S-function.
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(theta1_rad, theta2_rad);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u, CoeF1, CoeF2, CoeF3);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(theta1_rad, theta2_rad)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 6;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 6;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
% x0  = [0; theta1_rad; theta2_rad; 0; 0; 0];
x0  = [0; theta1_rad; theta2_rad; 0; 0; 0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u, CoeF1, CoeF2, CoeF3)

d = x(1);
th1 = x(2);
th2 = x(3);
dd = x(4);
dth1 = x(5);
dth2 = x(6);

% intermediate variables
iv1 = cos(th1);
iv2 = sin(th1);
iv3 = cos(th2);
iv4 = sin(th2);
iv5 = iv1^2;
iv6 = iv3^2;
iv7 = th1 - th2;
iv8 = sin(iv7);
iv9 = cos(iv7);
iv10 = iv9^2;

ivf9 = dth2^2;
ivf8 = dth1^2;
ivf7 = CoeF1(6,1)*iv10 + CoeF1(6,2);
ivf6 = CoeF1(5,1)*iv5 + CoeF1(5,2);
ivf5 = CoeF1(4,1)*iv6 + CoeF1(4,2);
ivf4 = CoeF1(3,1)*iv9 + CoeF1(3,2)*iv1*iv3;
ivf3 = CoeF1(2,1)*iv3 + CoeF1(2,2)*iv1*iv9;
ivf2 = CoeF1(1,1)*iv1 + CoeF1(1,2)*iv3*iv9;

ivden = CoeF2(1)*iv5 + CoeF2(2)*iv1*iv3*iv9 + ...
    CoeF2(3)*iv6 + CoeF2(4)*iv10 + CoeF2(5);
ivf1 = 2*ivden;

% fx
f1x = ((CoeF3(1,1)*iv2*ivf7) - (CoeF3(1,2)*iv8*ivf3))*ivf8 ...
    + ((CoeF3(1,3)*iv4*ivf7) + (CoeF3(1,4)*iv8*ivf2))*ivf9 ...
    + (CoeF3(1,5)*iv2*ivf2) + (CoeF3(1,6)*iv4*ivf3);

f2x = ((CoeF3(2,1)*iv2*ivf2) - (CoeF3(2,2)*iv8*ivf4))*ivf8 ...
    + ((CoeF3(2,3)*iv8*ivf5) + (CoeF3(2,4)*iv4*ivf2))*ivf9 ...
    + (CoeF3(2,5)*iv4*ivf4) + (CoeF3(2,6)*iv2*ivf5);

f3x = ((CoeF3(3,1)*iv4*ivf3) + (CoeF3(3,2)*iv8*ivf4))*ivf9 ...
    - ((CoeF3(3,3)*iv8*ivf6) - (CoeF3(3,4)*iv2*ivf3))*ivf8 ...
    + (CoeF3(3,5)*iv2*ivf4) + (CoeF3(3,6)*iv4*ivf6);

f1x = f1x / ivf1;
f2x = f2x / ivf1;
f3x = f3x / ivf1;

% bx
b1x = ivf7/2 - ivf2;
b2x = ivf2/2 - ivf5;
b3x = ivf3/2 - ivf4;

b1x = b1x / ivden;
b2x = b2x / ivden;
b3x = b3x / ivden;

ddd = f1x + b1x * u;
ddth1 = f2x + b2x * u;
ddth2 = f3x + b3x * u;

sys = [dd; dth1; dth2; ddd; ddth1; ddth2];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = [x(1); x(2); x(3); x(4); x(5); x(6)];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate

