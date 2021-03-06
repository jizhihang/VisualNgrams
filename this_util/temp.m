function temp

if 1
disp(' renaming god preview images'); 
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
compileCode_v2_depfun('displayExamplesPerSubcat5_tmp2', 0);
%disp('touch displayExamplesPerSubcat5_tmp.tgz'); keyboard;
mymatlabpoolopen;
for i=154
    objname = myClasses{i};
    disp(objname);
    
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_all_fastClusters_super.txt'];
    ngramnames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);  % get list of all ngram names         
    
    ngramModeldir_obj = [basedir '/' objname '/' ['kmeans_6'] '/']; 
    parfor ii=1:numel(ngramnames) 
        myprintf(ii,10);     
        cachedir = [ngramModeldir_obj '/' ngramnames{ii} '/'];
        for ik=1:6
            movefile([cachedir '/display/' '/montageGoogPrev_' num2str(ik, '%02d') '.jpg'],...
                [cachedir '/display/' '/montageGoogPrev2_' num2str(ik, '%02d') '.jpg']);
        end
    end
    %disp('pausing for 2 mins');
    %pause(120); 
    myprintfn;  
end  
end
%displayExamplesPerSubcat5_tmp2('cabin_aircraft_super','/projects/grail/santosh/objectNgrams/results/ngram_models//aeroplane/kmeans_6/cabin_aircraft_super/','9990','train')


if 0
disp(' saving new visualizations for display'); 
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
compileCode_v2_depfun('displayExamplesPerSubcat5_tmp2', 0);
%disp('touch displayExamplesPerSubcat5_tmp.tgz'); keyboard;
mymatlabpoolopen;
for i=1:numel(myClasses)
    objname = myClasses{i};
    disp(objname);
    
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_all_fastClusters_super.txt'];
    ngramnames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);  % get list of all ngram names         
    
    ngramModeldir_obj = [basedir '/' objname '/' ['kmeans_6'] '/']; 
    parfor ii=1:numel(ngramnames) 
        myprintf(ii,10);     
        cachedir = [ngramModeldir_obj '/' ngramnames{ii} '/'];
        if ~exist([cachedir '/display/' '/montageGoogPrev2_' num2str(6, '%02d') '.jpg'], 'file')
            %multimachine_grail_compiled(['displayExamplesPerSubcat5_tmp2 ' ngramnames{ii} ' ' cachedir  ' ' '9990' ' ' 'train'], 1, cachedir, 1, [], randqname, 2, 0, 1);
            displayExamplesPerSubcat5_tmp2(ngramnames{ii}, cachedir,'9990', 'train');    
        end
    end
    %disp('pausing for 2 mins');
    %pause(120); 
    myprintfn;  
end  
end
%displayExamplesPerSubcat5_tmp2('cabin_aircraft_super','/projects/grail/santosh/objectNgrams/results/ngram_models//aeroplane/kmeans_6/cabin_aircraft_super/','9990','train')


if 0
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
disp('writeAdjacencyMatrixToFile');
for i=[13 81] %1:numel(myClasses) 
    objname = myClasses{i};
    disp(objname);

    ngramImgClfrdir_obj = [basedir '/' objname '/' 'ngramPruning' '/'];  
    accfname = [strtok([ngramImgClfrdir_obj '/' objname '_all_fastICorder.txt'],'.') '1.txt'];    
    outfname = [ngramImgClfrdir_obj '/visualPairwiseScores.txt'];
    writeAdjacencyMatrixToFile(ngramImgClfrdir_obj, outfname, accfname);
end
 
end

if 0
load('/projects/grail/santosh/objectNgrams/results/cosegment/imgnetRes.mat','imgNet');  % based on imagenet_res_final sent on 9May14
classes = {'bg', 'aero', 'boat', 'car', 'cat', 'cow', 'dog', 'horse', 'sheep', 'tv', 'MEAN'};
for i=1:size(imgNet{1},2)
    fprintf('%5s [%2.1f,%2.1f,%2.1f] [%2.1f,%2.1f,%2.1f] [%2.1f,%2.1f,%2.1f]\n', classes{i},...
        imgNet{1}(2,i), imgNet{2}(2,i), imgNet{3}(2,i), ...
        imgNet{1}(3,i), imgNet{2}(3,i), imgNet{3}(3,i), ...
        imgNet{1}(1,i), imgNet{2}(1,i), imgNet{3}(1,i));    
end
end

