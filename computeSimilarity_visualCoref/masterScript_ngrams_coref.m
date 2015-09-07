function masterScript_ngrams_coref

% masterScript to compute similiarty values for coref data
% author: Santosh Divvala (santosh@cs.washington.edu), 2012-2014

% OBJINDS: optional argument to indicate the index of a particular concept to run (see VOCoptsClasses.m for list)

basedir = '/projects/grail/santosh/objectNgrams/results/coref_roth/';
%voc07dir = ['/projects/grail/' getenv('USER') '/Datasets/Pascal_VOC/VOC2007/']; % path to the voc 2007 data (whose images are used as background/negative data for training all models)
%conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');

%%% global variables (need to put them here instead of voc_config.m)
OVERWRITE = 1;                      % whether to overwrite compiled code or not

% set all the path names for this concept
diary([basedir '/diaryOutput_all.txt']);        % save a log of the entire run for debugging/record purposes

disp(['loading data at ' [basedir '/data/mentionPairs']]);
[col1, col2] = textread([basedir '/data/mentionPairs'], '%s %s');
pairs(:,1) = col1;
pairs(:,2) = col2;
numpairs = size(pairs,1);
myprintfn; myprintfn;

ngramDatadir_obj = [basedir '/results/'];
ngramImgClfrdir_obj = [basedir '/results/' '/classifiers/']; mymkdir(ngramImgClfrdir_obj); % to save data/results of the image classifier based pruning
    
disp('%%% GET RELEVANT TERMS IN THIS DATA (QUERY TERMS)');
inpfname_imgcl = [ngramDatadir_obj '/' 'uniqueTerms.txt'];
terms = unique(pairs(:));       %disp('get list of unique words');
numterms = size(terms,1);
fid = fopen(inpfname_imgcl, 'w');
for i=1:numterms
    %fprintf(fid, '%s %d\n', ngstrings_uniq{i}, ngcnts_uniq(i));
    fprintf(fid, '%s 1\n', terms{i});
end
fclose(fid);
                          
disp('%%% TRAIN IMAGE CLASSIFIER');
outfname_imgcl = [ngramImgClfrdir_obj '/' 'fastICorder.txt'];
outfname_imgcl1 = [strtok(outfname_imgcl,'.') '1.txt'];
outfname_imgcl2 = [strtok(outfname_imgcl,'.') '2.txt'];
outfname_imgcl3 = [strtok(outfname_imgcl,'.') '.mat'];
if ~exist(outfname_imgcl, 'file')    
    disp('******need to delete "done" directory if running on new dataset ******');
            
    disp('Extract (background/negative) features for training img classifier');    
    if ~exist([ngramImgClfrdir_obj '/negData_test.mat'], 'file')        
        %pascal_img_trainNtestNeval_cacheNegFeats(ngramImgClfrdir_obj, inpfname_imgcl, trainyear, objname, imgannodir);
        disp('symlink results, images, negData_test, negData_train at /projects/grail/santosh/objectNgrams/results/ngram_models/popular/ngramPruning to the results folder'); keyboard;
    end        

    disp('Train img classifiers');
    [~, numngrams] = system(['wc -l ' inpfname_imgcl ' | cut -f1 -d '' '' ']); numngrams = str2num(numngrams);
    if areAllFilesDone(ngramImgClfrdir_obj, numngrams, [], 1) ~= 0
        numjobsImgCls = min(100, areAllFilesDone(ngramImgClfrdir_obj, numngrams, [], 1));
        if numjobsImgCls < 10   % if only a few ngrams, then run locally (otherwise on cluster)
            pascal_img_trainNtestNeval_fast(ngramImgClfrdir_obj, inpfname_imgcl, 'blah', 'blah', 'blah');
        else
            compileCode_v2_depfun('pascal_img_trainNtestNeval_fast',1,'googleimages_dsk.py');
            multimachine_grail_compiled(['pascal_img_trainNtestNeval_fast ' ngramImgClfrdir_obj ' ' inpfname_imgcl ' ' 'blah' ' ' 'blah' ' ' 'blah'], numngrams, ngramImgClfrdir_obj, numjobsImgCls, [], randqname, 4, 0, OVERWRITE, 0);
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
    
    accvals = zeros(numterms,1);
    for f=1:numterms
        myprintf(f,100);
        tmp1 = load([ngramImgClfrdir_obj '/results/' terms{f} '_result.mat'], 'pr');
        accvals(f) = tmp1.pr.ap;
    end
    save(outfname_imgcl3, 'accvals', 'terms');
end
myprintfn; myprintfn;
        
disp('%%% COMPUTE PAIRWISE SIMILARITY');
outfname_imgcl_clus = [ngramImgClfrdir_obj '/' 'pairwiseScores.mat'];
if ~exist(outfname_imgcl_clus, 'file')    
    inpfname_imgcl1 = outfname_imgcl1;                          %inpfname_imgcl1 = [ngramImgClfrdir_obj '/' objname '_all_fastICorder1.txt'];
    getPairwiseScores_imgCl_coref(ngramImgClfrdir_obj, outfname_imgcl_clus, inpfname_imgcl1, pairs);         % select ngrams above cutoff and build edgemat    
end

disp('write results to file');
load(outfname_imgcl_clus, 'edgeval');
load(outfname_imgcl3, 'accvals', 'terms');

fid = fopen([ngramImgClfrdir_obj '/' 'summary.txt'],'w');
for f=1:numpairs
    myprintf(f,100);    
    indx1 = find(strcmp(terms, pairs{f,1}));
    indx2 = find(strcmp(terms, pairs{f,2}));
    fprintf(fid, '%s %s %2.1f %2.1f %2.1f %2.1f\n', pairs{f,1}, pairs{f,2}, edgeval(f,1), edgeval(f,2), accvals(indx1)*100, accvals(indx2)*100);
end
myprintfn;
fclose(fid);

fid = fopen([ngramImgClfrdir_obj '/' 'pairwiseScores.txt'],'w');
thresh = 15;
maxval = 10000;
for f=1:numpairs
    myprintf(f,100);    
    indx1 = find(strcmp(terms, pairs{f,1}));
    indx2 = find(strcmp(terms, pairs{f,2}));
    if accvals(indx1)*100 > thresh & accvals(indx2)*100 > thresh
        fprintf(fid, '%s %s %1.4f\n', pairs{f,1}, pairs{f,2}, -mean(edgeval(f,:))/maxval+1);
    else
        fprintf(fid, '%s %s %1.4f\n', pairs{f,1}, pairs{f,2}, -maxval/maxval+1);
    end
end
myprintfn;
fclose(fid);

diary off;
