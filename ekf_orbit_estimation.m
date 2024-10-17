function x_est = ekf_orbit_estimation(x0, P0, Q, R, F, H, measurements, num_steps, dt)
    % ekf_orbit_estimation_ekf: `extendedKalmanFilter` を使った汎用的なEKF実装
    % 引数:
    %   x0: 初期状態ベクトル [x, y, z, vx, vy, vz] (6x1 ベクトル)
    %   P0: 初期共分散行列 (6x6 行列)
    %   Q: システムノイズ共分散行列 (6x6 行列)
    %   R: 観測ノイズ共分散行列 (6x6 行列)
    %   F: 状態遷移行列 (6x6 行列)
    %   H: 観測モデル行列 (6x6 行列)
    %   measurements: 計測値 [x, y, z, vx, vy, vz]' の配列 (6xnum_steps 行列)
    %   num_steps: EKFを実行するステップ数
    %   dt: 時間ステップ
    %
    % 出力:
    %   x_est: 最終的に推定された状態ベクトルの履歴 (6xnum_steps 行列)

    % 状態遷移関数の定義
    stateTransitionFcn = @(x) F * x;

    % 観測関数の定義
    measurementFcn = @(x) H * x;

    % EKFの作成
    ekf = extendedKalmanFilter(stateTransitionFcn, measurementFcn, x0);

    % 共分散行列の設定
    ekf.StateCovariance = P0; % 初期の共分散行列
    ekf.ProcessNoise = Q;     % システムノイズ
    ekf.MeasurementNoise = R; % 観測ノイズ

    % EKFで状態を更新
    x_est = zeros(6, num_steps); % 推定結果を保存する配列

    for k = 1:num_steps
        % 1ステップごとにEKFを更新
        x_est(:, k) = correct(ekf, measurements(:, k)); % 計測値で更新
        predict(ekf); % 次の状態を予測
    end
end