function shrinkedMat = blockavg(matrix,numEl)
%% averages n elements in a vector with a blockfilter, outputs a shorter vector

if numEl==1 % do nothing if averaging over just 1 element
    shrinkedMat=matrix;
    return
end

blockSize = [numEl, 1];
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:));
shrinkedMat = blockproc(matrix, blockSize, meanFilterFunction);

end