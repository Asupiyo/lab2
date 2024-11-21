% 時間設定
startTime = datetime(2024,11,18,14,38,0);
stopTime = startTime + days(1);
sampleTime = 10;
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
numSatellites = 3; % 使用する衛星数
satList = [];
svmat = zeros(numSatellites, 3, length(startTime:sampleTime:stopTime)); % svmat: [N x 3 x T]

for i = 1:numSatellites
    semiMajorAxis = 7000000 + randi([0, 200000]); % 軌道長半径: 7000~7200 km
    eccentricity = rand() * 0.05; % 離心率: 0~0.05
    inclination = randi([0, 90]); % 傾斜角: 0~90°
    RAAN = randi([0, 360]); % 昇交点赤経: 0~360°
    argPeriapsis = randi([0, 360]); % 近地点引数: 0~360°
    trueAnomaly = randi([0, 360]); % 真近点角: 0~360°

    % 衛星を生成
    sat = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
        RAAN, argPeriapsis, trueAnomaly);

    satList = [satList; sat];

    % 衛星位置データをsvmatに格納
     for t = 1:length(startTime:sampleTime:stopTime)
        % 衛星の位置を取得
        [pos, ~] = states(sat, startTime + seconds((t-1)*sampleTime)); % 衛星の位置と速度
        svmat(i, :, t) = pos; % svmatに位置を格納
     end
end

% 地上局とのアクセス計算
accessData = {};
for j = 1:length(gsList)
    for i = 1:numSatellites
        % 地上局と衛星のアクセス計算
        ac = access(satList(i), gsList(j));
        intvls = accessIntervals(ac);
        accessData{end+1} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
    end
end

% 疑似距離計算
time_step = 10; % 計算の時間間隔 (秒)

% 出力ベクトル
prvec_all = zeros(length(startTime:sampleTime:stopTime), numSatellites); % 疑似距離
adrvec_all = zeros(length(startTime:sampleTime:stopTime), numSatellites); % 積算ドップラー

% 各時刻での疑似距離計算
for gsIdx = 1:length(gsList) % 各地上局に対して
    gsPos = [groundStations(gsIdx).Lat, groundStations(gsIdx).Lon, groundStations(gsIdx).Alt];
    
    for t = 1:length(startTime:sampleTime:stopTime) % 各時刻に対して
        % 地上局と衛星のアクセス情報を取得
        for i = 1:numSatellites
            
            % この時刻がアクセス可能時間帯内であれば
            if any(t >= intvls(:,1) & t <= intvls(:,2))
                % 単一時刻における衛星の位置
                svmat_t = squeeze(svmat(i, :, t)); % 衛星の位置 [1 x 3]
                
                % 擬似距離とドップラーを計算
                [prvec, adrvec] = genrng(1, gsPos, svmat_t, i, t * time_step, 0);
                
                % 保存
                prvec_all(t, i) = prvec; % 疑似距離
                adrvec_all(t, i) = adrvec; % 積算ドップラー
            end
        end
    end
end
   

% 結果の表示
disp('疑似距離:');
disp(prvec_all);
disp('積算ドップラー:');
disp(adrvec_all);

% アクセス情報の表示
fprintf("\n=== アクセス情報 ===\n");
for i = 1:length(accessData)
    fprintf("Satellite %d <-> GroundStation %d:\n", ...
        accessData{i}.Satellite, accessData{i}.GroundStation);
    disp(accessData{i}.Intervals);
end

gpsSatellites = satellite(sc, "gpsAlmanac.txt");
for i = 1:length(gpsSatellites)
    gpsSatellites(i).MarkerColor = [0, 0.5, 1]; % GPS衛星は青系で表示
end

play(sc);