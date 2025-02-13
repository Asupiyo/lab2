clear all
%load("addmpmat.mat");
%sndemo5見直す

usrxyz = llh2xyz([35.65606806*pi/180,139.54404914*pi/180,10]);%ECEFに変換(llh2xyz)
Ngps = [];
SeesatGps = [];
loadgps

randn('state',9083247);
bar1 = waitbar(0,'Calculating Position...   ');
for x = 1:1:10
svxyzmat = [];
svid = [];
i = 1;
count = 0;
mpmat = mpgen(100,3600,1,54321);
enuerrgps = [];
countsat = [];
seesatgps = {};
no0 = 0;
for t = 1:1:180
    [svxyzmat,svid] = gensv(usrxyz,t*10,20);  % Note the mask angle is set to 2 degrees
    if length(svid) >= 4
        [prvec,adrvec] = genrng(1,usrxyz,svxyzmat,svid,t*10,[1,0.2,0,1,0.2],[],mpmat);%mpmat統一
        initpos = mean(svxyzmat, 1);
        initpos = [initpos, 0]; % 時計誤差を0に設定
        [estusr] = olspos(prvec,svxyzmat,[llh2xyz([35.6895*pi/180,139.6917*pi/180,40]),0]);
        countsat(i,1) = length(svid);
        seesatgps{i,1} = svid;
        enuerrgps(i,:) = (xyz2enu(estusr(1:3),usrxyz))';
        terr(i) = estusr(4);  % true clk bias is zero
        waitbar(i/180)
        i=i+1;
        no0 = no0 + 1;
    else
        enuerrgps(i,:) = [0,0,0];
        countsat(i,1) = length(svid);
        seesatgps{i,1} = svid;
        i = i + 1;
    end
    sokuiritsu = no0 /i  * 100;
end
Ngps = [Ngps;enuerrgps];
SeesatGps = [SeesatGps;seesatgps];
end
close(bar1)

plot(Ngps(:,1),Ngps(:,2),'*')
axis('equal')
axis('square')
axis([-100 100 -100 100])
grid
title('GPS Positioning Error','FontSize', 14)
ylabel('north error (m)','FontSize', 14)
xlabel('east error (m)','FontSize', 14)

