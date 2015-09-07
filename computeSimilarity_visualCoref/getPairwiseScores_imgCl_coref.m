function getPairwiseScores_imgCl_coref(cachedir, outfname, inpfname, pairs) %, cutoffThresh, fsize, sbin, domode)

try    
    
disp(['getPairwiseScores_imgCl_coref(''' cachedir ''',''' inpfname ''')']);

conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
fsize = conf.threshs.fsize_fastImgClfr;
sbin = conf.threshs.sbin_fastImgClfr;
domode =  conf.threshs.featExtMode_imgClfr;

biasval = 1;
fsize = [fsize fsize];

disp('  computing adjacency matrix');
mymatlabpoolopen;

% get list of valid ngrams for this object
disp('load data');    
[~, phrasenames] = system(['cat ' inpfname ' | gawk ''{NF--};1'' | gawk ''{NF--};1'' ']);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];
for f=1:numel(phrasenames), phrasenames{f} = strrep(phrasenames{f}, ' ', '_'); end

numcls = numel(phrasenames);
if numcls == 0, disp('some error possibly with csscanf'); keyboard; end

disp('compute all positive features');
try
    load([cachedir '/posData_alltest.mat'], 'posData', 'phrasenames');
catch
    %tic;
    % for loop takes about 1 sec per class
    disp(numcls); 

    posData = cell(numcls, 1);
    for f=1:numcls  % didnt parfor this as getHOGFeatures is parfor'd
        myprintf(f,10);
        ids = mydir([cachedir '/images/' phrasenames{f} '/*.jpg'], 1);
        tmpld = load([cachedir '/results/' phrasenames{f} '_result.mat'], 'keepinds', 'dupfnd', 'testInds');
        keepinds = tmpld.keepinds; dupfnd = tmpld.dupfnd; testInds = tmpld.testInds;
        ids = ids(logical(keepinds));
        ids = ids(~logical(dupfnd));

        try
            ids_test = ids(testInds);
        catch
            disp('see error in getting inds'); keyboard; % see commented code below if that helps                
        end

        pos=[];
        for i=1:length(ids_test)
            pos(i).im = ids_test{i};
            pos(i).flip = 0;
        end                        
        feats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, domode);
        posData{f} = cat(2, feats{:})';
    end
    myprintfn;
    %posData(cellfun('isempty', posData)) = [];
    % save only for fast classifier, too heavy for slow classifier
    if domode == 1, save([cachedir '/posData_alltest.mat'], 'posData', 'phrasenames', '-v7.3'); end
end
tmp = load([cachedir '/negData_test.mat'], 'negData');
negData_test = tmp.negData;

%tic; %(366*366 takes about 6700 secs -- stats b4 doing parfor)
% for each pair, get rank and build matrix
disp(' compute scores');
maxmatval = 10^4;
numpairs = size(pairs,1);
edgeval1 = maxmatval*ones(numpairs, 1);
edgeval2 = maxmatval*ones(numpairs, 1);
edgeval = maxmatval*ones(numpairs, 2);
parfor c=1:numpairs          % for each pair
    myprintf(c, 10);
    tmp1 = load([cachedir '/results/' pairs{c,1} '_result.mat'], 'model');
    model1 = tmp1.model;
    tmp2 = load([cachedir '/results/' pairs{c,2} '_result.mat'], 'model');        
    model2 = tmp2.model;

    % edge i->j
    indx = find(strcmp(phrasenames, pairs{c,1}));
    if ~isempty(model2) & ~isempty(posData{indx})
        score_test = [posData{indx}  * model2.W - model2.rho; negData_test  * model2.W - model2.rho];
        testGt = [ones(size(posData{indx},1),1); -1*ones(size(negData_test,1),1)];
        [~, sind] = sort(score_test, 'descend');
        posId = testGt(sind);
        thisinds = find(posId == 1);
        if numel(thisinds)>1, edgeval1(c) = median(thisinds)/(numel(thisinds)/2); end % get edge weight
    end
    
    % edge i<-j
    indx = find(strcmp(phrasenames, pairs{c,2}));
    if ~isempty(model1) & ~isempty(posData{indx})        
        score_test = [posData{indx}  * model1.W - model1.rho; negData_test  * model1.W - model1.rho];
        testGt = [ones(size(posData{indx},1),1); -1*ones(size(negData_test,1),1)];
        [~, sind] = sort(score_test, 'descend');
        posId = testGt(sind);
        thisinds = find(posId == 1);
        if numel(thisinds)>1, edgeval2(c) = median(thisinds)/(numel(thisinds)/2); end % get edge weight
    end
end
myprintfn;  
edgeval(:,1) = edgeval1;
edgeval(:,2) = edgeval2;
save(outfname, 'edgeval', 'pairs');
%toc;

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
