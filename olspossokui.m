clear all
load("satellite12.mat");
%sndemo5見直す
svxyzmat = [];
svid = [];
mpmat = mpgen(100,3600,1,54321);
usrxyz = llh2xyz([35.65606806*pi/180,139.54404914*pi/180,10]);%ECEFに変換(llh2xyz)
enuerr = [];
countsat = [];
seesat = {};
count = 0;

loadgps
i=1;
randn('state',9083247);
bar1 = waitbar(0,'Calculating Position...   ');
for t = 1:1:180,
    [svxyzmat,svid] = gensv(usrxyz,t*10,30);  % Note the mask angle is set to 2 degrees
    for j=1:12
      if measureCollect{j}([1,t]) ~= 0
        svenu = xyz2enu(measureCollect{j}([1,3,5],t)',usrxyz);
      el = (180/pi)*atan2(svenu(3),norm(svenu(1:2)));
      if el >= 30
        svxyzmat = [svxyzmat;(measureCollect{j}([1,3,5],t))'];
        svid = [svid,40+j];
      end
      end
    end%衛星数が3台の時のエラー対策
    if length(svid) >= 4
        [prvec,adrvec] = genrng(1,usrxyz,svxyzmat,svid,t*10,[1 1 0 1 1],[],mpmat);
        estusr = olspos(prvec,svxyzmat);
        countsat(i,1) = length(svid);
        seesat{i,1} = svid;
        enuerr(i,:) = ( xyz2enu(estusr(1:3),usrxyz) )';
        terr(i) = estusr(4);  % true clk bias is zero
        waitbar(i/180)
        if enuerr(i,1) >= 1000 || enuerr(i,2) >= 1000 || isnan(enuerr(i,1))
            count = count + 1;
        end
        i=i+1;
    end
end
error1000 = count / i *100;
close(bar1)

plot(enuerr(:,1),enuerr(:,2),'*')
axis('equal')
axis('square')
axis([-100 100 -100 100])
grid
title('GPS Positioning Error  -  Static User  -  Half-Hour Scenario')
ylabel('north error (m)')
xlabel('east error (m)')
text(-2,7.5,'Noise, multipath and')
text(-2,6.5,'atmospheric delays simulated')