if 0
% see getSortedPosDataPerCompWithURLs_wrapper    
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
disp('Include image urls, their size, and final bbox coords (for releasing images)');
for i=13 %1:numel(myClasses)    
    objname = myClasses{i};
    disp(objname);

    ngramModeldir_obj = [basedir '/' objname '/' 'kmeans_6' '/']; 
    cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; 
    fname_load1 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_data_noparts.mat'];
    fname_save1 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_noparts.mat'];
    fname_load2 = [cachedir '/' ['baseobjectcategory_' objname] '_joint_data.mat'];
    fname_save2 = [cachedir '/' ['baseobjectcategory_' objname] '_joint.mat'];
    if exist(fname_load2, 'file')
        disp('doing fname_load2');
        fname_load = fname_load2;
        fname_save = fname_save2;        
    elseif exist(fname_load1, 'file')
        disp('doing fname_load1');
        fname_load = fname_load1;
        fname_save = fname_save1;        
    end
    
    try
        load(fname_save, 'posdata');
        posdata(end).imgurl;
        disp('already done');
    catch
        tmp = load(fname_load, 'pos', 'lbbox_befjnt', 'posscores_befjnt', 'model');
        lbbox_befjnt = tmp.lbbox_befjnt;
        posscores_befjnt = tmp.posscores_befjnt;
        pos = tmp.pos;
        model = tmp.model;
                  
        [poscell, posdata] = getSortedPosDataPerCompWithURLs(pos, posscores_befjnt, lbbox_befjnt, model);
                
        save(fname_save, 'posdata', 'poscell', '-append');
    end
    
end
end


if 0
disp('do joint without merging for visualization');
resultsdir = '/projects/grail/santosh/objectNgrams/results/';
trainyear = '9990';
dpm.numcomp = 6;                    % number of components for training DPM
dpm.wsup_fg_olap = 0.25;            % amount of foreground overlap (with ground-truth bbox)
dpm.borderoffset = 0.07;            % amount of image border to ignore (e.g., if its a 100pixel image, ignore a 8-pixel margin (7/100*500))
dpm.jointCacheLimit = 2*(3*2^30);   % amount of RAM for training DPM
myClasses = VOCoptsClasses;
for i=1:numel(myClasses)
    objname = myClasses{i};
    ngramModeldir_obj = [resultsdir '/ngram_models/' objname '/' ['kmeans_6'] '/']; 
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; 
    fname_imgcl_sprNg = [resultsdir '/ngram_models/'  '/' objname '/ngramPruning/' '/' objname '_all_fastClusters_super.txt'];
    ngramnames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);  % get list of all ngram names         
    if ~exist([baseobjdir '/' ['baseobjectcategory_' objname] '_joint_visdata_noparts.mat'], 'file')
        do_retraining = 0;        
        pascal_train_joint_wsup_vis_noparts(['baseobjectcategory_' objname], objname, ngramnames, baseobjdir, ...
            trainyear, dpm.wsup_fg_olap, dpm.borderoffset, dpm.jointCacheLimit, dpm.numcomp, do_retraining);
    end
end
end     


if 0
disp('rename all fastCluster and fastICorder filenames');
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
[myClasses, ~, ~, ~, ngramTypes] = VOCoptsClasses;
for i=1:numel(myClasses)-1
    objname = myClasses{i};
    ngramtype = ngramTypes(i); 
    disp(objname); 
    
    in_fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_0_all_fastClusters_super.txt'];
    
    if ~exist(in_fname_imgcl_sprNg, 'file')
        disp('done');   
        continue;
    end
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_all_fastClusters_super.txt'];
    movefile(in_fname_imgcl_sprNg, fname_imgcl_sprNg)
    
    infname_imgcl = [basedir '/' objname '/ngramPruning/' objname '_' num2str(ngramtype) '_all_fastICorder.txt'];
    infname_imgcl1 = [strtok(infname_imgcl,'.') '1.txt'];
    infname_imgcl2 = [strtok(infname_imgcl,'.') '2.txt'];    
    outfname_imgcl = [basedir '/' objname '/ngramPruning/' objname '_all_fastICorder.txt'];
    outfname_imgcl1 = [strtok(outfname_imgcl,'.') '1.txt'];
    outfname_imgcl2 = [strtok(outfname_imgcl,'.') '2.txt'];    
    movefile(infname_imgcl, outfname_imgcl);
    movefile(infname_imgcl1, outfname_imgcl1);
    movefile(infname_imgcl2, outfname_imgcl2);
    
    in_outfname_imgcl_clus = [basedir '/' objname '/ngramPruning/' objname '_' num2str(ngramtype) '_all_fastClusters.txt'];    
    in_supNgMatFname = [strtok(in_outfname_imgcl_clus,'.') '.mat'];
    in_outfname1 = [strtok(in_outfname_imgcl_clus, '.') '_info.txt'];    
    outfname_imgcl_clus = [basedir '/' objname '/ngramPruning/' objname '_all_fastClusters.txt'];    
    supNgMatFname = [strtok(outfname_imgcl_clus,'.') '.mat'];
    outfname1 = [strtok(outfname_imgcl_clus, '.') '_info.txt'];    
    movefile(in_outfname_imgcl_clus, outfname_imgcl_clus);
    movefile(in_supNgMatFname, supNgMatFname);
    movefile(in_outfname1, outfname1);
