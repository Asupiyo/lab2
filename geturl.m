url = 'https://celestrak.org/NORAD/elements/gp.php?GROUP=gps-ops&FORMAT=tle'; 
tleData = webread(url);

lines = strsplit(tleData, '\n');
numSats = floor(length(lines) / 3); 

%{
for i=1:numSats
    line1 = lines{(i-1)*3 + 2}; % TLEの1行目
    line2 = lines{(i-1)*3 + 3}; % TLEの2行目

    fileID = fopen('tle.txt', 'a');
    
    fprintf(fileID, '%s\n%s\n', line1, line2);
    
    fclose(fileID);
   end
%}

line1 = lines{2};
line2 = lines{3};

    fileID = fopen('tle.txt', 'w');
    
    fprintf(fileID, '%s\n%s\n', line1, line2);
    
    fclose(fileID);