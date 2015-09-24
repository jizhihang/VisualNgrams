function validate_images(OBJVAL)

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
basedir = '/datastore/zhenyang/Workspace/devel/project/vision/VisualNgrams/code/LEVAN_models'; % main project folder (with the code, results, etc)
wwwdir = 'http://levan.cs.uw.edu/download_concept.php?concept=%s';
modelsdir = fullfile(basedir, 'models');
resultsdir = fullfile(basedir, 'results');

conf = voc_config('paths.model_dir', '/zfs/isis1/zhenyang/Workspace/data/tmp/tmpdir_for_vocconfig/');
%numImages =  conf.threshs.numImgsToDwnldFrmGoog;
maxImgReSize = conf.threshs.maxImgSize;
weirdAspectThresh = conf.threshs.weirdAspectThresh;
minNumImgs = conf.threshs.minNumImgsDownloadCheck;
%samapi =  conf.threshs.samapi;

%#########################################################################################################
%%% main code
for objind = OBJINDS            % run either all concepts or a selected concept
    
    objname = allClasses{objind};
    thisPOStag = POStags{objind};
    ngramtype = ngramTypes(objind);      % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)

    % set all the path names for this concept
    rawgoogimgdir_obj = [resultsdir '/googImg_data/' objname];
    ngramModeldir_obj = [resultsdir '/ngram_models/' objname];

    disp(['Doing base object category ' num2str(objind) '.' objname]);

    %%% if the final results for this concept are already available, move on to the next concept
    if exist([ngramModeldir_obj '/' objname '.txt'], 'file')
        continue;
    end

    ignoredir = [rawgoogimgdir_obj '/ignore/']; mymkdir(ignoredir);

    disp(' chking if all images are valid; if so, resize');
    [ids, ~] = textread([ngramModeldir_obj '/baseobjectcategory_' objname '_all_images.txt'], '%s %s');
    fid = fopen([ngramModeldir_obj '/' objname '.txt'], 'w');
    if length(ids) > 0
        disp(' resizing images');
        %resizeGoogImages(ids, maxImgReSize);
        for i=1:length(ids)     % removing parfor as i want this too be slow so that download requests arent bombarded  
            try
                im = imread(ids{i});
                [ht, wd, dp] = size(im);
                if ht/wd > weirdAspectThresh && wd/ht > weirdAspectThresh           % looks like good aspect ratio image
                    im = imresize(im, maxImgReSize/max(size(im,1),size(im,2)), 'bilinear');
                    [a, b] = system(['rm -f ' ids{i}]);  % rm original downloaded images

                    imgfilename = [strtok(ids{i}, '.') '.jpg'];
                    imwrite(im, imgfilename);
                    fprintf(fid, '%s\n', strrep(imgfilename, '/datastore/zhenyang/Workspace/devel/project/vision/VisualNgrams/code/LEVAN_models/results/', ''));
                else
                    disp(['  bad aspet ratio' ids{i}]);
                    [a, b] = system(['mv ' ids{i} ' ' ignoredir '/']);
                end
            catch
                disp(['  cant load this image ' ids{i} ' ; ignoring it']);
                [a, b] = system(['mv ' ids{i} ' ' ignoredir '/']);  % mv instead of delete as it has other important .* files (.urls etc)
            end
        end
    else
        disp('some issue here'); keyboard;
        disp('  could not find images');
        continue;      
    end
    myprintfn;
    myprintfn;
    
    fclose(fid);
end
