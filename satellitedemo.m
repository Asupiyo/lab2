% シミュレーションの開始時刻と終了時刻
startTime = datetime(2024,12,23,12,00,0);
stopTime = datetime(2024,12,23,17,00,0);
sampleTime = 10; % サンプリング間隔（秒）

% シナリオの作成
sc = satelliteScenario(startTime, stopTime, sampleTime);

% 地上局の設定
%lat = 35.65606806; % 緯度
%lon = 139.54404914; % 経度
%alt = 10; % 高度（メートル）
%gs = groundStation(sc, lat, lon, Altitude=alt);
lat = 35.69374;
lon = 139.6917;
alt = 10;
gs = groundStation(sc, lat, lon, Altitude=alt);


semiMajorAxis = [8000000;8010000;8020000;8030000;8040000;8050000;7000000;7100000;7200000;7300000;7400000;7500000]; % 軌道長半径 (m)
eccentricity = [0.01; 0.01; 0.01; 0.01;0.01;0.01;0.01; 0.01; 0.01; 0.01;0.01;0.01];              % 離心率
inclination = [60;60;60;60;60;60;95;95;95;95;95;95];                       % 傾斜角 (度)
rightAscensionOfAscendingNode = [30;35;40;45;50;55;50;55;60;65;70;75];    % 昇交点赤経 (度)
argumentOfPeriapsis = [0; 0;0;0;0;0;0;0;0;0;0;0];               % 近地点引数 (度)
trueAnomaly = [0; 0;0;0;0;0;0;0;0;0;0;0];                      % 真近点離角 (度)

% 複数の衛星を追加
sat = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
    rightAscensionOfAscendingNode, argumentOfPeriapsis, trueAnomaly);

% アクセス計算（衛星と地上局間の可視性を計算）
ac = access(sat, gs);
intvls = accessIntervals(ac);

% シナリオの再生
play(sc);
