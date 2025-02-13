function [satellitePosData, satelliteVelData,svmat,accessData,prnoisarr,troperrarr,mperrprarr,ionoerrarr] = calculateSatellites(startTime, stopTime, sampleTime, gsList, sat) 
prnoisarr = [];
troperrarr = [];
mperrprarr = [];
ionoerrarr = [];

svxyzmat = zeros(length(gsList), 3);

for gsIdx = 1:length(gsList)
      gspos = [gsList(gsIdx).Latitude, ...
               gsList(gsIdx).Longitude, ...
               gsList(gsIdx).Altitude];
               usrxyz= llh2xyz([gspos(1)*pi/180,gspos(2)*pi/180,gspos(3)]);%ECEFに変換(llh2xyz)
               svxyzmat(gsIdx, 1:3) = usrxyz; 
end

% 衛星の追加とアクセス計算
satList = [];
accessData = cell(length(sat), 1);  % 衛星ごとのアクセスデータを保存するためのセル配列
for i = 1:length(sat)
    satList = [satList; sat];

    timeSteps = startTime:seconds(sampleTime):stopTime;  
    for t = 1:length(timeSteps)
        currentTime = timeSteps(t);
        [pos, vel] = states(sat(i), currentTime,"CoordinateFrame","ecef"); % 衛星の位置と速度
        svmat(i, :, t) = pos; % svmatに位置を格納
        svvmat(i,:,t) = vel;
    end

    % 各衛星のアクセス間隔を計算して保存
    for j = 1:length(gsList)
        ac = access(sat, gsList(j));
        intvls = accessIntervals(ac);  % アクセス間隔を取得
        accessData{i}{j} = struct('Satellite', i, 'GroundStation', j, 'Intervals', intvls);
    end
end

satellitePosData = cell(length(satList), 1);
satelliteVelData = cell(length(satList), 1);
estimatedPositions = cell(length(satList), 1);


for satIdx = 1:length(satList)
prvecs = zeros(length(gsList), length(timeSteps));
vrvec = zeros(length(gsList), length(timeSteps));
vrvecs = cell(size(vrvec));
    for gsIdx = 1:length(gsList)  % 各地上局に対して
        gsPos = svxyzmat(gsIdx,:);
        starttime = datetime(startTime, 'TimeZone', 'UTC');  % UTCに設定
        
        % 衛星ごとのアクセス間隔を取得
        intvls = accessData{satIdx}{gsIdx}.Intervals;
        
        for i = 1:size(intvls, 1)
            startT = intvls{i, 'StartTime'};
            endT = intvls{i, 'EndTime'};
            currentT = startT;
            while currentT <= endT
                elapsedTime = seconds(currentT - starttime) / sampleTime;
                if elapsedTime ~= 0
                svenu = xyz2enu(svmat(satIdx,:,elapsedTime)',gsPos);
                el = (180/pi)*atan2(svenu(3),norm(svenu(1:2)));
                if el >= 5
                svmat_t = squeeze(svmat(satIdx, :, elapsedTime)); % 衛星の位置 [1 x 3]
                vrvec = squeeze(svvmat(satIdx, :, elapsedTime));
                mpmat = mpgen(100,3600,1,randi([1, 100000]));
                [prvec, ~ ,prnois,troperr,mperrpr,ionoerr] = genrng(1, gsPos, svmat_t, satIdx, t * elapsedTime, [1,0.2,0,0.5,0.2],[],mpmat);
                prvecs(gsIdx, elapsedTime) = prvec;
                vrvecs(gsIdx, elapsedTime) = {vrvec};
                prnoisarr = [prnoisarr;prnois];
                troperrarr = [troperrarr;troperr];
                mperrprarr = [mperrprarr;mperrpr];
                ionoerrarr = [ionoerrarr;ionoerr];
                end
                end
                %fprintf('受信機%dの衛星%dに対する%sでの疑似距離は、%s\n', gsIdx, satIdx, currentT, prvec);
                currentT = currentT + seconds(sampleTime);

            end
        end
    end
satellitePosData{satIdx,1} = prvecs;
satelliteVelData{satIdx,1} = vrvecs;%観測期間中だけの速度を入れたい(できた)&そもそも受信機が速度を図ることはできる？
end