% 時間設定
startTime = datetime(2024,11,20,15,00,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);

% 地上局リスト
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

% ユーザー定義衛星リスト
satelliteParams = [
    struct('SemiMajorAxis', 7371000, 'Eccentricity', 0.01, 'Inclination', 52, ...
           'RAAN', 95, 'ArgPeriapsis', 93, 'TrueAnomaly', 0, 'Color', [1, 0, 0]),
    struct('SemiMajorAxis',8000000, 'Eccentricity',0.01, 'Inclination', 33,...
            'RAAN',33,'ArgPeriapsis',33,'TrueAnomaly', 33, 'Color', [1, 1, 0])
];

% 衛星の追加とアクセス計算
satList = [];
accessData = {};
for i = 1:length(satelliteParams)
    sat = satellite(sc, satelliteParams(i).SemiMajorAxis, satelliteParams(i).Eccentricity, ...
        satelliteParams(i).Inclination, satelliteParams(i).RAAN, ...
        satelliteParams(i).ArgPeriapsis, satelliteParams(i).TrueAnomaly);
    sat.MarkerColor = satelliteParams(i).Color;
    satList = [satList; sat];

       timeSteps = startTime:seconds(sampleTime):stopTime;  
        for t = 1:length(timeSteps)
            currentTime = timeSteps(t);
            [pos, ~] = states(sat, currentTime); % 衛星の位置と速度
            svmat(i, :, t) = pos; % svmatに位置を格納
        end
    
    for j = 1:length(gsList)
        ac = access(sat, gsList(j));
        intvls = accessIntervals(ac);
        accessData{end+1} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
    end
end
for satIdx = 1:length(satList)
for gsIdx = 1:length(gsList) % 各地上局に対して
    gsPos = [groundStations(gsIdx).Lat, groundStations(gsIdx).Lon, groundStations(gsIdx).Alt];
    startTime = datetime(startTime, 'TimeZone', 'UTC');  % UTCに設定
    %currentT = datetime(currentT, 'TimeZone', 'UTC');    % UTCに設定
    for i=1:size(intvls,1)
        startT = intvls{i,'StartTime'};
        endT = intvls{i,'EndTime'};
        currentT = startT;
        while currentT <= endT
            elapsedTime = seconds(currentT-startTime)/sampleTime; 
            svmat_t = squeeze(svmat(satIdx, :, elapsedTime)); % 衛星の位置 [1 x 3]
            [prvec, adrvec] = genrng(1, gsPos, svmat_t, i, t * elapsedTime, 0);
             fprintf('受信機%dの衛星%dに対する%sでの疑似距離は、%s\n',gsIdx,satIdx,currentT, prvec);
             currentT = currentT + seconds(sampleTime);
        end
    end
end
end

fprintf("\n=== アクセス情報 ===\n");
for i = 1:length(accessData)
    fprintf("Satellite %d <-> GroundStation %d:\n", ...
        accessData{i}.Satellite, accessData{i}.GroundStation);
    disp(accessData{i}.Intervals);
end

%めも
%観測期間中の疑似距離を計算
%ちょっと時間がかかる
%軌道をいい感じに配置するの難しい(いくつかは実際のLEO衛星の軌道をまねて作成する予定)
%今後はこの疑似距離を使ってEKFで軌道を計算、LSTMで軌道の予測、評価
%EKFには初期値が必要(t=0の時の衛星の位置を初期値とする)
%初期値の計算にはGPS→受信機の逆(受信機→LEO衛星)を行う
%ノイズは毎回変わる