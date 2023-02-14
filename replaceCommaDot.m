%% Replaces , (comma) with . (dot) and   (tab) with  ;  (semicolon) in Decimals in the CSV file
[File,Path] = uigetfile('*.csv','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);
DataString = fileread(full_Path);
DataString = strrep(DataString, ',', '.');
DataString = strrep(DataString, 'tab', ';');
FID = fopen(full_Path, 'w');
fwrite(FID, DataString, 'char');
fclose(FID);