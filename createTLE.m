% Constellation from openExample('aero/ModelGalileoConstellAsWalkerDeltaConstellExample'):
sc = satelliteScenario;
sat = walkerDelta(sc, 10000.8e3, 56, 24, 3, 1, ArgumentOfLatitude=15, Name="LEO");

% Initialise:
N = length(sat);
TLE = cell(N,1);

% Loop over satellites to extract TLEs:
for j = 1 : N
    TLE{j} = getTLE(sc.Satellites(j));
    % Display TLE in the console
    disp(TLE{j}{1})
    disp(TLE{j}{2})
end
satelliteScenarioViewer(sc, ShowDetails=false);

% Generate TLE from satellite:
function TLE = getTLE(satellite)

    %% Line 1:
    % ID:
    ID = num2str(satellite.ID, '%05.f');

    % Time:
    now = datetime;
    currentYear = year(now);
    yearStart = [num2str(currentYear) '-01-01'];
    yearDigits = yearStart(3:4);
    currentEpoch = convertTo(now, 'epochtime', 'Epoch', yearStart) / 86400;
    epoch = num2str(currentEpoch, '%012.08f');

    % Rocket launch:
    RocketLaunches2022 = 180;
    launchNumber = num2str(round((RocketLaunches2022 * currentEpoch) / 360), '%03.f');

    % Line 1:
    lineData = ['1 ' ID 'S ' yearDigits launchNumber 'A   ' yearDigits epoch ' +.00000000 +00000-0 +00000-0 0  000'];
    firstLine = [lineData checksum(lineData)];

    %% Line 2:
    % Orbital data
    i = satellite.orbitalElements.Inclination + randn() * 0.01; % Inclination error
    OM = satellite.orbitalElements.RightAscensionOfAscendingNode + randn() * 0.01; % RAAN error
    e = satellite.orbitalElements.Eccentricity + randn() * 1e-7; % Eccentricity error
    om = satellite.orbitalElements.ArgumentOfPeriapsis + randn() * 0.01; % Argument of periapsis error
    th = satellite.orbitalElements.TrueAnomaly + randn() * 0.01; % True anomaly error
    n = 86400 / satellite.orbitalElements.Period; % 平均運動の計算

    % 平均運動の1次微分値を計算
    % ここでは、平均運動に基づいて簡単なモデルを使用
    J2 = 1.08263e-3; % J2摂動係数
    R_earth = 6371; % 地球の半径 (km)
    altitude_km = satellite.orbitalElements.SemiMajorAxis - R_earth;
    
    % 簡単な摂動モデルに基づいて1次微分値を計算
    n_dot = -1.5 * J2 * (R_earth^2) * (n^2) * cosd(i) / (altitude_km^2);

    % Ensure values are within valid ranges
    e = max(0, min(e, 1)); % Eccentricity must be between 0 and 1
    i = max(0, min(i, 180)); % Inclination must be between 0 and 180

    % Line 2:
    lineData = ['2 ' ID ' ' num2str(i, '%08.04f') ' ' num2str(OM, '%08.04f') ' ' num2str(e * 1e7, '%07.f') ...
                 ' ' num2str(om, '%08.04f') ' ' num2str(th, '%08.04f') ' ' num2str(n, '%011.08f') num2str(n_dot, '%09.06f')];
    secondLine = [lineData checksum(lineData)];

    TLE = {firstLine; secondLine};
end

% Compute checksum for last line digit:
function cs = checksum(line)
    digits = strrep(line, '-', '1');
    signs = {'+','A','S',' ','0','.'};
    for j = 1 : length(signs)
        digits = erase(digits, signs{j});
    end
    sum = 0;
    for j = 1 : length(digits)
        sum = sum + str2num(digits(j));
    end
    sum = num2str(sum);
    cs = sum(end);
end
