% positions_rangeとvelocities_rangeの全データを取得
positionData = positions_range(:,:);
velocityData = velocities_range(:,:);

% 正規化のための最小値と最大値の取得
posMin = min(positionData, [], 'all');
posMax = max(positionData, [], 'all');
velMin = min(velocityData, [], 'all');
velMax = max(velocityData, [], 'all');

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1, :)'; velocityDataNorm(1:end-1, :)'];
targetData = positionDataNorm(2:end, :)';

% LSTMネットワークのレイヤー設計
inputSize = size(inputData, 1);
numHiddenUnits = 100;
outputSize = size(targetData, 1);

layers = [
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(outputSize)
    regressionLayer];

% 訓練オプションの設定
options = trainingOptions('adam', ...
    'MaxEpochs', 200, ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.01, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 100, ...
    'LearnRateDropFactor', 0.2, ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% シーケンスデータとして訓練データの形式を整える
XTrain = num2cell(inputData, 1);
YTrain = num2cell(targetData, 1);

% LSTMモデルの訓練
net = trainNetwork(XTrain, YTrain, layers, options);

% 予測用のデータ取得
positionData = rteme_results(:,:);
velocityData = rteme_results(:,:);

% 正規化のための最小値と最大値の取得
posMin = min(positionData, [], 'all');
posMax = max(positionData, [], 'all');
velMin = min(velocityData, [], 'all');
velMax = max(velocityData, [], 'all');

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力データの設定
inputData = [positionDataNorm(1:end-1, :)'; velocityDataNorm(1:end-1, :)'];
XTest = num2cell(inputData, 1);

% 予測実行
YPredNorm = predict(net, XTest);

% 予測結果の逆正規化と再整形
YPredNorm = cell2mat(YPredNorm);

% YPredNormを1000x3行列に整形（タイムステップ数 x 3次元出力）
YPred = reshape(YPredNorm, [], 3);

% 逆正規化
YPred = YPred * (posMax - posMin) + posMin;

% 結果のプロット
plot3(positions_range(2:end,1), positions_range(2:end,2), positions_range(2:end,3),'-o')
hold on
plot3(YPred(1,:), YPred(2,:), YPred(3,:), '-x')
legend('True Positions', 'Predicted Positions')
title('LSTM Prediction of Next Position with Normalization')
xlabel('X Position')
ylabel('Y Position')
zlabel('Z Position')
hold off
