startTime = find(str2double(cell2mat(splitTime))==rawData.deltaTInS);
j=0;
full_Path_split=full_Path;
while exist(full_Path_split,'file')
    j=j+1;
    if j<10
        name_split=File(1:end-4)+"_0"+j+".csv";
    else
        name_split=File(1:end-4)+"_"+j+".csv";
    end

    full_Path_split=Path+name_split;
end

rawData_split=rawData(startTime:end,:);
time=0:height(rawData_split)-1;
rawData_split.deltaTInS=time'/10;
writetable(rawData_split,full_Path_split,'Delimiter',';')
msgbox(sprintf('Createn new file: %s',name_split));