% シナリオを作成
sc = satelliteScenario;

% 地上局を追加
lat = 35.6895; % 緯度（例: 東京）
lon = 139.6917; % 経度
alt = 0; % 高度（海抜）

gs = groundStation(sc, lat, lon);

% 衛星を追加
%sat = satellite(sc, 42164e3, 0, 0, 0, 0, 0, Name="Test Satellite");

% 可視性の解析
%access = access(sat, gs);

% シミュレーションの実行
play(sc);

% 可視性のプロット
%plot(access, "Access Count");