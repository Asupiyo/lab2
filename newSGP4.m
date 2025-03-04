%--------------------------------------------------------------------------
%                   SGP4 Orbit Propagator
%
% References:
% Hoots, Felix R., and Ronald L. Roehrich. 1980. Models for Propagation of
% NORAD Element Sets. Spacetrack Report #3. U.S. Air Force: Aerospace Defense
% Command.
% 
% Vallado D. A; Fundamentals of Astrodynamics and Applications; McGraw-Hill
% , New York; 4th edition (2013).
% 
% Last modified:   2023/08/30   Meysam Mahooti
%--------------------------------------------------------------------------
clc
clear all
format long g

global const
SAT_Const

ge = 398600.8; % Earth gravitational constant [km3/s2]
TWOPI = 2*pi;
MINUTES_PER_DAY = 1440;
MINUTES_PER_DAY_SQUARED = (MINUTES_PER_DAY * MINUTES_PER_DAY);
MINUTES_PER_DAY_CUBED = (MINUTES_PER_DAY * MINUTES_PER_DAY_SQUARED);

% TLE file name
fname = 'tle.txt';

% Open the TLE file and read TLE elements
fid = fopen(fname, 'r');

% read first line
tline = fgetl(fid);
Cnum = tline(3:7);      			        % Catalog Number (NORAD)
SC   = tline(8);					        % Security Classification
ID   = tline(10:17);			            % Identification Number
year = str2num(tline(19:20));               % Year
doy  = str2num(tline(21:32));               % Day of year
epoch = str2num(tline(19:32));              % Epoch
TD1   = str2num(tline(34:43));              % first time derivative
TD2   = str2num(tline(45:50));              % 2nd Time Derivative
ExTD2 = str2num(tline(51:52));              % Exponent of 2nd Time Derivative
BStar = str2num(tline(54:59));              % Bstar/drag Term
ExBStar = str2num(tline(60:61));            % Exponent of Bstar/drag Term
BStar = BStar*1e-5*10^ExBStar;
Etype = tline(63);                          % Ephemeris Type
Enum  = str2num(tline(65:end));             % Element Number

% read second line
tline = fgetl(fid);
i = str2num(tline(9:16));                   % Orbit Inclination (degrees)
raan = str2num(tline(18:25));               % Right Ascension of Ascending Node (degrees)
e = str2num(strcat('0.',tline(27:33)));     % Eccentricity
omega = str2num(tline(35:42));              % Argument of Perigee (degrees)
M = str2num(tline(44:51));                  % Mean Anomaly (degrees)
no = str2num(tline(53:63));                 % Mean Motion
a = ( ge/(no*2*pi/86400)^2 )^(1/3);         % semi major axis (km)
rNo = str2num(tline(65:end));               % Revolution Number at Epoch

fclose(fid);

satdata.epoch = epoch;
satdata.norad_number = Cnum;
satdata.bulletin_number = ID;
satdata.classification = SC; % almost always 'U'
satdata.revolution_number = rNo;
satdata.ephemeris_type = Etype;
satdata.xmo = M * (pi/180);
satdata.xnodeo = raan * (pi/180);
satdata.omegao = omega * (pi/180);
satdata.xincl = i * (pi/180);
satdata.eo = e;
satdata.xno = no * TWOPI / MINUTES_PER_DAY;
satdata.xndt2o = TD1 * TWOPI / MINUTES_PER_DAY_SQUARED;
satdata.xndd6o = TD2 * 10^ExTD2 * TWOPI / MINUTES_PER_DAY_CUBED;
satdata.bstar = BStar;

tsince = 1440; % amount of time in which you are going to propagate satellite's state vector forward (+) or backward (-) [minutes] 

[rteme, vteme] = sgp4(tsince, satdata);

% read Earth orientation parameters
fid = fopen('eop.txt','r');
%  ----------------------------------------------------------------------------------------------------
% |  Date    MJD      x         y       UT1-UTC      LOD       dPsi    dEpsilon     dX        dY    DAT
% |(0h UTC)           "         "          s          s          "        "          "         "     s 
%  ----------------------------------------------------------------------------------------------------
while ~feof(fid)
    tline = fgetl(fid);
    k = strfind(tline,'NUM_OBSERVED_POINTS');
    if (k == 1)
        numrecsobs = str2num(tline(21:end));
        tline = fgetl(fid);
        for i=1:numrecsobs
            eopdata(:,i) = fscanf(fid,'%i %d %d %i %f %f %f %f %f %f %f %f %i',[13 1]);
        end
        for i=1:4
            tline = fgetl(fid);
        end
        numrecspred = str2num(tline(22:end));
        tline = fgetl(fid);
        for i=numrecsobs+1:numrecsobs+numrecspred
            eopdata(:,i) = fscanf(fid,'%i %d %d %i %f %f %f %f %f %f %f %f %i',[13 1]);
        end
        break
    end
end
fclose(fid);

if (year < 57)
    year = year + 2000;
else
    year = year + 1900;
end
[mon,day,hr,minute,sec] = days2mdh(year,doy);
MJD_Epoch = Mjday(year,mon,day,hr,minute,sec);
MJD_UTC = MJD_Epoch+tsince/1440;

% Earth Orientation Parameters
[x_pole,y_pole,UT1_UTC,LOD,dpsi,deps,dx_pole,dy_pole,TAI_UTC] = IERS(eopdata,MJD_UTC,'l');
[UT1_TAI,UTC_GPS,UT1_GPS,TT_UTC,GPS_UTC] = timediff(UT1_UTC,TAI_UTC);
MJD_UT1 = MJD_UTC + UT1_UTC/86400;
MJD_TT  = MJD_UTC + TT_UTC/86400;
T = (MJD_TT-const.MJD_J2000)/36525;
[reci, veci] = teme2eci(rteme,vteme,T,dpsi,deps)
[recef,vecef] = teme2ecef(rteme,vteme,T,MJD_UT1+2400000.5,LOD,x_pole,y_pole,2)
[rtod, vtod] = ecef2tod(recef,vecef,T,MJD_UT1+2400000.5,LOD,x_pole,y_pole,2,dpsi,deps)

% tsinceの範囲を設定
tsince_values = 1:1:10000; % 100刻みで1000から2000までの値

% 結果を保存するための行列を初期化
rteme_results = zeros(length(tsince_values), 3); % 位置ベクトル (X, Y, Z) の保存
vteme_results = zeros(length(tsince_values), 3); % 速度ベクトル (XDOT, YDOT, ZDOT) の保存

% 各tsince値に対してSGP4計算を実行
for k = 1:length(tsince_values)
    tsince = tsince_values(k);
    [rteme, vteme] = sgp4(tsince, satdata);
    
    % 結果を行列に保存
    rteme_results(k, :) = rteme*1000;
    vteme_results(k, :) = vteme*1000;
end
rteme_xy = rteme_results(:,1:2);
vteme_xy = vteme_results(:,1:2);

% 結果の表示
disp('位置ベクトル (rteme_results) [m]:');
disp(rteme_results);
disp('速度ベクトル (vteme_results) [m/s]:');
disp(vteme_results);

