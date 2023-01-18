function shrinkedMat = blockavg(matrix,numEl)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

blockSize = [numEl, 1];
meanFilterFunction = @(theBlockStructure) mean2(theBlockStructure.data(:));
shrinkedMat = blockproc(matrix, blockSize, meanFilterFunction);


% s = size(matrix);
% matrix=[matrix;nan(mod(-s(1),numEl),s(2))]; % fills up with NaN
% out = squeeze(nanmean(reshape(matrix,numEl,[],s(2))));

end