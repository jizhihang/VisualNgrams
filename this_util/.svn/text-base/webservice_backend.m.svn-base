function webservice_backend

try

conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
[classes, ~, ~, ~, ngramtypes]  = VOCoptsClasses;
basedir = ['/projects/grail/' getenv('USER') '/objectNgrams/'];                 % main project folder (with the code, results, etc)
resultsdir = fullfile(basedir, 'results');

disp('write concept names to file');
fid = fopen([conf.webbasedir '/conceptnames.txt'], 'w');
for f=1:numel(classes), fprintf(fid, '%s\n', classes{f}); end
fclose(fid);

% write to file
fid = fopen([conf.webbasedir '/numConcepts.txt'], 'w');
fprintf(fid, '%d\n', numel(classes));
fclose(fid);

disp('get total number of ngrams');
ngsum = zeros(numel(classes),1);
[ngimg, ngboxs] = deal(zeros(numel(classes),1));
for f=1:numel(classes)
    myprintf(f,10);    
      
    %fid = fopen([resultsdir '/ngram_models/' classes{f} '/object_ngram_data/numRawNngramStats.txt'], 'r');
    fid = fopen([resultsdir '/ngram_models/' classes{f} '/ngramPruning/numRefinedNngramStats.txt'], 'r');
    ngsum(f) = fscanf(fid, '%d');
    fclose(fid);
    
    fid = fopen([resultsdir '/ngram_models/' classes{f} '/ngramPruning/imgStats.txt'], 'r');
    ngimg(f) = fscanf(fid, '%d');
    fclose(fid);
    
    fid = fopen([resultsdir '/ngram_models/' classes{f} '/ngramPruning/boxStats.txt'], 'r');
    ngboxs(f) = fscanf(fid, '%d');
    fclose(fid);
end
myprintfn;

% write to file
fid = fopen([conf.webbasedir '/totalNgramStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngsum));
fclose(fid);

% write to file
fid = fopen([conf.webbasedir '/totalImgStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngimg));
fclose(fid);

% write to file
fid = fopen([conf.webbasedir '/totalBoxStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngboxs));
fclose(fid);

catch
    disp(lasterr); keyboard;
end

%{
disp('get total number of ngrams');
ngsum = zeros(numel(classes),1);
for f=1:numel(classes)
    myprintf(f,10);
    fname = [resultsdir '/ngram_models/' classes{f} '/object_ngram_data/' classes{f} '_' num2str(ngramtypes(f)) '_all_syn_uniquedNsort_rewrite.txt'];
    if ~exist(fname, 'file')
        fname = [resultsdir '/ngram_models/' classes{f} '/object_ngram_data/' classes{f} '_' num2str(ngramtypes(f)) '_all_uniquedNsort_rewrite.txt'];
        fprintf('.');
        if ~exist(fname, 'file')
            disp('issue here'); keyboard;
        end
    end
    [~, res] = system(['wc -l ' fname]);
    abc = str2double(strtok(res, ' '));
    ngsum(f) = abc;
end
myprintfn;
% write to file
fid = fopen([conf.webbasedir '/ngramStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngsum));
fclose(fid);

disp('get total number of imgs & boxes');
[ngimg, ngboxs] = deal(zeros(numel(classes),1));
for f=1:numel(classes)
    myprintf(f,10);
    % number of raw ngrams (64 imgs)
    fname1 = [resultsdir '/ngram_models/' classes{f} '/object_ngram_data/' classes{f} '_' num2str(ngramtypes(f)) '_all_syn_uniquedNsort_rewrite.txt'];
    if ~exist(fname1, 'file')
        fname1 = [resultsdir '/ngram_models/' classes{f} '/object_ngram_data/' classes{f} '_' num2str(ngramtypes(f)) '_all_uniquedNsort_rewrite.txt'];
        fprintf('.');
        if ~exist(fname1, 'file')
            disp('issue here'); keyboard;
        end
    end
    [~, res1] = system(['wc -l ' fname1]);
    res1 = str2double(strtok(res1, ' '));
    % number of processed ngrams (200 imgs)
    fname2 = [resultsdir '/ngram_models/' classes{f} '/ngramPruning/' classes{f} '_' num2str(ngramtypes(f)) '_all_fastICorder.txt'];
    [~, res2] = system(['wc -l ' fname2]);
    res2 = str2double(strtok(res2, ' '));        
    ngimg(f) = [(res1-res2)*64 + res2*200];
    ngboxs(f) = res2*200;
end
myprintfn;
% write to file
fid = fopen([conf.webbasedir '/imgStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngimg));
fclose(fid);

% write to file
fid = fopen([conf.webbasedir '/boxStats.txt'], 'w');
fprintf(fid, '%d\n', sum(ngboxs));
fclose(fid);
%}