end
end

if 0
disp('saving stats for web');
conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
[classes, ~, ~, ~, ngramtypes]  = VOCoptsClasses;
basedir = ['/projects/grail/' getenv('USER') '/objectNgrams/'];                 % main project folder (with the code, results, etc)
resultsdir = fullfile(basedir, 'results');

disp('writing raw ngram stats per concept');
for f=1:numel(classes)
    myprintf(f,10);
    ngramDatadir_obj = [resultsdir '/ngram_models/' classes{f} '/object_ngram_data/'];
    fname = [ngramDatadir_obj '/' classes{f} '_' num2str(ngramtypes(f)) '_all_syn_uniquedNsort_rewrite.txt'];
    if ~exist(fname, 'file')
        fname = [ngramDatadir_obj '/' classes{f} '_' num2str(ngramtypes(f)) '_all_uniquedNsort_rewrite.txt'];
        fprintf('.');
        if ~exist(fname, 'file')
            disp('issue here'); keyboard;
        end
    end
    [~, res] = system(['wc -l ' fname]);
    numofngrams = str2double(strtok(res, ' '));
    fid = fopen([ngramDatadir_obj '/numRawNngramStats.txt'], 'w');
    fprintf(fid, '%d\n', numofngrams);
    fclose(fid);    
        
    ngramImgClfrdir_obj = [resultsdir '/ngram_models/' classes{f} '/ngramPruning/'];
    fname2 = [ngramImgClfrdir_obj '/' classes{f} '_' num2str(ngramtypes(f)) '_all_fastICorder.txt'];
    [~, res2] = system(['wc -l ' fname2]);
    numofngrams2 = str2double(strtok(res2, ' '));
    fid = fopen([ngramImgClfrdir_obj '/numRefinedNngramStats.txt'], 'w');
    fprintf(fid, '%d\n', numofngrams2);
    fclose(fid);
    
    % write #imgStats to file
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
myprintfn;

end

if 0
    for i=1:47
        disp([num2str(i) '. ' num2str(size(feat.feat{i},1) - 28) ','  num2str(size(feat.feat{i},2) - 26)]);
    end    
end

if 0
basedir = '/projects/grail/santosh/objectNgrams/';                  % main project folder (with the code, results, etc)
resultsdir = fullfile(basedir, 'results');        
ngramtype = 0;
cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData_clean/'];
popListdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData_clean_popList/']; mymkdir(popListdir);
%ngram_uniqNsort_fname = [ngramDatadir_obj '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite.txt'];
getPopularNounsFromNgramData_2012(ngramtype, cleangramdir, popListdir);
end

