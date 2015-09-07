function masterScript_ngrams_getJointModelWithoutParts(OBJINDS)

% masterScript to run the ngram project
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

[allClasses, ~, POStags] = VOCoptsClasses;      % get list of all concepts and their corresponding parts-of-speech (POS) tags
if ~exist('OBJINDS', 'var') || isempty(OBJINDS)
    OBJINDS = 26:numel(allClasses)-1;  % ignoring voc object,action and 'man'
end 

%%% data year and types
trainyear = '9990';                         % what year of data to train on (default value: '9990' => web data)
testyear = '2007'; testdatatype = 'test';    % what year,type of data to test the models on ('2007, test', '2011, val',...)
valdatatype2 = 'val2';                      % what type of data to validate the models on ('val1', 'val2' => see README_val.txt for abbrievations)
%valdatatype1 = 'val1';
%traindatatype = 'train';

%%% main path names
voc07dir = ['/projects/grail/' getenv('USER') '/Datasets/Pascal_VOC/VOC2007/']; % path to the voc 2007 data (whose images are used as background/negative data for training all models)
basedir = ['/projects/grail/' getenv('USER') '/objectNgrams/'];                 % main project folder (with the code, results, etc)
wwwdir = '/projects/grail/www/projects/visual_ngrams/display/';                 % path to store/see visualizations on the web (contact support@cs to get space on the UW CSE WWW server)
wwwweburl = 'http://grail.cs.washington.edu/projects/visual_ngrams/display/';
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
    wwwdispdir_part = [objname '_trainNtestVis/'];
    wwwdispdir = [wwwdir '/' wwwdispdir_part]; mymkdir(wwwdispdir);  % to save visualizations on web server (for viewing over the web)
    fname_imgcl_sprNg = [ngramImgClfrdir_obj '/' objname '_0_all_fastClusters_super.txt'];                      % to save all the (super) ngram names associated with a concept    
    
    diary([resultsdir '/ngram_models/' objname '/diaryOutput_all.txt']);        % save a log of the entire run for debugging/record purposes
    
    disp(['Doing base object category ' num2str(objind) '.' objname]);
    
    %%% if the final results for this concept are already available, move on to the next concept
    if exist([baseobjdir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' [testyear '_joint_' num2str(100*0.25)] '.mat'], 'file')
        continue;
    end
                
    disp('%%% MERGE COMPONENTS ACROSS ALL NGRAM MODELS (joint training)');
    ngramnames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);  % get list of all ngram names
    if ~exist([baseobjdir '/' ['baseobjectcategory_' objname] '_joint_data_noparts.mat'], 'file')
        do_retraining = 0;
        pascal_train_joint_wsup_prepare_noparts(['baseobjectcategory_' objname], objname, ngramnames, baseobjdir, trainyear, dpm.wsup_fg_olap, dpm.borderoffset, dpm.jointCacheLimit, dpm.numcomp, do_retraining);        
    end
    myprintfn; myprintfn;
    
    diary off;
end
