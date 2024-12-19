isNaNMask = any(isnan(estimatesResults{1}),2);
notNaNMask = ~isNaNMask;

OrbitResults = estimatesResults{1};
% positions_rangeとvelocities_rangeのデータを取得
positionData = estimateStates([1,3,5],:);
velocityData = estimateStates([2,4,6],:);

% 正規化のための最小値と最大値の取得
nanIdx = any(isnan(estimateStates),1)|any(isnan(estimateStates),1);
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
    posMin = min(positionData(:,block),[],2);
    posMax = max(positionData(:,block),[],2);
    velMin = min(velocityData(:,block),[],2);
    velMax = max(velocityData(:,block),[],2);

    positionDataNorm = (positionData(:,block) - posMin) ./ (posMax - posMin);
    velocityDataNorm = (velocityData(:,block) - velMin) ./ (velMax - velMin);
    maxdata = [posMax;velMax];
    mindata = [posMin;velMin];
    TrainData = [positionDataNorm(:,1:end-1);velocityDataNorm(:,1:end-1)];
    TargetData = [positionDataNorm(:,2:end);velocityDataNorm(:,2:end)];

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
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(outputSize, 'WeightLearnRateFactor', 0.1)  % 重み学習率の調整
    regressionLayer];

% 訓練オプションの設定
options = trainingOptions('adam', ...
    'MaxEpochs', 200, ...
    'MiniBatchSize', 64, ... 
    'GradientThreshold', 10, ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 100, ...
    'LearnRateDropFactor', 0.1, ...
    'Verbose', 0, ...
    'Plots', 'training-progress');


% LSTMモデルの訓練
Xnet = trainNetwork(XTrain, YTrain, layers, options);
x = endIdx(i) + 1;
while(isnan(estimateStates(1,x))&&x<=length(timeSteps))
    inputData = [positionDataNorm(:,end);velocityDataNorm(:,end)];
    inputDataSeq = {inputData};
    YPredNorm = predict(Xnet,inputDataSeq);

% 予測結果の逆正規化
    YPred = cell2mat(YPredNorm);
    Y = YPred .* (maxdata - mindata) + mindata;
    positionDataNorm(:,end+1) = YPred([1,2,3],1);
    velocityDataNorm(:,end+1) = YPred([4,5,6],1);
    positionData(:,x) = Y([1,2,3],1);
    velocityData(:,x) = Y([4,5,6],1);
    estimatesResults{1}([1,3,5],x) = Y([1,2,3],1);
    estimatesResults{1}([2,4,6],x) = Y([4,5,6],1);
    inputData = YPred(:,1);
    x = x + 1;
end
end
