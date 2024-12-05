clear all
startTime = datetime(2024,11,20,15,00,0);
stopTime = startTime + days(1);
sampleTime = 10;

% 地上局リスト
groundStations = [
    struct('Lat', 35.6722116666667, 'Lon', 139.528622277778, 'Alt', 50); % 東京
    struct('Lat', 43.0642, 'Lon', 141.3468, 'Alt', 20); % 札幌
    struct('Lat', 26.2124, 'Lon', 127.6809, 'Alt', 30);  % 沖縄
    struct('Lat',35.8818,'Lon',139.828395,'Alt',4.7);
    struct('Lat',34.8393,'Lon',134.694,'Alt',50.8)
    struct('Lat',39.86627,'Lon',116.378174,'Alt',0);%北京
    struct('Lat',-33.985502,'Lon',151.171875,'Alt',0);%シドニー
    struct('Lat',19.482129,'Lon',-155.545903,'Alt',0);%太平洋
];

numOrbits = 1; % 軌道の数
semiMajorAxisBase = 8000000; % 基本の軌道長半径 (m)
eccentricityBase = 0.01; % 基本の離心率
inclinationBase = 70; % 基本の傾斜角 (度)

% 色を定義 (色を36色生成)
colors = jet(numOrbits); % Jetカラーマップを利用

satelliteParams = struct();

for i = 1:numOrbits
    % パラメータを計算
    semiMajorAxis = semiMajorAxisBase; % 軌道長半径を少しずつ増加
    eccentricity = eccentricityBase; % 一定
    inclination = inclinationBase; % 傾斜角は一定 (70度)
    raan = 100;%randi([0,359]); % RAANを増加させて360度で折り返し
    argPeriapsis = 100;%randi([0,359]); % 近地点引数も増加
    trueAnomaly = 100;%randi([0,359]); % 真近点離角も増加
    color = colors(i, :); % 色を割り当て
    
    % i番目の構造体を作成して、構造体配列に代入
    satelliteParams(i).SemiMajorAxis = semiMajorAxis;
    satelliteParams(i).Eccentricity = eccentricity;
    satelliteParams(i).Inclination = inclination;
    satelliteParams(i).RAAN = raan;
    satelliteParams(i).ArgPeriapsis = argPeriapsis;
    satelliteParams(i).TrueAnomaly = trueAnomaly;
    satelliteParams(i).Color = color;
end

[gsList,satpos,satvel,truepos]=calculateSatellites(startTime,stopTime,sampleTime,groundStations,satelliteParams);

% サンプルのセル配列（各要素がベクトル）
A = satvel{1};

% 各列の要素を同じインデックスで平均を取る
numRows = size(A, 1);  % 行数
numCols = size(A, 2);  % 列数

% 結果を格納するためのセル配列
meanResults = cell(1, numCols);
for colIdx = 1:numCols
    % 各列のベクトルを取り出し、同じインデックスの要素ごとに平均を取る
    tempVec = cell2mat(A(:, colIdx));  % 各列のベクトルを数値配列に変換
    meanResults{colIdx} = mean(tempVec, 1);  % 各列のインデックスごとに平均を取る
end

for i=1:numel(meanResults)
    if isempty(meanResults{i})
        meanResults{i} = 0;
    end
end



