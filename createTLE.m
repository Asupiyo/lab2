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
launchNumber =  num2str(round((RocketLaunches2022 * currentEpoch) / 360), '%03.f');

% Line 1:
lineData = ['1 ' ID 'S ' yearDigits launchNumber 'A   ' yearDigits epoch ' +.00000000 +00000-0 +00000-0 0  000'];
firstLine = [lineData checksum(lineData)];

%% Line 2:

% Orbital data:
i = num2str(satellite.orbitalElements.Inclination, '%08.04f');
OM = num2str(satellite.orbitalElements.RightAscensionOfAscendingNode, '%08.04f');
e = num2str(satellite.orbitalElements.Eccentricity * 1e7, '%07.f');
om = num2str(satellite.orbitalElements.ArgumentOfPeriapsis, '%08.04f');
th = num2str(satellite.orbitalElements.TrueAnomaly, '%08.04f');
n = num2str(86400 / satellite.orbitalElements.Period, '%011.08f');

% Line 2:
lineData = ['2 ' ID ' ' i ' ' OM ' ' e ' ' om ' ' th ' ' n '00000'];
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