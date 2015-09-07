function masterScript_ngrams_testExternalData(OBJINDS)

% masterScript to run the ngram project
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

[allClasses, ~, POStags] = VOCoptsClasses;      % get list of all concepts and their corresponding parts-of-speech (POS) tags
if ~exist('OBJINDS', 'var') || isempty(OBJINDS)
    %OBJINDS = numel(allClasses):numel(allClasses);
    %OBJINDS = [1 4 7 8 10 12 13 17 20];        % VOC1001
    %OBJINDS = [1 4 7 8 10 12 13 17 20 85];     % VOC1001
    OBJINDS = [1 7 13];        % VOC1002
end

%%% data year and types
trainyear = '9990';                         % what year of data to train on (default value: '9990' => web data)
%testyear = '1001'; testdatatype = 'test';    % what year,type of data to test the models on ('2007, test', '2011, val',...)
testyear = '1002'; testdatatype = 'test';    % what year,type of data to test the models on ('2007, test', '2011, val',...)

%%% main path names
voc07dir = ['/projects/grail/' getenv('USER') '/Datasets/Pascal_VOC/VOC2007/']; % path to the voc 2007 data (whose images are used as background/negative data for training all models)
%imagenetdir = ['/projects/grail/izadinia/segram/data/'];

basedir = ['/projects/grail/' getenv('USER') '/objectNgrams/'];                 % main project folder (with the code, results, etc)
resultsdir = fullfile(basedir, 'results');
imgannodir = [resultsdir '/VOC9990/']; mymkdir(imgannodir);
jpgimagedir = [resultsdir '/VOC9990/JPEGImages/']; mymkdir(jpgimagedir);
imgsetdir = [resultsdir '/VOC9990/ImageSets/Main/']; mymkdir(imgsetdir);
imgsetdir_voc = [resultsdir '/VOC9990/ImageSets/voc/']; mymkdir(imgsetdir_voc);
annosetdir = [resultsdir '/VOC9990/Annotations/']; mymkdir(annosetdir);
wwwturkdir = [resultsdir '/turkAnnotations_www/']; mymkdir(wwwturkdir);
turkdir = [resultsdir '/turkAnnotations/']; mymkdir(turkdir);
ngramcntrfname = [resultsdir '/ngram_counter.txt'];                 % file to maintain the unique counter index (used for naming the images, etc)

%%% global variables (need to put them here instead of voc_config.m)
OVERWRITE = 1;                      % whether to overwrite compiled code or not
ngramtype = 23450;                   % type of ngram data (raw ngrams => 2345 or dependencies => 0)
dpm.numcomp = 6;                    % number of components for training DPM
dpm.wsup_fg_olap = 0.25;            % amount of foreground overlap (with ground-truth bbox)
dpm.borderoffset = 0.07;            % amount of image border to ignore (e.g., if its a 100pixel image, ignore a 8-pixel margin (7/100*500))
dpm.jointCacheLimit = 2*(3*2^30);   % amount of RAM for training DPM

%%% main code
for objind = OBJINDS            % run either all concepts or a selected concept
    
    objname = allClasses{objind};   
    thisPOStag = POStags{objind};   
    
    % set all the path names for this concept
    rawgoogimgdir_obj = [resultsdir '/googImg_data/' objname]; mymkdir(rawgoogimgdir_obj);                  % to save images downloaded from google
    ngramDatadir_obj = [resultsdir '/ngram_models/' objname '/object_ngram_data/']; mymkdir(ngramDatadir_obj);  % to save processed ngram data 
    ngramImgClfrdir_obj = [resultsdir '/ngram_models/' objname '/ngramPruning/']; mymkdir(ngramImgClfrdir_obj); % to save data/results of the image classifier based pruning
    ngramDupdir_obj = [resultsdir '/ngram_models/' objname '/findDuplicates/']; mymkdir(ngramDupdir_obj);       % to save data/results for duplicate image deletion
    ngramDispdir_obj = [resultsdir '/ngram_models/' objname '/display/']; mymkdir(ngramDispdir_obj);            % to save visualizations
    ngramModeldir_obj = [resultsdir '/ngram_models/' objname '/' ['kmeans_' num2str(dpm.numcomp)] '/']; mymkdir(ngramModeldir_obj); % to save data/results for DPM 
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);% to save data/results of the merged model
    
    diary([resultsdir '/ngram_models/' objname '/diaryOutput_test_VOC' testyear '.txt']);        % save a log of the entire run for debugging/record purposes
    
    disp(['Doing base object category ' num2str(objind) '.' objname]);
            
    disp(['%%% TESTING (on VOC' testyear ' data)']);
    compileCode_v2_depfun('pascal_test_sumpool_multi_imgnet', 1, 'linuxUpdateSystemNumThreadsToMax.sh');
    modelname = 'joint';
    if exist([baseobjdir '/' ['baseobjectcategory_' objname] '_joint.mat'], 'file') && ...
            ~exist([baseobjdir '/' 'baseobjectcategory_' objname '_boxes_' testdatatype '_' testyear '_' modelname '.mat'], 'file') % test _joint model on test set (cluster version)
        resdir = [baseobjdir '/testFiles_' testyear '/'];
        num_ids = getNumImagesInDataset_imgnet(baseobjdir, testyear, testdatatype, thisPOStag, objname);
        if areAllFilesDone(resdir, num_ids, [], 1) ~= 0
            numjobsDetTest = min(100, areAllFilesDone(resdir, num_ids, [], 1));
            %pascal_test_sumpool(baseobjdir, ['baseobjectcategory_' objname], testdatatype, testyear, testyear, modelname);                     % single machine version
            if numjobsDetTest < 10     
                pascal_test_sumpool_multi_imgnet(baseobjdir, ['baseobjectcategory_' objname], testdatatype, testyear, testyear, modelname, thisPOStag, objname);   % cluster version
            else  
                multimachine_grail_compiled(['pascal_test_sumpool_multi_imgnet ' baseobjdir ' ' ['baseobjectcategory_' objname] ' ' testdatatype ' ' testyear ' ' testyear ' ' modelname ' ' thisPOStag ' ' objname], num_ids, resdir, numjobsDetTest, [], 'notcuda.q', 8, 0, OVERWRITE, 0);                
            end
            areAllFilesDone(resdir, num_ids);     
        end
        pascal_test_sumpool_reducer_imgnet(baseobjdir, ['baseobjectcategory_' objname], testdatatype, testyear, testyear, modelname, thisPOStag, objname);
    end
    myprintfn; myprintfn;
                            
    diary off;
end
