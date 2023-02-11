%% makes File which contains multiple measurements into one continuous measurement
clear;
[File,Path] = uigetfile('*.csv','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);
rawData=readtable(full_Path,"Delimiter",";"); %readsData
rawData.deltaTInS=(0:0.1:(height(rawData)-1)/10)';
inName=File(1:end-4);
name=inName+ "_cont.csv";
name=Path + name;
writetable(rawData,name,'Delimiter',';');