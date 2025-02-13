clear all
load("25doerr_changed.mat");
%sndemo5見直す
loadgps
N = [];
Seesat = [];
prnoisarrolspos = [];
troperrarrolspos = [];
mperrprarrolspos = [];
ionoerrarrolspos = [];
usrxyz = llh2xyz([35.65606806*pi/180,139.54404914*pi/180,10]);%ECEFに変換(llh2xyz)

i=1;
gyoukaku = 15;
randn('state',9083247);
bar1 = waitbar(0,'Calculating Position...   ');
for x = 1:1:10
    mpmat = mpgen(100,3600,1,54321+x);
    svxyzmat = [];
    svid = [];
    enuerr = [];
    countsat = [];
    seesat = {};
    count = 0;
    i = 1;
    no0 = 0;

for t = 1:1:180
    [svxyzmat,svid] = gensv(usrxyz,t*10,gyoukaku);  % Note the mask angle is set to 2 degrees
    for j=1:length(satpos)
      if measureCollect{j}(1,t) ~= 0
      svenu = xyz2enu(measureCollect{j}([1,2,3],t)',usrxyz);
      el = (180/pi)*atan2(svenu(3),norm(svenu(1:2)));
      if el >= gyoukaku
        svxyzmat = [svxyzmat;(measureCollect{j}([1,2,3],t))'];
        svid = [svid,40+j];
      end
      end
    end%衛星数が3台の時のエラー対策
    if length(svid) >= 4
        [prvec,adrvec,prnois,troperr,mperradr,ionoerr] = genrng(1,usrxyz,svxyzmat,svid,t*10,[1,0.2,0,1,0.2],[],mpmat);%mpmat統一させる
        initpos = mean(svxyzmat, 1);
        initpos = [initpos, 0]; % 時計誤差を0に設定
        [estusr] = olspos(prvec,svxyzmat,[llh2xyz([35.6895*pi/180,139.6917*pi/180,40]),0]);
        countsat(i,1) = length(svid);
        seesat{i,1} = svid;
        enuerr(i,:) = (xyz2enu(estusr(1:3),usrxyz))';
        terr(i) = estusr(4);  % true clk bias is zero
        waitbar(i/180)
        i=i+1;
        no0 = no0 + 1;
    else
        enuerr(i,:) = [0,0,0];
        countsat(i,1) = length(svid);
        seesat{i,1} = svid;
        i = i + 1;
    end
    sokuiritsu = no0 / i * 100;
    prnoisarrolspos = [prnoisarrolspos,prnois];
    troperrarrolspos = [troperrarrolspos,troperr];
    mperrprarrolspos = [mperrprarrolspos,mperradr];
    ionoerrarrolspos = [ionoerrarrolspos,ionoerr];
end
N = [N;enuerr];
Seesat = [Seesat;seesat];
end
close(bar1)

plot(N(:,1),N(:,2),'*')
axis('equal')
axis('square')
axis([-100 100 -100 100])
grid
title('GPS+LEO Positioning Error','FontSize', 14)
ylabel('north error (m)','FontSize', 14)
xlabel('east error (m)','FontSize', 14)

