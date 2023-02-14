function shrinkedMat = blockavg(matrix,numEl)
%% averages n elements in a vector with a blockfilter, outputs a shorter vector

if numEl==1 % do nothing if averaging over just 1 element
    shrinkedMat=matrix;
    return
end

blockSize = [numEl, 1];
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:));
shrinkedMat = blockproc(matrix, blockSize, meanFilterFunction);


% s = size(matrix);
% matrix=[matrix;nan(mod(-s(1),numEl),s(2))]; % fills up with NaN
% out = squeeze(nanmean(reshape(matrix,numEl,[],s(2))));

end