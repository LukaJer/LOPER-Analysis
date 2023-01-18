[File,Path] = uigetfile('*.csv','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);

if isequal(File,0)
    return;
end

rawData=readtable(full_Path); %readsData

%% Extracts KR temperature Data
temperature_wall=table2array(rawData(:,56:66));
%temperature_wall(:,2)=(temperature_wall(:,1)+temperature_wall(:,3))/2; %% interpolates Temperature as TC is broken
temperature_wall(:,2)=[];
temperature_wall=flip(temperature_wall,2); % flips so that table position matches TC position (1st column = bottom TC)




n = 10;
s = size(temperature_wall);
temperature_wall=[temperature_wall;nan(mod(-s(1),n),s(2))]; % fills up with NaN
out = squeeze(nanmean(reshape(temperature_wall,n,[],s(2))));

%clear File Path full_Path;% Define the block parameter.  Average in a 100 row by 1 column wide window.
blockSize = [10, 1];
% Block process the image to replace every element in the 
% 100 element wide block by the mean of the pixels in the block.
% First, define the averaging function for use by blockproc().
meanFilterFunction = @(theBlockStructure) mean2(theBlockStructure.data(:));
% Now do the actual averaging (block average down to smaller size array).
blockAveragedDownSignal = blockproc(temperature_wall, blockSize, meanFilterFunction);
% Let's check the output size.
[rows, columns] = size(blockAveragedDownSignal)