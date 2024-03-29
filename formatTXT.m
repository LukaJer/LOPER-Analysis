%% Converts multi run TXT file into single run CSV files and replaces , (comma) with . (dot) 
clear;
minDur=60; % minimum Duration of measurement [s]

[File,Path] = uigetfile('*.txt','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);

varNames={'deltaTInS','DurchflussInL_min','EintrittsenthalpieInKJ_kg','LeistungDerVorheizungInW',...
    'VerdampferleistungSollInW','GesamtspannungInV','GesamtstromInA','TemperaturImBeh_lterIn_C',...
    'DruckVorVerdampferrohrInBar','TemperaturVorVerdampferrohrIn_C','Rohrwandtemperatur1In_C',...
    'Rohrwandtemperatur2In_C','Rohrwandtemperatur3In_C','Rohrwandtemperaturr4In_C','Rohrwandtemperatur5In_C',...
    'Rohrwandtemperatur6In_C','Rohrwandtemperatur7In_C','Rohrwandtemperatur8In_C','Rohrwandtemperatur9In_C',...
    'Rohrwandtemperatur10In_C','SpannungsabfallUeberT1UndT2InV','SpannungsabfallUeberT3undT4InV',...
    'SpannungsabfallUeberT5InV','SpannungsabfallUeberT6InV','SpannungsabfallUeberT7InV','SpannungsabfallUeberT8InV',...
    'SpannungsabfallUeberT9InV','SpannungsabfallUeberT10InV','FluidtemperaturNachSchauglasIn_C',...
    'FluidtemperaturNachSchauglas2In_C','DruckNachVerdampferrohrInBar','TemperaturNachKondensatorIn_C',...
    'Rohrinnentemperatur1In_C','Rohrinnentemperatur2In_C','Rohrinnentemperatur3In_C','Rohrinnentemperaturr4In_C',...
    'Rohrinnentemperatur5In_C','Rohrinnentemperatur6In_C','Rohrinnentemperatur7In_C','Rohrinnentemperatur8In_C',...
    'Rohrinnentemperatur9In_C','Rohrinnentemperatur10In_C','Waermestromdichte1InW_m_K','Waermestromdichte2InW_m_K',...
    'Waermestromdichte3InW_m_K','Waermestromdichte4InW_m_K','Waermestromdichte5InW_m_K','Waermestromdichte6InW_m_K',...
    'Waermestromdichte7InW_m_K','Waermestromdichte8InW_m_K','Waermestromdichte9InW_m_K','Waermestromdichte10InW_m_K',...
    'SpannungsabfallKRInV','DruckVorKRInBar','TemperaturKreisringeintrittIn_C','RohrinnentemperaturKR0In_C',...
    'RohrinnentemperaturKR1In_C','RohrinnentemperaturKR2In_C','RohrinnentemperaturKR3In_C','RohrinnentemperaturKR4In_C',...
    'RohrinnentemperaturKR5In_C','RohrinnentemperaturKR6In_C','RohrinnentemperaturKR7In_C','RohrinnentemperaturKR8In_C',...
    'RohrinnentemperaturKR9In_C','RohrinnentemperaturKR10In_C','TemperaturKreisringaustrittIn_C','DruckNachKRInBar','UmgebungstemperaturKRIn_C'};
rawData=readtable(full_Path,'Delimiter','tab','DecimalSeparator',',');
rawData.Properties.VariableNames=varNames;
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

