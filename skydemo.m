%  sndemo02.m         Short example of satellite motion through sky
%    
[x,y,z]= geodetic2ecef(wgs84Ellipsoid,35.65606806,139.54404914,10);%ECEFに変換(llh2xyz)
usrxyz(1:3) = [x,y,z];
loadgps

for t = 1:1:180,
  [svxyzmat,svid] = gensv(usrxyz,t*10,30);
  for j=1:12
      svenu = xyz2enu(measureCollect{j}([1,3,5],t)',usrxyz);
      el = (180/pi)*atan2(svenu(3),norm(svenu(1:2)));
      if el >= 30
        svxyzmat = [svxyzmat;(measureCollect{j}([1,3,5],t))'];
        svid = [svid,40+j];
      end
  end
  pause(0.1)
  skyplot(svxyzmat,svid,usrxyz,0,0)
  hold on
end

text(0.6,0.9,'Satellite motion depicted')
text(0.6,0.8,'over 1 hour')
text(-1.5,-0.9,'User at Lat 35 deg, Lon 139 deg')