% positions_rangeとvelocities_rangeのデータを取得
positionData = positions_range(:,:);
velocityData = velocities_range(:,:);

% 正規化のための最小値と最大値の取得
PposMin = min(positionData,[],1);
PposMax = max(positionData,[],1);
PvelMin = min(velocityData,[],1);
PvelMax = max(velocityData,[],1);

PpositionDataNorm = (positionData - PposMin) ./ (PposMax - PposMin);
PvelocityDataNorm = (velocityData - PvelMin) ./ (PvelMax - PvelMin);

% 入力とターゲットの設定
%batchNorm
inputData = [PpositionDataNorm(1:end-1,:), PvelocityDataNorm(1:end-1,:)]';
targetData = PpositionDataNorm(2:end,:)';

% LSTMネットワークのレイヤー設計
inputSize = 6;
numHiddenUnits = 200;
outputSize = 3;

% シーケンスデータとして訓練データの形式を整える
XTrain = num2cell(inputData, 1);
YTrain = num2cell(targetData,1);

layers = [
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(outputSize, 'WeightLearnRateFactor', 0.1)  % 重み学習率の調整
    regressionLayer];

% 訓練オプションの設定
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'GradientThreshold', 10, ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 100, ...
    'LearnRateDropFactor', 0.1, ...
    'Verbose', 0, ...
    'Plots', 'training-progress');


% LSTMモデルの訓練
Xnet = trainNetwork(XTrain, YTrain, layers, options);

% 初期値としてテスト用の入力を設定
positionData = positions_range(:,:);
velocityData = positions_range(:,:);

% 正規化のための最小値と最大値の取得
PposMin = min(positionData,[],1);
PposMax = max(positionData,[],1);
PvelMin = min(velocityData,[],1);
PvelMax = max(velocityData,[],1);
% データの正規化
PpositionDataNorm = (positionData - PposMin) ./ (PposMax - PposMin);
PvelocityDataNorm = (velocityData - PvelMin) ./ (PvelMax - PvelMin);

% 入力とターゲットの設定
inputData = [PpositionDataNorm(1:end-1,:), PvelocityDataNorm(1:end-1,:)]';
targetData = PpositionDataNorm(2:end,:)';

XTrain = num2cell(inputData, 1);

XTest = XTrain;

% 予測実行
YPredNorm = predict(Xnet, XTest);

% 予測結果の逆正規化
YPredNorm = cell2mat(YPredNorm);
YPred = YPredNorm * (PposMax - PposMin) + PposMin;

plot3(positions_range(2:end,1), positions_range(2:end,2), positions_range(2:end,3),'r')
hold on
plot3(YPred(:,1),YPred(:,2), YPred(:,3),'b')