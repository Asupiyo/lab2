startTime = datetime(2024,11,18,14,38,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);
sat = satellite(sc,"gpsAlmanac.txt");

p = states(sat);
gs1 = groundStation(sc,35.6895,139.6917,Altitude=50);
gs2 = groundStation(sc,35.65775005,139.54355865);

semiMajorAxis = 7371000;%m
eccentricity = 0.01;%離心率
inclination = 52;%傾斜角
rightAscensionOfAscendingNode = 95;
argumentOfPeriapsis = 93;
trueAnomaly = 0;%真近角点(意外と大事)
sat2 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
trueAnomaly = 180;
sat3 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
ac21 = access(sat2,gs1);
ac22 = access(sat2,gs2);
ac31 = access(sat3,gs1);
ac32 = access(sat3,gs2);
intvls21 = accessIntervals(ac21);
intvls22 = accessIntervals(ac22);
intvls31 = accessIntervals(ac31);
intvls32 = accessIntervals(ac32);
sat2.MarkerColor = [1, 0, 0];
sat3.MarkerColor = [1,1,0];
inclination = 10;
rightAscensionOfAscendingNode = 10;
argumentOfPeriapsis = 20;
sat4 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);
ac41 = access(sat4,gs1);
ac42 = access(sat4,gs2);
intvls41 = accessIntervals(ac41);
intvls42 = accessIntervals(ac42);
sat4.MarkerColor = [1,0,1];
play(sc);
disp(intvls21);
disp(intvls31);
disp(intvls41);
disp(intvls21);
disp(intvls32);
disp(intvls42);
