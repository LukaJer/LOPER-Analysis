%%
clear;
minDur=60; % minimum Duration of measurement [s]

[File,Path] = uigetfile('*.csv','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);

%% format file: Replace , (comma) with . (dot) and   (tab) with  ;  (semicolon) in Decimals in the CSV file
DataString = fileread(full_Path);
DataString = strrep(DataString, ',', '.');
DataString = strrep(DataString, 'tab', ';');
FID = fopen(full_Path, 'w');
fwrite(FID, DataString, 'char');
fclose(FID);

%% import file and split into seperate Runs
rawData=readtable(full_Path,"Delimiter",";"); %readsData
NewStart=find(rawData.deltaTInS==0);
inName=File(1:end-4);
NewStart(end+1)=height(rawData)+1;
j=1;
for i=1:length(NewStart)-1
    if rawData.deltaTInS(NewStart(i+1)-1)>minDur
        if j<10
            name= inName + "_0" + j + ".csv";
        else
            name= inName + "_" + j + ".csv";
        end
        name=Path + name;
        writetable(rawData((NewStart(i):NewStart(i+1)-1),:),name,'Delimiter',';')
        j=j+1;
    end
end
msgbox(sprintf('Split into %i files',j-1));
%delete (Data);

