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
basedir = '/datastore/zhenyang/Workspace/devel/project/vision/VisualNgrams/code/LEVAN_results'; % main project folder (with the code, results, etc)
wwwdir = 'http://levan.cs.uw.edu/download_concept.php?concept=%s';
modelsdir = fullfile(basedir, 'models'); mymkdir(modelsdir);
resultsdir = fullfile(basedir, 'results'); mymkdir(resultsdir);

%#########################################################################################################
%%% main code
for objind = OBJINDS            % run either all concepts or a selected concept
    
    objname = allClasses{objind};   
    thisPOStag = POStags{objind};   
    ngramtype = ngramTypes(objind);      % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)

    % set all the path names for this concept
    rawgoogimgdir_obj = [resultsdir '/googImg_data/' objname]; mymkdir(rawgoogimgdir_obj);        % to save images downloaded from google
    ngramModeldir_obj = [resultsdir '/ngram_models/' objname]; mymkdir(ngramDatadir_obj);         % to save ngram models

    diary([ngramModeldir_obj '/diaryOutput_all.txt']);        % save a log of the entire run for debugging/record purposes

    disp(['Doing base object category ' num2str(objind) '.' objname]);

    %%% if the final results for this concept are already available, move on to the next concept
    if exist([ngramModeldir_obj '/baseobjectcategory_' objname '_all_ngrams.txt'], 'file')
        continue;
    end

    disp('%%% Download PreComputed Model ');
    matfilename = [modelsdir '/baseobjectcategory_' objname '.mat'];
    %%% if the precomputed model for this concept is not available, download from LEVAN website
    if ~exist(matfilename, 'file')
        u = sprintf(wwwdir, objname);
        system(['wget -O ' matfilename ' ' u]);
    end
    premodel = load(matfilename);
    myprintfn;
    myprintfn;

    disp('%%% Process Model ');
    nNgs = length(premodel.model.phrasenames);
    fname_model_ngs = [ngramModeldir_obj '/baseobjectcategory_' objname '_all_ngrams.txt'];
    fid = fopen(fname_model_ngs, 'w');
    for ng = 1:nNgs
        fprintf(fid, '%s\n', premodel.model.phrasenames{ng});
    end
    myprintfn;
    myprintfn;

    disp('%%% Download Images ');
    assert(length(premodel.poscell) == nNgs);
    fname_model_imgs = [ngramModeldir_obj '/baseobjectcategory_' objname '_all_images.txt'];
    fid = fopen(fname_model_imgs, 'w');
    for ng = 1:nNgs
        
        %%% 
        Ngdir = strrep(premodel.model.phrasenames{ng}, ' ', '_');
        imgNgdir_obj = [rawgoogimgdir_obj '/' Ngdir]; mymkdir(imgNgdir_obj);

        %%% for each ngram download the images
        for ig = 1:length(premodel.poscell{ng})
            imgurl = premodel.poscell{ng}(ig).imgurl;
            [~,imgname,imgext] = fileparts(imgurl);
            imgfilename = [imgNgdir_obj '/' Ngdir '_' num2str(ig) '.' imgext];
            system(['wget -O ' imgfilename ' ' imgurl]);

            fprintf(fid, '%s %s\n', imgfilename, imgurl);
        end
    end
    myprintfn;
    myprintfn;

end
