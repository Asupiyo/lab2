% 円軌道のパラメータ
r = 10;                              % 半径
theta = linspace(0, 2*pi, 200);      % 0から2πまでの角度（200点）

% 円軌道の x, y 座標を計算
x = r * cos(theta);  % x座標
y = r * sin(theta);  % y座標

% 速度（x', y'）を計算（数値微分）
dx = gradient(x);  % x の微分（近似）
dy = gradient(y);  % y の微分（近似）

% 学習用データ範囲を設定 (0から1/2πまで)
train_idx = theta <= pi/2;

% 学習データ
X_train = [x(train_idx)', y(train_idx)', dx(train_idx)', dy(train_idx)'];
Y_train = [x(train_idx)', y(train_idx)'];

% 予測データ範囲を設定 (1/2πから2πまで)
predict_idx = theta > pi/2;
X_predict = [x(predict_idx)', y(predict_idx)', dx(predict_idx)', dy(predict_idx)'];

% LSTMのレイヤー構造
layers = [
    sequenceInputLayer(4)        % 4つの特徴量 (x, y, x', y')
    lstmLayer(50, 'OutputMode', 'sequence') % LSTM層（出力モードはシーケンス）
    fullyConnectedLayer(2)       % 出力は2つの座標 (x, y)
    regressionLayer              % 回帰問題として扱う
];

% トレーニングオプション
options = trainingOptions('adam', ...
    'MaxEpochs', 500, ...
    'MiniBatchSize', 100, ...
    'InitialLearnRate', 0.01, ...
    'Plots', 'training-progress', ...
    'Verbose', 0);

% LSTMのトレーニング
net = trainNetwork(X_train', Y_train', layers, options);

% LSTMによる予測
YPred = predict(net, X_predict');  % 予測 (2×データ点数)

% 予測結果を転置してサイズを揃える
YPred = YPred';  % 列ベクトルとして出力

% 実際のデータと予測結果をプロット
figure;
plot(x, y, 'r-', 'LineWidth', 2);           % 実際の円軌道
hold on;
plot(x(train_idx), y(train_idx), 'go', 'MarkerSize', 6);  % 学習範囲を緑で表示
plot(YPred(:,1), YPred(:,2), 'b--', 'LineWidth', 2);      % 予測された軌道
legend('True Trajectory', 'Training Data', 'Predicted Trajectory');
xlabel('x');
ylabel('y');
title('LSTM Prediction from Trained Quarter of Circular Trajectory');
axis equal;  % 軸のスケールを同じにする
