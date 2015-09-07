function preprocessing_ngrams(OBJVAL)

% masterScript to run the ngram project
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

[allClasses, ~, POStags, ~, ngramTypes] = VOCoptsClasses;      % get list of all concepts and their corresponding parts-of-speech (POS) tags
%if ~exist('OBJINDS', 'var') || isempty(OBJINDS)
if ~exist('OBJVAL', 'var') || isempty(OBJVAL)
    %OBJINDS = numel(allClasses):numel(allClasses);
    OBJINDS = 1:numel(allClasses);
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
DO_NGRAM_CORPUS_DWNLD = 0;          % set this to 1 only if running this script for the first time
if DO_NGRAM_CORPUS_DWNLD            % download (from https://books.google.com/ngrams/datasets) & compress ngram data corpus
    disp('download & compressing ngram corpus data');
    OVERWRITE = 0;
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

%#########################################################################################################
DO_VOC2007_COPY = 1;                % set this to 1 only if running this script for the first time
if DO_VOC2007_COPY                  % copy voc images (useful for negatives, need not do for every object)
    disp('copy VOC images & annotations; softlink it to Datasets directory ');
    copyVOC2007dataToNgramData(voc07dir, jpgimagedir, annosetdir, imgsetdir_voc);
    system(['ln -s ' resultsdir '/VOC9990/' ' ' voc07dir '/../']);       
end

%#########################################################################################################
%%% main code
for objind = OBJINDS            % run either all concepts or a selected concept
    
    objname = allClasses{objind};   
    thisPOStag = POStags{objind};   
    ngramtype = ngramTypes(objind);      % type of ngram data (raw ngrams => 2345 or dependencies => 0 or both => 23450)

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
    fname_imgcl_sprNg = [ngramImgClfrdir_obj '/' objname '_all_fastClusters_super.txt'];                      % to save all the (super) ngram names associated with a concept    
    
    diary([resultsdir '/ngram_models/' objname '/diaryOutput_all.txt']);        % save a log of the entire run for debugging/record purposes
    
    disp(['Doing base object category ' num2str(objind) '.' objname]);

    %%% if the final results for this concept are already available, move on to the next concept
    if exist([baseobjdir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' [testyear '_joint_' num2str(100*0.25)] '.mat'], 'file')
        continue;
    end
    

    disp('%%% GET NEGATIVE IMAGE SET');
    if ~exist([imgsetdir_voc '/' objname '_trainval.txt'], 'file')
        createNegativeImageSet(voc07dir, imgsetdir_voc, objname);
    end
    myprintfn; myprintfn;
    
    
    disp('%%% GET RELEVANT NGRAMS FOR THIS CONCEPT (QUERY TERMS)');
    ngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite.txt'];
    if ~exist(ngram_uniqNsort_fname, 'file')
        if ngramtype == 0
            cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData_clean/'];
            objectNgramData_2012(ngramtype, objname, cleangramdir, ngramDatadir_obj, ngram_uniqNsort_fname, thisPOStag);            
        elseif ngramtype == 2345
            for ijk=2:5
                cleangramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData_clean/'];
                thisngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ijk) '_all_uniquedNsort_rewrite.txt'];
                if ~exist(thisngram_uniqNsort_fname, 'file')
                    disp(ijk);                    
                    ngramDatadir_obj_tmpdir = [ngramDatadir_obj '/tempFiles_' num2str(ijk) '/'];                    
                    if areAllFilesDone(ngramDatadir_obj_tmpdir, ngramGoogFileInfo(ijk), [], 1) ~= 0
                        %objectNgramData_2012_mapper(ijk, objname, cleangramdir, ngramDatadir_obj_tmpdir, thisPOStag);
                        compileCode_v2_depfun('objectNgramData_2012_mapper',1,'fetchNgramdata_2012.sh', 'fetchNgramdata_2012_2345.sh');
                        multimachine_grail_compiled(['objectNgramData_2012_mapper ' num2str(ijk) ' '  objname ' ' cleangramdir ' ' ngramDatadir_obj_tmpdir ' ' thisPOStag], ngramGoogFileInfo(ijk), ngramDatadir_obj_tmpdir, 25, [], qnameval, 8, 0, OVERWRITE, 0);
                        areAllFilesDone(ngramDatadir_obj_tmpdir, ngramGoogFileInfo(ijk));
                    end
                    objectNgramData_2012(ijk, objname, cleangramdir, ngramDatadir_obj, thisngram_uniqNsort_fname, thisPOStag);
                end
            end
            
            ngram_uniqNsort_fname_tmp = [ngramDatadir_obj '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite_b4mrg.txt'];
            for ijk=2:5
                thisngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ijk) '_all_uniquedNsort_rewrite.txt'];
                system(['cat ' thisngram_uniqNsort_fname ' >> ' ngram_uniqNsort_fname_tmp]);
            end
            conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
            minNgramCnt = conf.threshs.minNgramFreqInBooks;
            clear conf;
            merge2345ngram_topData(minNgramCnt, 2012, ngram_uniqNsort_fname_tmp, ngram_uniqNsort_fname);            
        elseif ngramtype == 23450
            for ijk=[0 2:5]
                cleangramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData_clean/'];
                thisngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ijk) '_all_uniquedNsort_rewrite.txt'];
                if ~exist(thisngram_uniqNsort_fname, 'file')
                    disp(ijk);
                    if ijk ~= 0                        
                        ngramDatadir_obj_tmpdir = [ngramDatadir_obj '/tempFiles_' num2str(ijk) '/'];
                        if areAllFilesDone(ngramDatadir_obj_tmpdir, ngramGoogFileInfo(ijk), [], 1) ~= 0
                            %objectNgramData_2012_mapper(ijk, objname, cleangramdir, ngramDatadir_obj_tmpdir, thisPOStag);
                            compileCode_v2_depfun('objectNgramData_2012_mapper',1,'fetchNgramdata_2012.sh', 'fetchNgramdata_2012_2345.sh');
                            multimachine_grail_compiled(['objectNgramData_2012_mapper ' num2str(ijk) ' '  objname ' ' cleangramdir ' ' ngramDatadir_obj_tmpdir ' ' thisPOStag], ngramGoogFileInfo(ijk), ngramDatadir_obj_tmpdir, 25, [], qnameval, 8, 0, OVERWRITE, 0);
                            areAllFilesDone(ngramDatadir_obj_tmpdir, ngramGoogFileInfo(ijk));
                        end
                    end
                    objectNgramData_2012(ijk, objname, cleangramdir, ngramDatadir_obj, thisngram_uniqNsort_fname, thisPOStag);
                end
            end
            
            ngram_uniqNsort_fname_tmp = [ngramDatadir_obj '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite_b4mrg.txt'];
            for ijk=[0 2:5]
                thisngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ijk) '_all_uniquedNsort_rewrite.txt'];
                system(['cat ' thisngram_uniqNsort_fname ' >> ' ngram_uniqNsort_fname_tmp]);
            end
            conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
            minNgramCnt = conf.threshs.minNgramFreqInBooks;
            clear conf;
            merge2345ngram_topData(minNgramCnt, 2012, ngram_uniqNsort_fname_tmp, ngram_uniqNsort_fname);
        end
        [~, numofngrams] = system(['wc -l ' ngram_uniqNsort_fname ' | gawk ''{NF--};1'' ']);        
        numofngrams = str2double(numofngrams(1:end-1));
        disp(['Got a total of ' num2str(numofngrams) ' raw ngrams']);
        fid = fopen([ngramDatadir_obj '/numRawNngramStats.txt'], 'w');
        fprintf(fid, '%d\n', numofngrams);
        fclose(fid);
    end
    myprintfn; myprintfn;


    disp('%%% PRUNE NGRAMS BY IMAGE CLASSIFIER');
    outfname_imgcl = [ngramImgClfrdir_obj '/' objname '_all_fastICorder.txt'];
    %outfname1 = [ngramImgClfrdir_obj '/' objname '_all_fastICorder1.txt'];
    %outfname2 = [ngramImgClfrdir_obj '/' objname '_all_fastICorder2.txt'];
    outfname_imgcl1 = [strtok(outfname_imgcl,'.') '1.txt'];
    outfname_imgcl2 = [strtok(outfname_imgcl,'.') '2.txt'];
    if ~exist(outfname_imgcl, 'file')
        disp('Extract (background/negative) features for training img classifier');
        %inpfname_imgcl = [ngramDatadir_obj '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite.txt'];
        inpfname_imgcl = ngram_uniqNsort_fname;
        if ~exist([ngramImgClfrdir_obj '/negData_test.mat'], 'file')
            pascal_img_trainNtestNeval_cacheNegFeats(ngramImgClfrdir_obj, inpfname_imgcl, trainyear, objname, imgannodir);
        end        
        
        disp('Train img classifiers');
        [~, numngrams] = system(['wc -l ' inpfname_imgcl ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
        if areAllFilesDone(ngramImgClfrdir_obj, numngrams, [], 1) ~= 0
            numjobsImgCls = min(100, areAllFilesDone(ngramImgClfrdir_obj, numngrams, [], 1));
            if numjobsImgCls < 10   % if only a few ngrams, then run locally (otherwise on cluster)
                pascal_img_trainNtestNeval_fast(ngramImgClfrdir_obj, inpfname_imgcl, trainyear, objname, imgannodir);
            else
                compileCode_v2_depfun('pascal_img_trainNtestNeval_fast',1,'googleimages_dsk.py');
                multimachine_grail_compiled(['pascal_img_trainNtestNeval_fast ' ngramImgClfrdir_obj ' ' inpfname_imgcl ' ' trainyear ' ' objname ' ' imgannodir], numngrams, ngramImgClfrdir_obj, numjobsImgCls, [], qnameval, 8, 0, OVERWRITE, 0);
            end
            areAllFilesDone(ngramImgClfrdir_obj, numngrams);
        end
        
        disp('Reorder ngrams (based on classifier scores)');        
        if ~exist(outfname_imgcl2, 'file')
            orderNgramsUsingFastImgClRes(ngramImgClfrdir_obj, inpfname_imgcl, outfname_imgcl1, outfname_imgcl2, 1);
        end
        if ~exist(outfname_imgcl, 'file')
            ngramListBasedOnCutoffPruning(outfname_imgcl1, outfname_imgcl);
        end
        disp(' write stats');
        [~, numofngrams2] = system(['wc -l ' outfname_imgcl ' | gawk ''{NF--};1'' ']);        
        numofngrams2 = str2double(numofngrams2(1:end-1))-1; %-1 as I add a blank line for the download script
        disp(['Got a total of ' num2str(numofngrams2) ' refined ngrams']);
        fid = fopen([ngramImgClfrdir_obj '/numRefinedNngramStats.txt'], 'w'); 
        fprintf(fid, '%d\n', numofngrams2);
        fclose(fid);
        
        % write #imgStats to file
        [~, numofngrams] = system(['wc -l ' ngram_uniqNsort_fname ' | gawk ''{NF--};1'' ']);        
        numofngrams = str2double(numofngrams(1:end-1));
        fid = fopen([ngramImgClfrdir_obj '/imgStats.txt'], 'w');        
        fprintf(fid, '%d\n', ...
            [(numofngrams-numofngrams2)*conf.threshs.numThumbImgsToDwnldFrmGoog + ...
            numofngrams2*conf.threshs.numImgsToDwnldFrmGoog]);
        fclose(fid);
        
        % write #boxStats to file
        fid = fopen([ngramImgClfrdir_obj '/boxStats.txt'], 'w');
        fprintf(fid, '%d\n', numofngrams2*conf.threshs.numImgsToDwnldFrmGoog);
        fclose(fid);
    end
    myprintfn; myprintfn;
        
    
    disp('%%% DOWNLOAD IMAGES FROM GOOGLE IMAGE SEARCH ');
    %ngramfname_dwld = [ngramImgClfrdir_obj '/' objname '_all_fastICorder.txt'];
    ngramfname_dwld = outfname_imgcl;
    [~, numngrams] = system(['wc -l ' ngramfname_dwld ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams)-1;  % -1 as i add an empty line at the end of the file
    if areAllFilesDone(rawgoogimgdir_obj, numngrams, [], 1) ~= 0        
        
        vocconfigfname = [resultsdir '/ngram_models/' objname '/voc_config_info.mat'];
        if ~exist(vocconfigfname, 'file')   % save all parameter info for record purposes (this can be moved to the beginning of the for loop above)
            conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
            save(vocconfigfname, 'conf');
            clear conf;
        end
        
        numjobsDld = min(15, areAllFilesDone(rawgoogimgdir_obj, numngrams, [], 1)); % if samapi==1, then 15 only
        if numjobsDld <= 10
            downloadGoogImgs(ngramfname_dwld, rawgoogimgdir_obj);
        else
            compileCode_v2_depfun('downloadGoogImgs', 1, 'samGoogDownload.sh', 'samYahooDownload.sh', 'googleimages_dsk.py', 'samGoogPhantomDownload.sh', 'google-images.js');
            multimachine_grail_compiled(['downloadGoogImgs ' ngramfname_dwld ' ' rawgoogimgdir_obj], numngrams, rawgoogimgdir_obj, numjobsDld, [], qnameval, 8, 0, OVERWRITE, 0);
        end
        areAllFilesDone(rawgoogimgdir_obj, numngrams);
    end
    myprintfn; myprintfn;
    
    
    disp('%%% CREATE SUPER NGRAMS');
    outfname_imgcl_clus = [ngramImgClfrdir_obj '/' objname '_all_fastClusters.txt'];    
    supNgMatFname = [strtok(outfname_imgcl_clus,'.') '.mat'];
    if ~exist(outfname_imgcl_clus, 'file')
        disp('Cluster ngrams at image level');        
        inpfname_imgcl1 = outfname_imgcl1;                          %inpfname_imgcl1 = [ngramImgClfrdir_obj '/' objname '_all_fastICorder1.txt'];
        getAdjacencyMatrix_imgCl(ngramImgClfrdir_obj, inpfname_imgcl1);         % select ngrams above cutoff and build edgemat
        
        outfname1 = [strtok(outfname_imgcl_clus, '.') '_info.txt']; %outfname1 = [ngramImgClfrdir_obj '/' objname '_all_fastClusters_info.txt'];
        accfname = inpfname_imgcl1;                                 %accfname = [ngramImgClfrdir_obj '/' objname '_all_fastICorder1.txt'];
        getDiverseNgrams_fastImgCl(ngramImgClfrdir_obj, outfname_imgcl_clus, outfname1, supNgMatFname, accfname);
        
        pairScfname = [ngramImgClfrdir_obj '/' objname '_visualPairwiseScores.txt'];
        writeAdjacencyMatrixToFile(ngramImgClfrdir_obj, pairScfname, accfname);        
    end
    if ~exist(fname_imgcl_sprNg, 'file')
        disp('Create new dirs and softlink images');        
        inpfname = supNgMatFname;   %inpfname = [ngramImgClfrdir_obj '/' objname '_all_fastClusters.mat'];
        createSuperNgrams(inpfname, fname_imgcl_sprNg, rawgoogimgdir_obj);
    end
    myprintfn; myprintfn;
    
    
    disp('%%% CREATE PASCAL VOC-style .TXT FILES (NEEDED TO TRAIN DPMs)');
    ngramnames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);  % get list of all ngram names         
    if ~exist([imgsetdir '/baseobjectcategory_' objname '_val2_withLabels.txt'], 'file')
        mvImgsNcreateTxt(objname, fname_imgcl_sprNg, ngramcntrfname, rawgoogimgdir_obj, jpgimagedir, imgsetdir, annosetdir);
        disp('visualize downloaded train images (just to make sure if .txt files have been properly created)');
        displayNgramImagesWithAnnotations(fname_imgcl_sprNg, ngramDispdir_obj, imgsetdir, jpgimagedir);
    end
    myprintfn; myprintfn;


    %{
    disp('%%% DELETE DUPLICATE IMAGES (between TRAIN & VOC TEST)');
    dtype = ['test_' testyear];
    if ~exist([ngramDupdir_obj '/resultsHashing_' dtype '/' dtype '_' objname '.txt'], 'file')
        %disp('need to test & recompile findNearDuplicates_hashing?'); keyboard;
        disp('Extract features');
        if ~exist([ngramDupdir_obj '/posData_' dtype '.mat'], 'file') % note that the duplicate code actually picks non-plain bgrnd and non-intra class duplicated images!!
            findNearDuplicates_cacheFeats(ngramDupdir_obj, objname, [voc07dir '/JPEGImages/'], [voc07dir '/ImageSets/Main/'] , dtype);
        end
           
        disp('Compute distances (mapper)');
        cachedir = [ngramDupdir_obj '/resultsHashing_' dtype '/']; mymkdir(cachedir);
        ids = textread([voc07dir '/ImageSets/Main/test.txt'], '%s'); numimgs = length(ids);
        if areAllFilesDone(cachedir, numimgs, [], 1) ~= 0
            findNearDuplicates_hashing(cachedir, dtype);
            %multimachine_grail_compiled(['findNearDuplicates_hashing ' cachedir ' ' dtype], numimgs, cachedir, 100, [], qnameval, 8, 0, OVERWRITE, 0);
            areAllFilesDone(cachedir, numimgs);
        end
        
        disp('Compute distances (reducer) & update files');
        findNearDuplicates_reducer_voctest(cachedir, dtype, [voc07dir '/ImageSets/Main/'], objname);        
    end
    myprintfn; myprintfn;
    %}
    
    disp('%%% DELETE DUPLICATE IMAGES (between TRAIN & VAL)');
    dtype = 'val2';
    if ~exist([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withDups.txt'], 'file')
        disp('Extract features');
        if ~exist([ngramDupdir_obj '/posData_' dtype '.mat'], 'file') % note that the duplicate code actually picks non-plain bgrnd and non-intra class duplicated images!!
            findNearDuplicates_cacheFeats(ngramDupdir_obj, objname, jpgimagedir, imgsetdir, dtype);
        end
        
        disp('Compute distances (mapper)');
        cachedir = [ngramDupdir_obj '/resultsHashing_' dtype '/']; mymkdir(cachedir);        
        [ids, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels.txt'], '%s %d'); numimgs = length(ids(gt==1));
        if areAllFilesDone(cachedir, numimgs, [], 1) ~= 0
            numjobsImgDups = min(100, areAllFilesDone(cachedir, numimgs, [], 1));
            compileCode_v2_depfun('findNearDuplicates_hashing',1);            
            multimachine_grail_compiled(['findNearDuplicates_hashing ' cachedir ' ' dtype], numimgs, cachedir, numjobsImgDups, [], qnameval, 8, 0, OVERWRITE, 0);
            areAllFilesDone(cachedir, numimgs);
            %findNearDuplicates_hashing(cachedir, dtype);            
        end
        
        disp('Compute distances (reducer) & update files');
        findNearDuplicates_reducer(cachedir, dtype, imgsetdir, objname, ngramnames);
    end
    myprintfn; myprintfn;


    %###########################################################################
    %disp('%%% WEAKLY-SUPERVISED DPM TRAINING');
    %disp('%%% WEAKLY-SUPERVISED DPM TESTING ON VAL DATA (needed for merging similar components)');
    %disp('%%% MERGING SIMILAR COMPONENTS');
    %......
    %......
    %......
}