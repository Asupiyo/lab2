isNaNMask = any(isnan(estimatesResults{1}),2);
notNaNMask = ~isNaNMask;

OrbitResults = estimatesResults{1};
% positions_rangeとvelocities_rangeのデータを取得
positionData = estimatesResults{1}([1,3,5],:);
velocityData = estimatesResults{1}([2,4,6],:);

% 正規化のための最小値と最大値の取得
posMin = min(positionData,[],1);
posMax = max(positionData,[],1);
velMin = min(velocityData,[],1);
velMax = max(velocityData,[],1);

positionDataNorm = (positionData - posMin) ./ (posMax - posMin);
velocityDataNorm = (velocityData - velMin) ./ (velMax - velMin);
nanIdx = any(isnan(positionDataNorm),1)|any(isnan(velocityDataNorm),1);
validIdx = ~nanIdx;
startIdx = find(diff([0; validIdx(:)]) == 1);
endIdx = find(diff([validIdx(:); 0]) == -1); 

% 入力とターゲットの設定
positionTrain = [];
velocityTrain = [];
for i=1:length(startIdx)
    block = startIdx(1):endIdx(i);
    if i >= 3
        block = startIdx(i-2):endIdx(i);
    end
    TrainData = [positionDataNorm(:,startIdx(1):endIdx(i)-1);velocityDataNorm(:,startIdx(1):endIdx(i)-1)];
    TargetData = [positionDataNorm(:,startIdx(1)+1:endIdx(i));velocityDataNorm(:,startIdx(1)+1:endIdx(i))];

    % シーケンスデータとして訓練データの形式を整える
    XTrain = num2cell(TrainData, 1);
    YTrain = num2cell(TargetData,1);

% LSTMネットワークのレイヤー設計
inputSize = 6;
numHiddenUnits = 200;
outputSize = 6;

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
inputData = [positionDataNorm(:,endIdx(i));velocityDataNorm(:,endIdx(i))];
x = endIdx(i) + 1;
while((x <= size(positionDataNorm, 2)) && isnan(positionDataNorm(1, x)))
    inputDataSeq = {inputData};
    YPredNorm = predict(Xnet,inputDataSeq);

% 予測結果の逆正規化
    YPred = cell2mat(YPredNorm);
    Y = YPred * (posMax - posMin) + posMin;
    positionDataNorm(:,x) = YPred([1,2,3],1);
    velocityDataNorm(:,x) = YPred([4,5,6],1);
    estimatesResults{1}([1,3,5],x) = Y([1,2,3],1);
    estimatesResults{1}([2,4,6],x) = Y([4,5,6],1);
    inputData = YPred(:,1);
    x = x + 1;
end
end
plot3(positions_range(2:end,1), positions_range(2:end,2), positions_range(2:end,3),'r')
hold on
plot3(Y(:,1),Y(:,2), Y(:,3),'b')