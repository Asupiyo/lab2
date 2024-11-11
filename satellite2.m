% 定数
G = 6.67430e-11;  % 重力定数 (m^3 kg^-1 s^-2)
M = 5.972e24;     % 地球の質量 (kg)
R = 6371e3;       % 地球の半径 (m)
J2 = 1.08263e-3;  % J2摂動項

% 軌道要素
a = 7000e3;  % 軌道半径 (m)
e = 0.5;    % 離心率
i = deg2rad(45);  % 軌道傾斜 (rad)
raan = deg2rad(0);  % 昇交点経度 (rad)
argp = deg2rad(0);  % 近地点引数 (rad)

% 平均運動の計算
n = sqrt(G * M / a^3);  % 平均運動 (rad/s)

% BSTAR抗力項の設定
bstar = 0.74395e-4;  % BSTAR (kg/m^2)

% 軌道計算関数
function [positions, velocities, n_dot] = simulate_orbit(n, e, a, raan, argp, i, t_end, dt)
    % 定数
    G = 6.67430e-11;  % 重力定数 (m^3 kg^-1 s^-2)
    M = 5.972e24;     % 地球の質量 (kg)
    R = 6371e3;       % 地球の半径 (m)
    J2 = 1.08263e-3;  % J2摂動項
    times = 1:dt:t_end;
    positions = zeros(length(times), 3);
    velocities = zeros(length(times), 3);
    n_dot = zeros(length(times), 1);  % 平均運動の変化率を格納する配列

    for k = 1:length(times)
        t = times(k);
        M_t = n * t;  % 平均運動による平均近点角
        E = M_t;  % 初期の離心率の近似

        % ケプラー方程式を解く（近似）
        for j = 1:10  % ニュートン法による反復
            E = M_t + e * sin(E);
        end

        % 真近点角の計算
        nu = 2 * atan2(sqrt(1 + e) * sin(E / 2), sqrt(1 - e) * cos(E / 2));

        % 位置の計算
        r = a * (1 - e * cos(E));
        x = r * (cos(raan) * cos(argp + nu) - sin(raan) * sin(argp + nu) * cos(i));
        y = r * (sin(raan) * cos(argp + nu) + cos(raan) * sin(argp + nu) * cos(i));
        z = r * (sin(argp + nu) * sin(i));
        positions(k, :) = [x, y, z];

        % 速度の計算
        h = sqrt(G * M * a * (1 - e^2)); % 比エネルギー定数
        vx = (G * M / h) * (-cos(raan) * sin(argp + nu) - sin(raan) * cos(argp + nu) * cos(i));
        vy = (G * M / h) * (-sin(raan) * sin(argp + nu) + cos(raan) * cos(argp + nu) * cos(i));
        vz = (G * M / h) * cos(argp + nu) * sin(i);
        velocities(k, :) = [vx, vy, vz];

        % J2摂動による平均運動の変化を計算
        n_dot(k) = - (3/2) * J2 * (G * M)^(2/3) * (R^2) * (cos(i)) / (a^(7/2));  % J2による変化率
    end
end

% シミュレーション
t_end = 10001;
dt = 10;
[positions, velocities, n_dot] = simulate_orbit(n, e, a, raan, argp, i, t_end, dt);  % 6000秒のシミュレーション


for i=1:t_end
    positions_range = positions(:,:);
    velocities_range = velocities(:,:);
end

