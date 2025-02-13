startTime = datetime(2024,12,16,00,00,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);

semiMajorAxis = [8100000;7000000;7100000;7200000;7300000;7400000;7500000;7600000;7700000;7800000;7900000;8000000;7777777;8200000;7788999;8019999];
eccentricity = [0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01];
inclination = [0;10;15;30;45;50;60;75;90;105;120;125;135;150;165;185];
rightAscensionOfAscendingNode = [0;10;15;30;45;50;60;75;90;105;120;125;135;150;165;185];
argumentOfPeriapsis = [288,163,156,297,39,48,62,141,300,290,21,144,190,150,237,226];
trueAnomaly = [0;10;15;30;45;50;60;75;90;105;120;125;135;150;165;185];


sat = satellite(sc,semiMajorAxis,eccentricity,inclination, ...
    rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);

groundStations = [
    struct('Lat', 43.06417, 'Lon', 141.34694, 'Alt', 20);  % 札幌
    struct('Lat', 35.6895, 'Lon', 139.6917, 'Alt', 40);    % 東京
    struct('Lat', 34.69374, 'Lon', 135.50218, 'Alt', 50);  % 大阪
    struct('Lat', 32.7903, 'Lon', 130.7414, 'Alt', 30);    % 熊本
    struct('Lat', 26.2123, 'Lon', 127.6791, 'Alt', 30);    % 沖縄
    struct('Lat', 37.4133, 'Lon', 136.91, 'Alt', 25);      % 金沢
    struct('Lat', 36.2048, 'Lon', 138.2529, 'Alt', 50);    % 長野
    struct('Lat', 31.5966, 'Lon', 130.5571, 'Alt', 20);    % 鹿児島
    struct('Lat',35.65606806,'Lon',139.54404914,'Alt',10)
];


gsList = [];
for i = 1:length(groundStations)
    gs = groundStation(sc, groundStations(i).Lat, groundStations(i).Lon, Altitude=groundStations(i).Alt);
    %gs.MinElevationAngle = 1;
    gsList = [gsList; gs];
end

for j = 1:length(gsList)
        ac = access(sat, gsList(j));
        intvls = accessIntervals(ac);  % アクセス間隔を取得
        accessData{j} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
end

for gsIdx = 1:length(gsList)
    intvls = accessData{gsIdx}.Intervals;
    for i = 1:size(intvls, 1)
        startT = intvls{i, 'StartTime'};
        endT = intvls{i, 'EndTime'};
        currentT = startT;
        while currentT <= endT
            elapsedTime = seconds(currentT - starttime) / sampleTime;

            % 無効な elapsedTime をスキップ
            if elapsedTime <= 0 || elapsedTime ~= floor(elapsedTime)
                currentT = currentT + seconds(sampleTime); % 次のタイムステップへ
                continue;
            end

            disp(elapsedTime);
            currentT = currentT + seconds(sampleTime);
        end
    end
end

play(sc,PlaybackSpeedMultiplier=40)