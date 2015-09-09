function preprocess_models(OBJVAL)

% masterScript to run the ngram project
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

[allClasses, ~, POStags, ~, ngramTypes] = VOCoptsClasses;      % get list of all concepts and their corresponding parts-of-speech (POS) tags
%if ~exist('OBJINDS', 'var') || isempty(OBJINDS)
if ~exist('OBJVAL', 'var') || isempty(OBJVAL)
    %OBJINDS = numel(allClasses):numel(allClasses);
    OBJINDS = 1:numel(allClasses);
else
    OBJINDS = OBJVAL;
    %OBJINDS = find(strcmp(allClasses, OBJVAL));
end

%%% main path names
voc07dir = '/zfs/isis1/zhenyang/Workspace/data/PASCAL/VOC2007/'; % path to the voc 2007 data (whose images are used as background/negative data for training all models)
basedir = '/datastore/zhenyang/Workspace/devel/project/vision/VisualNgrams/code/LEVAN_results';   % main project folder (with the code, results, etc)
wwwdir = 'http://levan.cs.uw.edu/download_concept.php?concept=%s';
modelsdir = fullfile(basedir, 'models');
resultsdir = fullfile(basedir, 'results');

%%% global variables (need to put them here instead of voc_config.m)


%#########################################################################################################
%%% main code
for objind = OBJINDS            % run either all concepts or a selected concept
    
    objname = allClasses{objind};   
    thisPOStag = POStags{objind};   
    ngramtype = ngramTypes(objind);      % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)

    % set all the path names for this concept
    rawgoogimgdir_obj = [resultsdir '/googImg_data/' objname]; mymkdir(rawgoogimgdir_obj);                  % to save images downloaded from google
    ngramDatadir_obj = [resultsdir '/ngram_models/' objname '/object_ngram_data/']; mymkdir(ngramDatadir_obj);  % to save processed ngram data
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);% to save data/results of the merged model
    fname_imgcl_sprNg = [ngramImgClfrdir_obj '/' objname '_all_fastClusters_super.txt'];                      % to save all the (super) ngram names associated with a concept    

    diary([resultsdir '/ngram_models/' objname '/diaryOutput_all.txt']);        % save a log of the entire run for debugging/record purposes

    disp(['Doing base object category ' num2str(objind) '.' objname]);

    %%% if the final results for this concept are already available, move on to the next concept
    if exist([baseobjdir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' [testyear '_joint_' num2str(100*0.25)] '.mat'], 'file')
        continue;
    end
    
    disp('%%% DOWNLOAD IMAGES ');
    disp('%%% DOWNLOAD IMAGES ');
    disp('%%% DOWNLOAD IMAGES ');

    
    
end
