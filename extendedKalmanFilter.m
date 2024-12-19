startTime = datetime(2024,12,16,00,00,0);
stopTime = startTime + days(1);
sampleTime = 10;
timeSteps = startTime:seconds(sampleTime):stopTime;
dt = sampleTime;
sc = satelliteScenario(startTime, stopTime, sampleTime);
measureInitialState = [0;0;0;0;0;0];%x,dx,y,dy,z,dz
measureCollect = cell(length(satpos),1);
measureStates = zeros(6,length(timeSteps));
initialCovariance = diag([1e-1,1e-2,1e-1,1e-2,1e-1,1e-2]);
processNoise = diag([0;1e-2;0;1e-2;0;1e-2]);

measureNoise = diag([2e-6;2e-6;2e-6;2e-6;2e-6;2e-6]);
estimateStates = NaN(size(measureStates));
estimatesResults = cell(length(satpos), 1);


for satIdx = 1:length(satpos)
 %   prvec = satellitePosData{satIdx}; % [地上局数 x 時間ステップ数]
  %  vrvec = satelliteVelData{satIdx}; % [地上局数 x 時間ステップ数]

    % 各衛星の位置推定を格納するための空の配列を初期化
    satelliteEstimatedPositions = cell(1,length(timeSteps));  % 衛星ごとの位置推定結果を格納

    for j = 1:length(timeSteps)
        prvecAtStart = satpos{satIdx}(:,j);  % 衛星位置のデータ
        vrvecAtStart = satvel{satIdx}(:,j); % 速度データも使用する場合

        % 地上局の位置データを格納
        svxyzmat = zeros(length(gsList), 3); % [地上局数 x 3]
        validGsCount = 0;  % 衛星を観測できる地上局の数をカウント
        count = 0;
        % 地上局ごとに処理
        for gsIdx = 1:length(gsList)
            gsPos = [groundStations(gsIdx).Lat, ...
                     groundStations(gsIdx).Lon, ...
                     groundStations(gsIdx).Alt];
            [x,y,z] = geodetic2ecef(wgs84Ellipsoid,gsPos(1),gsPos(2),gsPos(3));%ECEFに変換(llh2xyz)
            svxyzmat(gsIdx, [1,2,3]) = [x,y,z];
            if prvecAtStart(gsIdx,1) ~= 0
                count =count + 1;
            end
        end

        if count >= 5%0が2個以上だと精度下がりそう?→rankの欠落が起こるから恐らく確定
            validIdx = all(prvecAtStart ~= 0,2);
            prvecValid = prvecAtStart(validIdx,:);
            svxyzmatValid = svxyzmat(validIdx,:);
            estusr = olspos(prvecValid,svxyzmatValid,measureStates([1,3,5],j-1));
        
            % 推定された位置を衛星ごとのリストに追加
            %satelliteEstimatedPositions{1,j} = estusr(1,1:3);  % 位置推定結果を追加
            if(abs(estusr(1))<= 10^10)
            measureStates(1,j) = estusr(1,1);
            measureStates(3,j) = estusr(1,2);
            measureStates(5,j) = estusr(1,3);
            measureStates(2,j) = meanResults{j}(1);
            measureStates(4,j) = meanResults{j}(2);
            measureStates(6,j) = meanResults{j}(3);
            end
        end
    end
measureCollect{satIdx} = measureStates;
end
%%ここから先がEKF
%filter = trackingEKF(State=measureStates(:,1),StateCovariance=initialCovariance,...
 %       StateTransitionFcn=@stateModel,ProcessNoise=processNoise,...
 %   MeasurementFcn=@measureModel,MeasurementNoise=measureNoise);

%for i=2:length(timeSteps)
 %   isPredicting = false;
  %  value=measureStates(:,i);
   % zerosum = sum(value == 0);
   % if zerosum <= 3
%        if ~isPredicting
 %           filter.State = value;
  %          isPredicting = true;
   %     end
    %    predict(filter,dt);
     %   estimateStates(:,i) = correct(filter,measureStates(:,i));
    %else
%        isPredicting = false;
%   end
%end
%estimatesResults{satIdx,1} = estimateStates;
%end

function stateNext = stateModel(state,dt)
    F = [1 dt 0 0 0 0;
        0 1 0 0 0 0;
        0 0 1 dt 0 0;
        0 0 0 1 0 0;
        0 0 0 0 1 dt;
        0 0 0 0 0 1];
    stateNext = F*state;
end

function z = measureModel(state)
    x = state(1);
    dx = state(2);
    y = state(3);
    dy = state(4);
    z = state(5);
    dz = state(6);
    z = [x;dx;y;dy;z;dz];
end