function masterScript_phrases_v2_5jul13(DO_MODE, DO_AWS)

basedir = '/projects/grail/santosh/objectNgrams/';
OVERWRITE = 1;

if nargin < 2, DO_AWS = 0; end

resultsdir = fullfile(basedir, 'results');
resultsdir_nfs = fullfile(basedir, 'results');

myClasses = VOCoptsClasses; 
vocyear = '2007'; 
phrasevocyear = '9990';         % I call it so
modelblahnote = 'blah';
testdatatype = 'test';
traindatatype = 'train'; 
valdatatype1 = 'val1'; %(see README_val.txt for abbrievations)
valdatatype2 = 'val2';
wwwturkdir = [resultsdir_nfs '/turkAnnotations_www/']; %mymkdir(wwwdispdir);
turkdir = [resultsdir_nfs '/turkAnnotations/'];
numcomp = 6;  
codedir = ['kmeans_' num2str(numcomp)];
ngramtype = 0;
tmpdirname_cleanNgramData = '/scratch/';      % tmp dirname on local machine (not /tmp but /data on some grail machines OR /scratch on old+new grai machines)
minNgramFreqInBooks = 200;  % changed to 200 from 100 on 17Mar13 (based on analysis; see notes)
precCutOffThresh_fastImgClfrAcc = 10.0;
fsize_fastImgClfr = 10; sbin_fastImgClfr = 8;
Cval_fastImgClfr = 0.088388;    % magic parameters (set after checking a few classes)
maxImgSize = 500;
pcntTrngImgsPerNgram = 50/100;
pcntValImgsPerNgram = 25/100;
pcntTstImgsPerNgram = 25/100;
fsize_dupDtn = 20; sbin_dupDtn = 4;
wsup_fg_olap = 0.25;
borderoffset = 0.07;            % if its a 100pixel image, ignore a 8-pixel margin (7/100*500)
jointCacheLimit = 2*(3*2^30);   % set this variable corectly/calclate; be careful while modifying params (rembr ur old exp where u modified memory and had to modify #iterations)
minAP_compThresh_full = 15;  % 8Apr13: played around a bit (10 or 15 or 20); 10 keeps some crap, 20 kind of looses good stuff, so 15 is best
minAP_compThresh = 20;       % changed to 20 (from 10) on 5/12/13 after seeing top 75 good ones; before 10 was selected by looking at pr curves
minNumValInst_comp = 4;      % looked at pr curves and then arrived at this
minNumTrngInst_comp = 8; %4; % changed to 8 on 5/12 after seeing top 75 good ones, 6 on 5/5/13 after analyzing remaining 200 componets (just before adding parts)
rankThresh_simComp = 25;
rankThresh_disimComp1 = 100; ovThresh_disimCmp1 = 0.25;     % weak score, better be good overlap (random stuff?)
rankThresh_disimComp2 = 50; ovThresh_disimComp2 = 0.05;     % strong score, ok to have low overlap (e.g., head on body)

        
if DO_MODE == 1.1               %download ngram data
    disp('dowloadin data');    
    disp(['doing ngramtype ' num2str(ngramtype)]);        
    rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '/'];  mymkdir(rawngramdir);    
    downloadNgramData_2012(ngramtype, rawngramdir);        
    %multimachine_warp_depfun(['downloadNgramData_2012(' num2str(ngramtype) ',''' rawngramdir ''')' ], ngramGoogFileInfo(ngramtype), rawngramdir, ngramGoogFileInfo(ngramtype), [], 'all.q', 16, 0, OVERWRITE);
    %downloadNgramData(ngramtype, rawngramdir);                 % 2009 version
    %{
elseif DO_MODE == 1.20     %compress/clean ngram data
    disp('this is slow as invovles moving data over network, fix it before using it for large datasets'); keyboard;
    
    disp('split data');
    compileCode_v2_depfun('splitNgramData_2012',0);
    ngramtype = 0;
    disp(['doing ngramtype ' num2str(ngramtype)]);
    rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '/'];
    rawngramdir_split = [resultsdir '/ngram_data/' num2str(ngramtype) '_split/'];  mymkdir(rawngramdir_split);    
    %splitNgramData_2012(ngramtype, rawngramdir, rawngramdir_split); 
    multimachine_grail_compiled(['splitNgramData_2012 ' num2str(ngramtype) ' ' rawngramdir ' ' rawngramdir_split], 1, rawngramdir, 3, [], 8, 0, 1); 
    
    disp('zip data');   
    compileCode_v2_depfun('renameNzip_NgramData_2012',0);
    ngramtype = 0;
    rawngramdir_split = [resultsdir '/ngram_data/' num2str(ngramtype) '_split/'];
    %multimachine_grail_compiled(['renameNzip_NgramData_2012 ' num2str(ngramtype) ' ' rawngramdir_split], 1, rawngramdir_split, 5, [], 8, 0, 1); 
    renameNzip_NgramData_2012(ngramtype, rawngramdir_split);    
elseif DO_MODE == 1.21      % compress/clean ngram data (old)
    disp('cleanin data');    
    ngramtype = 0;
    compileCode_v2_depfun('cleanNgramData_2012_old',0);
    rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '/'];
    %rawngramdir_split = [resultsdir '/ngram_data/' num2str(ngramtype) '_split/'];
    cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '_clean2/']; mymkdir(cleangramdir);
    cleanNgramData_2012_old(ngramtype, rawngramdir, cleangramdir);
    %multimachine_grail_compiled(['cleanNgramData_2012_old ' num2str(ngramtype) ' ' rawngramdir ' ' cleangramdir], 1, cleangramdir,2, [], 8, 0, 0);
    %}
elseif DO_MODE == 1.22          % compress/clean ngram data (updated)
    disp('cleanin data');    
    compileCode_v2_depfun('cleanNgramData_2012',0);
    rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '/'];    
    cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '_clean3/']; mymkdir(cleangramdir);    
    cleanNgramData_2012(ngramtype, rawngramdir, cleangramdir, tmpdirname_cleanNgramData);        
    %multimachine_grail_compiled(['cleanNgramData_2012 ' num2str(ngramtype) ' ' rawngramdir ' ' cleangramdir ' ' tmpdirname_cleanNgramData], ngramGoogFileInfo(ngramtype), rawngramdir, ngramGoogFileInfo(ngramtype), [], 'all.q', 16, 0, OVERWRITE);
    %cleanNgramData(ngramtype, rawngramdir, cleangramdir);      % 2009 version
    
elseif DO_MODE == 1.3           % copy voc images (useful for negatives, need not do for every object)    
    copyVOC2007dataToNgramData([basedir '/../']);
end

%{
if DO_AWS
%dsk
keyfile = '/projects/grail/santosh/aws/sshkeyec2.pem';
ackey='AKIAJEHOYKS6WQ4HDJFQ';
seckey='Hiuj9A8DT+Tqp7dNuvUAO750NJHTys/WHd+FNp27';
%{
%select
keyfile = '/projects/grail/santosh/aws/graphlabkey4.pem';
ackey='AKIAJXT7NQ2DSMWFKILA';
seckey='+BT3mGhabNtAu+M0TISG/Z3JOKs6OHAVVnjbgVOk';
%}
[initcommandstr, exitcommandstr] = getcommandstr2();
globalinfo.keyfile = keyfile;
globalinfo.masternode =  getMasterNodeInfo_aws(ackey, seckey);
end

if 0    % AWS stuff
%run this from my linux machine
%decideSpotBiddingPrize;
startAWScluster(125, 0.26);
masternode=getMasterNodeInfo_aws(ackey,seckey);
disp('login to monitor cluster and run the following two commands as root');
disp('qconf -mattr queue load_thresholds np_load_avg=300 all.q ; qconf -mp orte $fill_up'); 
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no root@%s '], keyfile, masternode);
disp(sshcmd);
% create outputs dir
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no ubuntu@%s ''%s'''], keyfile, masternode, 'mkdir ~/outputs/');
disp(sshcmd);
% create projects dir
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no ubuntu@%s ''%s'''], keyfile, masternode, 'mkdir /projects/grail/santosh2/');
disp(sshcmd);
summaryFileName = '/projects/grail/santosh/objectNgrams/code/utilScripts/distributedProc/aws_hpc/summary.sh';
scpcmd = sprintf(['scp -i %s -oStrictHostKeyChecking=no %s ubuntu@%s:~/outputs/'], keyfile, summaryFileName, masternode);
disp(scpcmd);
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no ubuntu@%s '], keyfile, masternode);
disp(sshcmd);
% hope the data is fresh & tarred
disp(['cd /projects/grail/santosh/Datasets/Pascal_VOC/VOC2007/ ; tar -cvzhf /projects/www/projects/visual_ngrams/JPEGImages.tgz JPEGImages/']);
% wget data to masternode and untar
disp(['wget http://grail.cs.washington.edu/projects/visual_ngrams/JPEGImages.tgz; tar -xvzf JPEGImages.tgz ; \rm JPEGImages.tgz ; ']);
%getcommandstr2
%stopAWScluster
%restartAWScluster
end
%}

for i = 13 %[1 4 13 14 19] %1:20  
    objname = myClasses{i}; 
    disp(['Doing base object category ' objname]);
    
    rawgoogimgdir = [resultsdir_nfs '/googImg_data/']; mymkdir(rawgoogimgdir);
    objngramdir = [resultsdir_nfs '/object_ngram_data/' objname '/']; mymkdir(objngramdir);
    imgannodir = [resultsdir_nfs '/VOC9990/']; mymkdir(imgannodir);
    jpgimagedir = [resultsdir_nfs '/VOC9990/JPEGImages/']; mymkdir(jpgimagedir);
    imgsetdir = [resultsdir_nfs '/VOC9990/ImageSets/Main/']; mymkdir(imgsetdir);
    annosetdir = [resultsdir_nfs '/VOC9990/Annotations/']; mymkdir(annosetdir);
    ngramModeldir_obj = [resultsdir_nfs '/ngram_models/' objname '/' codedir '/']; mymkdir(ngramModeldir_obj);
    %try [phrasenames, phrasenames_disp] = getPhraseNamesForObject(objname, objngramdir); end
    %try [phrasenames, phrasenames_disp] = getPhraseNamesForObject_new(objname, objngramdir); end    
    
    %%% GET RELEVANT NGRAMS FOR THIS OBJECT (QUERY TERMS) 
    if DO_MODE == 3.11          % ngram data per object (2012 version)
        disp('getting ngram data per object');
        compileCode_v2_depfun('objectNgramData_2012',0);        
        for ngramtype = [0]
            if ~exist([objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'], 'file')
                disp([' doing ngramtype ' num2str(ngramtype)]);
                cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) '_clean3/'];
                objectNgramData_2012(ngramtype, objname, cleangramdir, objngramdir, minNgramFreqInBooks);
                %multimachine_grail_compiled(['objectNgramData_2012 ' num2str(ngramtype) ' '  objname ' ' cleangramdir ' ' objngramdir], 1, objngramdir, 1, [], 'all.q', 8, 0, OVERWRITE);
            end
        end
        %{
    elseif DO_MODE == 3.12         % ngram data per object (2009 version)
        disp('getting ngram data per object');
        for ngramtype = [2 3 4 5]
            if ~exist([objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'], 'file')
                disp([' doing ngramtype ' num2str(ngramtype)]);
                cleangramdir = [resultsdir '/ngram_cleandata/' num2str(ngramtype) '_clean1/'];
                objectNgramData(ngramtype, objname, cleangramdir, objngramdir);
                %(['objectNgramData(' num2str(ngramtype) ',''' objname ''',''' cleangramdir ''',''' objngramdir ''')' ], 1, objngramdir, 1, [], 2, 0, OVERWRITE);
            end
        end
        while ~exist([objngramdir '/' objname '_5_all.txt'], 'file'), fprintf('.'); pause(15); end
        merge2345ngram_topData(objname, objngramdir, 100, 2009);
        %}
                
        
    %%%% PRUNE NGRAMS BY FAST IMG CLASSIFIER    
    elseif DO_MODE == 4.1       % fast img classifier        
        compileCode_v2_depfun('pascal_img_trainNtestNeval_fast',0);
        cachedir = [resultsdir_nfs '/ngramPruning/' objname '/']; mymkdir(cachedir);        
        inpfname = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];        
        [~, numngrams] = system(['wc -l ' inpfname ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);        
        if numngrams-25 > numdone       % if it has some errors, ok forget and continue, will fix them later        
            disp('check getFeatures function'); keyboard;
            pascal_img_trainNtestNeval_cacheNegFeats(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize_fastImgClfr, sbin_fastImgClfr);
            disp('do 3fold cv same as _slow'); keyboard;
            pascal_img_trainNtestNeval_fast(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize_fastImgClfr, sbin_fastImgClfr, Cval_fastImgClfr);
            %multimachine_grail_compiled(['pascal_img_trainNtestNeval_fast ' cachedir ' ' inpfname ' ' phrasevocyear ' ' objname ' ' imgannodir ' ' num2str(fsize_fastImgClfr) ' '  num2str(sbin_fastImgClfr) ' ' num2str(Cval_fastImgClfr)], 20000, cachedir, 25, [], 'all.q', 8, 0, OVERWRITE);
            while numngrams-25 > numdone, pause(60); numdone = length(mydir([cachedir '/done/*.done'])); fprintf('%s ', [num2str(numdone) '/' num2str(numngrams)]); end
        end
    elseif DO_MODE == 4.2       % reorder ngrams (based on classifier scores)
        cachedir = [resultsdir_nfs '/ngramPruning/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt']; 
        outfname1 = [objngramdir '/' objname '_0_all_fastICorder1.txt'];
        outfname2 = [objngramdir '/' objname '_0_all_fastICorder2.txt'];       
        [~, numngrams] = system(['wc -l ' inpfname ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);
        if ~exist(outfname2, 'file') && numdone >= numngrams
            orderNgramsUsingFastImgClRes(cachedir, inpfname, outfname1, outfname2, 1);
        end   
    elseif DO_MODE == 4.30      % prune based on 1. cutoff         
        inpfname = [objngramdir '/' objname '_0_all_fastICorder1.txt'];
        outfname = [objngramdir '/' objname '_0_all_fastICorder.txt'];        
        disp('some issue with missing last line; check before doing large scale'); keyboard;
        [~,~,~,phrasenames] = selectTopPhrasenames(inpfname, precCutOffThresh_fastImgClfrAcc);
        fid = fopen(outfname, 'w');
        for ii=1:numel(phrasenames), fprintf(fid, '%s\n', phrasenames{ii}); end
        fprintf(fid, '\n');   % needed for the download gui
        fclose(fid);
    %{    
    elseif DO_MODE == 4.31   % select ngrams above cutoff and build edgemat
        cachedir = [resultsdir_nfs '/ngramPruning/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_fastICorder1.txt'];        
        fsize = 10; sbin = 8;
        compileCode_v2_depfun('getAdjacencyMatrix_imgCl',0);
        if exist(inpfname, 'file') && ~exist([cachedir '/edgematrix.mat'], 'file')
            getAdjacencyMatrix_imgCl(cachedir, inpfname, precCutOffThresh, fsize, sbin, 1);
            %multimachine_grail_compiled(['getAdjacencyMatrix_imgCl ' cachedir ' ' inpfname ' ' num2str(precCutOffThresh) ' ' num2str(fsize) ' '  num2str(sbin)], 1, cachedir, 1, [], 'tesla,silicon-mechanics', 8, 0, 1);
        end
    elseif DO_MODE == 4.32   % cluster ngrams using edgemat
        cachedir = [resultsdir_nfs '/ngramPruning/' objname '/'];                
        accfname = [objngramdir '/' objname '_0_all_fastICorder1.txt'];
        outfname = [objngramdir '/' objname '_0_all_fastClusters.txt'];        
        if exist([cachedir '/edgematrix.mat'], 'file')  && ~exist(outfname, 'file') 
            getDiverseNgrams_fastImgCl(cachedir, outfname, accfname, precCutOffThresh, 1);
        end
        %try copyfile(outfname, [wwwdispdir '/']); end
    %}
        
        
    %%%% PRUNE NGRAMS BY MORE COMPLICATED CLASSIFIER  (right now: full images)
    %{
    elseif DO_MODE == 5.0   % resize, delete bad ones and link downloaded images
        compileCode_v2_depfun('mvImgs_imgCl',0);
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/']; mymkdir(cachedir);        
        ngramfname = [objngramdir '/' objname '_0_all_fastICorder.txt'];
        mvImgs_imgCl(ngramfname, rawgoogimgdir, [cachedir '/images/']);
        %multimachine_grail_compiled(['mvImgs_imgCl ' ngramfname ' ' rawgoogimgdir ' ' [cachedir '/images/']], 1000, [cachedir '/images/'], 25, [], 'tesla,silicon-mechanics', 8, 0, 1);
    elseif DO_MODE == 5.1   % slow/full img classifier        
        compileCode_v2_depfun('pascal_img_trainNtestNeval_slow',0);
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/']; mymkdir(cachedir);        
        inpfname = [objngramdir '/' objname '_0_all_fastICorder1.txt'];        
        fsize = 10; sbin = 8;
        phrasenames = selectTopPhrasenames(inpfname, precCutOffThresh); numngrams = length(phrasenames);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);
        if numngrams-25 > numdone  % if it has some errors, ok forget and continue, will fix them later
            pascal_img_trainNtestNeval_cacheNegFeats(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize, sbin);
            pascal_img_trainNtestNeval_slow(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize, sbin);
            %multimachine_grail_compiled(['pascal_img_trainNtestNeval_slow ' cachedir ' ' inpfname ' ' phrasevocyear ' ' objname ' ' imgannodir ' ' num2str(fsize) ' '  num2str(sbin)], 20000, cachedir, 25, [], 'tesla,silicon-mechanics', 8, 0, 1);
            while numngrams-25 > numdone, pause(60); numdone = length(mydir([cachedir '/done/*.done'])); fprintf('%s ', [num2str(numdone) '/' num2str(numngrams)]); end
        end
        %pascal_img_trainNtestNeval_slowDisplay(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize, sbin);
        %pascal_img_trainNtestNeval_slow_dupDetection(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize, sbin);        
    elseif DO_MODE == 5.2   % reorder ngrams (based on classifier scores)
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_fastICorder1.txt'];
        outfname1 = [objngramdir '/' objname '_0_all_slowICorder1.txt'];
        outfname2 = [objngramdir '/' objname '_0_all_slowICorder2.txt'];        
        phrasenames = selectTopPhrasenames(inpfname, precCutOffThresh); numngrams = length(phrasenames);        
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);
        if numdone >= numngrams && ~exist(outfname2, 'file')
            orderNgramsUsingFastImgClRes(cachedir, inpfname, outfname1, outfname2, 2);
        end
    elseif DO_MODE == 5.30   % prune based on 1. cutoff
        inpfname = [objngramdir '/' objname '_0_all_slowICorder1.txt'];
        outfname = [objngramdir '/' objname '_0_all_slowICorder.txt'];        
        [~,~,~,phrasenames] = selectTopPhrasenames_slow(inpfname, precCutOffThresh);
        fid = fopen(outfname, 'w');
        for ii=1:numel(phrasenames), fprintf(fid, '%s\n', phrasenames{ii}); end
        fclose(fid);
    elseif DO_MODE == 5.31   % select ngrams above cutoff and build edgemat
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_slowICorder1.txt'];        
        fsize = 10; sbin = 8;
        compileCode_v2_depfun('getAdjacencyMatrix_imgCl',0);
        if exist(inpfname, 'file') && ~exist([cachedir '/edgematrix.mat'], 'file')
            getAdjacencyMatrix_imgCl(cachedir, inpfname, precCutOffThresh, fsize, sbin, 2);
            %multimachine_grail_compiled(['getAdjacencyMatrix_imgCl ' cachedir ' ' inpfname ' ' num2str(precCutOffThresh) ' ' num2str(fsize) ' '  num2str(sbin)], 1, cachedir, 1, [], 'tesla,silicon-mechanics', 8, 0, 1);
        end
    elseif DO_MODE == 5.32   % prune based on 1. cutoff 2. based on diversity; select top K
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        accfname = [objngramdir '/' objname '_0_all_slowICorder1.txt'];
        outfname = [objngramdir '/' objname '_0_all_slowClusters.txt'];
        outfname2 = [objngramdir '/' objname '_0_all_slowClusters.mat'];        
        if exist([cachedir '/edgematrix.mat'], 'file')  && ~exist(outfname2, 'file')
            getDiverseNgrams_fastImgCl(cachedir, outfname, outfname2, accfname, precCutOffThresh, 2);
        end
        %try copyfile(outfname, [wwwdispdir '/']); end
    %}
    
    
    %%% CREATE SUPER NGRAMS    
    %{
    elseif DO_MODE == 6.1   % create super ngrams        
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_slowClusters.mat'];
        outfname = [objngramdir '/' objname '_0_all_slowClusters_super.txt'];
        outfname2 = [objngramdir '/' objname '_0_all_slowClusters_super_basename.txt'];
        numNgramsToPick = 150;
        maxNumImagesInSuperNgram = 1000;
        createSuperNgrams(inpfname, outfname, cachedir, numNgramsToPick, maxNumImagesInSuperNgram);
        createSuperNgrams_objname(inpfname, outfname2, cachedir, objname, numNgramsToPick);
        %system(['mv ' [cachedir '/done/'] ' ' [cachedir '/done_ngram_mvdForSuperNg/']]);
    %}        
    %{
    elseif DO_MODE == 6.2   % run slow/full img classifier for super ngrams
        compileCode_v2_depfun('pascal_img_trainNtestNeval_slow',0);
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/']; mymkdir(cachedir);        
        inpfname = [objngramdir '/' objname '_0_all_slowClusters_super.txt'];        
        fsize = 10; sbin = 8;
        [~, numngrams] = system(['wc -l ' inpfname ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);
        if numngrams > numdone  % if it has some errors, ok forget and continue, will fix them later
            %pascal_img_trainNtestNeval_slow(cachedir, inpfname, phrasevocyear, objname, imgannodir, fsize, sbin);
            multimachine_grail_compiled(['pascal_img_trainNtestNeval_slow ' cachedir ' ' inpfname ' ' phrasevocyear ' ' objname ' ' imgannodir ' ' num2str(fsize) ' '  num2str(sbin)], 20000, cachedir, 25, [], 'tesla,silicon-mechanics', 8, 0, 1); 
            while numngrams > numdone, pause(60); numdone = length(mydir([cachedir '/done/*.done'])); fprintf('%s ', [num2str(numdone) '/' num2str(numngrams)]); end
        end
    elseif DO_MODE == 6.3   % reorder ngrams (based on classifier scores)
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_slowClusters_super.txt'];
        outfname1 = [objngramdir '/' objname '_0_all_superSlowICorder1.txt'];
        outfname2 = [objngramdir '/' objname '_0_all_superSlowICorder2.txt'];        
        [~, numngrams] = system(['wc -l ' inpfname ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        disp(['total of ' num2str(numngrams) ' & ' num2str(numdone) ' are done']);
        if numdone >= numngrams && ~exist(outfname2, 'file')
            orderNgramsUsingFastImgClRes(cachedir, inpfname, outfname1, outfname2, 3);
        end
    %}
        
    
    %%% DOWNLOAD 200+ IMAGES AND CREATE .TXT FILES
    elseif DO_MODE == 6.5
        cachedir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        inpfname = [objngramdir '/' objname '_0_all_slowClusters_super.txt'];
        disp('SPLIT & PARALLELIZABLE'); 
        mvImgsNcreateTxt_v5(objname, inpfname, cachedir, jpgimagedir, imgsetdir, annosetdir, maxImgSize, pcntTrngImgsPerNgram, pcntValImgsPerNgram, pcntTstImgsPerNgram);
       
        
    %%% DELETE DUPLICATE IMAGES    
    elseif DO_MODE == 6.91
        % note that the duplicate code actually picks non-plain bgrnd and non-intra class duplicated images!!
        %inpdir = [resultsdir_nfs '/ngramPruning_slow/' objname '/'];
        %inpfname = [objngramdir '/' objname '_0_all_slowClusters_super.txt'];
        %findNearDuplicates_exhaustive(inpfname, inpdir);        
        cachedir = [resultsdir_nfs '/ngram_models/' objname '/findDuplicates/']; mymkdir(cachedir);
        findNearDuplicates_cacheFeats(cachedir, jpgimagedir, imgsetdir, sbin_dupDtn, fsize_dupDtn);
    elseif DO_MODE == 6.921
        compileCode_v2_depfun('findNearDuplicates',0);
        dtype = 'val2';
        cachedir = [resultsdir_nfs '/ngram_models/' objname '/findDuplicates/' '/results_' dtype '/']; mymkdir(cachedir);        
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        %[~, numimgs] = system(['wc -l ' imgsetdir '/' dtype '.txt' ' | cut -f1 -d '' '' ']); numimgs = str2num(numimgs);
        [ids, gt] = textread([imgsetdir '/' dtype '_withLabels.txt'], '%s %d'); numimgs = length(ids(gt==1));
        disp(['total of ' num2str(numimgs) ' & ' num2str(numdone) ' are done']);
        if numimgs > numdone
            disp('INCLUDE INFO ABT THE DUPLICATE BY SAVING A info VARIABLE'); keyboard;
            %findNearDuplicates(cachedir, dtype, hogchi2ThisDimThresh);
            multimachine_grail_compiled(['findNearDuplicates ' cachedir ' ' dtype ' ' num2str(hogchi2ThisDimThresh)], 20000, cachedir, 50, [], 'tesla,silicon-mechanics', 8, 0, 1);
            while numimgs > numdone, pause(60); numdone = length(mydir([cachedir '/done/*.done'])); fprintf('%s ', [num2str(numdone) '/' num2str(numimgs)]); end
        end
    elseif DO_MODE == 6.931
        cachedir = [resultsdir_nfs '/ngram_models/' objname '/findDuplicates/' '/results_val2'];
        findNearDuplicates_reducer(cachedir, 'val2', imgsetdir);
    %{    
    elseif DO_MODE == 6.922
        dtype = 'test';
        cachedir = [resultsdir_nfs '/findDuplicates/' objname '/results_' dtype '/']; mymkdir(cachedir);
        numdone = length(mydir([cachedir '/done/*.done']));     % has to be done and not mat as done are unique
        %[~, numimgs] = system(['wc -l ' imgsetdir '/' dtype '.txt' ' | cut -f1 -d '' '' ']); numimgs = str2num(numimgs);
        [ids, gt] = textread([imgsetdir '/' dtype '_withLabels.txt'], '%s %d'); numimgs = length(ids(gt==1));
        disp(['total of ' num2str(numimgs) ' & ' num2str(numdone) ' are done']);
        if numimgs > numdone
            %findNearDuplicates(cachedir, dtype);
            multimachine_grail_compiled(['findNearDuplicates ' cachedir ' ' dtype], 20000, cachedir, 50, [], 'tesla,silicon-mechanics', 8, 0, 1);
            while numimgs > numdone, pause(60); numdone = length(mydir([cachedir '/done/*.done'])); fprintf('%s ', [num2str(numdone) '/' num2str(numimgs)]); end
        end        
    elseif DO_MODE == 6.932
        cachedir = [resultsdir_nfs '/findDuplicates/' objname '/results_test'];
        findNearDuplicates_reducer(cachedir, 'test', imgsetdir);
    %}
        
        
    %%% WSUP TRAINING
    elseif DO_MODE == 7.11     % train wsup detectors, mix 
        compileCode_v2_depfun('pascal_train_wsup2', 0);
        %ii = find(strcmp(phrasenames,doclasses{jj})); %doclasses = {'front_horse', 'lying_horse', 'buggy_horse', 'head_horse', 'jockey_horse_super', 'jumper_horse_super', 'gypsy_horse_super'};
        doparts = 0;
        for ii = 1:numel(phrasenames)    
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/']; mymkdir(cachedir);
            if ~exist([cachedir '/' phrasenames{ii} '_mix.mat'], 'file') 
                %pascal_train_wsup2(phrasenames{ii}, numcomp, modelblahnote, cachedir, phrasevocyear, wsup_fg_olap, borderoffset, doparts);                 
                multimachine_grail_compiled(['pascal_train_wsup2 ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear ' ' num2str(wsup_fg_olap) ' ' num2str(borderoffset) ' ' num2str(doparts)], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE);                
            end
        end        
        %{
    elseif DO_MODE == 7.112     % train wsup detectors, mix  (debug)
        %analysis_tooManyDets(ngramModeldir_obj, phrasenames, valdatatype2, phrasevocyear);
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        analyzeNormBehavior(cachedir, ['baseobjectcategory_' objname], valdatatype2, phrasevocyear);
        %}
    elseif DO_MODE == 7.12     % train wsup detectors, parts 
        compileCode_v2_depfun('pascal_train_wsup2', 0);
        doparts = 1;
        for ii = 1:numel(phrasenames)         
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            if ~exist([cachedir '/' phrasenames{ii} '_parts.mat'], 'file')
                %pascal_train_wsup2(phrasenames{ii}, numcomp, modelblahnote, cachedir, phrasevocyear, wsup_fg_olap, borderoffset, doparts);
                multimachine_grail_compiled(['pascal_train_wsup2 ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear ' ' num2str(wsup_fg_olap) ' ' num2str(borderoffset) ' ' num2str(doparts)], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE); 
            end            
        end    
        %{
    elseif DO_MODE == 7.122     % train wsup detectors, parts, debug
        compileCode_v2_depfun('pascal_train_wsup2', 0);
        doparts = 1;
        for ii = 134         
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            %if ~exist([cachedir '/' phrasenames{ii} '_parts_retrain.mat'], 'file')
                pascal_train_wsup2(phrasenames{ii}, numcomp, modelblahnote, cachedir, phrasevocyear, doparts);
                %multimachine_aws(['pascal_train_wsup ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                %multimachine_grail_compiled(['pascal_train_wsup2 ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear ' ' num2str(doparts)], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE);
            %end
        end        
    elseif DO_MODE == 7.123     % train wsup detectors, parts, retrain to check sv behavior
        compileCode_v2_depfun('pascal_train_wsup2', 0);
        doparts = 1;
        for ii = 1 %84 %1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir '/' phrasenames{ii} '_parts_retrain.mat'], 'file')
                pascal_train_wsup2_retrain(phrasenames{ii}, numcomp, modelblahnote, cachedir, phrasevocyear, doparts);
                %multimachine_aws(['pascal_train_wsup ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                %multimachine_grail_compiled(['pascal_train_wsup2 ' phrasenames{ii} ' ' num2str(numcomp) ' ' modelblahnote ' ' cachedir  ' ' phrasevocyear ' ' num2str(doparts)], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE);
            end
        end
        %}
    elseif DO_MODE == 7.13     % train wsup detectors, joint after parts  
        compileCode_v2_depfun('pascal_train_joint_wsup', 0);
        compileCode_v2_depfun('poslatent_joint_worker', 0);
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];        
        pascal_train_joint_wsup(['baseobjectcategory_' objname], objname, phrasenames, cachedir, phrasevocyear, wsup_fg_olap, borderoffset, jointCacheLimit, numcomp);
        %{
    elseif DO_MODE == 7.132     % train wsup detectors, joint after parts  (debug)
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        pascal_train_joint_wsup_debug1(['baseobjectcategory_' objname], objname, phrasenames, cachedir, phrasevocyear, numcomp);
        %}
        
        
    %%% WSUP TESTING   
    elseif DO_MODE == 7.21      % test _mix model on val set (for pruning and clustering)
        compileCode_v2_depfun('pascal_test_sumpool', 0);
        modelname = 'mix';
        for ii = 1:numel(phrasenames)      
            disp([num2str(ii) ' ' phrasenames{ii}]); 
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if  exist([cachedir '/' phrasenames{ii} '_' modelname '.mat'], 'file') && ~exist([cachedir '/' phrasenames{ii} '_boxes_' valdatatype2 '_' phrasevocyear '_' modelname '.mat'], 'file')
                %pascal_test_sumpool(cachedir, phrasenames{ii}, valdatatype2, phrasevocyear, phrasevocyear, modelname);
                multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype2 ' ' phrasevocyear ' ' phrasevocyear ' ' modelname], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE);
                %multimachine_aws(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype2 ' ' phrasevocyear ' ' phrasevocyear ' ' modelname], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr, globalinfo);
            end
        end
    elseif DO_MODE == 7.221      % test _joint model on test set (cluster version)
        compileCode_v2_depfun('pascal_test_sumpool_multi', 0);
        modelname = 'joint';
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        if  exist([cachedir '/' 'baseobjectcategory_' objname '_' modelname '.mat'], 'file') && ~exist([cachedir '/' 'baseobjectcategory_' objname '_boxes_' testdatatype '_' vocyear '_' modelname '.mat'], 'file')
            %pascal_test_sumpool_multi(cachedir, ['baseobjectcategory_' objname], testdatatype, vocyear, vocyear, modelname);
            %%{
            resdir = [cachedir '/testFiles_' vocyear '/'];
            num_ids = getNumImagesInDataset(cachedir, vocyear, testdatatype);
            multimachine_grail_compiled(['pascal_test_sumpool_multi ' cachedir ' ' ['baseobjectcategory_' objname] ' ' testdatatype ' ' vocyear ' ' vocyear ' ' modelname], num_ids, resdir, round(num_ids/20), [], 'all.q', 2, 0, OVERWRITE, 0);
            %multimachine_grail_compiled(['pascal_test_sumpool_multi ' cachedir ' ' ['baseobjectcategory_' objname] ' ' testdatatype ' ' vocyear ' ' vocyear ' ' modelname], num_ids, resdir, 75, [], 'all.q', 2, 0, 0, 0);
            areAllFilesDone(resdir, num_ids);
            %%}
            pascal_test_sumpool_reducer(cachedir, ['baseobjectcategory_' objname], testdatatype, vocyear, vocyear, modelname);
        end
    elseif DO_MODE == 7.222      % test _joint model on test set (single mach)
        compileCode_v2_depfun('pascal_test_sumpool', 0);
        modelname = 'joint';
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        if  exist([cachedir '/' 'baseobjectcategory_' objname '_' modelname '.mat'], 'file') && ~exist([cachedir '/' 'baseobjectcategory_' objname '_boxes_' testdatatype '_' vocyear '_' modelname '.mat'], 'file')
            pascal_test_sumpool(cachedir, ['baseobjectcategory_' objname], testdatatype, vocyear, vocyear, modelname);
            %multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype2 ' ' phrasevocyear ' ' phrasevocyear ' ' modelname], 1, cachedir, 1, [], 'all.q', 8, 0, OVERWRITE);
        end    
        %{
    elseif DO_MODE == 7.223      % debug        
        modelname = 'joint';
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        pascal_test_sumpool_debug4(cachedir, ['baseobjectcategory_' objname], testdatatype, vocyear, vocyear, modelname);        
        %}
        %{
    elseif DO_MODE == 7.23     % use in detection test VOC9990, test VOC2007, val1, val2
        %pascal_test_calib_wsup - % WAS EARLIER THIS NAME (originally run that style)
        compileCode_v2_depfun('pascal_test_sumpool', 0);
        rmode = 3; % mode =3
        OVERWRITE = 0;
        for ii = 1:numel(phrasenames)   
            disp([num2str(ii) ' ' phrasenames{ii}]); 
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            tlkdir = [cachedir '/doingAllTesting.lock'];
            if  exist([cachedir '/' phrasenames{ii} '_final.mat'], 'file') && ~exist(tlkdir,'dir')
                mymkdir(tlkdir);
                if ~exist([cachedir '/' phrasenames{ii} '_boxes_' testdatatype '_' phrasevocyear '.mat'], 'file')
                    if rmode == 1, pascal_test_sumpool(cachedir, phrasenames{ii}, testdatatype, phrasevocyear, phrasevocyear);
                    elseif rmode == 2, multimachine_aws(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                    elseif rmode == 3, multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 'pe1950,tesla,silicon-mechanics', 8, 0, OVERWRITE); end
                end
                if ~exist([cachedir '/' phrasenames{ii} '_boxes_' testdatatype '_' vocyear '.mat'], 'file')
                    if rmode == 1, pascal_test_sumpool(cachedir, phrasenames{ii}, testdatatype, vocyear, vocyear);
                    elseif rmode == 2, multimachine_aws(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' testdatatype ' ' vocyear ' ' vocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                    elseif rmode == 3, multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' testdatatype ' ' vocyear ' ' vocyear], 1, cachedir, 1, [], 'pe1950,tesla,silicon-mechanics', 8, 0, OVERWRITE); end
                end
                if ~exist([cachedir '/' phrasenames{ii} '_boxes_' valdatatype1 '_' phrasevocyear '.mat'], 'file')
                    if rmode == 1, pascal_test_sumpool(cachedir, phrasenames{ii}, valdatatype1, phrasevocyear, phrasevocyear);
                    elseif rmode == 2, multimachine_aws(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype1 ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                    elseif rmode == 3, multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype1 ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 'pe1950,tesla,silicon-mechanics', 8, 0, OVERWRITE); end
                end
                if ~exist([cachedir '/' phrasenames{ii} '_boxes_' valdatatype2 '_' phrasevocyear '.mat'], 'file')
                    if rmode == 1, pascal_test_sumpool(cachedir, phrasenames{ii}, valdatatype2, phrasevocyear, phrasevocyear);
                    elseif rmode == 2, multimachine_aws(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype2 ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE, initcommandstr, exitcommandstr);
                    elseif rmode == 3, multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' phrasenames{ii} ' ' valdatatype2 ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 'pe1950,tesla,silicon-mechanics', 8, 0, OVERWRITE); end
                end
            end
        end   
        %}
        %{
    elseif DO_MODE == 7.231     %incrementally update all previous mat files with new image detections        
        for ii = 1:96
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];                        
            if exist([cachedir '/' phrasenames{ii} '_boxes_val1_' phrasevocyear '.mat'], 'file')    
                % create backup (copy) of existing boxes (pr curve, etc) information
                movefile([cachedir '/' phrasenames{ii} '_boxes_val1_' phrasevocyear '.mat'], ...
                    [cachedir '/' phrasenames{ii} '_boxes_val1_' phrasevocyear '_beforeHorseFront.mat']);                
            end            
            % run each ngram detector on newly added images; append the new dets to previous mat file; save the new file
            pascal_test_sumpool_inc(cachedir, phrasenames{ii}, 'val1', 'val1_beforeHorseFront', phrasevocyear, phrasevocyear, 'beforeHorseFront');            
        end        
        %}
        
    %%% LABEL TEST DATA FOR EVALUATION    
    %{
    elseif DO_MODE == 7.30     %% (OLD MANUAL) label test and/or calib set
        PASannotatedir_ngram;
    %}
    elseif DO_MODE == 7.301
        %1. generates input file ; 2. make sures question, properties file
        %exist too; 3. copies images to web folder so that they are accessible        
        turkbaseurl = 'http://grail.cs.washington.edu/projects/visual_ngrams/mturk_annotation/annotate_imgArSel.html?category-image=';
        generateInputFileForTurk(objname, turkdir, [wwwturkdir '/images/' objname], turkbaseurl, imgsetdir, jpgimagedir);
    elseif DO_MODE == 7.302
        % run.sh and then waits until all jobs are done
        runTurkTask(objname, [turkdir '/' objname]);
    elseif DO_MODE == 7.303
        % getResults.sh and then waits until all jobs are done        
        getResultsTurkTask(objname, [turkdir '/' objname]);
    elseif DO_MODE == 7.304        
        % converts output/results info to voc format xml files        
        writeTurkResultsToXMLfiles(objname, [turkdir '/' objname], annosetdir);
        disp('display & check if annotations are correctly written'); keyboard;        
    elseif DO_MODE == 7.305       
        % delete tasks 
        approveNdeleteTurkTask(objname, [turkdir '/' objname]);
        
        
    %%% EVALUATION (SNN_BEFORE CALIBRATION/EXPERT SELECTION; PER_NGRAM)
    %{
    elseif DO_MODE == 7.401      % evaluate SNN_before: compute AP for each det
        compileCode_v2_depfun('pascal_eval_ngramEvalObj', 0);
        compileCode_v2_depfun('pascal_eval_ngramEvalObj_pos', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            if 0 && ~exist([cachedir phrasenames{ii} '_pr_' testdatatype '_' phrasevocyear '.mat'], 'file')                
                pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, phrasevocyear);
                %multimachine_grail_compiled(['pascal_eval_ngramEvalObj ' phrasenames{ii} ' ' ['baseobjectcategory_' objname] ' ' cachedir ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 2, 0, OVERWRITE);                
                %multimachine_aws(['pascal_eval_ngramEvalObj ' phrasenames{ii} ' ' ['baseobjectcategory_' objname] ' ' cachedir ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 2, 0, OVERWRITE, initcommandstr, exitcommandstr);
            end
            if ~exist([cachedir phrasenames{ii} '_pr_' testdatatype '_' vocyear '.mat'], 'file')                
                pascal_eval_ngramEvalObj(phrasenames{ii}, objname, cachedir, testdatatype, vocyear, vocyear);
                %multimachine_grail_compiled(['pascal_eval_ngramEvalObj ' phrasenames{ii} ' ' objname ' ' cachedir ' ' testdatatype ' ' vocyear ' ' vocyear], 1, cachedir, 1, [], '', 2, 0, OVERWRITE);
                %multimachine_aws(['pascal_eval_ngramEvalObj ' phrasenames{ii} ' ' objname ' ' cachedir ' ' testdatatype ' ' vocyear ' ' vocyear], 1, cachedir, 1, [], 2, 0, OVERWRITE, initcommandstr, exitcommandstr);
            end
            if 0 && ~exist([cachedir phrasenames{ii} '_prpos_' testdatatype '_' phrasevocyear '.mat'], 'file')
                pascal_eval_ngramEvalObj_pos(phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
                %multimachine_grail_compiled(['pascal_eval_ngramEvalObj_pos ' phrasenames{ii} ' ' cachedir ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], '', 2, 0, OVERWRITE);
            end
        end    
        printResults_ngram(ngramModeldir_obj, wwwdispdir, phrasenames, objname, 1); 
    %}
    elseif DO_MODE == 7.4031             
        modelname = 'joint';
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];        
        pascal_eval_ngramEvalObj(['baseobjectcategory_' objname], objname, cachedir, testdatatype, vocyear, [vocyear '_' modelname]);
        %{
    elseif DO_MODE == 7.4032
        modelname = 'joint';
        %cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/results_curvSatAllDir_unsharedNeg/'];
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        pascal_eval_ngramEvalObj_debug1(['baseobjectcategory_' objname], objname, cachedir, testdatatype, vocyear, [vocyear '_' modelname]);
        %}
        
        
    %%% ANALYSIS
    %{
    elseif DO_MODE == 7.41        % compute gtruth statisc about how many covered
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_noCalib/'];
        nmsolap = 0.5;          %NumToKeep = Inf; %50000;
        calibrateNgramModels_noNMSKeepTop(cachedir, ['baseobjectcategory_' objname], phrasenames, ngramModeldir_obj, testdatatype, phrasevocyear, nmsolap);
        pascal_eval_box_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, phrasevocyear);        
    elseif DO_MODE == 7.42
        confusionMatrix_carlos;
    %}
    elseif DO_MODE == 7.430     %analyze training behavior (also placed directly in pascal_train_wsup.m)
        compileCode_v2('displayExamplesPerSubcat4', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if  exist([cachedir '/' phrasenames{ii} '_final.mat'], 'file') &&  ~exist([cachedir '/display/montageAVG_' num2str(numcomp, '%02d') '.jpg'], 'file')                
                displayExamplesPerSubcat4(phrasenames{ii}, cachedir, phrasevocyear, traindatatype);
                %multimachine_aws(['displayExamplesPerSubcat3 ' phrasenames{ii} ' ' cachedir ' ' phrasevocyear ' ' traindatatype], 1, cachedir, 1, [], 2, 0, OVERWRITE, initcommandstr, exitcommandstr);
            end
        end
    elseif DO_MODE == 7.432     %analyze training behavior (also placed directly in pascal_train_wsup.m)        
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if  exist([cachedir '/' phrasenames{ii} '_final.mat'], 'file') %&&  ~exist([cachedir '/display/montageAVG_' num2str(numcomp, '%02d') '.jpg'], 'file')                                
                displayWeightVectorsPerAspect_v5(phrasenames{ii}, cachedir);
                %multimachine_aws(['displayExamplesPerSubcat3 ' phrasenames{ii} ' ' cachedir ' ' phrasevocyear ' ' traindatatype], 1, cachedir, 1, [], 2, 0, OVERWRITE, initcommandstr, exitcommandstr);
            end
        end        
    elseif DO_MODE == 7.433     %analyze training behavior (also placed directly in pascal_train_wsup.m)
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        displayWeightVectorsPerAspect_v5(['baseobjectcategory_' objname], cachedir);        
    elseif DO_MODE == 7.440     % analyze test results (also placed directly in pascal_test_sumpool.m)
        compileCode_v2('displayDetection_rankedMontages_v5', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if  exist([cachedir '/' phrasenames{ii} '_final.mat'], 'file') %&&  ~exist([cachedir '/display/all_' testdatatype '_' testyear '_' '001-049.jpg'], 'file')
                displayDetection_rankedMontages_v5(phrasenames{ii}, testdatatype, cachedir, testyear, testyear);
                %multimachine_warp_depfun(['displayDetection_rankedMontages_v5(''' phrasenames{ii} ''',''' testdatatype ''',''' cachedir ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 3, 0, OVERWRITE);
            end
        end
    elseif DO_MODE == 7.441      % analyze test results (also placed directly in pascal_test_sumpool.m)
        modelname = 'joint';        
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];        
        displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, vocyear, vocyear, modelname);
        %cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/results_curvSatAllDir_unsharedNeg/'];
        %displayDetection_rankedMontages_v5_debug1(['baseobjectcategory_' objname], testdatatype, cachedir, vocyear, vocyear, modelname);
        %{
    elseif DO_MODE == 7.442      % join detection displays
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            cachedir2 = [resultsdir_nfs '/ngram_models/' objname '/baselrsplit/' phrasenames{ii} '/'];
            try
                im = imread([cachedir '/display/all_001-049.jpg']); im2 = imread([cachedir2 '/display/all_001-049.jpg']);                
                imwrite([im zeros(size(im,1), 10, 3) im2], [cachedir '/display/mergedDisplay.jpg']);
            end
        end
        %}
    elseif DO_MODE == 7.443     % copy results to webdir for easier browsing of results
        wwwdispdir_part = [objname '_trainNtestVis/'];          % change this path in 7.462 too
        wwwdispdir = ['/projects/www/projects/visual_ngrams/display/' wwwdispdir_part]; mymkdir(wwwdispdir);
        for ii = 1:numel(phrasenames)
            myprintf(ii,10);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii}];            
            for kk=1:numcomp, copyfile([cachedir '/display/montageOverIt_' num2str(kk,'%03d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montageOverIt_' num2str(kk,'%03d') '.jpg']); end
            for kk=1:numcomp, copyfile([cachedir '/display/montage3x3_' num2str(kk,'%02d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montage3x3_' num2str(kk,'%02d') '.jpg']); end
            for kk=1:numcomp, copyfile([cachedir '/display/montageAVG_' num2str(kk,'%02d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '.jpg']); end
            for kk=1:numcomp, system(['convert -resize 100x100 ' [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '.jpg'] ' ' [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '_100.jpg']]); end
            for kk=1:numcomp, copyfile([ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/display/pr/' phrasenames{ii} '_' num2str(kk) '_ngram.jpg'], [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '.jpg']); end
            for kk=1:numcomp, system(['convert -resize 100x100 ' [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '.jpg'] ' ' [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '_100.jpg']]); end
            try copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_001-049.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_001-049.jpg']); 
            copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_050-098.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_050-098.jpg']);
            copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_099-147.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_099-147.jpg']); end
        end
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        createWebPageWithTrainingDisplay(phrasenames, numcomp, [cachedir '/display/'], wwwdispdir_part, cachedir);    
        
        
    %%% BUILDING GRAPH
    %(OLD EXP SEL) 
    %{ 
    elseif DO_MODE == 7.451      % (OLD EXP SEL) compute phraseorder/phrasethresh + build graph
        %cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildGraph/']; mymkdir(cachedir);
        %buildGraph(cachedir, phrasenames, phrasenames_disp, phrasevocyear, 'val2');
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree/']; mymkdir(cachedir);
        basefname = [objngramdir '/' objname '_0_all_slowClusters_super_basename.txt'];
        %valdatatype_matrix = 'val1'; valdatatype_thresh = 'val2';
        valdatatype_matrix = 'val2'; valdatatype_thresh = 'val2';
        getAdjacencyMatrix(cachedir, phrasenames, phrasevocyear, valdatatype_matrix, 0, numcomp);
        getGraphFromAdjacencyMatrix(cachedir, phrasenames, phrasenames_disp, basefname, phrasevocyear, valdatatype_matrix, 0, numcomp);
        getOrderNthreshFromGraph(cachedir, phrasenames, phrasevocyear, valdatatype_matrix, valdatatype_thresh, 0, numcomp);
        % now go run expertSelect
    elseif DO_MODE == 7.452      % (OLD EXP SEL) build graph at component level
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(cachedir);
        getAdjacencyMatrix(cachedir, phrasenames, phrasevocyear, 'val1', 1, numcomp);
        getGraphFromAdjacencyMatrix(cachedir, phrasenames, phrasenames_disp, basefname, phrasevocyear, 'val1', 1, numcomp);
        getOrderNthreshFromGraph(cachedir, phrasenames, phrasevocyear, 'val1', 'val2', 1, numcomp);
        % now go run expertSelect
    %}
    elseif DO_MODE == 7.461      % identify good components per model        
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(cachedir);
        modelname = 'mix';
        pascal_getGoodComps(cachedir, phrasenames, valdatatype2, phrasevocyear, numcomp, modelname, minAP_compThresh_full, minAP_compThresh, minNumValInst_comp, minNumTrngInst_comp);
    elseif DO_MODE == 7.462      % cluster good components per model
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        modelname = 'mix';
        wwwdispdir_part = [objname '_trainNtestVis/'];
        getAdjacencyMatrix_noTensor(cachedir, phrasenames, phrasevocyear, valdatatype2, 1, numcomp, modelname);
        pascal_getNondupComps(cachedir, phrasenames, valdatatype2, phrasevocyear, numcomp, modelname, wwwdispdir_part, rankThresh_simComp, rankThresh_disimComp1, ovThresh_disimCmp1, rankThresh_disimComp2, ovThresh_disimComp2);
    elseif DO_MODE == 7.463      % copy html file to webspace for easier browsing
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        wwwdispdir_part = [objname '_trainNtestVis/'];
        wwwdispdir = ['/projects/www/projects/visual_ngrams/display/' wwwdispdir_part];
        copyfile([cachedir '/display/' '/selectedComponetsDisplay.html'], [wwwdispdir '/']);
    elseif DO_MODE == 7.47      % draw graph
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        getGraphFromAdjacencyMatrix_joint(cachedir, ['baseobjectcategory_' objname], objname, phrasevocyear, valdatatype2);
                
        
    %%% MERGE NGRAM DETECTORS (E.G., CALIBRATION, CONTEXT RESCORING, EXPERT SELECTION)
    % 7. UNSUPERVISED PEDRO CONTEXT RESCORE - using fake GTRUTH on val set  
    %{
    elseif DO_MODE == 7.561      % learn params        
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        if ~exist([cachedir / 'baseobjectcategory_' objname '_val1context_LSVMnoSIG.mat'], 'file')
            context_train_allboxessepdiff_wsup(cachedir, 'val1', phrasevocyear, phrasenames{ii}, phrasenames, 3, phrasenames{ii});
        end        
    elseif DO_MODE == 7.562      % apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        if exist([cachedir phrasenames{ii} '_val1context_LSVMnoSIG_' phrasenames{ii} '.mat'], 'file') && ...
                ~exist([cachedir phrasenames{ii} '_boxes_' testdatatype '_val1context_LSVMnoSIG_' phrasenames{ii} '_' phrasevocyear '.mat'], 'file')
            context_test_allboxessep_wsup(cachedir, phrasevocyear, 'val1', testdatatype, phrasenames{ii}, phrasenames{ii}, phrasenames, 3, phrasenames{ii});
        end        
    elseif DO_MODE == 7.563      % evaluate 
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];        
        if ~exist([cachedir phrasenames{ii} '_prpos_' testdatatype ['_val1context_LSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat'], 'file')
            pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);            
        end        
    %}
    
        
    %%% PNN (BASELINE COMPARISON)    
    elseif DO_MODE == 8.1    % PNN: training
        compileCode_v2('pascal_train_wsup', 0);
        disp(' which one to use: pascal_train_wsup vs pascal_train_wsup2'); keyboard;
        for numComp = [6 12 18 25]
            cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/']; mymkdir(cachedir);
            if  ~exist([cachedir '/' 'baseobjectcategory_' objname '_final.mat'], 'file')
                %pascal_train_wsup(['baseobjectcategory_' objname], numComp, modelblahnote, cachedir, phrasevocyear);
                multimachine_grail_compiled(['pascal_train_wsup ' ['baseobjectcategory_' objname] ' ' num2str(numComp) ' ' modelblahnote ' ' cachedir ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE);
                %[initcommandstr, exitcommandstr] = getcommandstr2(localdatasetpath, phrasevocyear, cachedir);
                %multimachine_aws(['pascal_train_wsup ' ['baseobjectcategory_' objname] ' ' num2str(numComp) ' ' modelblahnote ' ' cachedir ' ' phrasevocyear], 1, cachedir, 1, [], 4, 0, OVERWRITE, initcommandstr, exitcommandstr);
            end
        end
    elseif DO_MODE == 8.2   % PNN: testing
        compileCode_v2('pascal_test_sumpool', 0);
        testdatatype = 'test1';
        for numComp = [6 12 18 25]
            cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/'];
            if  exist([cachedir '/' 'baseobjectcategory_' objname '_final.mat'], 'file') &&  ~exist([cachedir '/' 'baseobjectcategory_' objname '_boxes_' testdatatype '_' phrasevocyear '.mat'], 'file')
                %pascal_test_sumpool(cachedir, ['baseobjectcategory_' objname], testdatatype, phrasevocyear, phrasevocyear);
                multimachine_grail_compiled(['pascal_test_sumpool ' cachedir ' ' ['baseobjectcategory_' objname] ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 8, 0, OVERWRITE);
            end
        end
    elseif DO_MODE == 8.31   % PNN: evaluation
        testdatatype = 'test1';
        for numComp = [6 12 18 25]
            cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/'];
            if  exist([cachedir '/' 'baseobjectcategory_' objname '_boxes_' testdatatype '_' phrasevocyear '.mat'], 'file') && ~exist([cachedir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' phrasevocyear '.mat'], 'file')                
                pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, phrasevocyear);
                %multimachine_warp_depfun(['pascal_eval_wsup(''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
            end
        end
    elseif DO_MODE == 8.321  % PNN: evaluation per ngram
        compileCode_v2('pascal_eval_wsup_pvnPerNgram', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/']; 
            if ~exist([cachedir '/perngram/' ['baseobjectcategory_' objname] '_pr_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')
                pascal_eval_wsup_pvnPerNgram(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);                
                %multimachine_grail_compiled(['pascal_eval_wsup_pvnPerNgram ' ['baseobjectcategory_' objname] ' ' phrasenames{ii} ' ' cachedir ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 1, 0, OVERWRITE);
                %multimachine_grail(['pascal_eval_wsup_pvnPerNgram(''' ['baseobjectcategory_' objname] ''',''' phrasenames{ii} ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')'], 1, cachedir, 1, [], 1, 0, OVERWRITE);                
            end
        end        
    elseif DO_MODE == 8.322   % PNN: evaluation per ngram
        compileCode_v2('pascal_eval_wsup_pvnPerNgram', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/']; 
            if ~exist([cachedir '/perngram/' ['baseobjectcategory_' objname] '_prpos_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')                
                pascal_eval_wsup_pvnPerNgram_pos(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
                %multimachine_grail_compiled(['pascal_eval_wsup_pvnPerNgram ' ['baseobjectcategory_' objname] ' ' phrasenames{ii} ' ' cachedir ' ' testdatatype ' ' phrasevocyear ' ' phrasevocyear], 1, cachedir, 1, [], 1, 0, OVERWRITE);
                %multimachine_grail(['pascal_eval_wsup_pvnPerNgram(''' ['baseobjectcategory_' objname] ''',''' phrasenames{ii} ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')'], 1, cachedir, 1, [], 1, 0, OVERWRITE);
            end
        end
    elseif DO_MODE == 8.4   % PNN: result analysis (if with labels else merged with pascal_test 8.2)
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PNN_' num2str(numComp) '/']; 
        %multimachine_warp_depfun(['displayExamplesPerSubcat3(''' ['baseobjectcategory_' objname] ''',''' cachedir ''','''  phrasevocyear ''',''' traindatatype ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
        multimachine_warp_depfun(['displayDetection_rankedMontages_v5(''' ['baseobjectcategory_' objname] ''',''' testdatatype ''',''' cachedir ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 3, 0, OVERWRITE);
    
    %%% PVN (BASELINE COMPARISON)
    elseif DO_MODE == 9.1    % PVN: training
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/']; mymkdir(cachedir);        
        %multimachine_warp(['pascal_train_wsup(''' ['baseobjectcategory_' objname] ''',' num2str(numcomp) ',''' modelblahnote ''',''' cachedir ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 8, 0, OVERWRITE);
        indir = ['/nfs/hn12/sdivvala/visualSubcat/results_lustre/uoctti_models/release3_retrained/VOC2007trainval_VOC2007test/parts_v5/' objname '/baselrsplit/'];        
        system(['ln -s ' indir '/' objname '_final.mat' ' ' cachedir '/' 'baseobjectcategory_' objname '_final.mat']);
    elseif DO_MODE == 9.2   % PVN: testing
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/'];        
        multimachine_warp_depfun(['pascal_test_sumpool(''' cachedir ''',''' ['baseobjectcategory_' objname] ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 8, 0, OVERWRITE);
    elseif DO_MODE == 9.3   % PVN: evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/'];
        %multimachine_warp_depfun(['pascal_eval_wsup(''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, phrasevocyear);        
    elseif DO_MODE == 9.31  % PVN: per ngram evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/'];
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);            
            if ~exist([cachedir ['baseobjectcategory_' objname] '_pr_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')
            pascal_eval_wsup_pvnPerNgram(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
            end
        end
    elseif DO_MODE == 9.32  % PVN: per ngram evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/'];
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            if ~exist([cachedir '/perngram/' ['baseobjectcategory_' objname] '_prpos_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')
                pascal_eval_wsup_pvnPerNgram_pos(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
            end
        end
    elseif DO_MODE == 9.4   % PVN: result analysis
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVN/'];
        multimachine_warp_depfun(['displayDetection_rankedMontages_v5(''' ['baseobjectcategory_' objname] ''',''' testdatatype ''',''' cachedir ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 3, 0, OVERWRITE);
    end
    
    %%% PVV (BASELINE COMPARISON)
    if DO_MODE == 10.1    % PVN: training
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/']; mymkdir(cachedir);
        indir = ['/nfs/hn12/sdivvala/visualSubcat/results_lustre/uoctti_models/release3_retrained/VOC2007trainval_VOC2007test/parts_v5/' objname '/baselrsplit/'];
        system(['ln -s ' indir '/' objname '_final.mat' ' ' cachedir '/' 'baseobjectcategory_' objname '_final.mat']);
    elseif DO_MODE == 10.2   % PVN: testing
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/'];
        multimachine_warp_depfun(['pascal_test_sumpool(''' cachedir ''',''' ['baseobjectcategory_' objname] ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 8, 0, OVERWRITE);
    elseif DO_MODE == 10.3   % PVN: evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/'];        
        %pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, vocyear, vocyear);
        pascal_eval_ngramEvalObj(['baseobjectcategory_' objname], objname, cachedir, testdatatype, vocyear, vocyear);
    elseif DO_MODE == 10.31  % PVN: per ngram evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/'];
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);            
            if ~exist([cachedir ['baseobjectcategory_' objname] '_pr_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')
            pascal_eval_wsup_pvnPerNgram(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
            end
        end
    elseif DO_MODE == 10.32  % PVN: per ngram evaluation
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/'];
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            if ~exist([cachedir '/perngram/' ['baseobjectcategory_' objname] '_prpos_' testdatatype '_' phrasevocyear '_' phrasenames{ii} '.mat'], 'file')
                pascal_eval_wsup_pvnPerNgram_pos(['baseobjectcategory_' objname], phrasenames{ii}, cachedir, testdatatype, phrasevocyear, phrasevocyear);
            end
        end
    elseif DO_MODE == 10.4      % analyze (with labels)
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_PVV/'];
        vocyear = '2007';
        displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, vocyear, vocyear, []);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [initcommandstr, exitcommandstr] = getcommandstr2()

%logininfo = 'sdivvala@onega.graphics.cs.cmu.edu';
initcommandstr = ['sshfs santosh@sumatra.cs.washington.edu:/m-grail30/grail30/santosh /projects/grail/santosh -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ; mkdir /projects/grail/santosh2; sshfs santosh@peets.cs.washington.edu:/m-grail76/grail76/santosh /projects/grail/santosh2 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'];
exitcommandstr = [];
                
%{
function [initcommandstr, exitcommandstr] = getcommandstr(localdatasetpath, phrasevocyear, cachedir)

%disp('changing putdatacmd'); 
%putdatacmd = ['rsynconec2 sdivvala@onega.graphics.cs.cmu.edu:' localdatasetpath '/VOC' phrasevocyear ' ' '~/VOC' phrasevocyear];
%putdatacmd = ['wget http://ladoga.graphics.cs.cmu.edu/sdivvala/.all/Datasets/Pascal_VOC/VOC9990.tgz; tar -xvzf VOC9990.tgz; '];

%logininfo = 'sdivvala@onega.graphics.cs.cmu.edu';
logininfo = 'santosh@kas.cs.washington.edu';

putdatacmd = '';
orgdatacmd = ['sudo mkdir -p ' localdatasetpath ' ; cd ' localdatasetpath ' ; sudo ln -s ~/VOC' phrasevocyear ' .; cd ~; '];
putresultscmd = ['mkdir -p /tmp/' cachedir ' ; rsync -rvzL --delete ' logininfo ':' cachedir ' /tmp/' cachedir ' ; '];
orgresultcmd = ['sudo rm -rf ' cachedir ' ; sudo mkdir -p ' cachedir ' ; sudo chmod -R 777 ' cachedir ' ; cd ' cachedir ' ; sudo ln -s /tmp/' cachedir '/* .; cd ~ ; '];
initcommandstr = [putdatacmd ' ' orgdatacmd ' ' putresultscmd ' ' orgresultcmd];

getresultscmd = ['rsync -rvzL ' cachedir '/* ' logininfo ':' cachedir ' '];
exitcommandstr = [getresultscmd];
%}

%%%%%%%%%%%%%%%%
%{

    %{
    % 1. SUPERVISED SIGMOID CALIBRATION - BASE GTRUTH, SEP CLASSIFIER    
    elseif DO_MODE == 7.5011     % calibration: learn params (get labels for dets & compute sigAB)
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            if  exist([cachedir '/' phrasenames{ii} '_boxes_calib_' phrasevocyear '.mat'], 'file') %&& ~exist([cachedir '/' phrasenames{ii} '_calibParams.mat'], 'file')
                multimachine_warp_depfun(['pascal_eval_calib_wsup(''' phrasenames{ii} ''',''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' valdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
            end
        end
    elseif DO_MODE == 7.5012     % calibration: learn params on hled out dataset (get labels for dets & compute sigAB)
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if  exist([cachedir '/' phrasenames{ii} '_boxes_test_' phrasevocyear '.mat'], 'file') && ~exist([cachedir '/' phrasenames{ii} '_calibParamsHO.mat'], 'file')
                multimachine_warp_depfun(['pascal_eval_calibHO_wsup(''' phrasenames{ii} ''',''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' valdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
            end
        end   
    elseif DO_MODE == 7.5013     % calibration: learn params on hled out dataset per component (get labels for dets & compute sigAB)
        trainThresh = 0.25;
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            tmppr =load([cachedir '/' phrasenames{ii} '_prpos_' valdatatype '_' phrasevocyear '.mat'], 'ap');
            if  tmppr.ap > trainThresh && exist([cachedir '/' phrasenames{ii} '_boxes_' valdatatype '_' phrasevocyear '.mat'], 'file') && ...
                    ~exist([cachedir '/' phrasenames{ii} '_calibParamsHOPC_' valdatatype '_' phrasenames{ii} '.mat'], 'file')
                %multimachine_warp_depfun(['pascal_eval_calibHOPC_wsup(''' phrasenames{ii} ''',''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' valdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
                %delete([cachedir '/' ['baseobjectcategory_' objname] '_gt_anno_' valdatatype '_p33tn_' phrasevocyear '.mat']);
                %system(['ln -s ' cachedir '/../alldata/' ['baseobjectcategory_' objname] '_gt_anno_' valdatatype '_p33tn' phrasevocyear '.mat ' cachedir '/']);
                pascal_eval_calibHOPC_wsup(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, valdatatype, phrasevocyear, phrasevocyear);
            end
        end
    elseif DO_MODE == 7.5014     % calibration: learn params on hled out dataset per component (get labels for dets & compute sigAB)
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            if  exist([cachedir '/' phrasenames{ii} '_boxes_' valdatatype '_' phrasevocyear '.mat'], 'file') && ...
                    ~exist([cachedir '/' phrasenames{ii} '_calibParamsHOPC_' valdatatype '_' phrasenames{ii} '.mat'], 'file')
                %multimachine_warp_depfun(['pascal_eval_calibHOPC_wsup(''' phrasenames{ii} ''',''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' valdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
                pascal_eval_calibHOPC_wsup(phrasenames{ii}, phrasenames{ii}, cachedir, valdatatype, phrasevocyear, phrasevocyear);
            end
        end        
    elseif DO_MODE == 7.503      % evaluate: calibrate scores with learned params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_CalibHOPC_perngram/']; mymkdir(cachedir);
        ngramnmsolap = 0.25;
        if ~exist([cachedir '/' ['baseobjectcategory_' objname] '_boxes_' testdatatype '_' valdatatype '_' phrasevocyear '.mat'], 'file')
            calibrateNgramModels(cachedir, ['baseobjectcategory_' objname], phrasenames, ngramModeldir_obj, testdatatype, valdatatype, phrasevocyear, 'calibParamsHOPC', ngramnmsolap);
        end
    elseif DO_MODE == 7.504      % evaluate: compute AP for all (i.e., SNN)
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_CalibHOPC_perngram/'];
        if ~exist([cachedir '/' ['baseobjectcategory_' objname] '_pr_' testdatatype '_' valdatatype '_' phrasevocyear '.mat'],'file')
            pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, [valdatatype '_' phrasevocyear]);
        %multimachine_warp_depfun(['pascal_eval_wsup(''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 2, 0, OVERWRITE);        
        %multimachine_warp_depfun(['pascal_eval_ignoreBboxLabels(''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 2, 0, OVERWRITE);
        %multimachine_warp_depfun(['displayDetection_rankedMontages_v5(''' ['baseobjectcategory_' objname]  ''',''' testdatatype ''',''' cachedir ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 2, 0, OVERWRITE);        
        end
    %}    
    
    %{
    % 2.(UN)SUPERVISED PEDRO CONTEXT RESCORE - Just for HORSE ngram, BASE (horse) GTRUTH
    elseif DO_MODE == 7.511      % context rescore D1 boxes: learn params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContext/']; mymkdir(cachedir);
        %context_train_wsup(cachedir, valdatatype, phrasevocyear, objname, ['baseobjectcategory_' objname], phrasenames);
        context_train_allboxessep_wsup(cachedir, 'val1', phrasevocyear, ['baseobjectcategory_' objname], phrasenames, 1, objname);
    elseif DO_MODE == 7.512      % context rescore D1 boxes: apply params        
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContext/'];
        %context_test_wsup(cachedir, phrasevocyear, testdatatype, objname, ['baseobjectcategory_' objname], phrasenames)
        context_test_allboxessep_wsup(cachedir, phrasevocyear, 'val1', testdatatype, ['baseobjectcategory_' objname], ['baseobjectcategory_' objname], phrasenames, 1, objname);
    elseif DO_MODE == 7.513      % context rescore D1 boxes: evaluate
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContext/'];        
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['p33tnval1context_KSVMnoSIG_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
        %displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['context_' phrasevocyear]);
    %}
    
    %{
    % 3. SUPERVISED PEDRO CONTEXT RESCORE - all ngrams, BASE (horse) GTRUTH, SINGLE CLASSIFIER    
    elseif DO_MODE == 7.521      % context rescore all boxes: learn params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS/']; mymkdir(cachedir);
        context_train_allboxes_wsup(cachedir, valdatatype, phrasevocyear, ['baseobjectcategory_' objname], phrasenames);
    elseif DO_MODE == 7.522      % context rescore all boxes: apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS/'];
        context_test_allboxes_wsup(cachedir, phrasevocyear, testdatatype, ['baseobjectcategory_' objname], phrasenames)
    elseif DO_MODE == 7.523      % context rescore all boxes: evaluate
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS/'];
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['context_' phrasevocyear]);
        %displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['context_' phrasevocyear]);
    %}
    
    %{
    % 4. (UN)SUPERVISED PEDRO CONTEXT RESCORE - all ngrams, BASE (horse) GTRUTH, SEP CLASSIFIER
    elseif DO_MODE == 7.531      % context rescore all boxes separate classifier: learn params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM/']; mymkdir(cachedir);
        context_train_allboxessep_wsup(cachedir, 'val1', phrasevocyear, ['baseobjectcategory_' objname], phrasenames, 1);
    elseif DO_MODE == 7.532      % context rescore all boxes  separate classifier: apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM/'];
        context_test_allboxessep_wsup(cachedir, phrasevocyear, 'val1', testdatatype, ['baseobjectcategory_' objname], ['baseobjectcategory_' objname], phrasenames, 1);
    elseif DO_MODE == 7.5321
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            %system(['rm ' cachedir phrasenames{ii} '_boxes_' testdatatype '_context_' phrasevocyear '.mat']);
            %system(['rm ' cachedir 'context_data_' testdatatype '_' phrasevocyear '.mat']);
            if ~exist([cachedir phrasenames{ii} '_boxes_' testdatatype '_context_' phrasevocyear '.mat'], 'file')
            system(['ln -s ' cachedir '/../baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM/sizes_' testdatatype '_' phrasevocyear '.mat' ' ' cachedir '/.']);
            system(['ln -s ' cachedir '/../baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM/context_data_' testdatatype '_' phrasevocyear '.mat' ' ' cachedir '/.']);
            context_test_allboxessep_wsup(cachedir, phrasevocyear, testdatatype, phrasenames{ii}, ['baseobjectcategory_' objname], phrasenames, 5, phrasenames{ii});
            end
        end        
    elseif DO_MODE == 7.5331      % context rescore all boxes  separate classifier: evaluate
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM/'];
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['val1context_KSVMnoSIG_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
        %displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['context_KSVMnoSIG_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
    elseif DO_MODE == 7.5332      % evaluate SNN_afterRescoreBaseObjnameGtruth: compute AP for each det
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir phrasenames{ii} '_pr_' testdatatype '_' ['context_' ['baseobjectcategory_' objname] '_' phrasevocyear] '.mat'], 'file')
                pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['context_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
            end
            %multimachine_grail(['pascal_eval_ngramEvalObj(''' phrasenames{ii} ''',''' ['baseobjectcategory_' objname] ''',''' cachedir ''',''' testdatatype ''',''' phrasevocyear ''',''' phrasevocyear ''')' ], 1, cachedir, 1, [], 1, 0, OVERWRITE);
        end
    %}
    
    %{
    % 5. (UN)SUPERVISED PEDRO CONTEXT RESCORE - Well-performing NGRAMS ONLY, BASE (horse) GTRUTH, SEP CLASSIFIER
    elseif DO_MODE == 7.541      % context rescore all boxes separate classifier: learn params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextTopNgramsNMS_sepKSVM/']; mymkdir(cachedir);        
        context_train_allboxessep_wsup(cachedir, 'val1', phrasevocyear, ['baseobjectcategory_' objname], phrasenames, 1);
    elseif DO_MODE == 7.542      % context rescore all boxes  separate classifier: apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextTopNgramsNMS_sepKSVM/'];
        context_test_allboxessep_wsup(cachedir, phrasevocyear, 'val1', testdatatype, ['baseobjectcategory_' objname], ['baseobjectcategory_' objname], phrasenames, 1);
    elseif DO_MODE == 7.5431      % context rescore all boxes  separate classifier: evaluate
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextTopNgramsNMS_sepKSVM/'];
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['p33tnval1context_KSVMnoSIG_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
        %displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['context_KSVMnoSIG_' ['baseobjectcategory_' objname] '_' phrasevocyear]);
    %}
    
    %{
    % 6. SUPERVISED PEDRO CONTEXT RESCORE - NGRAM manual GTRUTH (IGNORE OTHER NGRAMS), SEPARATE CLASSIFIER per ngram
    elseif DO_MODE == 7.551      % context rescore all boxes separate classifier: learn params
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir phrasenames{ii} '_context_KSVMnoSIG_' phrasenames{ii} '.mat'], 'file')
                %disp('moving'); movefile([cachedir phrasenames{ii} '_context_KSVMnoSIG_' phrasenames{ii} '_batch.mat'], [cachedir phrasenames{ii} '_context_KSVMnoSIG_' phrasenames{ii} '.mat']);
                context_train_allboxessepdiff_wsup(cachedir, valdatatype, phrasevocyear, phrasenames{ii}, phrasenames, 1, phrasenames{ii});
            end
        end
    elseif DO_MODE == 7.5521      % context rescore all boxes  separate classifier: apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextAllboxesNMS_sepKSVM_ngramGtruth/'];
        context_test_allboxessep_wsup(cachedir, phrasevocyear, testdatatype, ['baseobjectcategory_' objname], [], phrasenames, 1);    
    elseif DO_MODE == 7.5522      % context rescore all boxes  separate classifier: apply params
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if exist([cachedir phrasenames{ii} '_context_KSVMnoSIG_' phrasenames{ii} '.mat'], 'file') && ...
                    ~exist([cachedir phrasenames{ii} '_boxes_' testdatatype '_context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear '.mat'], 'file')
                context_test_allboxessep_wsup(cachedir, phrasevocyear, testdatatype, phrasenames{ii}, phrasenames{ii}, phrasenames, 1, phrasenames{ii});
            end
        end
    elseif DO_MODE == 7.5531      % evaluate SNN_afterRescoreNgramGtruth: compute AP for each det
        for ii = [1 3 7] %1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir phrasenames{ii} '_pr_' testdatatype '_' ['context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat'], 'file')
                pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);
            end
        end
    elseif DO_MODE == 7.5532      % evaluate SNN_afterRescoreNgramGtruth: compute AP for each det
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir phrasenames{ii} '_prpos_' testdatatype '_' ['context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat'], 'file')
                pascal_eval_ngramEvalObj_pos(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);
            end
        end
    %}
    
    %{
    % 7. UNSUPERVISED PEDRO CONTEXT RESCORE - NGRAM fake GTRUTH (IGNORE OTHER NGRAMS), SEPARATE CLASSIFIER per ngram
    elseif DO_MODE == 7.560         
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            write_ground_truth(cachedir, phrasenames{ii}, ['baseobjectcategory_' objname], 'val1', phrasevocyear);            
        end
    elseif DO_MODE == 7.5601
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_PedroContextTopNgramsNMS_sepKSVM/'];
        visualize_ground_truth_montage(cachedir, ['baseobjectcategory_' objname], 'val1', phrasevocyear);
    elseif DO_MODE == 7.561      % unsupervised context rescore all boxes separate classifier: learn params
        %compileCode_v2('context_train_allboxessepdiff_wsup', 0);
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            if ~exist([cachedir phrasenames{ii} '_val1context_LSVMnoSIG_' phrasenames{ii} '.mat'], 'file')
                context_train_allboxessepdiff_wsup(cachedir, 'val1', phrasevocyear, phrasenames{ii}, phrasenames, 3, phrasenames{ii});
                %multimachine_grail_compiled(['context_train_allboxessepdiff_wsup ' cachedir ' ' 'val1' ' ' phrasevocyear ' ' phrasenames{ii} ' ' num2str(0) ' ' num2str(1) ' ' phrasenames{ii}], 1, cachedir, 1, [], 4, 0, 0);
            end
        end
    elseif DO_MODE == 7.562      % unsupervised context rescore all boxes  separate classifier: apply params
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            %movefile([cachedir phrasenames{ii} '_boxes_' testdatatype '_val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear '.mat'], [cachedir phrasenames{ii} '_boxes_' testdatatype '_val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear '.mat_overfit']);
            if exist([cachedir phrasenames{ii} '_val1context_LSVMnoSIG_' phrasenames{ii} '.mat'], 'file') && ...
                    ~exist([cachedir phrasenames{ii} '_boxes_' testdatatype '_val1context_LSVMnoSIG_' phrasenames{ii} '_' phrasevocyear '.mat'], 'file')
                context_test_allboxessep_wsup(cachedir, phrasevocyear, 'val1', testdatatype, phrasenames{ii}, phrasenames{ii}, phrasenames, 3, phrasenames{ii});
            end
        end
    elseif DO_MODE == 7.563      % evaluate SNN_afterRescoreNgramGtruth: compute AP for each det
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];
            %movefile([cachedir phrasenames{ii} '_prpos_' testdatatype ['_val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat'], [cachedir phrasenames{ii} '_prpos_' testdatatype ['_val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat_overfit']);
            if ~exist([cachedir phrasenames{ii} '_prpos_' testdatatype ['_val1context_LSVMnoSIG_' phrasenames{ii} '_' phrasevocyear] '.mat'], 'file')
                %pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);
                pascal_eval_ngramEvalObj_pos(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['val1context_LSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);
            end
        end
    elseif DO_MODE == 7.564      % compute AP on train data (pos from that ngram and bgrnd unseen negs)
        for ii = 1:numel(phrasenames)
            disp([num2str(ii) ' ' phrasenames{ii}]);
            cachedir = [ngramModeldir_obj '/' phrasenames{ii} '/'];            
            if ~exist([cachedir phrasenames{ii} '_prpos_val1_' phrasevocyear '.mat'], 'file')
                %pascal_eval_ngramEvalObj(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['val1context_KSVMnoSIG_' phrasenames{ii} '_' phrasevocyear]);
                pascal_eval_ngramEvalObj_pos(phrasenames{ii}, ['baseobjectcategory_' objname], cachedir, 'val1', phrasevocyear, phrasevocyear);
            end
        end
    %}
    
    %{
    % 8. SUPERVISED CARLOS EXPERT SELECTION - BASE GTRUTH, SINGLE CLASSIFIER
    elseif DO_MODE == 7.571      % carlos feature: learn params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_CarlosFeature/']; mymkdir(cachedir);
        context_train_carlos_wsup(cachedir, valdatatype, phrasevocyear, ['baseobjectcategory_' objname], phrasenames, 4);
        %context_train_carlos_wsup_displayBoxes(cachedir, valdatatype, phrasevocyear, ['baseobjectcategory_' objname], phrasenames, 1);
    elseif DO_MODE == 7.572      % carlos feature: apply params
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_CarlosFeature/'];
        context_test_carlos_wsup(cachedir, phrasevocyear, valdatatype, testdatatype, ['baseobjectcategory_' objname], phrasenames, 4);
    elseif DO_MODE == 7.573      % carlos feature: evaluate
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_CarlosFeature/'];
        pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, ['context_LSVMnoSIG_' phrasevocyear]);
        %displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['context_KSVMnoSIG_' phrasevocyear]);
    %}

    %{
    % 9. EXPERT SELECTION
    elseif DO_MODE == 7.581      % Training: pick order and thresholds  
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_expertSelect/']; mymkdir(cachedir);
        %%doExpertSel_train(cachedir, phrasevocyear, 'val1', 'val1', ['baseobjectcategory_' objname], phrasenames, 'thresh6');
        indir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree/'];        
        system(['rm ' cachedir '/' ['baseobjectcategory_' objname] '_ordering_' valdatatype2 'thresh10_9990.mat']);
        system(['ln -s ' indir '/order_tree_' valdatatype2 '_9990.mat' ' ' cachedir '/' ['baseobjectcategory_' objname] '_ordering_' valdatatype2 'thresh10_9990.mat']);
        
        %indir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
        %system(['rm ' cachedir '/' ['baseobjectcategory_' objname] '_ordering_val1thresh11_9990.mat']);
        %system(['ln -s ' indir '/order_tree_val1_9990.mat' ' ' cachedir '/' ['baseobjectcategory_' objname] '_ordering_val1thresh11_9990.mat']);
    elseif DO_MODE == 7.582      % Testing: pick boxes across ngrams according to selected order and threholds
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_expertSelect/'];
        doExpertSel_test(cachedir, phrasevocyear, valdatatype2, testdatatype, ['baseobjectcategory_' objname], phrasenames, 'thresh10', vocyear, numcomp);
        %doExpertSel_test(cachedir, phrasevocyear, valdatatype2, testdatatype, ['baseobjectcategory_' objname], phrasenames, 'thresh10', phrasevocyear, numcomp);
    elseif DO_MODE == 7.583      % evaluate SNN_expertSelect
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_expertSelect/'];                        
        pascal_eval_ngramEvalObj(['baseobjectcategory_' objname], objname, cachedir, testdatatype, vocyear, [valdatatype2 'thresh10' '_' vocyear]);
        %pascal_eval_wsup(['baseobjectcategory_' objname], cachedir, testdatatype, phrasevocyear, [valdatatype2 'thresh10' '_' phrasevocyear]);
    elseif DO_MODE == 7.584      % analyze    
        cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_expertSelect/'];
        %displayDetection_rankedMontages_v6(['baseobjectcategory_' objname], testdatatype, cachedir, phrasevocyear, ['val1' 'thresh10' '_' phrasevocyear], phrasenames);
        testyear = '2007'; testdatatype = 'test';
        displayDetection_rankedMontages_v5(['baseobjectcategory_' objname], testdatatype, cachedir, vocyear, ['val1' 'thresh10' '_' vocyear]);
   %}     
    
%}
