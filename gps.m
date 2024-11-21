% 時間設定
startTime = datetime(2024,11,18,14,38,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% 地上局リスト（設定）
groundStations = [
    struct('Lat', 35.6895, 'Lon', 139.6917, 'Alt', 50), % 東京
    struct('Lat', 43.0642, 'Lon', 141.3468, 'Alt', 20), % 札幌
    struct('Lat', 26.2124, 'Lon', 127.6809, 'Alt', 30)  % 沖縄
];

% 地上局の追加
gsList = [];
for i = 1:length(groundStations)
    gs = groundStation(sc, groundStations(i).Lat, groundStations(i).Lon, Altitude=groundStations(i).Alt);
    gsList = [gsList; gs];
end

% 衛星のランダム生成設定
numSatellites = 30; % ランダム生成する衛星の数
satList = [];
accessData = {};
for i = 1:numSatellites
    semiMajorAxis = 7000000 + randi([0, 200000]); % 軌道長半径: 7000~7200 km
    eccentricity = rand() * 0.05; % 離心率: 0~0.05
    inclination = randi([0, 90]); % 傾斜角: 0~90°
    RAAN = randi([0, 360]); % 昇交点赤経: 0~360°
    argPeriapsis = randi([0, 360]); % 近地点引数: 0~360°
    trueAnomaly = randi([0, 360]); % 真近点角: 0~360°
    color = rand(1, 3); % ランダムな色

    % 衛星を生成
    sat = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
        RAAN, argPeriapsis, trueAnomaly);
    sat.MarkerColor = color; % 衛星の色設定
    satList = [satList; sat];

    % 地上局とのアクセス計算
    for j = 1:length(gsList)
        ac = access(sat, gsList(j));
        intvls = accessIntervals(ac);
        accessData{end+1} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
    end
end

% 衛星の軌道要素を取得
elements = [];
for i = 1:length(satList)
    ele = orbitalElements(satList(i));
    elements = [elements;ele];
end


% GPS衛星をGPSアルマナックから追加
gpsSatellites = satellite(sc, "gpsAlmanac.txt");
for i = 1:length(gpsSatellites)
    gpsSatellites(i).MarkerColor = [0, 0.5, 1]; % GPS衛星は青系で表示
end

% シナリオを再生
play(sc);

% アクセス情報の表示
fprintf("\n=== アクセス情報 ===\n");
for i = 1:length(accessData)
    fprintf("Satellite %d <-> GroundStation %d:\n", ...
        accessData{i}.Satellite, accessData{i}.GroundStation);
    disp(accessData{i}.Intervals);
end
