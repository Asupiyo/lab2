% 初期軌道パラメータ
a = 6786230;              % 半長軸 (m)
ecc = 0.01;                % 離心率
incl = 52;                 % 傾斜角 (度)
RAAN = 95;                 % 昇交点赤経 (度)
argp = 93;                 % 近地点引数 (度)
nu = 300;                  % 真近点離角 (度)

% 万有引力定数
mu = 3.986e14;             % 地球の標準重力定数 (m^3/s^2)

% 軌道周期の計算
T = 2 * pi * sqrt(a^3 / mu);  % 軌道周期 (秒)

% 真近点離角の時間変化を計算
n = 2 * pi / T;              % 平均運動 (rad/s)

% 時間範囲の設定
time_range = 1:100;          % 秒

% 位置と速度を記録する配列
r_ijk_series = zeros(length(time_range), 3);  % 各時刻の位置ベクトルを保存
v_ijk_series = zeros(length(time_range), 3);  % 各時刻の速度ベクトルを保存

% 各時刻の真近点離角を計算して、位置・速度を取得
for t = time_range
    % 真近点離角を更新
    nu_t = nu + rad2deg(n * t);  % 平均運動に基づき真近点離角を増加
    nu_t = mod(nu_t, 360);       % 真近点離角を0-360度の範囲に保持
    
    % 位置と速度を計算
    [r_ijk, v_ijk] = keplerian2ijk(a, ecc, incl, RAAN, argp, nu_t);
    
    % 配列に保存
    r_ijk_series(t, :) = r_ijk;
    v_ijk_series(t, :) = v_ijk;
end

% 結果の表示
disp('各時刻の位置ベクトル (m):');
disp(r_ijk_series);
disp('各時刻の速度ベクトル (m/s):');
disp(v_ijk_series);
