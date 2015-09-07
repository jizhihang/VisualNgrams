function preprocessing_ngrams(OBJVAL)

% masterScript to run the ngram project
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

[allClasses, ~, POStags, ~, ngramTypes] = VOCoptsClasses;      % get list of all concepts and their corresponding parts-of-speech (POS) tags
%if ~exist('OBJINDS', 'var') || isempty(OBJINDS)
if ~exist('OBJVAL', 'var') || isempty(OBJVAL)
    OBJINDS = numel(allClasses):numel(allClasses);
else
    OBJINDS = find(strcmp(allClasses, OBJVAL));
end

%%% data year and types
trainyear = '9990';                         % what year of data to train on (default value: '9990' => web data)
testyear = '2007'; testdatatype = 'test';    % what year,type of data to test the models on ('2007, test', '2011, val',...)
valdatatype2 = 'val2';                      % what type of data to validate the models on ('val1', 'val2' => see README_val.txt for abbrievations)
%valdatatype1 = 'val1';
%traindatatype = 'train';

%%% main path names
voc07dir = '/zfs/isis1/zhenyang/Workspace/data/PASCAL/VOC2007/'; % path to the voc 2007 data (whose images are used as background/negative data for training all models)
basedir = '/datastore/zhenyang/Workspace/devel/project/vision/VisualNgrams/';   % main project folder (with the code, results, etc)
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
qnameval = ''; %randqname   
OVERWRITE = 1;                      % whether to overwrite compiled code or not
%%%ngramtype = 0;                   % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)
ngramtype_global = 0;               % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)
dpm.numcomp = 6;                    % number of components for training DPM
dpm.wsup_fg_olap = 0.25;            % amount of foreground overlap (with ground-truth bbox)
dpm.borderoffset = 0.07;            % amount of image border to ignore (e.g., if its a 100pixel image, ignore a 8-pixel margin (7/100*500))
dpm.jointCacheLimit = 2*(3*2^30);   % amount of RAM for training DPM
conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');

%%% pre-processing (to be done once for all concepts)
DO_NGRAM_CORPUS_DWNLD = 1;          % set this to 1 only if running this script for the first time
if DO_NGRAM_CORPUS_DWNLD            % download (from https://books.google.com/ngrams/datasets) & compress ngram data corpus
    disp('download & compressing ngram corpus data');
    %OVERWRITE = 0;
    compileCode_v2_depfun('downloadNcleanNgramData_2012',1);
    if ngramtype_global == 0
        cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype_global) 'gramData_clean/']; mymkdir(cleangramdir);
        downloadNcleanNgramData_2012(ngramtype_global, cleangramdir);
        %multimachine_grail_compiled(['downloadNcleanNgramData_2012 ' num2str(ngramtype) ' ' cleangramdir], ngramGoogFileInfo(ngramtype), rawngramdir, ngramGoogFileInfo(ngramtype), [], qnameval, 16, 0, OVERWRITE);
    elseif ngramtype_global == 2345
        for ijk=2:5
            disp(ijk);
            cleangramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData_clean/']; mymkdir(cleangramdir);
            if areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk), [], 1) ~= 0
                numjobsDwldNcln = min(150, areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk), [], 1));
                %downloadNcleanNgramData_2012(ijk, cleangramdir);
                multimachine_grail_compiled(['downloadNcleanNgramData_2012 ' num2str(ijk) ' ' cleangramdir], ngramGoogFileInfo(ijk), cleangramdir, numjobsDwldNcln, [], qnameval, 8, 0, OVERWRITE, 0);
                %areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk));
            end
        end    
    elseif ngramtype_global == 23450
        for ijk=[0 2:5]
            disp(ijk);            
            cleangramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData_clean/']; mymkdir(cleangramdir);
            if ijk~=0
                if areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk), [], 1) ~= 0
                    numjobsDwldNcln = min(150, areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk), [], 1));
                    %downloadNcleanNgramData_2012(ijk, cleangramdir);
                    multimachine_grail_compiled(['downloadNcleanNgramData_2012 ' num2str(ijk) ' ' cleangramdir], ngramGoogFileInfo(ijk), cleangramdir, numjobsDwldNcln, [], qnameval, 8, 0, OVERWRITE, 0);
                    %areAllFilesDone(cleangramdir, ngramGoogFileInfo(ijk));
                end
            else
                downloadNcleanNgramData_2012(ngramtype_global, cleangramdir);
            end                            
        end
    end
end
