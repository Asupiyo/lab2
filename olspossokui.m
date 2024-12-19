clear all
load("heusu.mat");
svxyzmat = [];
svid = [];
mpmat = mpgen(50,3600,1,54321);
[x,y,z]= geodetic2ecef(wgs84Ellipsoid,35.65606806,139.54404914,10);%ECEFに変換(llh2xyz)
usrxyz(1:3) = [x,y,z];
enuerr = [];

loadgps
i=0;
randn('state',9083247);
bar1 = waitbar(0,'Calculating Position...   ');
for t = 8120:1:8148,
    i=i+1;
    [svxyzmat,svid] = gensv(usrxyz,t,2);  % Note the mask angle is set to 2 degrees
    randomIndex = randi([1,length(svid)],1,2);
    svxyzmat = svxyzmat(randomIndex,:);
    svid = svid(:,randomIndex);
    svxyzmat = [svxyzmat;(measureCollect{2}([1,3,5],t))';(measureCollect{3}([1,3,5],t))';(measureCollect{4}([1,3,5],t))';(measureCollect{5}([1,3,5],t))';(measureCollect{6}([1,3,5],t))'];
    svid = [svid,41,42,43,44,45];
    [prvec,adrvec] = genrng(1,usrxyz,svxyzmat,svid,t,[1 1 0 1 1],[],mpmat);
    estusr = olspos(prvec,svxyzmat);
    enuerr(i,:) = ( xyz2enu(estusr(1:3),usrxyz) )';
    terr(i) = estusr(4);  % true clk bias is zero
    waitbar(i/180)
 end
close(bar1)

plot(enuerr(:,1),enuerr(:,2),'*')
axis('equal')
axis('square')
axis([-10 10 -10 10])
grid
title('GPS Positioning Error  -  Static User  -  Half-Hour Scenario')
ylabel('north error (m)')
xlabel('east error (m)')
text(-2,7.5,'Noise, multipath and')
text(-2,6.5,'atmospheric delays simulated')