if 0
if DO_MODE == 1.1                   % download the full ngram corpus from https://books.google.com/ngrams/datasets
    disp('dowloadin data');
    disp(['doing ngramtype ' num2str(ngramtype)]);
    if ngramtype == 0
        rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData/'];  mymkdir(rawngramdir);
        downloadNgramData_2012(ngramtype, rawngramdir);
        %multimachine_warp_depfun(['downloadNgramData_2012(' num2str(ngramtype) ',''' rawngramdir ''')' ], ngramGoogFileInfo(ngramtype), rawngramdir, ngramGoogFileInfo(ngramtype), [], 'all.q', 16, 0, OVERWRITE);
    elseif ngramtype == 2345
        for ijk=2:5
            rawngramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData/'];  mymkdir(rawngramdir);
            downloadNgramData_2012(ijk, rawngramdir);
        end
    end
    return;
    
elseif DO_MODE == 1.22              % compress/clean the downloaded ngram data
    disp('cleaning data');
    compileCode_v2_depfun('cleanNgramData_2012',0);
    if ngramtype == 0
        rawngramdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData/'];
        cleangramdir = [resultsdir '/ngram_data/' num2str(ngramtype) 'gramData_clean/']; mymkdir(cleangramdir);
        cleanNgramData_2012(ngramtype, rawngramdir, cleangramdir, tmpdirname_cleanNgramData);
        %multimachine_grail_compiled(['cleanNgramData_2012 ' num2str(ngramtype) ' ' rawngramdir ' ' cleangramdir ' ' tmpdirname_cleanNgramData], ngramGoogFileInfo(ngramtype), rawngramdir, ngramGoogFileInfo(ngramtype), [], 'all.q', 16, 0, OVERWRITE);
    elseif ngramtype == 2345
        for ijk=2:5
            rawngramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData/'];
            cleangramdir = [resultsdir '/ngram_data/' num2str(ijk) 'gramData_clean/']; mymkdir(cleangramdir);
            cleanNgramData_2012(ijk, rawngramdir, cleangramdir, tmpdirname_cleanNgramData);
        end
    end
    return;
end
end
    
if 0
disp('printing test file');
indir = '/projects/grail/santosh/Datasets/Pascal_VOC/VOC9990/ImageSets/Main';
inpfile = [indir '/baseobjectcategory_horse_test_withLabels_orig.txt'];
outfile = [indir '/baseobjectcategory_horse_test.txt']; 
[ids gt] = textread(inpfile, '%s %d');
ids = ids(gt ==1);
ids = myrandpermVect(ids);

disp('here'); keyboard;  
fid = fopen(outfile, 'w');
for f=1:100
    fprintf(fid, '%s\n', ids{f});
end
end

if 0
disp('reading');
disp('update val files belonging to all ngrams to remove dups');
imgsetdir = ['/projects/grail/santosh/objectNgrams/results/' '/VOC9990/ImageSets/Main/']; 
parfname = [imgsetdir '/baseobjectcategory_' 'reading' '_' 'val2' '_withLabels.txt'];
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
fname_imgcl_sprNg = [basedir '/' 'reading' '/ngramPruning/' '/' 'reading' '_0_all_fastClusters_super.txt'];
phrasenames = getPhraseNamesForObject_new('reading', fname_imgcl_sprNg);
for f=1:numel(phrasenames) 
    myprintf(f, 10);
    fname = [imgsetdir '/' phrasenames{f} '_val.txt'];
    fname_keep = [imgsetdir '/' phrasenames{f} '_val_beforeDups.txt'];      
    movefile(fname, fname_keep);    % keep for records    
    system(['grep -F -f ' fname_keep ' ' parfname ' > ' fname]);    
end
end

if 0
disp('print summary info');
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=21 %1:20  
    objname = myClasses{i};
    disp(objname);      
    baseobjdir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];       
    ngramDatadir_obj = [basedir '/' objname '/object_ngram_data/'];
    ngramImgClfrdir_obj = [basedir '/' objname '/ngramPruning/'];
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_0_all_fastClusters_super.txt'];
    printNgramSummaryForObject(baseobjdir, objname, fname_imgcl_sprNg, [baseobjdir '/summaryInfo.txt'], ...
        [ngramDatadir_obj '/' objname '_' num2str(0) '_all_uniquedNsort_rewrite.txt'],...
        [ngramImgClfrdir_obj '/' objname '_0_all_fastICorder.txt']);

end
end

if 0
disp('print summary of summary info');
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
system(['rm ' [basedir '/summaryOfSummary.txt']]); 
for i=1:20
    objname = myClasses{i};
    disp(objname);      
    baseobjdir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
    system(['cat ' [baseobjdir '/summaryInfo.txt'] ' >> ' [basedir '/summaryOfSummary.txt']]);
end
end


% update selected comp display
if 0
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=10   %1:numel(myClasses)  
    objname = myClasses{i};
    disp(objname);      
    baseobjdir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];       
    wwwdispdir_part = [objname '_trainNtestVis/'];
    wwwdispdir = ['/projects/grail/www/projects/visual_ngrams/display/' wwwdispdir_part];
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_0_all_fastClusters_super.txt'];
    createWebPageWithTrainingDisplay_selected_reorder(baseobjdir, wwwdispdir, wwwdispdir_part, objname, fname_imgcl_sprNg, 6);
end
end

% move part files
if 0
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=[1:9 11:numel(myClasses)]   
    objname = myClasses{i};
    disp(objname);      
    baseobjdir = [basedir '/' objname '/kmeans_6/'];           
    fname_imgcl_sprNg = [basedir '/' objname '/ngramPruning/' '/' objname '_0_all_fastClusters_super.txt'];
    phrasenames = getPhraseNamesForObject_new(objname, fname_imgcl_sprNg); 
    for f=1:numel(phrasenames)
        myprintf(f,10);     
        movefile([baseobjdir '/' phrasenames{f} '/' phrasenames{f} '_parts.mat'], [baseobjdir '/' phrasenames{f} '/' phrasenames{f} '_parts_withUnequalSamples.mat']);
    end    
    myprintfn;
end
end

if 0 
disp('move joint files   ');      
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=[1:9 11:numel(myClasses)]        
    objname = myClasses{i};
    disp(objname);
    resdir = [basedir '/' objname '/kmeans_6/' '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
    mymkdir([resdir '/beforeBalancing/']);
    system(['mv ' [resdir '/baseobjectcategory_' objname '_joint_data.mat'] ' ' [resdir '/beforeBalancing/']]);
    system(['mv ' [resdir '/baseobjectcategory_' objname '_joint.mat'] ' ' [resdir '/beforeBalancing/']]);
    system(['mv ' [resdir '/testFiles_2007'] ' ' [resdir '/beforeBalancing/']]);
    system(['mv ' [resdir '/baseobjectcategory_' objname '_boxes_test_2007_joint.mat'] ' ' [resdir '/beforeBalancing/']]);
    system(['mv ' [resdir '/display_test_2007_2007'] ' ' [resdir '/beforeBalancing/']]);
    system(['mv ' [resdir '/baseobjectcategory_' objname '_pr_test_2007_joint_*'] ' ' [resdir '/beforeBalancing/']]);
    myprintfn;   
end
end

% print joint montages
if 0 
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=1:numel(myClasses)      
    disp(i);    
    objname = myClasses{i};
    detressavedir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/display_test_2007_2007/'];       
    wwwdispdir = ['/projects/grail/www/projects/visual_ngrams/display/' objname '_trainNtestVis/']; 
    imlist = mydir([detressavedir '/all_*.jpg'],1);
    for ll=1:numel(imlist)
        mimgj{ll} = imread(imlist{ll});
    end    
    mimg = montage_list(mimgj, 2, [1 1 1], [numel(imlist)*2000 2000 3], [numel(imlist), 1]);
    imwrite(mimg, [detressavedir '/jointMontage.jpg']);
    copyfile([detressavedir '/'  'jointMontage.jpg'], [wwwdispdir '/display_test_2007_2007_jointMontage.jpg']);
end
end

% print phrasenames to file for reference
if 0
basedir = '/projects/grail/santosh/objectNgrams/results/ngram_models/';
myClasses = VOCoptsClasses; 
for i=1:numel(myClasses)     
    disp(i);    
    objname = myClasses{i};
    cachedir = [basedir '/' objname '/kmeans_6/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; 
    load([cachedir '/baseobjectcategory_' objname '_joint_data.mat'], 'models_all');
    getphrasenames_modelmerged(models_all, [cachedir '/componentNamesWithIndices.txt']);
end
end 

% compute pff_v5 25% overlap result
if 0
resdir = '/projects/grail/santosh/objectNgrams/results/pff_v5/';
myClasses = VOCoptsClasses; 
for i=1:numel(myClasses)     
    disp(i);    
    %boxfname = [resdir '/' myClasses{i} '/' myClasses{i}  '_boxes_test_2007.mat']; 
    %outfname = [resdir '/' myClasses{i} '/' myClasses{i}  '_pr_test_2007_25.mat']; 
    %if ~exist(outfname, 'file')
        %pascal_eval(myClasses{i}, [resdir '/' myClasses{i} '/' ], 'test', '2007', '2007');
        displayDetection_rankedMontages_v5(myClasses{i}, 'test', [resdir '/' myClasses{i} '/'], '2007', '2007', []); 
    %end 
end
end 

if 0 
% copy pff_v5 from ladoga to grail
indir = '~/visualSubcat/results_lustre/uoctti_models/release3_retrained/VOC2007trainval_VOC2007test/parts_v5/';
outdir = '/projects/grail/santosh/objectNgrams/results/pff_v5/';
myClasses = VOCoptsClasses; 
for i=6:numel(myClasses)     
    disp(i);
    mymkdir([outdir '/' myClasses{i}]); 
    %outfname = [outdir '/' myClasses{i} '/' myClasses{i}  '_boxes_test_2007.mat']; 
    %inpfname = [indir '/' myClasses{i} '/baselrsplit/' myClasses{i}  '_boxes_test_2007.mat'];    
    inpfname = [indir '/' myClasses{i} '/baselrsplit/*.mat'];
    %if ~exist(outfname, 'file')
        cmd = ['scp sdivvala@ladoga.graphics.cs.cmu.edu:' inpfname ' ' outdir '/' myClasses{i} '/'];         
        system(cmd);
    %end 
end
end

if 0
% move 
% /nfs/hn12/sdivvala/objectNgrams/results_lustre/ngramGImg_models/horse
% to 
% /nfs/hn12/sdivvala/objectNgrams/results/ngramGImg_models/horse
indir = '/nfs/hn12/sdivvala/objectNgrams/results_lustre/ngramGImg_models/horse';
outdir = '/nfs/hn12/sdivvala/objectNgrams/results/ngramGImg_models/horse';
listOfDirs = dir(indir);
listOfDirs = listOfDirs(3:end);
for i=3:50
    myprintf(i);    
    system(['mv ' indir '/' listOfDirs(i).name ' ' outdir '/' ]);
    system(['ln -s ' outdir '/' listOfDirs(i).name ' ' indir '/']);
end
myprintfn;
end

if 0
[ht wd dth] = size(im);
if ht/wd < 0.5
    ht = 0.5*wd;
    im = imresize(im, [ht wd]);
elseif wd/ht < 0.5
    wd = 0.5 * ht;    
    im = imresize(im, [ht wd]);
end
end

if 0
for i=1:20
    cls = classes{i};
    load(['~/visualSubcat/results_lustre/uoctti_models/release3_retrained/VOC2007trainval_VOC2007test/parts_v5/' cls '/baselrsplit/' cls '_final.mat']);
    model.stats.filter_usage(1:6)'
end
end
    
if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    savename2 = [objngramdir '/' objname '_0_all_uniquedNsort.txt'];
    savename2b = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];
    savename2c = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite_old.txt'];
    system(['mv ' savename2b ' ' savename2c]);
    system(['/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012.sh' ' ' ...
        savename2 ' ' savename2b]);
end
end


if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    inpfname = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];
    inpfname2 = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite_utf8copy.txt'];
    system(['cp ' inpfname ' ' inpfname2]);      
    system(['iconv -f UTF-8 -t US-ASCII//TRANSLIT < ' inpfname2 ' > ' inpfname]);
end
end

if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    inpfname = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];
    inpfname2 = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite_XobjnameXcopy.txt'];
    system(['cp ' inpfname ' ' inpfname2]);
    system(['grep -w ' objname ' ' inpfname2 ' > ' inpfname]);
end
end

if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    %{
    savename2 = [objngramdir '/' objname '_0_all_uniquedNsort.txt'];
    savename3 = [objngramdir '/' objname '_0_all_uniquedNsort_100.txt'];
    savename2b = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];
    savename3b = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite_100.txt'];
    savename2c = [objngramdir '/' objname '_0_all_uniquedNsort.mat'];
    savename3c = [objngramdir '/' objname '_0_all_uniquedNsort_100.mat'];    
    system(['mv ' savename2 ' ' savename3]);
    system(['mv ' savename2b ' ' savename3b]);
    system(['mv ' savename2c ' ' savename3c]);
    %} 
    merge2345ngram_topData(objname, objngramdir, 200, 2012);
end
end

if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    outfname1 = [objngramdir '/' objname '_0_all_fastICorder1.txt'];
    outfname1b = [objngramdir '/' objname '_0_all_fastICorder1_100.txt'];
    system(['mv ' outfname1 ' ' outfname1b]);
    outfname2 = [objngramdir '/' objname '_0_all_fastICorder2.txt'];        
    outfname2b = [objngramdir '/' objname '_0_all_fastICorder2_100.txt'];        
    system(['mv ' outfname2 ' ' outfname2b]);
end
end

if 0
myClasses = VOCoptsClasses;
for i = [2:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    mvdir = [objngramdir '/all_0_WithObjnameX/']; mymkdir(mvdir);    
    savename = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite*'];
    system(['mv ' savename ' ' mvdir]);
    savename = [objngramdir '/' objname '_0_all_fast*'];
    system(['mv ' savename ' ' mvdir]);
    savename = [objngramdir '/' objname '_0_all_slow*'];
    system(['mv ' savename ' ' mvdir]);
    savename = [objngramdir '/' objname '_0_all_clusters*'];
    system(['mv ' savename ' ' mvdir]);        
end
end

if 0
myClasses = VOCoptsClasses;
for i = [1:20]
    objname = myClasses{i}
    objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
    savename2 = [objngramdir '/' objname '_0_all_uniquedNsort.txt'];
    savename2b = [objngramdir '/' objname '_0_all_uniquedNsort_rewrite.txt'];
    system(['/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012.sh' ' ' ...
        savename2 ' ' savename2b ' ' objname]);     
end
end


if 0
basedir = '/projects/grail/santosh/objectNgrams/';
resultsdir_nfs = fullfile(basedir, 'results');
disp('rewrite horse_front xml files with correct image size');
imgannodir = [resultsdir_nfs '/object_ngramImg_finalData/'];
jpgimagedir = [resultsdir_nfs '/object_ngramImg_finalData/JPEGImages/'];
annosetdir = [resultsdir_nfs '/object_ngramImg_finalData/Annotations/'];
[ids gt] = textread([imgannodir '/ImageSets/Main/horse_front_imgtrain.txt'], '%s %d');
ids = ids(gt == 1);
[ids2 gt2] = textread([imgannodir '/ImageSets/Main/horse_front_imgtest.txt'], '%s %d');
ids2 = ids2(gt2 == 1);
ids = [ids; ids2];
for i=1:numel(ids)    
    myprintf(i);
    destfname = [jpgimagedir '/' ids{i} '.jpg'];
    destfname_anno = [annosetdir '/' ids{i} '.xml'];    
    createXMLannotation(destfname_anno, [ids{i} '.jpg'], 'horse_front', ['baseobjectcategory_horse'], destfname);
end
myprintfn;

end

if 0
[sval sind] = sort(scores, 'descend');
cid=comp(sind(find(comp(sind(1:end-1)) - comp(sind(2:end)))'));
aa=find(comp(sind(1:end-1)) - comp(sind(2:end)));
numinst=[aa-[0; aa(1:end-1)]];
precv=prec((find(comp(sind(1:end-1)) - comp(sind(2:end)))'));
[cid numinst precv]'
end

if 0
% move training and test visualizations to www folder (for easier viewing
% of graph)
objname = 'horse';
ngimgModeldir_obj = ['/projects/grail/santosh/objectNgrams/results/ngramGImg_models/' objname '/kmeans_6/'];
dispdir = ['/projects/grail/santosh/objectNgrams/results/display/trainNtestVis']; mymkdir(dispdir);
objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
for c=1:numel(phrasenames)
    myprintf(c);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_01.jpg' ' ' dispdir '/' phrasenames{c} '_train01.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_02.jpg' ' ' dispdir '/' phrasenames{c} '_train02.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_03.jpg' ' ' dispdir '/' phrasenames{c} '_train03.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_04.jpg' ' ' dispdir '/' phrasenames{c} '_train04.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_05.jpg' ' ' dispdir '/' phrasenames{c} '_train05.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/montageOverIt_06.jpg' ' ' dispdir '/' phrasenames{c} '_train06.jpg']);
    system(['cp ' ngimgModeldir_obj '/' phrasenames{c} '/display/all_001-049.jpg' ' ' dispdir '/' phrasenames{c} '_test01.jpg']);
end
end


if 0
% rewrite VOC9990 train .xml files with "horse" changed to corresponding
% ngram name and baseobjectcategory
basedir = '/projects/grail/santosh/objectNgrams/results/object_ngramImg_finalData';
imsetdir = [basedir '/ImageSets/Main/'];
jpgimagedir = [basedir '/JPEGImages/'];
annosetdir = [basedir '/Annotations/'];

objname = 'horse';
objngramdir = [basedir '/../object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);

for f=1:numel(phrasenames)
    myprintf(f);       
    [ids gt] = textread([imsetdir '/' phrasenames{f} '_train.txt'], '%s %d');
    ids = ids(gt == 1);
    for i = 1:length(ids)                
        destfname = [jpgimagedir '/' ids{i} '.jpg'];
        destfname_anno = [annosetdir '/' ids{i} '.xml'];
        createXMLannotation(destfname_anno, [ids{i} '.jpg'], phrasenames{f}, ['baseobjectcategory_' objname], destfname);
    end    
end
myprintfn;

end

if 0
disp('moving boxes_val1 to boxes_postrain500val');
objname = 'horse';
ngimgModeldir_obj = ['/projects/grail/santosh/objectNgrams/results/ngramGImg_models/' objname '/kmeans_6/'];
objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
for i=1:numel(phrasenames)
    myprintf(i);
    cls = phrasenames{i};
    cachedir = [ngimgModeldir_obj '/' cls '/'];    
    movefile([cachedir cls '_boxes_val1_9990.mat'], [cachedir cls '_boxes_postrain500val_9990.mat'])
end
myprintfn;
end

if 0
indir = '/projects/grail/santosh/objectNgrams/results/ngramGImg_models/horse/kmeans_6/';
objname = 'horse';
objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
for i=1:numel(phrasenames)
    cls = phrasenames{i};
    a = load([indir '/' cls '/' cls '_calibParamsHO_val2'], 'sigAB');
    load([indir '/' cls '/' cls '_context_KSVMSIGclassifier'], 'model');
    disp([num2str(model.ProbA) ' ' num2str(model.ProbB) ' vs ' num2str(a.sigAB(1)) ' ' num2str(a.sigAB(2))]);
end
end

if 0
indir = '/projects/grail/santosh/objectNgrams/results/ngramGImg_models/horse/kmeans_6/';
objname = 'horse';
objngramdir = ['/projects/grail/santosh/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
for i=1:numel(phrasenames)
    cls = phrasenames{i};
    load([indir '/' cls '/' cls '_context_KSVMSIGclassifier'], 'model');
    disp([num2str(model.ProbA) ' ' num2str(model.ProbB)]);
end
end

%{
if 0
disp(' compute gttruth statistic');    
cnt = 0;
fnd = 0;
for f=1:numel(gt)
    if ~isempty(gt(f).det)
        for j=1:length(gt(f).det)
            fnd = fnd + gt(f).det(j);
            cnt = cnt+1;
        end
    end
end
end

if 0
disp('show important ngrams in context rescoring');
load('/nfs/hn12/sdivvala/objectNgrams/results/ngramGImg_models/horse/kmeans_6/baseobjectcategory_horse_SNN_PedroContext/baseobjectcategory_horse_context_classifier.mat', 'model');
w = model.SVs' * model.sv_coef;

objname = 'horse';
objngramdir = ['/nfs/hn12/sdivvala/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
wnames = {'boxscore', 'boxx1', 'boxy1', 'boxx2', 'boxy2', phrasenames{:}};

impinds = find(abs(w) > 0.5);
for i=1:length(impinds)
    fprintf('%20s\t%2.2f\n', wnames{impinds(i)}, w(impinds(i)));
end
disp('here'); keyboard;
end


if 0
disp('renaming calibParm files');    
objname = 'horse';
objngramdir = ['/nfs/hn12/sdivvala/objectNgrams/results/object_ngram_data/' objname '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
ngimgModeldir_obj = ['/nfs/hn12/sdivvala/objectNgrams/results/ngramGImg_models/' objname '/kmeans_6/'];
valset1 = 'val1';
valset2 = 'val2';

for f = 1:numel(phrasenames)
    myprintf(f);
    
    cls = phrasenames{f};
    cachedir = [ngimgModeldir_obj '/' cls '/'];    
    
    if exist([cachedir cls '_calibParamsHO.mat'], 'file')
    try movefile([cachedir cls '_calibParams.mat'],[cachedir cls '_calibParams_' valset1 '.mat']); end
    movefile([cachedir cls '_boxes_calib_9990.mat'],[cachedir cls '_boxes_' valset1 '_9990.mat']);
    
    movefile([cachedir cls '_calibParamsHOPC.mat'],[cachedir cls '_calibParamsHOPC_' valset2 '.mat']);
    movefile([cachedir cls '_calibParamsHO.mat'],[cachedir cls '_calibParamsHO_' valset2 '.mat']);        
    end
    
end
end

    
if 0
% rewrite VOC9990 train .xml files after images resized
imsetdir = '/nfs/hn12/sdivvala/Datasets/Pascal_VOC/VOC9990/ImageSets/Main/';
jpgimagedir = '/nfs/hn12/sdivvala/Datasets/Pascal_VOC/VOC9990/JPEGImages/';
annosetdir = '/nfs/hn12/sdivvala/Datasets/Pascal_VOC/VOC9990/Annotations/';
[ids gt] = textread([imsetdir '/trainval_withLabels.txt'], '%s %d');
ids = ids(gt == 1);
objname = 'horse';
for i = 1:length(ids)
    myprintf(i,100);    
        
    destfname = [jpgimagedir '/' ids{i} '.jpg'];
    destfname_anno = [annosetdir '/' ids{i} '.xml'];    
    createXMLannotation(destfname_anno, [ids{i} '.jpg'], objname, destfname);    
end
myprintfn;
end

if 0
% resize VOC9990 trainval images
jpgimagedir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData_backup/JPEGImages/';
imgsetdir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/ImageSets/Main/';
outdir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/JPEGImages/';mymkdir(outdir);
[ids gt] = textread([imgsetdir '/trainval_withLabels.txt'], '%s %d');
ids = ids(gt == 1);
maximsize = 500;
for i=1:length(ids)
    myprintf(i,10);
    im = imread([jpgimagedir '/' ids{i} '.jpg']);
    [ht wd dpth] = size(im);
    if max(ht,wd) > 500
        im = imresize(im, maximsize/max(ht,wd), 'bilinear');
        imwrite(im, [outdir '/' ids{i} '.jpg']);
    else
        imwrite(im, [outdir '/' ids{i} '.jpg']);
    end    
end
myprintfn;
end

if 0
% resize VOC9990 test images
jpgimagedir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData_backup/JPEGImages/';
imgsetdir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/ImageSets/Main/';
outdir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/JPEGImages/';mymkdir(outdir);
[ids gt] = textread([imgsetdir '/test_withLabels.txt'], '%s %d');
ids = ids(gt == 1);
maximsize = 500;
for i=1:length(ids)
    myprintf(i,10);
    im = imread([jpgimagedir '/' ids{i} '.jpg']);
    [ht wd dpth] = size(im);
    if max(ht,wd) > 500
        im = imresize(im, maximsize/max(ht,wd), 'bilinear');
        imwrite(im, [outdir '/' ids{i} '.jpg']);
    else
        imwrite(im, [outdir '/' ids{i} '.jpg']);
    end    
end
myprintfn;
end

if 0
% move kmeans_15bicycle* to kmeans_15/bicycle*
indir = '/nfs/hn12/sdivvala/objectNgrams/results_lustre/rel5_2007/bicycle/kmeans_15/';
flist = dir([indir '/kmeans_15*']);
for i=1:length(flist)
    movefile([indir '/' flist(i).name], [indir '/' flist(i).name(10:end)]);
end
    
% move _train.txt to _imgtrain.txt
indir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/ImageSets/Main/';
flist = dir([indir '/*_train.txt']);
for i=1:length(flist)
    myprintf(i,10);
    movefile([indir '/' flist(i).name], [indir '/' flist(i).name(1:end-10) '_imgtrain.txt']);    
end
flist = dir([indir '/*_test.txt']);
for i=1:length(flist)
    myprintf(i,10);
    movefile([indir '/' flist(i).name], [indir '/' flist(i).name(1:end-9) '_imgtest.txt']);    
end

% rename _imgtest.txt 
indir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/ImageSets/Main/';
flist = dir([indir '/*_imgtrain.txt']);
for i=1:length(flist)
    myprintf(i,10);
    movefile([indir '/' flist(i).name(1:end-14) '_imgtest.txt'], ...
        [indir '/' flist(i).name(1:end-13) '_imgtest.txt']);    
end
end

%}
