% 定数
G = 6.67430e-11;  % 重力定数 (m^3 kg^-1 s^-2)
M = 5.972e24;     % 地球の質量 (kg)
R = 6371e3;       % 地球の半径 (m)
J2 = 1.08263e-3;  % J2摂動項

% 軌道要素
a = 7000e3;  % 軌道半径 (m)
e = 0.01;    % 離心率
i = deg2rad(45);  % 軌道傾斜 (rad)
raan = deg2rad(0);  % 昇交点経度 (rad)
argp = deg2rad(0);  % 近地点引数 (rad)

% 平均運動の計算
n = sqrt(G * M / a^3);  % 平均運動 (rad/s)

% BSTAR抗力項の設定
bstar = 1.0e-5;  % BSTAR (kg/m^2)

% 軌道計算関数

function [positions, n_dot] = simulate_orbit(n, e, a, raan, argp, i, t_end, dt, bstar, J2)
% 定数
G = 6.67430e-11;  % 重力定数 (m^3 kg^-1 s^-2)
M = 5.972e24;     % 地球の質量 (kg)
R = 6371e3;       % 地球の半径 (m)
J2 = 1.08263e-3;  % J2摂動項
    times = 0:dt:t_end;
    positions = zeros(length(times), 3);
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

        % J2摂動による平均運動の変化を計算
        n_dot(k) = - (3/2) * J2 * (G * M)^(2/3) * (R^2) * (cos(i)) / (a^(7/2));  % J2による変化率
    end
end

% シミュレーション
t_end = 6000;
dt = 10;
[positions, n_dot] = simulate_orbit(n, e, a, raan, argp, i, t_end, dt, bstar, J2);  % 6000秒のシミュレーション

% t=3000の地点での値を出力
target_time = 3000;
target_index = find(0:dt:t_end == target_time);

fprintf('At t = %d seconds:\n', target_time);
fprintf('BSTAR: %.2e kg/m^2\n', bstar);
fprintf('Eccentricity: %.4f\n', e);
fprintf('Average Motion Change: %.6f rad/s^2\n', n_dot(target_index));

% 結果のプロット
figure;
plot3(positions(:, 1), positions(:, 2), positions(:, 3));
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Orbital Simulation with J2 Perturbation');
grid on;
axis equal;
