% 時間設定
startTime = datetime(2024,11,20,15,00,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);

% 地上局リスト
groundStations = [
    struct('Lat', 35.6722116666667, 'Lon', 139.528622277778, 'Alt', 50); % 東京
    struct('Lat', 43.0642, 'Lon', 141.3468, 'Alt', 20); % 札幌
    struct('Lat', 26.2124, 'Lon', 127.6809, 'Alt', 30);  % 沖縄
    struct('Lat',35.8818,'Lon',139.828395,'Alt',4.7);
    struct('Lat',34.8393,'Lon',134.694,'Alt',50.8)
];

% 地上局の追加
gsList = [];
for i = 1:length(groundStations)
    gs = groundStation(sc, groundStations(i).Lat, groundStations(i).Lon, Altitude=groundStations(i).Alt);
    gsList = [gsList; gs];
end

numOrbits = 1; % 軌道の数
semiMajorAxisBase = 7200000; % 基本の軌道長半径 (m)
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
    raan = randi([0,359]); % RAANを増加させて360度で折り返し
    argPeriapsis = randi([0,359]); % 近地点引数も増加
    trueAnomaly = randi([0,359]); % 真近点離角も増加
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
            [pos, vel] = states(sat, currentTime); % 衛星の位置と速度
            svmat(i, :, t) = pos; % svmatに位置を格納
            svvmat(i,:,t) = vel;
        end
    
    for j = 1:length(gsList)
        ac = access(sat, gsList(j));
        intvls = accessIntervals(ac);
        accessData{end+1} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
    end
end
satellitePosData = cell(numOrbits,1);
satelliteVelData = cell(numOrbits,1);
prvecs = zeros(length(gsList),length(timeSteps));
vrvec = zeros(length(gsList),length(timeSteps));
vrvecs = cell(size(vrvec));
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
            svvmat_t = squeeze(svvmat(satIdx,:,elapsedTime));
            [prvec, adrvec] = genrng(1, gsPos, svmat_t, i, t * elapsedTime, 0);
             fprintf('受信機%dの衛星%dに対する%sでの疑似距離は、%s\n',gsIdx,satIdx,currentT, prvec);
             currentT = currentT + seconds(sampleTime);
             prvecs(gsIdx,elapsedTime) = prvec;
             vrvecs(gsIdx,elapsedTime) = {svvmat_t};
        end
    end
end
satellitePosData{satIdx,1} = prvecs;
satelliteVelData{satIdx,1} = vrvecs;%観測期間中だけの速度を入れたい(できた)&そもそも受信機が速度を図ることはできる？
end

%fprintf("\n=== アクセス情報 ===\n");
%for i = 1:length(accessData)
%    fprintf("Satellite %d <-> GroundStation %d:\n", ...
%        accessData{i}.Satellite, accessData{i}.GroundStation);
%    disp(accessData{i}.Intervals);
%end

play(sc);
%めも
%観測期間中の疑似距離を計算
%ちょっと時間がかかる
%軌道をいい感じに配置するの難しい(いくつかは実際のLEO衛星の軌道をまねて作成する予定)
%今後はこの疑似距離を使ってEKFで軌道を計算、LSTMで軌道の予測、評価
%EKFには初期値が必要(t=0の時の衛星の位置を初期値とする)
%初期値の計算にはGPS→受信機の逆(受信機→LEO衛星)を行う
%ノイズは毎回変わる