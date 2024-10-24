% 位置と速度の計算
velocities = zeros(length(positions), 3);
times = 0:dt:t_end;  % 時間配列の定義
for k = 1:length(positions)-1
    dt = times(k+1) - times(k);  % 時間間隔
    velocities(k, :) = (positions(k+1, :) - positions(k, :)) / dt;  % 差分から速度を計算
end

% 最後の速度データを補完（ゼロで埋める）
velocities(end, :) = velocities(end-1, :);

% データの正規化
data = [positions, velocities];
data = (data - mean(data)) ./ std(data);  % 標準化

% 学習用とテスト用に分割
train_size = 100;  % LSTMに学習させる時間ステップ数
X_train = data(1:train_size, :);
y_train = data(2:train_size + 1, :);  % 次の時刻のデータをターゲットに

% テストデータを準備（次の100秒分）
X_test = data(train_size + 1:end, :);
y_test = data(train_size + 2:end, :);

% LSTMネットワークの構築
numFeatures = size(X_train, 2);  % 特徴量の数
numResponses = size(y_train, 2);  % 予測する応答の数
numHiddenUnits = 50;  % 隠れユニットの数

layers = [
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(numResponses)
    regressionLayer];

% オプションの設定
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 10, ...
    'Shuffle', 'never', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% モデルの学習
XTrain = num2cell(X_train, 2);
YTrain = num2cell(y_train, 2);
net = trainNetwork(X_train, y_train, layers, options);

% テストデータの予測
XTest = num2cell(X_test, 2);
YPred = predict(net, XTest);

% 予測結果を元のスケールに戻す
YPred = cell2mat(YPred);
y_pred_original = (YPred * data_std) + data_mean;
y_test_original = (y_test * data_std) + data_mean;

% 位置データのプロット
figure;
hold on;
plot(y_test_original(:, 1), 'DisplayName', 'True x');
plot(y_pred_original(:, 1), 'DisplayName', 'Predicted x', 'LineStyle', '--');
title('True vs Predicted Position (x)');
xlabel('Time Step');
ylabel('Position (m)');
legend;
hold off;

% 他の座標 (y, z) についても同様にプロット


