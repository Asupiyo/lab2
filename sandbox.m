clear all
startTime = datetime(2024,12,23,12,00,0);
stopTime = datetime(2024,12,23,17,00,0);
sampleTime = 10; % サンプリング間隔（秒）
sc = satelliteScenario(startTime, stopTime, sampleTime);

% 地上局リスト
groundStations = [
    struct('Lat', 43.06417, 'Lon', 141.34694, 'Alt', 20);  % 札幌
    struct('Lat', 35.6895, 'Lon', 139.6917, 'Alt', 40);    % 東京
    struct('Lat', 34.69374, 'Lon', 135.50218, 'Alt', 50);  % 大阪
    struct('Lat', 32.7903, 'Lon', 130.7414, 'Alt', 30);    % 熊本
    struct('Lat', 26.2123, 'Lon', 127.6791, 'Alt', 30);    % 沖縄
    struct('Lat', 37.4133, 'Lon', 136.91, 'Alt', 25);      % 金沢
    struct('Lat', 36.2048, 'Lon', 138.2529, 'Alt', 50);    % 長野
    struct('Lat', 31.5966, 'Lon', 130.5571, 'Alt', 20);    % 鹿児島
];


gsList = [];
for i = 1:length(groundStations)
    gs = groundStation(sc, groundStations(i).Lat, groundStations(i).Lon, Altitude=groundStations(i).Alt);
    %gs.MinElevationAngle = 1;
    gsList = [gsList; gs];
end


semiMajorAxis = [8000000;8010000;8020000;8030000;8040000;8050000];% 軌道長半径 (m)
eccentricity = [0.01; 0.01; 0.01; 0.01;0.01;0.01];              % 離心率
inclination = [280;280;280;280;280;280];                       % 傾斜角 (度)
rightAscensionOfAscendingNode = [50;55;60;65;70;75];    % 昇交点赤経 (度)
argumentOfPeriapsis = [0;0;0;0;0;0];               % 近地点引数 (度)
trueAnomaly = [-85;-80;-75;-70;-65;-60]; 

sat = satellite(sc,semiMajorAxis,eccentricity,inclination, ...
    rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);


[satpos,satvel,truepos,~,prnoisarr,troperrarr,mperrprarr,ionoerrarr]=calculateSatellites(startTime,stopTime,sampleTime,gsList,sat);

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