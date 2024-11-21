<<<<<<< HEAD
% 時間設定
=======
>>>>>>> 0c484dc1ef9874ee119d58395d4cc797d7a859c1
startTime = datetime(2024,11,18,14,38,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime, stopTime, sampleTime);

<<<<<<< HEAD
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
=======
p = states(sat);
gs1 = groundStation(sc,35.6895,139.6917,Altitude=50);
gs2 = groundStation(sc,35.65775005,139.54355865);

semiMajorAxis = 7371000;%m
eccentricity = 0.01;%離心率
inclination = 52;%傾斜角
rightAscensionOfAscendingNode = 95;
argumentOfPeriapsis = 93;
trueAnomaly = 0;%真近角点(意外と大事)
sat2 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
trueAnomaly = 180;
sat3 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
ac21 = access(sat2,gs1);
ac22 = access(sat2,gs2);
ac31 = access(sat3,gs1);
ac32 = access(sat3,gs2);
intvls21 = accessIntervals(ac21);
intvls22 = accessIntervals(ac22);
intvls31 = accessIntervals(ac31);
intvls32 = accessIntervals(ac32);
sat2.MarkerColor = [1, 0, 0];
sat3.MarkerColor = [1,1,0];
inclination = 10;
rightAscensionOfAscendingNode = 10;
argumentOfPeriapsis = 20;
sat4 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
ac41 = access(sat4,gs1);
ac42 = access(sat4,gs2);
intvls41 = accessIntervals(ac41);
intvls42 = accessIntervals(ac42);
sat4.MarkerColor = [1,0,1];
play(sc);
disp(intvls21);
disp(intvls31);
disp(intvls41);
disp(intvls21);
disp(intvls32);
disp(intvls42);
>>>>>>> 0c484dc1ef9874ee119d58395d4cc797d7a859c1
