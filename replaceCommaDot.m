%% Replaces , (comma) with . (dot) in Decimals in the CSV file
Data = uigetfile('*.csv','Select the measurement data');%open file browser
DataString = fileread(Data);
DataString = strrep(DataString, ',', '.');
DataString = strrep(DataString, 'tab', ';');
FID = fopen(Data, 'w');
fwrite(FID, DataString, 'char');
fclose(FID);