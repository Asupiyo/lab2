% positions_rangeとvelocities_rangeのデータを取得
positionData = positions_range(:,1);
velocityData = velocities_range(:,1);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
%batchNorm
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

% LSTMネットワークのレイヤー設計
inputSize = 2;
numHiddenUnits = 100;
outputSize = 1;

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
YTrain = num2cell(targetData);

% LSTMモデルの訓練
net = trainNetwork(XTrain, YTrain, layers, options);

% 初期値としてテスト用の入力を設定
positionData = rteme_results(:,1);
velocityData = rteme_results(:,1);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

XTrain = num2cell(inputData, 1);

XTest = XTrain;

% 予測実行
YPredNorm = predict(net, XTest);

% 予測結果の逆正規化
YPredNorm = cell2mat(YPredNorm);
YPred1 = YPredNorm * (posMax - posMin) + posMin;

% positions_rangeとvelocities_rangeのデータを取得
positionData = positions_range(:,2);
velocityData = velocities_range(:,2);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

% LSTMネットワークのレイヤー設計
inputSize = 2;
numHiddenUnits = 100;
outputSize = 1;

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
YTrain = num2cell(targetData);

% LSTMモデルの訓練
net = trainNetwork(XTrain, YTrain, layers, options);

% 初期値としてテスト用の入力を設定
positionData = rteme_results(:,2);
velocityData = rteme_results(:,2);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

XTrain = num2cell(inputData, 1);

XTest = XTrain;

% 予測実行
YPredNorm = predict(net, XTest);

% 予測結果の逆正規化
YPredNorm = cell2mat(YPredNorm);
YPred2 = YPredNorm * (posMax - posMin) + posMin;

% positions_rangeとvelocities_rangeのデータを取得
positionData = positions_range(:,3);
velocityData = velocities_range(:,3);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

% LSTMネットワークのレイヤー設計
inputSize = 2;
numHiddenUnits = 100;
outputSize = 1;

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
YTrain = num2cell(targetData);

% LSTMモデルの訓練
net = trainNetwork(XTrain, YTrain, layers, options);

% 初期値としてテスト用の入力を設定
positionData = rteme_results(:,3);
velocityData = rteme_results(:,3);

% 正規化のための最小値と最大値の取得
posMin = min(positionData);
posMax = max(positionData);
velMin = min(velocityData);
velMax = max(velocityData);

% データの正規化
positionDataNorm = (positionData - posMin) / (posMax - posMin);
velocityDataNorm = (velocityData - velMin) / (velMax - velMin);

% 入力とターゲットの設定
inputData = [positionDataNorm(1:end-1), velocityDataNorm(1:end-1)]';
targetData = positionDataNorm(2:end)';

XTrain = num2cell(inputData, 1);

XTest = XTrain;

% 予測実行
YPredNorm = predict(net, XTest);

% 予測結果の逆正規化
YPredNorm = cell2mat(YPredNorm);
YPred3 = YPredNorm * (posMax - posMin) + posMin;

YPred = cat(2,YPred1,YPred2,YPred3);

% 結果のプロット
plot3(positions_range(2:end,1), positions_range(2:end,2), positions_range(2:end,3),'-o')
hold on
plot3(YPred(:,1),YPred(:,2),YPred(:,3), '-x')
legend('True Positions', 'Predicted Positions')
title('LSTM Prediction of Next Position with Normalization')
xlabel('X Position')
ylabel('Y Position')
zlabel('Z Position')
hold off
