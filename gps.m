startTime = datetime(2020,5,1,11,36,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);
sat = satellite(sc,"gpsAlmanac.txt");

p = states(sat);
gs = groundStation(sc,35.6895,139.6917,Altitude=50);
ac = access(sat,gs);
intvls1 = accessIntervals(ac);

semiMajorAxis = 6786230;
eccentricity = 0.01;
inclination = 52;
rightAscensionOfAscendingNode = 95;
argumentOfPeriapsis = 93;
trueAnomaly = 0;
sat2 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
ac2 = access(sat2,gs);
intvls = accessIntervals(ac);
sat2.MarkerColor = [1, 0, 0];
play(sc);